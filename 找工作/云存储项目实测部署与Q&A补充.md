# 云存储项目·实测部署与 Q&A 补充

> 依据：当前仓库源码 + 2026-09-08 本机 Docker 三容器真实部署（`/home/ayanami/AI_YunCunChu`）。
> 收录口径：只写能实证的代码事实与部署结果；与主口径一致处用「精确化」，与实证有出入处用「修正」标注；理想能力一律标为「改进」。
> 主口径见 `实际面经整理与原始归档.md`；本文不展开 AI 能力（同主口径约定，仅在第 1 节拓扑中如实现象地提及存在 ai 监听进程）。

---

## 一、架构与部署（Q&A 口径 + 实证）

### 1.1 实际容器/进程/端口拓扑

三容器单机 Compose，自定义 bridge `my_net`，子网 `172.30.0.0/16`，静态 IP：

| 容器                    | 镜像                   | IP         | 对外发布端口                  | 容器内进程                                                  |
| --------------------- | -------------------- | ---------- | ----------------------- | ------------------------------------------------------ |
| tc_fcgi_mysql         | docker-tc_mysql      | 172.30.0.2 | 3307→3306               | mysqld（healthcheck：mysqladmin ping）                    |
| tc_fcgi_nginx_fastdfs | docker-nginx_fastdfs | 172.30.0.3 | 80→80、443→443           | nginx（2 worker）+ 1 tracker(:22122) + 1 storage(:23000) |
| tc_fcgi_app           | docker-fastcgi_app   | 172.30.0.4 | 10000-10012→10000-10012 | redis(127.0.0.1:6379) + 13 个 spawn-fcgi 监听进程           |

- 一个容器内同时跑 nginx + tracker + storage，是「三容器」的真正含义，不要表述为「Nginx 单独一容器」。
- fastcgi 容器内有 redis（随启动脚本 daemonize）；redis 无数据 volume、每次都是全新实例，容器重建（--force-recreate/down+up）即丢失全部 Token/分片会话，需要重新登录——由「无持久化」机制决定，属于确定结论。
- MySQL、FastDFS 数据用命名 volume（mysql_data、fastdfs_data），`docker compose down` 不丢。

### 1.2 13 条路由 ↔ 端口 ↔ 模块（代码核对）

| 端口    | 路由                 | 模块            | 是否 verify_token           |
| ----- | ------------------ | ------------- | ------------------------- |
| 10000 | /api/login         | login         | 无（登录本身）                   |
| 10001 | /api/reg           | register      | 无（注册本身）                   |
| 10002 | /api/upload        | upload        | **无**                     |
| 10003 | /api/md5           | md5           | 有                         |
| 10004 | /api/myfiles       | myfiles       | 有                         |
| 10005 | /api/dealfile      | dealfile      | 有                         |
| 10006 | /api/sharefiles    | sharefiles    | **无**（公共分享列表）             |
| 10007 | /api/dealsharefile | dealsharefile | **无**（取消/转存/公共下载计数在此，越权点） |
| 10008 | /api/sharepic      | sharepicture  | 有                         |
| 10009 | /api/chunk_init    | chunk_init    | 有                         |
| 10010 | /api/chunk_upload  | chunk_upload  | **无**                     |
| 10011 | /api/chunk_merge   | chunk_merge   | 有                         |
| 10012 | /api/ai            | ai（扩展，不进主口径）  | 有                         |

- 每个端口是 `spawn-fcgi -a 0.0.0.0 -p X -f /app/bin_cgi/模块` 起的**单实例**，`main()` 里 `FCGI_Accept()` 循环，天然**串行**处理；说「13 个常驻进程」即可，不要说成 13 进程高并发。
- nginx 全部 `fastcgi_pass 172.30.0.4:PORT`（写死容器 IP），`http{}` 里**没有 upstream**，所以没有应用层负载均衡；这也是「框架可集群、本项目单实例」的证据。

### 1.3 一条 API 请求实测路径（/api/login）

浏览器 → `https://127.0.0.1:443`（http:80 全部 301）→ nginx 443 server → `location /api/login` 加 CORS 头 → `fastcgi_pass 172.30.0.4:10000` → login CGI → MySQL(172.30.0.2)/Redis(127.0.0.1) → 回 `{"code":0,"token":…}`。

实测回显（字段要对得上，否则 code1）：
- 注册：`{"userName","nickName","firstPwd","phone","email"}`，firstPwd = MD5(明文)。返回 `{"code":0}`。
- 登录：`{"user","pwd"}`，pwd = MD5(明文)。返回 `{"code":0,"token":"32位hex"}`。
- 用明文密码直接手测登录会得到 code1 —— 前端在 Login.js:94-95 先 `calculateMD5(password)` 再发。

