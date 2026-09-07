# 云存储项目架构、接口与代码复核手册

> 复核基线：`D:\Desktop\AI_YunCunChu` 当前工作树。
>
> 本文以仓库中的 C/C++、React、SQL、Nginx、Docker 和启动脚本为事实源。凡写成“当前实现”的结论都能在代码或配置中找到依据；凡写成“建议”“应当”的内容都只是改进方向，面试时不能说成已完成。
>
> AI 描述与语义检索已经出现在代码库中，但按当前求职策略属于后续项目迭代，暂时不进入项目介绍、项目亮点和面试标准回答。本手册只在第 8 节单独记录其代码事实，防止与主回答口径混用。

## 0. 先记住这组结论

- 传统云存储业务模块主要用 C，AI 迭代模块与 FAISS 封装用 C++，前端用 React；不能笼统说成“后端全部使用 C++”。
- Docker Compose 实际启动 3 个容器：MySQL；Nginx + 单 Tracker + 单 Storage；FastCGI 程序 + Redis。它是单机学习环境，不是高可用集群。
- Nginx 把 13 条 `/api/*` 路由分别转发到 13 个 FastCGI TCP 端口；当前配置没有 `upstream`，也没有多业务实例负载均衡。
- MySQL 初始化脚本共有 8 张表，其中 6 张属于传统云存储主线，2 张属于 AI 迭代。
- Redis 保存 `用户名 -> Token`、分片会话 Hash、共享排行榜 ZSet 和展示 Hash；普通上传链路没有“SETEX 暂存预期 MD5”。
- Token 固定 TTL 为 24 小时，校验时只读不续期，不是滑动过期，也不是 JWT。
- 普通上传接口没有 Token，且服务端没有重新计算真实正文 MD5，只校验客户端声明的大小。
- 大于 10 MiB 的文件按 10 MiB 分片；前端当前顺序上传，不是线程池并发上传。
- 分片上传接口只有 `md5` 与 `index`，没有 Token，也不校验分片摘要、边界、总大小或会话所有者。
- 合并只检查编号对应的文件是否存在，然后按顺序调用 FastDFS appender API；没有合并锁、状态机或整体 MD5 复核。
- 图片分享表虽然有提取码字段，但浏览接口不校验提取码，创建响应也没有返回提取码。
- 当前仓库没有 Storage 侧 LRU-K 缓存、动态反馈负载均衡、线程池、数据库连接池或内存池的项目源码。可以讲原理或改进，但不能作为现状成果。

## 1. 实际部署拓扑

```text
浏览器 / React
       |
       | HTTPS :443（HTTP :80 重定向）
       v
Nginx + Tracker + Storage 容器 172.30.0.3
       |                    |
       | FastCGI/TCP        | ngx_fastdfs_module 返回文件
       v                    |
FastCGI + Redis 容器 172.30.0.4
       |                    |
       +---- MySQL ---------+--> MySQL 8 容器 172.30.0.2
       |
       +---- FastDFS 客户端/命令行 ----> Tracker/Storage
```

### 1.1 三个容器

| 容器职责 | 实际内容 | 持久化情况 |
| --- | --- | --- |
| 数据库 | MySQL 8，容器内 3306，宿主机映射 3307 | `mysql_data` 卷 |
| Web 与文件存储 | Nginx、1 个 Tracker、1 个 Storage、FastDFS Nginx 模块 | `fastdfs_data` 卷 |
| 应用 | 13 个 FastCGI 程序和本地 Redis | 只挂载 `client.conf`；Redis、`/tmp/chunks`、FAISS 索引没有持久卷 |

Compose 有健康检查和 `depends_on`，但这些只解决启动顺序与健康探测，不等于多副本、高可用或自动故障转移。

### 1.2 Nginx 的真实职责

- `80` 端口重定向到 HTTPS。
- `443` 使用仓库内自签名证书。
- `worker_processes 2`，每个 worker 配置 `worker_connections 1024`。
- React 静态资源由 Nginx 返回，前端路由通过 `try_files` 回退到入口页。
- `/api/login` 到 `/api/ai` 分别转发到 `10000` 到 `10012` 的 FastCGI 程序。
- `/group...` 通过 `ngx_fastdfs_module` 读取 FastDFS 文件。
- `client_max_body_size 12m`，与 10 MiB 分片配合。
- CORS 直接反射请求 `Origin` 且允许凭证，没有来源白名单，是安全风险。

