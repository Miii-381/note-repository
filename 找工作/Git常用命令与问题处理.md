# Git 常用命令与问题处理

> **用途**：满足日常开发中的代码拉取、提交、分支管理、代码合并和冲突处理，也可用于面试回答。  
> **核心原则**：提交前先更新代码，提交时只提交相关修改；已经推送到公共分支的提交，优先使用 `git revert` 撤销，不随意改写历史。

---

## 一、Git 的基本概念

Git 中最常用的几个区域：

- **工作区**：正在编辑的本地文件；
- **暂存区**：通过 `git add` 选中、准备提交的修改；
- **本地仓库**：通过 `git commit` 保存的提交记录；
- **远程仓库**：GitHub、GitLab、Gitee 等服务器上的仓库。

一段代码从修改到上传的过程：

```text
修改文件 → git add → git commit → git push
工作区      暂存区       本地仓库       远程仓库
```

---

## 二、日常最常用的命令

### 1. 初始化与获取项目

```bash
# 在当前目录创建 Git 仓库
git init

# 克隆远程项目
git clone <仓库地址>

# 查看远程仓库地址
git remote -v
```

### 2. 查看代码状态和历史

```bash
# 查看哪些文件被修改、暂存或未跟踪
git status

# 查看工作区中尚未暂存的修改
git diff

# 查看已经暂存、即将提交的修改
git diff --staged

# 简洁地查看提交历史
git log --oneline --graph --decorate --all

# 查看某次提交的具体内容
git show <commit-id>
```

### 3. 提交代码

```bash
# 将指定文件加入暂存区，推荐使用
git add <文件名>

# 将当前目录下所有修改加入暂存区
git add .

# 提交暂存区中的修改
git commit -m "feat: 增加用户登录功能"

# 将本地提交推送到当前远程分支
git push
```

提交信息可以使用简单、统一的前缀：

| 前缀 | 含义 | 示例 |
| --- | --- | --- |
| `feat` | 新功能 | `feat: 增加文件上传功能` |
| `fix` | 修复问题 | `fix: 修复登录超时问题` |
| `refactor` | 重构，不改变功能 | `refactor: 重构用户服务` |
| `docs` | 文档修改 | `docs: 补充部署说明` |
| `test` | 测试修改 | `test: 增加登录接口测试` |
| `chore` | 构建、配置等杂项 | `chore: 更新依赖版本` |

### 4. 拉取远程代码

```bash
# 拉取远程更新并合并到当前分支
git pull

# 分两步执行，过程更清楚
git fetch origin
git merge origin/main
```

`git pull` 基本可以理解为 `git fetch` 加一次合并操作。日常使用前应先确认自己所在的分支以及工作区是否干净。

---

## 三、分支管理

### 1. 常用命令

```bash
# 查看本地分支
git branch

# 查看本地和远程的所有分支
git branch -a

# 创建新分支
git branch feature/login

# 切换分支
git switch feature/login

# 创建并立即切换到新分支
git switch -c feature/login

# 第一次推送新分支，并建立远程跟踪关系
git push -u origin feature/login

# 删除已经合并的本地分支
git branch -d feature/login

# 删除远程分支
git push origin --delete feature/login
```

旧项目中也经常看到以下写法：

```bash
# 相当于 git switch feature/login
git checkout feature/login

# 相当于 git switch -c feature/login
git checkout -b feature/login
```

### 2. 常见分支开发流程

假设从 `main` 创建功能分支：

```bash
# 1. 切换到主分支并拉取最新代码
git switch main
git pull origin main

# 2. 创建功能分支
git switch -c feature/login

# 3. 开发后提交
git add <相关文件>
git commit -m "feat: 完成登录功能"

# 4. 推送功能分支
git push -u origin feature/login

# 5. 在 GitHub 或 GitLab 上创建 Pull Request / Merge Request
```

团队开发中通常不直接向 `main` 提交，而是在功能分支开发，通过代码评审后再合并。

---

## 四、分支合并

### 1. 使用 merge 合并

将 `feature/login` 合并到 `main`：

```bash
# 先更新 main
git switch main
git pull origin main

# 将功能分支合并进当前分支
git merge feature/login

# 推送合并结果
git push origin main
```

`git merge` 会保留分支开发历史，必要时产生一个合并提交。它直观、安全，适合公共分支和大多数团队协作场景。

### 2. 使用 rebase 整理提交

在功能分支上，将自己的提交移动到最新 `main` 之后：

```bash
git switch feature/login
git fetch origin
git rebase origin/main
```

`rebase` 可以让提交历史更整洁，但它会改写提交历史。因此：

- 适合整理自己尚未共享的本地功能分支；
- 不要随意对多人共同使用的公共分支执行 `rebase`；
- 如果变基过程中不想继续，可以执行 `git rebase --abort`。

### 3. merge 和 rebase 的区别