### 1.4 一条文件下载实测路径

`https://127.0.0.1/group1/M00/00/00/xxx` → nginx `location ~/group([0-9])/M([0-9])([0-9])` → ngx_fastdfs 模块在本容器读 storage 本地路径返回。

实测合并出的 223,219,546 B 的 mp4：
- HEAD → HTTP 200，Content-Type video/mp4，Content-Length 与上传声明**完全一致**；
- Range → HTTP 206，字节正确（mp4 头可读）。说明文件正文确实落盘且由 nginx 按真实长度服务。

### 1.5 前端「内网地址绕行」细节（主口径没提，面试可讲）

- cfg.json：`web_server/storage_web_server = 172.30.0.3:80`，DB `file_info.url` 存的就是 `http://172.30.0.3:80/group1/M00/…`（内网地址，浏览器不可达）。
- 前端 `config/index.js` 把 `STORAGE_URL` 设成同样的 `http://172.30.0.3:80`，`images/share/ai` 拿到 url 后做 `url.replace(STORAGE_URL, BASE_URL='')` → 变成同源相对路径 `/group1/M00/…`，再由当前域名的 nginx 反代。
- 优点：避免把 docker 内网 IP 暴露给浏览器。弱点：纯字符串替换，只要后端 URL 格式（协议/端口/host）和 STORAGE_URL 不完全一致，替换就失效，图片直接裂。这也是「为什么不能在前端存死内网地址」的现实依据。

---

## 二、注册、登录与安全（Q&A 口径 + 实证）

1. **密码几次摘要、盐在哪**：前端 1 次 MD5 → 服务端 reg 生成随机盐存 `user_info.salt`，存 `MD5(salt + 前端MD5)`（reg_cgi.c 计算加盐哈希）。登录时取出 salt 与存储 hash，重算 `MD5(salt + 客户端pwd)` 比对，所以客户端要传的是 MD5 而不是明文。
2. **为什么带盐双层 MD5 仍不适合生产**：MD5 本身快、无 KDF 拉伸；盐随机、逐用户，但仍是弱口令可离线爆破的对象；应换 bcrypt/scrypt/argon2 的「改进」，不是现状。
3. **Token 怎么生成 / Redis 结构 / TTL**：`token = MD5hex( base64( DES( username + 4×(rand%1000) ) ) )`（login_cgi.c set_token，192 行的逻辑），即用户名拼接随机数后 DES→base64→MD5 定长 32 hex。Redis `SETEX username 86400 token`：**key = 用户名**（实测键名就是 "123123"），value = token，TTL 固定 86400 s。校验 `verify_token` 读 key=用户名 的 value 直接 strcmp，只读不续期。
4. **为什么不是 JWT / 不是滑动过期**：是无状态的客户端自校验就没有；这里 token 是 Redis 里的服务端状态，Redis 丢（重建容器/重启）就要重新登录；TTL 固定不续期。
5. **同用户再登录 / 多设备**：同一 key（用户名）SETEX 覆盖旧值 → 旧设备 token 立即失效，语义上「单会话」，不是多设备独立会话。要向「每会话一条记录」改进。
6. **哪些写接口缺 Token（越权面，代码核实）**：`upload`(10002)、`chunk_upload`(10010)、`dealsharefile`(10007) 未调 verify_token；`dealsharefile` 承载取消分享/转存/公共下载计数，是文档已确认的越权点。带 token 的接口清单见 1.2 表。
7. **SQL 拼接 / 敏感日志 / CORS**：全部 `sprintf` 拼 SQL（无预处理语句），用户名/文件名可控 → SQL 注入风险；login 日志把请求里密码字段原文打出（实测日志 `pwd = …` 可见）；nginx 对所有 /api 配了 `Access-Control-Allow-Origin $http_origin` + `*` Methods 的宽放 CORS。全部属于「当前缺陷 → 改进」。
8. **正确推导身份**：服务端应从 token（服务端签发、能反查会话）得到 user_id，而不是信任请求体/参数里的 username；现状是多数接口把用户名当入参、token 仅做开关校验（chunk_merge 甚至用请求里的 user 查库），是统一鉴权的改进点。

---

## 三、秒传与普通上传（Q&A 口径 + 实证）

