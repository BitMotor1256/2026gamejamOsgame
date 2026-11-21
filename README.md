# 永昌之路（Dora SSR 项目）

基于 Dora SSR 引擎的游戏项目。入口为项目根的 `init.ts`（构建后生成 `init.lua`，引擎实际运行的是 Lua）。

## 仓库信息

- 远程地址：`https://github.com/BitMotor1256/2026gamejamOsgame.git`
- 远程名：`origin`
- 主分支：`main`
- 认证方式：GitHub **HTTPS 访问令牌（token）**。引擎内置 Git 只支持 HTTPS 的 basic / token 认证，**不支持 SSH**。

## 版本控制方式

本项目使用 Dora SSR 引擎内置的 Git 客户端，而不是系统 `git` 命令行。可用入口有三个：

1. **Web IDE 的 Git 面板**：填远程地址与 token 后即可执行提交与推送，token 只保存在 IDE 侧，不写入仓库。
2. **Agent / 脚本中的 `Git.run()`**：`Git.run(repoPath, command, callback, optionsJSON)`，命令不走 shell，也不支持 `git -C`；需要认证的命令用 `optionsJSON` 传入 `{"auth":{"type":"token","token":"<你的令牌>","username":"token"}}`。
3. **`Dora cli agent command --input request.json`**：从 JSON 读取 Lua 或 Git 请求，结果以 JSON 输出到标准输出。

`repoPath` 必须位于引擎可写目录或资源目录内，并用 `Git.isRepoPathAllowed(repoPath)` 校验通过。

## 日常提交流程

```text
git status
git add -A
git commit -m "feat: <改动说明>" --author-name <名字> --author-email <邮箱>
git push
```

要点：

- **必须显式传 `--author-name` / `--author-email`**：引擎内置 Git 没有全局作者配置，省略会提交失败。
- 首次推送带 `-u` 建立上游关联：`push -u origin main`；之后直接 `push` 即可。
- 推送需要 token 时，在 Web IDE Git 面板或凭据提示中输入，**不要**把令牌写进任何被跟踪文件、提交信息或脚本。
- 不要使用 `-f` / `--force`：本仓库不需要重写历史。

## 首次推送（尚未执行）

```text
git push -u origin main
```

远程仓库当前为空，首次推送会把本地 `main` 连同已有提交一起上传，并把 `main` 建立为远程分支。

## 文件与忽略规则

`.gitignore` 排除以下内容：

| 规则 | 原因 |
| --- | --- |
| `.agent/` | Agent 的计划、记忆与会话记录 |
| `API/` | `Dora cli ts install` 生成的引擎类型定义，可随时重建 |
| `.DS_Store` / `Thumbs.db` | 系统垃圾文件 |

编译产物 `init.lua` **入库**，不忽略。因此约定：修改 `init.ts` 后先构建再提交，保证仓库里的 `.lua` 与源码一致，不要提交过期产物。

## 环境准备（新克隆后）

`API/` 与 `tsconfig.json` 由 Dora CLI 生成，未纳入版本控制，新克隆的副本需要执行一次：

```sh
Dora cli ts install -p /path/to/project -l zh-Hans
```

该命令会写入 `tsconfig.json` 并把引擎类型定义刷新到 `API/`（`API/` 已被 `.gitignore` 排除，不会出现在提交里）。

构建项目：

```sh
Dora cli build -p /path/to/project
```