配置里没有 `upstream`，所以不能回答“项目通过 Nginx 轮询多个后端”。当前只是路径路由。

### 1.3 FastCGI 进程模型

启动脚本实际拉起 13 个独立程序，每个模块一个常驻进程、一个端口：

| 端口 | 程序 | 路由 |
| --- | --- | --- |
| 10000 | `login_cgi` | `/api/login` |
| 10001 | `reg_cgi` | `/api/reg` |
| 10002 | `upload_cgi` | `/api/upload` |
| 10003 | `md5_cgi` | `/api/md5` |
| 10004 | `myfiles_cgi` | `/api/myfiles` |
| 10005 | `dealfile_cgi` | `/api/dealfile` |
| 10006 | `sharefiles_cgi` | `/api/sharefiles` |
| 10007 | `dealsharefile_cgi` | `/api/dealsharefile` |
| 10008 | `sharepicture_cgi` | `/api/sharepic` |
| 10009 | `chunk_init_cgi` | `/api/chunk/init` |
| 10010 | `chunk_upload_cgi` | `/api/chunk/upload` |
| 10011 | `chunk_merge_cgi` | `/api/chunk/merge` |
| 10012 | `ai_cgi` | `/api/ai`（后续迭代，不进入当前面试口径） |

传统业务程序使用 `FCGI_Accept()` 循环受理请求。当前项目代码没有业务线程池、FastCGI 多实例池或数据库连接池；每次处理通常新建 MySQL/Redis 连接。不要把“FastCGI 可以多进程”说成“本项目已经配置了多进程池”。

## 2. 数据模型

### 2.1 传统云存储主线：6 张表

| 表 | 作用 | 关键事实 |
| --- | --- | --- |
| `user_info` | 用户信息 | `user_name` 唯一；保存密码摘要、盐，另有当前主线不使用的 `api_key` 字段 |
| `file_info` | 一份物理文件 | 以 MD5 查重；保存 `file_id`、URL、大小、类型、引用计数 `count` |
| `user_file_list` | 用户拥有的文件目录项 | 用户、MD5、文件名、分享状态、下载量、时间 |
| `user_file_count` | 冗余计数 | 普通用户文件数；特殊用户名还被用于公共分享总数 |
| `share_file_list` | 普通公开分享 | 分享者、MD5、文件名、下载量、时间 |
| `share_picture_list` | 图床分享 | `urlmd5`、`key`、浏览量等 |

### 2.2 AI 迭代：另有 2 张表

| 表 | 作用 |
| --- | --- |
| `file_ai_desc` | MD5 级全局描述与向量缓存 |
| `user_file_ai_desc` | 用户级文件描述、向量和索引元数据 |

回答传统网盘项目时说“主链路使用 6 张表”；被问完整 SQL 初始化脚本时再补充“另有 2 张 AI 迭代相关表，总计 8 张”。

### 2.3 数据模型想表达的不变量

- 一份物理正文由 `file_info` 表示，多个用户目录项可引用它。
- 用户秒传或转存只新增关系，不再上传正文。
- 删除用户目录项后，只有引用计数归零才应删除物理正文。
- `user_file_count`、公共分享总数、Redis 排行都是冗余数据，应能由明细表重建。

### 2.4 当前数据库约束不足

初始化脚本没有外键，也没有给 `user_file_list`、`share_file_list` 建立能够阻止重复关系的完整唯一约束；多表更新大多是多条独立 SQL，没有事务。这意味着并发秒传、转存、分享或重复重试可能造成重复行、错计数和跨表不一致。

传统模块的 SQL 多由 `sprintf` 拼接外部输入，没有参数化查询或完整转义，是注入风险。

## 3. 注册、登录与 Token

### 3.1 密码实际怎样保存

1. React 端先对明文密码做一次 MD5。
2. 注册服务端生成 8 个随机字节，编码成 16 位十六进制盐。
3. 服务端保存 `MD5(salt + 客户端MD5)` 与盐。
4. 登录时从 MySQL 取盐，以相同方式计算并比对。

所以旧回答“数据库保存无盐 MD5”不准确；当前是带盐的双层 MD5。它仍不适合作为生产密码方案，因为 MD5 太快、客户端 MD5 本身会成为可重放的等价密码，随机数来源也不够强。生产改进应在 HTTPS 下由服务端使用 Argon2id、scrypt 或 bcrypt，并采用密码学安全随机盐。