1. **/api/md5 的分支与返回码**（md5_cgi.c，code 注释：004/005/006）：
   - 用户已有同名同 md5 目录项 → 直接返回已存在（不再上传也不重复计引用）；
   - 物理文件存在但用户未拥有 → 加用户关系 + `file_info.count` 引用计数 + `user_file_count` 用户计数，算「秒传」；
   - 物理文件不存在 → 返回不能秒传，走真实上传。
2. **秒传仍写关系/计数**：文件正文在 `file_info` 只有一份，秒传本质是让多个用户的目录项共享同一正文，必须写 `user_file_list` 关系与两个计数。
3. **是否有 Redis 暂存预期 MD5**：普通上传/秒传**没有**；Redis 只在登录 Token、分片会话（`chunk:{md5}` Hash）、分享排行这些场景用。不要把分片 Hash 与秒传混谈。
4. **普通上传是否校验 Token / 重算正文 MD5**：upload_cgi **未调 verify_token**；`recv_save_file` 只按解析出的正文长度与请求声明比对，**不重算内容摘要**。客户端声明的 md5 是信任输入。
5. **为什么全量读 multipart 有内存问题**：upload_cgi 里 `malloc(len)` 一次读整个请求体进内存再解析（代码 `file_buf = malloc(len); fread(file_buf,1,len,stdin)`），文件越大占用越大；而大文件已走分片，所以小文件接口还在可接受范围，这是「为何拆小文件/大文件两条链路」的一个理由。
6. **上传后查 MD5 仍不能解决并发去重**：两请求同时「查 MD5 不存在 → 各自上传」就是经典的检查—执行竞态；之后补查只能事后发现重复，无法阻止重复正文写入。要「唯一内容记录 + UPLOADING/READY/FAILED 占位 + 原子争抢」改进。
7. **fork/exec + 管道串联**（upload_cgi.c 实证）：
   - `pipe()` → `fork()` → 子进程 `dup2(fd[1], STDOUT_FILENO)` → `execlp("fdfs_upload_file", conf_path, filename)`；文件正文经 FastDFS 客户端上 tracker/storage，file_id 从管道读出；
   - 再 `fork/execlp("fdfs_file_info", conf, fileid)` 拿 size/信息回填。
   - 所以上传不是项目内嵌 FastDFS API 的服务器，而是外部可执行文件 + 管道取回显，进程模型接近「传统 CGI + 外部命令」。
8. **FastDFS 成功、MySQL 失败留什么**：FastDFS 已写正文、`file_info` 可能没写或写一半 → 留孤儿正文；反之 DB 记了但 FastDFS 失败 → 关系指向不存在的正文。多处 sprintf 更新无事务（本项目无外键/无整体事务）。
9. **完善链路**：唯一占位 + 用户关系唯一键 + 事务 + outbox/补偿任务清理孤儿，属「改进」。
10. **MD5→SHA-256 解决/不解决什么**：解决碰撞/长度扩展类顾虑与更符合现代规范；不能解决检查—执行竞态、鉴权缺失、无事务这些一致性/安全问题。

---

## 四、分片与续传（Q&A 口径 + 实证 + 事故）

### 4.1 实测会话与文件布局

- 阈值与分片都 10 MiB（`config/index.js`：CHUNK_SIZE/CHUNK_THRESHOLD = 10*1024*1024）。
- 前端逐片 `await`（顺序上传，不是并发）。
- 初始化：chunk_init 校验 Token，Redis `chunk:{md5}` Hash 字段实测为：`filename / filesize / chunk_count / user / uploaded`，并 `EXPIRE chunk:{md5} 86400`（chunk_init_cgi.c:200）。
- 分片落盘 `/tmp/chunks/{md5}/{0..N-1}`（chunk_upload 按 URL `?md5=&index=` 写文件）。
- 单片上传：不验 Token/所有者/编号范围/单片大小/摘要；`uploaded` 是**先读后拼的逗号字符串**（非原子读改写）。
- 合并（chunk_merge）只 `verify_all_chunks` 检查各编号文件**存在**，不核对大小/哈希/总大小；随后首片 `storage_upload_appender_by_filename1`，后续 `storage_append_by_filename1` 按序追加，每片 append 完就 `unlink` 本地片。

### 4.2 实测一次完整合并（可引用的真数据，非编造）

- 文件 `[Sakura_Trick][01][720p][BDrip].mp4`，22 片，总字节 223,219,546（21×10 MiB + 末片 3,018,586）。
- 合并成功 file_id：`group1/M00/00/00/rB4AA2qfx4uENU2KAAAAAOGqdOw946.mp4`。
- 复验：HTTP 200 + Content-Length 与声明一致 + Range 206 正常；`user_file_list`/`file_info` 记录齐全（file_info.url 为内网 `http://172.30.0.3:80/…`）。
- 这条证明「分片→appender→nginx 下载」整条链路在真实部署里可用。

