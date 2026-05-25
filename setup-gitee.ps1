# ============================================================
# WorkBuddy Claw 项目 -> Gitee 一键上传脚本
# 使用方法：在单位电脑上，右键此文件 -> 用 PowerShell 运行
# ============================================================

# 配置区 —— 修改这两行为你的 Gitee 信息
$GITEE_USER  = "你的Gitee用户名"
$REPO_NAME   = "workbuddy-claw"   # 在 Gitee 上创建的仓库名
$GITEE_TOKEN = ""                  # 可选：Gitee 私人令牌（避免每次输密码）

# 项目路径（一般不用改）
$WORK_DIR = "C:\Users\Administrator\WorkBuddy\Claw"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  WorkBuddy Claw -> Gitee 同步初始化"     -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Git 是否安装
Write-Host "[1/6] 检查 Git..." -ForegroundColor Yellow
$gitVersion = git --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 未检测到 Git，请先安装：https://git-scm.com/download/win" -ForegroundColor Red
    pause
    exit 1
}
Write-Host "  ✓ $gitVersion" -ForegroundColor Green

# 进入项目目录
Write-Host "[2/6] 进入项目目录..." -ForegroundColor Yellow
if (-not (Test-Path $WORK_DIR)) {
    Write-Host "  ✗ 目录不存在: $WORK_DIR" -ForegroundColor Red
    pause; exit 1
}
Set-Location $WORK_DIR
Write-Host "  ✓ 当前目录: $(Get-Location)" -ForegroundColor Green

# 初始化 Git
Write-Host "[3/6] 初始化 Git 仓库..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init
    git branch -M main
    Write-Host "  ✓ Git 仓库初始化完成" -ForegroundColor Green
} else {
    Write-Host "  ⊙ Git 仓库已存在，跳过初始化" -ForegroundColor Gray
}

# 配置 .gitignore（如果不存在）
Write-Host "[4/6] 检查 .gitignore..." -ForegroundColor Yellow
if (-not (Test-Path ".gitignore")) {
    Write-Host "  ✗ .gitignore 不存在，请先创建" -ForegroundColor Red
    pause; exit 1
}
Write-Host "  ✓ .gitignore 已存在" -ForegroundColor Green

# 添加文件并提交
Write-Host "[5/6] 添加文件并提交..." -ForegroundColor Yellow
git add .
$status = git status --short
if (-not $status) {
    Write-Host "  ⊙ 没有新文件需要提交" -ForegroundColor Gray
} else {
    $commitMsg = "同步工作区文件 - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m $commitMsg
    Write-Host "  ✓ 提交完成: $commitMsg" -ForegroundColor Green
}

# 添加远程仓库并推送
Write-Host "[6/6] 推送到 Gitee..." -ForegroundColor Yellow
$REMOTE_URL = "https://gitee.com/$GITEE_USER/$REPO_NAME.git"

# 检查 remote 是否已存在
$existingRemote = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    git remote add origin $REMOTE_URL
    Write-Host "  ✓ 添加远程仓库: $REMOTE_URL" -ForegroundColor Green
} else {
    Write-Host "  ⊙ 远程仓库已存在: $existingRemote" -ForegroundColor Gray
    git remote set-url origin $REMOTE_URL
}

# 推送
Write-Host ""
Write-Host "正在推送到 Gitee..." -ForegroundColor Yellow
if ($GITEE_TOKEN) {
    $AUTH_URL = "https://$GITEE_USER`:$GITEE_TOKEN@gitee.com/$GITEE_USER/$REPO_NAME.git"
    git push -u $AUTH_URL main
} else {
    git push -u origin main
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  ✓ 推送成功！" -ForegroundColor Green
    Write-Host "  仓库地址: https://gitee.com/$GITEE_USER/$REPO_NAME" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  ✗ 推送失败，请检查：" -ForegroundColor Red
    Write-Host "    1. Gitee 仓库是否已创建（必须是空仓库）" -ForegroundColor Yellow
    Write-Host "    2. 用户名和仓库名是否正确" -ForegroundColor Yellow
    Write-Host "    3. 如果是第一次推送，需要输入 Gitee 账号密码" -ForegroundColor Yellow
}

Write-Host ""
pause