### 3.2 Token 实际怎样工作

- 登录成功后，用用户名和若干 `rand()` 值拼接，经 DES、Base64、MD5 得到不透明 Token。
- Redis Key 是用户名，Value 是 Token，TTL 为 `86400` 秒。
- 校验时根据请求中的用户名 `GET` Token，再做字符串比较。
- 校验成功不会刷新 TTL，所以不是滑动过期。
- 同一用户名再次登录会覆盖旧 Token，因此更接近单会话模型。
- 它不是 JWT，不能离线验签；Redis 不可用时登录态校验失败。

安全边界包括弱随机 Token、旧式 DES/MD5 组合、没有多设备会话 ID、部分日志会记录敏感请求内容，以及多个写接口根本没有 Token 校验。

## 4. 普通上传与秒传

### 4.1 前端预检

前端用 SparkMD5 按 2 MiB 读取文件并计算完整 MD5，然后调用 `/api/md5`，请求包含用户、Token、文件名和 MD5。

服务端的真实分支是：

1. 验证 `用户名 -> Token`。
2. 查询 `file_info` 是否存在该 MD5。
3. 若物理文件存在，再检查当前用户是否已经有相同 MD5 和文件名。
4. 已拥有则返回“已存在”；未拥有则新增用户关系、增加物理引用计数和用户文件计数，完成秒传。
5. 物理文件不存在则让前端进入真实上传。

这里没有 Redis `SETEX` 保存预期 MD5。

### 4.2 小文件真实上传

不超过 10 MiB 的文件走 `/api/upload`：

1. React 发送 multipart，当前服务端解析依赖字段顺序：文件、用户、MD5、大小。
2. `upload_cgi` 把整个请求体读入内存，再把正文写入本地临时文件。
3. 它校验提取出的字节数是否等于客户端声明大小，但不重新计算真实文件 MD5。
4. 它在收到正文后再次查询数据库，尝试降低并发重复上传概率，但该检查没有唯一占位或事务保护。
5. 通过 `fork/exec` 调用 `fdfs_upload_file`，从管道读取 `file_id`。
6. 通过 `fdfs_file_info` 获取信息，但最终用配置里的 Storage Web 地址拼接并保存 HTTP URL。
7. 依次写入 `file_info`、`user_file_list`、`user_file_count`。

### 4.3 必须主动说明的缺口

- `/api/upload` 没有 Token 字段，也不校验登录身份。
- 信任客户端 MD5，没有服务端正文摘要复算，秒传内容身份并不可靠。
- 全量缓冲请求体会占用与文件大小同阶的内存。
- 临时文件名包含客户端文件名，缺少严格路径净化和随机化。
- 数据库多步更新无事务、无完整唯一约束。
- FastDFS 成功而数据库失败会留下孤儿正文；数据库已删而物理删除失败也缺少可靠补偿。
- 保存的是内部 HTTP URL；HTTPS 页面依靠前端字符串替换变成同源路径，设计较脆弱。

## 5. 大文件分片与断点续传

### 5.1 前端真实行为

- 大于 10 MiB 才进入分片流程。
- 每片 10 MiB。
- 前端使用普通 `for` 循环逐片 `await` 上传，因此是顺序 HTTP 请求，不是多线程或并发窗口。
- 分片阶段占进度 90%，合并阶段占 10%。

### 5.2 初始化 `/api/chunk/init`

请求包含 `user`、`token`、`filename`、完整 MD5、文件大小和分片数。服务端校验 Token，创建目录 `/tmp/chunks/{md5}`，并在 Redis 保存：

```text
Key: chunk:{md5}
Type: Hash
Fields: filename, filesize, chunk_count, user, uploaded
TTL: 24 hours
```

`uploaded` 是逗号分隔的分片编号字符串。会话 Key 只有完整 MD5，没有用户或独立 `upload_id`，所以不同用户上传同内容时会共享甚至碰撞同一会话。已有 Key 时，服务端也没有完整核对新请求和旧元数据是否一致。

### 5.3 上传分片 `/api/chunk/upload`

请求 URL 只有 `md5` 与 `index`，正文是原始分片字节。当前实现：