### 4.3 Q&A 补充口径

1. **为什么只用 MD5 当会话 ID 会跨用户碰撞**：Redis key、目录名都用客户端给的 md5，A 用户可在不知道 B 内容的情况下用同 md5 撞到 B 的会话/目录；会话应含用户维度（user+md5）或服务端签发 upload_id。
2. **边追加边删分片的后果**：任一后续分片 append 失败，已删的本地片无法重传补齐，只能整批重来；append 未做整体校验，失败无法定位到片。本次代码行 300/322 可见 `unlink`。
3. **Redis TTL 到期不删 /tmp/chunks**：Redis 只管理 `chunk:{md5}` 键的 86400 秒；`/tmp/chunks` 目录没有任何 GC/定时清理，键过期后磁盘残留目录与分片——孤儿文件累积。需「过期回收任务」改进。
4. **能否跨容器重建续传**：`/tmp/chunks` 在 fastcgi 容器可写层（无 volume），Redis 也无数据 volume，重建容器后分片与会话都不复存在；只能讲「同一容器生命周期内的缺片补传」。
5. **理想设计**：服务端 `upload_id`、Bitmap/原子位图标记已传片、单片哈希与大小校验、`PENDING/READY/MERGING/FAILED` 状态机、可持久化分片目录 + 过期 GC。全部属「改进」。

### 4.4 真实事故复盘：chunk_merge 10011「启动即崩」

- 现象：容器 healthy，但分片上传完成后合并请求全部失败；`lsof -i:10011` 无监听；docker logs 只有 spawn 行无报错；`/app/logs/cgi/…/chunk_merge-08.log` 只有初始化一行就停。
- 根因：start.sh **先 spawn chunk_merge、后 mkdir** `/fastdfs_data_and_log/client`。chunk_merge `main()` 里 `read_cfg()` 后立即 `fdfs_client_init()`，而 FastDFS client 需要 base_path 目录存在；目录缺失时 init 直接 abort，进程死、端口不监听。做了**可控复现**：删掉该目录再 spawn，10011 立刻起不来；恢复目录则正常。
- 修复：把 `mkdir -p /tmp/chunks /fastdfs_data_and_log/client /data/faiss` 提前到所有 spawn 之前；重 build fastcgi 镜像 + 冷启动后 10000-10012 全部监听、无崩溃日志。
- 面试价值：① 容器健康检查只查 `lsof -i:10000`（或 nginx 查 443），**10011 挂了容器仍 healthy** → 健康检查 ≠ 高可用，也 ≠ 端口全覆盖，本次直接踩到；② FastCGI 进程的启动顺序/前置目录/外部依赖要在启动脚本里显式先就绪。

---

## 五、分享、转存与删除（Q&A 口径 + 实证）

- 分享创建接口 sharepicture **校验 Token**；取消失效/转存/公共下载计数集中在 dealsharefile（**未校验 Token**，越权面）。
- MySQL 分享行是持久事实源；Redis ZSet/Hash 是缓存，未命中回查可回填（与主口径一致）。
- 转存只新增目标用户 `user_file_list` 关系并把 `file_info.count` +1，不重复上传正文。
- 删除：删用户关系 → 计数减一 → 归零才删物理记录与 FastDFS 正文；跨存储无事务、无补偿表 → 中途失败留不一致。
- 图片分享：sharepicture 建 `urlmd5` 与 4 位 `key`，但创建响应**不返回 key**、浏览接口只按 `urlmd5` 查（sharepicture_cgi.c 中 browse 只解析 urlmd5），所以「提取码保护」**未生效**，只能说生成了一列但没有强制校验。

---

## 六、真实部署故障复盘（两起 + 一坑）

### 6.1 CRLF 行尾导致容器崩溃循环（Windows/Linux 转义）

- 现象：fastcgi_app `Restarting (255)`，`docker logs` 反复 `exec /app/start.sh: no such file or directory`。
- 根因：仓库大量文件是 CRLF（Windows 检出/提交），start.sh 被 `COPY` 进镜像后首行 `#!/bin/sh\r`，内核把解释器当成 `/bin/sh\r` → 找不到 → 起不来。不只是 sh：Makefile/nginx.conf/FastDFS conf/dockerfile 全 CRLF，各自有隐患。
- 修复：全仓库 88 个 tracked 文本文件归一 LF；新增 `.gitattributes`（`* text=auto eol=lf`）；**必须重 build**（CRLF 已在镜像层里，光重启没用）。
- 面试价值：Linux 下可执行脚本/构建上下文对行尾敏感；git 跨平台协作要靠 attributes 而非依赖编辑器；复制进镜像的内容等于最终运行内容，改文件要重建镜像。