| 对比项 | `merge` | `rebase` |
| --- | --- | --- |
| 历史结构 | 保留真实分支结构 | 形成较整洁的线性历史 |
| 是否改写历史 | 否 | 是 |
| 使用难度 | 较低 | 较高 |
| 常用场景 | 合并公共分支、完成需求 | 更新并整理个人功能分支 |

面试时可以回答：

> `merge` 会保留两个分支原有的提交历史，必要时生成合并提交，适合公共分支协作；`rebase` 会把当前分支的提交重新应用到目标分支之后，使历史更线性，但会改变提交哈希，所以一般只用于自己的功能分支，不随意用于已经共享的公共分支。

---

## 五、代码冲突的处理

### 1. 为什么会产生冲突

当两个分支修改了同一文件的同一位置，Git 无法自动判断应该保留哪一份内容，就会产生冲突。冲突常出现在 `merge`、`rebase`、`pull` 或 `stash pop` 时。

### 2. merge 冲突的解决步骤

```bash
# 1. 查看冲突文件
git status

# 2. 手动编辑冲突文件，保留最终需要的代码

# 3. 将已经解决的文件加入暂存区
git add <冲突文件>

# 4. 完成合并提交
git commit
```

文件中的冲突标记通常如下：

```text
<<<<<<< HEAD
当前分支的代码
=======
被合并分支的代码
>>>>>>> feature/login
```

需要人工决定保留哪部分代码，删除 `<<<<<<<`、`=======`、`>>>>>>>` 等标记，然后进行编译和测试。

如果不想继续本次合并：

```bash
git merge --abort
```

### 3. rebase 冲突的解决步骤

```bash
# 修改冲突文件后标记为已解决
git add <冲突文件>

# 继续变基
git rebase --continue

# 放弃本次变基，恢复到开始前
git rebase --abort
```

注意：解决 `rebase` 冲突后通常不直接执行 `git commit`，而是执行 `git rebase --continue`。

### 4. 面试中的冲突处理回答

> 我会先用 `git status` 确认冲突文件，再打开文件查看冲突标记，根据业务逻辑和双方改动确定最终代码。修改完成后删除冲突标记，使用 `git add` 标记为已解决。如果是 `merge`，就完成合并提交；如果是 `rebase`，就执行 `git rebase --continue`。最后一定会编译并运行相关测试，确认合并后的代码不仅没有语法冲突，也没有业务逻辑冲突。如果不确定正确结果，我会先与相关开发者确认，而不是直接选择一方覆盖。

---

## 六、临时保存未完成的修改

当正在开发，但需要临时切换分支处理其他问题时，可以使用 `stash`：

```bash
# 临时保存当前已跟踪文件的修改
git stash push -m "正在开发登录功能"

# 如需同时保存未跟踪文件，增加 -u
git stash push -u -m "正在开发登录功能"

# 查看保存列表
git stash list

# 恢复最近一次保存，并从列表中删除
git stash pop

# 恢复指定保存，但不从列表中删除
git stash apply stash@{0}

# 删除指定保存
git stash drop stash@{0}
```

`stash pop` 也可能产生冲突，处理方法与普通冲突类似。

---

## 七、常见误操作与恢复

### 1. 文件改乱了，想放弃尚未暂存的修改

```bash
# 恢复指定文件到最近一次提交或暂存状态
git restore <文件名>

# 放弃当前目录下所有尚未暂存的修改，执行前必须确认
git restore .
```

这些操作会覆盖工作区内容，未提交的修改可能无法恢复。

### 2. 不小心执行了 git add

```bash
# 将文件移出暂存区，但保留工作区修改
git restore --staged <文件名>
```

### 3. 最近一次提交信息写错或漏了文件

```bash
# 修改最近一次提交信息
git commit --amend -m "fix: 正确的提交信息"

# 漏提交文件时
git add <遗漏文件>
git commit --amend --no-edit
```

如果该提交已经推送并被其他人使用，不应随意 `amend`，因为它会改变提交历史。

### 4. 撤销已经提交的代码

```bash
# 生成一个新提交，反向撤销指定提交，适合已经推送的公共分支
git revert <commit-id>
```

`revert` 不删除原来的提交，而是新增一次反向修改，因此更适合团队协作。

### 5. 本地提交后发现提交错了

```bash
# 撤销最近一次提交，修改仍保留在暂存区
git reset --soft HEAD~1

# 撤销最近一次提交，修改保留在工作区但移出暂存区
git reset HEAD~1

# 撤销提交并丢弃工作区修改，高风险
git reset --hard HEAD~1
```

简单记忆：

- `--soft`：保留修改和暂存状态；
- 默认的 `--mixed`：保留修改，但取消暂存；
- `--hard`：提交和本地修改一起丢弃。

不要对已经推送到公共分支的提交随意使用 `reset` 后强制推送。公共历史需要撤销时优先使用 `git revert`。

### 6. 找回误删的提交

```bash
# 查看 HEAD 曾经指向过的位置
git reflog

# 查看找到的提交内容
git show <commit-id>

# 从该提交创建恢复分支
git switch -c recover-branch <commit-id>
```