- 不携带、不校验 Token。
- 不核对 Redis 会话是否存在及其所有者。
- 不校验 `index` 上下界。
- 不校验单片大小、单片摘要或整个文件摘要。
- 把整片读入内存，以 `O_TRUNC` 写入 `{index}` 文件。
- 以非原子的“读字符串—追加—写回”更新 `uploaded`，并发时可能丢更新或产生重复编号。

### 5.4 合并 `/api/chunk/merge`

合并接口校验请求中的用户与 Token，但没有把该用户与 Redis 会话内记录的 `user` 比较。随后：

1. 先尝试按 MD5 复用已有物理文件。
2. 从 Redis 读取分片总数和文件大小。
3. 只检查 `0..chunk_count-1` 的临时文件是否存在。
4. 第一片调用 `storage_upload_appender_by_filename1` 创建 appender 文件。
5. 后续分片按编号调用 `storage_append_by_filename1`。
6. 每片追加成功后立刻删除本地分片。
7. 全部成功后写数据库、删 Redis Key 和临时目录。

### 5.5 “支持断点续传”应怎样准确表达

准确说法是：在应用容器仍存活、Redis Key 和 `/tmp/chunks` 尚在的 24 小时窗口内，客户端可根据 `uploaded` 补传缺片。它不具备跨应用容器重建的可靠恢复能力，因为 Redis 和临时目录没有持久卷；Redis TTL 到期也不会自动清理磁盘临时文件。

合并没有锁或 `UPLOADING/MERGING/DONE` 状态机。两个合并请求可能并发执行；中途失败时，已追加的分片已从本地删除，远端可能留下半成品 appender，无法从原状态无损重试。

### 5.6 理想改进

- 使用随机 `upload_id`，服务端绑定用户、摘要、大小、片数与租约。
- 分片接口统一鉴权并校验所有者、编号、大小和 SHA-256。
- 用 Bitmap/Set 或数据库唯一键原子记录分片，而不是逗号字符串。
- 合并前校验清单、总大小和整体摘要。
- 用条件更新抢占合并权，重复请求返回同一结果。
- 临时数据挂持久卷，并用定时任务清理过期目录和远端半成品。
- 建立 FastDFS 与数据库之间的 outbox/补偿记录。

这些都是应当补做的工程化能力，不是当前代码现状。

## 6. 分享、转存、下载计数与删除

### 6.1 普通分享

`dealfile_cgi` 的 `share`、`del` 和个人文件 `pv` 会校验 Token。分享时：

- 用原始字符串 `md5 + filename` 作为 Redis 成员；没有分隔符，理论上可能产生拼接歧义。
- 先查 Redis ZSet，未命中再查 MySQL 的分享状态。
- 更新 `user_file_list.shared_status`。
- 插入 `share_file_list`。
- 通过特殊 `user_file_count` 行维护公共分享总数。
- 更新 `FILE_PUBLIC_ZSET` 和 `FILE_NAME_HASH`。

共享列表可在 Redis 计数不一致时从 MySQL 重建，因此 MySQL 是较可靠的持久事实源，Redis 是查询加速层。

### 6.2 取消分享与转存的真实权限缺口

`dealsharefile_cgi` 的 `cancel`、`save`、`pv` 请求都没有 Token。前端也只发送用户名、MD5 和文件名。这意味着调用者可以伪造用户名，尝试替别人取消分享或向任意用户名转存。回答时不能笼统说“所有写操作都统一鉴权”。

转存成功会新增用户关系、增加 `file_info.count` 和目标用户计数，但这些仍是非事务性的多步更新。

### 6.3 下载量不是下载授权

个人下载量更新会校验 Token；公共分享下载量更新不校验。实际文件下载是浏览器直接访问 FastDFS URL，计数请求与正文请求分离，所以计数可漏记、重复或伪造。`pv` 是访问统计，不是下载凭证。

### 6.4 删除与引用计数

删除会清理用户的分享记录、用户文件关系、用户计数并减少物理文件引用计数。引用归零后才删除 `file_info` 和 FastDFS 正文。

当前顺序与事务边界仍有风险：数据库删除与 FastDFS 删除无法原子提交，且缺少可重试清理表；并发删除又可能使引用计数错误。

## 7. 图片分享子系统

后端实现了 `share`、`normal`、`cancel`、`browse` 四类操作，但当前 React 页面和服务层没有接入该 API，所以它不是现有前端的活跃功能。