### 6.2 宿主机 80 被系统 nginx 抢占，前端「连不上」

- 现象：`http://127.0.0.1` 返回的是另一份 nginx 默认欢迎页（HTTP 200 但不是本项目），443 无监听；docker 发布 80:80 一直失败。
- 处理：`systemctl stop/disable nginx` 释放 80，compose 才能发布 80/443。
- 面试价值：端口占用是「本地部署连不上前端」的第一排查点；先 `ss -tlnp` 看监听归属，别只盯 docker。

### 6.3 排障方法论沉淀（可直接讲）

- `docker compose ps` 看健康态 ≠ 功能可用；结合 `docker exec … lsof -i` 逐端口核对监听。
- FastCGI/常驻进程「没日志多半是没起来」，用 `spawn-fcgi` 前台/手动执行 + 看 `/app/logs/cgi/*.log` 定位启动中断点。
- 怀疑环境因素时做**可控复现**（删目录→spawn→复现崩溃；补目录→正常）比猜代码更高效。

---

## 七、对《实际面经整理》统一口径的精确化清单

主文档基本事实准确，以下按本次实证做精确化/小修正：

| 原口径 | 本次实测后的精确化 |
| --- | --- |
| Token Redis 是「用户名 -> Token」 | 键就是**用户名**（如 `123123`），SETEX 86400；同 key 覆盖 = 单会话语义。 |
| 13 个 FastCGI 程序 ↔ 13 条路由 | 端口 10000-10012 共 13 个 listener，全 spawn-fcgi 单实例、串行；其中 ai(10012) 不进主口径。 |
| 「三容器」 | 精确为：MySQL 一容器；nginx+tracker+storage **同容器**；FastCGI+redis 同容器。 |
| 健康检查不等于高可用 | 实例佐证：fastcgi 只查 10000、nginx 只查 443 2xx，10011 挂了容器仍 healthy（本次事故）。 |
| 分片会话 TTL 24 小时 | 代码 `EXPIRE chunk:{md5} 86400`；但 /tmp/chunks **无 GC**，键过期文件仍在。 |
| 登录失败=用户不存在？ | 更精确：登录传 `{user,pwd}` 且 pwd 要是 **MD5(明文)**；明文直接手测会 code1（前端先 MD5）。别把「字段/加密不对」当成后端故障。 |
| 下载/去重 | 普通上传不重算 MD5、只比对声明长度，已实证；MD5/秒传的分支返回码是 004/005/006。 |
| 越权写接口 | 代码核实：upload、chunk_upload、dealsharefile 未调 verify_token；受保护面清单见 1.2。 |
| — | 新增：前端用 `url.replace(STORAGE_URL,'')` 把内网 `172.30.0.3:80` 文件地址转同源相对路径；DB 里 file_info.url 存的就是内网地址。 |
| — | 新增：redis 无数据 volume、容器重建即全新实例，Token/分片会话丢失需重新登录（由无持久化机制决定）。 |

「改进」清单与主文档第六部分一致：统一写鉴权、SHA-256 复算 + 唯一内容记录、upload_id/位图/状态机续传、MySQL 事务 + FastDFS outbox、分片目录持久化与 GC、图片 key/签名下载/SQL 参数化。

---

## 八、实测证据附录（面试可引用的真数据）

- 静态 IP/端口/容器名：见 1.1 表。
- Redis：`keys *` 曾出现 `123123 / chunk:7e0674… / t_…`；`hgetall chunk:7e0674…` → `filename/filesize(223219546)/chunk_count(22)/user(123123)/uploaded(0..21)`。
- 合并实例：`fileid=group1/M00/00/00/rB4AA2qfx4uENU2KAAAAAOGqdOw946.mp4`；HEAD Content-Length=223219546、video/mp4；Range→206。
- 启动修复前后：修复前 10011 无监听且容器 healthy；修复后冷启动 10000-10012 全部 LISTEN，日志无 buffer/abort。
- 一条端到端 API：注册 code0 → 登录 code0+token（MD5 密码）→（该 token 曾在 redis 为 `123123` 键值）。

> 所有数字仅来自本次本地部署，不推广到任意环境；压测/并发/性能数据未做，不提供。
