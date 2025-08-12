## 部署发布说明（GitHub Pages）

- **仓库**: [quyingying421-source/index-html-page](https://github.com/quyingying421-source/index-html-page)
- **网站地址（Pages）**: [https://quyingying421-source.github.io/index-html-page/](https://quyingying421-source.github.io/index-html-page/)

### 前置要求
- 已安装并配置：`git`、`gh`（GitHub CLI）。
- 本机已使用 `gh` 登录 GitHub 账号：
```bash
gh auth status -h github.com
# 如未登录或掉线：
gh auth login --hostname github.com --git-protocol https --web
```

### 一键发布
在项目根目录执行：
```bash
./scripts/deploy.sh
```
若遇到“权限不足”，先执行：
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 脚本会做什么
- 自动校验并登录 GitHub（需要时会走浏览器设备授权）。
- 自动 `git add .`，生成带时间戳的提交信息，并 `push` 到远程当前分支（默认 `main`）。
- 确保已开启 GitHub Pages（从 `main` 分支根路径 `/` 发布）。
- 输出最终访问地址（如：`https://quyingying421-source.github.io/index-html-page/`）。

### 常用 Git 配置（可选）
为避免提交时提示身份信息，建议设置全局用户名与邮箱：
```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

### 常见问题
- **图片/图标无法显示**：`index.html` 中的图片变量当前指向 `http://localhost:3845/assets/...`，在 GitHub Pages 上会加载失败。建议将资源放到本项目 `assets/` 目录，并将 CSS 变量改为相对路径（如 `./assets/xxx.png`）。
- **favicon 404**：可在项目根目录放置 `favicon.ico`，或在 `index.html` `<head>` 中添加自定义 favicon 链接。

### 手动发布（不使用脚本）
```bash
git add .
git commit -m "chore: update page"
git push
# 确保已开启 Pages（一次性）：
# gh api -X POST repos/OWNER/REPO/pages -f 'source[branch]=main' -f 'source[path]=/'
```