创建时生成：

- `urlmd5 = MD5(filemd5 + 时间 + 随机数)`；
- 4 位十六进制 `key`；
- `pv = 0` 的图片分享记录。

然而当前响应只返回 `urlmd5`，没有返回 `key`；`browse` 也只按 `urlmd5` 查询，不验证 `key`。因此数据库里虽然有“提取码”，但保护逻辑没有闭环。`cancel` 也没有 Token。

面试时准确回答：图片分享有不透明标识和提取码字段，但当前浏览链路没有强制提取码，取消分享也缺少鉴权，属于未完成的权限边界。

## 8. AI 迭代代码事实（暂不进入回答口径）

> 本节只用于代码维护和后续迭代。当前项目介绍、面经答案与背诵口径均不引用本节。

### 8.1 已实现范围

`/api/ai` 支持 `describe`、`search` 和 `rebuild`。图片调用 `qwen-vl-plus` 生成描述；DOCX 通过 `unzip` 抽取 XML；若干文本/代码格式读取前部内容。文本再通过 `text-embedding-v3` 生成 1024 维向量，归一化后存入按用户划分的 FAISS `IndexFlatIP`。默认 Top K 为 10，阈值为 0.45。

它属于“文件描述与语义检索”，不是完整 RAG：没有文档分块、混合检索、重排、带引用的答案生成，也不回答用户问题。

### 8.2 迭代缺口

- 后端只接受请求体 `api_key`；前端自动描述调用没有传 Key，上传后自动描述通常失败。
- Key 保存在浏览器 `localStorage`，请求时仍会上传服务端；日志可能记录 POST 内容。
- DashScope HTTPS 请求关闭了证书对端校验。
- FAISS 数据目录没有持久卷，容器重建后需从数据库重建。
- DOCX 与文本抽取较粗糙，不支持 PDF/OCR 等完整内容解析。

这些事实暂不并入当前求职回答，等用户决定把 AI 迭代正式纳入项目后再单独形成面试题组。

## 9. 接口契约总表

| 路由 | 主要操作 | 当前鉴权 |
| --- | --- | --- |
| `/api/reg` | 注册 | 无需 Token |
| `/api/login` | 登录 | 无需 Token |
| `/api/md5` | 秒传预检/建引用 | 有 Token |
| `/api/upload` | 小文件真实上传 | **无 Token** |
| `/api/myfiles` | 数量、列表 | 有 Token |
| `/api/dealfile` | 分享、删除、个人下载计数 | 有 Token |
| `/api/sharefiles` | 公共分享数量、列表、排行 | 公开 |
| `/api/dealsharefile` | 取消分享、转存、公共下载计数 | **无 Token** |
| `/api/sharepic` | 创建/查询/取消/浏览图片分享 | 创建和普通查询有；取消、浏览无 |
| `/api/chunk/init` | 初始化分片会话 | 有 Token |
| `/api/chunk/upload` | 写入单片 | **无 Token** |
| `/api/chunk/merge` | 追加合并 | 有 Token，但未绑定会话用户 |
| `/api/ai` | AI 后续迭代 | 有 Token；不纳入当前回答 |

各模块的 `code` 值不是全局统一枚举，部分传统接口即使返回 JSON 也使用 `text/html`。前端按具体接口解释响应，不能假定全局一致的错误码或 MIME 类型。

## 10. 跨存储一致性与并发事实

### 10.1 当前没有全局事务

一次业务操作可能同时修改 MySQL、Redis、本地临时目录和 FastDFS。代码没有分布式事务，也没有统一 outbox、补偿队列或后台对账器。

典型失败窗口：

- FastDFS 已写成功，MySQL 插入失败：孤儿正文。
- MySQL 关系已写，计数更新失败：目录项与计数不一致。
- MySQL 分享成功，Redis 更新失败：公共列表缓存落后。
- 数据库删除成功，FastDFS 删除失败：不可见但占空间的文件。
- appender 追加一半失败：远端半成品、本地前半分片已删。

### 10.2 当前幂等与并发能力有限

- `/api/md5`、真实上传、转存和分享没有完整唯一键 + 事务闭环。
- 分片 `uploaded` 是非原子字符串更新。
- 合并没有抢占锁。
- 引用计数可能在并发下失真。
- 下载计数与正文下载分离。