`reflog` 主要记录本地操作，是处理误 `reset`、误删分支等问题的重要手段。

---

## 八、其他常见问题

### 1. push 被拒绝

常见原因是远程分支存在本地没有的新提交。可以先拉取并整合：

```bash
git pull --rebase origin <当前分支名>
git push origin <当前分支名>
```

如果产生冲突，解决后执行：

```bash
git add <冲突文件>
git rebase --continue
git push origin <当前分支名>
```

不要在不清楚影响范围时直接使用 `git push --force`。个人分支确实需要更新重写后的历史时，优先使用相对安全的：

```bash
git push --force-with-lease
```

它会在远程分支出现自己不知道的新提交时拒绝覆盖，但仍应谨慎使用。

### 2. 切换分支时提示本地修改会被覆盖

可根据实际情况选择一种处理方式：

```bash
# 修改已经完成：先提交
git add <相关文件>
git commit -m "wip: 保存当前进度"

# 修改尚未完成：临时保存
git stash push -u -m "临时保存"

# 修改不需要：放弃指定文件的修改
git restore <文件名>
```

### 3. 已经提交了不应该进入仓库的文件

先将文件写入 `.gitignore`，再取消 Git 对它的跟踪：

```bash
git rm --cached <文件名>
git commit -m "chore: 停止跟踪本地配置文件"
```

`.gitignore` 只对尚未被 Git 跟踪的文件生效。密码、密钥等敏感信息一旦推送过，仅删除文件并不能消除泄露风险，还应立即更换相关凭据，并按团队流程清理历史。

### 4. 分支名称或远程分支信息没有及时更新

```bash
# 获取远程最新信息，并清理已经不存在的远程分支引用
git fetch --prune
```

---

## 九、日常提交检查清单

提交代码前可以按以下顺序检查：

```bash
# 1. 确认当前分支和文件状态
git status

# 2. 查看具体修改，避免提交调试代码或无关内容
git diff

# 3. 只暂存本次任务相关文件
git add <相关文件>

# 4. 再次确认即将提交的内容
git diff --staged

# 5. 提交
git commit -m "feat: 简明描述本次修改"

# 6. 拉取并整合远程更新
git pull --rebase

# 7. 编译或运行测试后推送
git push
```

实际团队中应遵循项目自己的分支规范、提交信息规范和 Pull Request / Merge Request 流程。

---

## 十、面试快速回答

### 1. 你平时怎样使用 Git 提交代码？

> 我一般从最新的主分支创建功能分支，在功能分支完成开发。提交前先通过 `git status` 和 `git diff` 检查改动，只将本次需求相关文件加入暂存区，再使用清晰的提交信息进行 `commit`。推送前会同步远程最新代码，解决冲突并完成编译和测试，然后推送功能分支，最后通过 Pull Request 或 Merge Request 进行代码评审和合并。

### 2. Git 冲突怎样处理？

> 先通过 `git status` 找到冲突文件，再根据冲突标记和业务逻辑手动合并代码。处理完成后使用 `git add` 标记为已解决；`merge` 冲突继续完成提交，`rebase` 冲突执行 `git rebase --continue`。最后必须重新编译和测试。如果业务逻辑无法确定，我会与对应开发者沟通后再处理。

### 3. git fetch 和 git pull 有什么区别？

> `git fetch` 只把远程仓库的最新提交和引用下载到本地，不会直接修改当前工作分支；`git pull` 会在获取远程更新后，继续把更新合并或变基到当前分支。需要先检查远程变化时使用 `fetch` 更稳妥，日常确认可以直接整合时可以使用 `pull`。

### 4. git reset 和 git revert 有什么区别？

> `reset` 会移动分支指针，可以撤销本地提交，并根据参数决定是否保留文件修改，但可能改写历史；`revert` 会生成一个新的反向提交，不删除已有历史。个人尚未推送的提交可以使用 `reset` 调整，已经推送到公共分支的提交通常使用 `revert` 撤销。

---

## 十一、最小命令速查

```bash
git status                         # 查看状态
git diff                           # 查看未暂存修改
git diff --staged                  # 查看已暂存修改
git add <文件名>                   # 暂存文件
git commit -m "说明"               # 提交
git pull --rebase                  # 拉取远程代码并变基当前提交
git push                           # 推送代码
git switch -c <分支名>             # 创建并切换分支
git switch <分支名>                # 切换分支
git merge <分支名>                 # 合并分支
git stash push -u -m "说明"        # 临时保存修改
git stash pop                      # 恢复临时修改
git restore <文件名>               # 放弃未暂存修改
git restore --staged <文件名>      # 取消暂存
git revert <commit-id>             # 安全撤销公共提交
git reflog                         # 查找本地操作和丢失提交
```

日常工作重点不在于记住所有命令，而在于养成三个习惯：**提交前检查差异、合并后执行测试、公共分支不随意改写历史。**
