#!/usr/bin/env bash
set -euo pipefail

# Config
REPO_FULL="quyingying421-source/index-html-page"
BRANCH="main"
PAGES_SOURCE_PATH="/"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

say() { echo -e "${GREEN}$*${NC}"; }
err() { echo -e "${RED}$*${NC}" 1>&2; }

# 1) Check deps
command -v git >/dev/null 2>&1 || { err "git 未安装"; exit 1; }
command -v gh >/dev/null 2>&1 || { err "gh (GitHub CLI) 未安装"; exit 1; }

# 2) Auth status
if ! gh auth status -h github.com >/dev/null 2>&1; then
  say "需要登录 GitHub，启动设备授权..."
  gh auth login --hostname github.com --git-protocol https --web
fi

# 3) Ensure gh manages git credentials
gh auth setup-git -h github.com >/dev/null 2>&1 || true

# 4) Commit changes
say "提交变更..."
if ! git diff --quiet || ! git diff --cached --quiet; then
  git add .
  git commit -m "chore: deploy $(date +%F' '%T)"
else
  say "无变更需要提交"
fi

# 5) Push
say "推送到远程..."
DEFAULT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "${BRANCH}")
TARGET_BRANCH=${DEFAULT_BRANCH:-${BRANCH}}

git push -u origin "$TARGET_BRANCH"

# 6) Enable GitHub Pages (idempotent)
say "确保开启 GitHub Pages..."
if gh api repos/$REPO_FULL/pages >/dev/null 2>&1; then
  gh api -X PUT repos/$REPO_FULL/pages -f "source[branch]=$TARGET_BRANCH" -f "source[path]=$PAGES_SOURCE_PATH" >/dev/null || true
else
  gh api -X POST repos/$REPO_FULL/pages -f "source[branch]=$TARGET_BRANCH" -f "source[path]=$PAGES_SOURCE_PATH" >/dev/null || true
fi

PAGES_URL=$(gh api repos/$REPO_FULL/pages --jq '.html_url' 2>/dev/null || echo "")

say "部署完成！"
if [[ -n "$PAGES_URL" ]]; then
  say "访问地址: $PAGES_URL"
else
  say "GitHub Pages 正在初始化，请稍后刷新仓库的 Pages 设置页面。"
fi