因此面试时应说“项目实现了功能链路，同时通过代码复核识别了并发和一致性缺口”，不能说“已经保证强一致与完全幂等”。

## 11. 安全问题按优先级整理

### P0：直接越权或凭证风险

- `/api/upload`、`/api/chunk/upload`、`dealsharefile` 写操作、图片取消分享缺少 Token。
- 分片合并不核对会话所有者。
- 图片提取码未校验。
- 请求日志可能记录密码摘要或 Token。

### P1：注入、身份与完整性

- 多数 SQL 使用字符串拼接。
- 普通上传信任客户端 MD5。
- Token 随机性和加密构造较弱。
- CORS 反射任意 Origin 且允许凭证。
- 临时文件名与分片路径缺少严格输入净化。

### P2：工程化与隐私

- 永久文件 URL 暴露并可绕过业务计数。
- 自签名 TLS 只适合学习环境。
- 配置中存在明文数据库密码。

## 12. 项目中“没有实现”的内容

以下主题可以作为八股或设计扩展，但当前仓库没有相应业务源码：

- Storage 侧 LRU-K 文件内容缓存；
- 动态反馈负载均衡算法及 Tracker 源码改造；
- Nginx `upstream` 多实例负载均衡；
- 业务线程池、数据库连接池、内存池；
- 多 Tracker、多 Storage、跨主机 FastDFS 集群；
- 消息队列、异步补偿任务、定时垃圾回收；
- 服务端 SHA-256 或真实 MD5 复算；
- 自动化后端测试、端到端测试与可信系统压测。

若这些确实存在于另一个未纳入仓库的个人实验中，应单独提供源码和测试证据；在当前项目回答里应说“学习过/计划改进”，而不是“已实现”。

## 13. 可直接用于面试的回答

### 13.1 两分钟介绍

> 这是一个在 Linux 上运行的学习型云存储系统，使用 Docker Compose 做单机三容器部署。React 前端通过 Nginx 访问静态资源和 API，传统云存储后端由多个常驻 C FastCGI 模块组成；FastDFS 保存文件正文，MySQL 用 6 张主链路表保存用户、物理文件、用户目录项和分享关系，Redis 保存用户名到 Token、分片会话以及公共分享排行。项目实现了注册登录、基于 MD5 的秒传、普通上传、10 MiB 分片与 FastDFS appender 合并、文件列表、分享、取消分享、转存、下载计数和引用计数删除。当前部署只有一个 Tracker 和一个 Storage，不是高可用集群。代码复核还暴露了普通上传和分片上传鉴权不足、服务端未复算摘要、多表更新无事务、分片合并无状态机等边界。LRU-K 和动态负载均衡在当前仓库没有实现，所以我只把它们作为后续改进，不作为项目成果。

### 13.2 最大技术难点

> 我会选“大文件分片状态与 FastDFS appender 合并”。当前代码用 Redis Hash 记录 24 小时会话，用 `/tmp/chunks/{md5}` 存片，客户端按顺序上传，服务端按编号追加到 FastDFS。它能跑通同容器生命周期内的续传，但复核后发现会话只按 MD5 命名、上传片不鉴权、不校验摘要，`uploaded` 更新不原子，合并也没有锁；失败时还可能留下半成品。我能同时讲清现有调用链、失败窗口和升级方案：独立 `upload_id`、统一鉴权、Bitmap/唯一键、分片与整体 SHA-256、合并状态机、持久卷和可重试补偿。

### 13.3 秒传

> 前端先算完整 MD5，服务端在 `file_info` 查物理正文，再在 `user_file_list` 查当前用户的同名关系。物理文件存在且用户未拥有时，只新增关系并增加引用计数，不传正文；用户已经有同名同摘要文件则返回已存在。当前普通上传没有 Redis 预期 MD5，也没有服务端重算正文摘要，所以只能说实现了基于客户端 MD5 的去重流程，不能说完成了抗伪造的内容校验。

### 13.4 如何回答“是否高可用”

> 不是。Compose 只有一个 Nginx、一个 Tracker、一个 Storage、一个 MySQL 和一个应用容器，Redis还与应用同容器。健康检查不等于冗余。FastDFS 理论上支持对等 Tracker、多个 Group 和同组副本，但那是框架能力，不是当前部署事实。

### 13.5 如何回答 LRU-K 与动态负载均衡

> 我学习过 LRU-K 和动态反馈调度的原理，但在这次复核的仓库中没有找到对应源文件、构建目标、配置或测试。因此不会把它们描述为当前项目实现或个人实测成果。如果后续补做，会单独提交代码、接入点、对照实验与原始数据。

## 14. 改造优先级

1. 给所有写接口统一鉴权，从 Token 推导用户身份，不信任请求中的任意用户名。
2. 停止记录密码、Token 和 API Key 等敏感请求内容。
3. 普通上传和分片合并由服务端计算 SHA-256；摘要、大小与所有权都由服务端约束。
4. 为物理文件、用户关系、分享关系增加合适唯一键；相关 MySQL 更新放入事务。
5. 使用 `upload_id`、原子分片状态与合并状态机，并持久化 Redis 和临时目录。
6. 建立 FastDFS 操作日志/outbox、重试与对账清理任务。
7. 修复图片提取码闭环和短期签名下载，避免永久直链绕过授权。
8. 增加后端单元、接口、并发、故障注入和端到端测试，再谈吞吐与性能提升。

## 15. 复核清单

面试前逐条自检：

- 是否把仓库路径写成实际的 `D:\Desktop\AI_YunCunChu`？
- 是否把传统业务层准确说成“主要 C”，而非“全 C++”？
- 是否明确只有 3 个容器和单 Tracker/Storage？
- 是否说清传统主链路 6 张表、完整初始化脚本 8 张表？
- 是否避免“无盐 MD5”“滑动 TTL”“Redis 预期 MD5”三个旧错误？
- 是否承认普通上传和分片上传的鉴权/摘要缺口？
- 是否把顺序分片误说成并发上传？
- 是否把存在性检查误说成大小、摘要和整体完整性校验？
- 是否把图片提取码字段误说成已经生效？
- 是否把 AI 迭代混入当前回答口径？
- 是否把 LRU-K、动态负载均衡、线程池或高可用集群误说成已实现？
- 是否把“理想设计”与“当前代码”分开？

只要这 12 项不说错，项目回答就能和当前仓库及现阶段求职策略保持一致。

## 16. 代码事实定位索引

| 事实 | 主要源码或配置 |
| --- | --- |
| 三容器、IP、端口、卷、健康检查 | `docker/docker-compose.yaml` |
| 2 个 worker、HTTPS、13 条 FastCGI 路由、12 MiB、FastDFS 下载 | `docker/nginx_fastdfs/nginx.conf` |
| 13 个常驻程序的启动方式 | `docker/fastcgi_app/start.sh` |
| 8 张表、索引和默认数据结构 | `docker/mysql/init.sql` |
| 注册盐与密码摘要 | `src_cgi/reg_cgi.c` |
| 登录、Token 生成与 24 小时 TTL | `src_cgi/login_cgi.c`、`common/redis_op.c` |
| MD5 秒传分支 | `src_cgi/md5_cgi.c` |
| multipart、临时文件、命令行上传 | `src_cgi/upload_cgi.c` |
| 个人列表与排序 | `src_cgi/myfiles_cgi.c` |
| 分享、删除、个人下载计数 | `src_cgi/dealfile_cgi.c` |
| 公共列表与 Redis 重建 | `src_cgi/sharefiles_cgi.c` |
| 取消分享、转存、公共计数 | `src_cgi/dealsharefile_cgi.c` |
| 图片 `urlmd5`、Key、浏览与取消 | `src_cgi/sharepicture_cgi.c` |
| 分片 Hash 与临时目录 | `src_cgi/chunk_init_cgi.c`、`src_cgi/chunk_upload_cgi.c` |
| appender 合并与落库 | `src_cgi/chunk_merge_cgi.c` |
| 前端 MD5、10 MiB 阈值和顺序分片 | `picture_bed/src/pages/ImageList.js`、`picture_bed/src/services/images.js` |
| AI 后续迭代 | `src_cgi/ai_cgi.cpp`、`common/dashscope_api.cpp`、`common/faiss_wrapper.cpp` |

复核时还遍历了仓库的 99 个 Git 跟踪文件，并把第三方库、依赖压缩包和构建产物与项目自有业务代码分开；“没有实现”的判断来自自有源码、构建脚本、配置和路由中均无对应接入证据，而不是仅凭文件名猜测。
