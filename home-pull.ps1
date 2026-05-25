# 家里电脑一键拉取 WorkBuddy 项目脚本
# 使用方法：右键 → 用 PowerShell 运行

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  WorkBuddy Claw 项目同步脚本" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# ========== 配置区（修改为你自己的信息）==========

# GitHub 用户名
$GITEE_USER  = "xamxleo"

# 仓库名
$REPO_NAME   = "leopm0212"

# 家里电脑 WorkBuddy 工作区路径（按实际修改）
# 如果家里电脑用户名不同，需要修改此路径
$WORKSPACE   = "C:\Users\$env:USERNAME\WorkBuddy\Claw"

# ============================================================

# 拼接仓库地址
$REPO_URL = "https://github.com/$GITEE_USER/$REPO_NAME.git"

Write-Host "配置信息：" -ForegroundColor Yellow
Write-Host "  仓库地址：$REPO_URL"
Write-Host "  本地路径：$WORKSPACE"
Write-Host ""

# 检查 Git 是否安装
Write-Host "【1/4】检查 Git 安装状态..." -ForegroundColor Cyan
try {
    $GitVersion = git --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Git not found" }
    Write-Host "  ✅ $GitVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ 未检测到 Git，请先安装：" -ForegroundColor Red
    Write-Host "     https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按 Enter 退出"
    exit 1
}

# 检查目录是否存在
Write-Host ""
Write-Host "【2/4】检查本地工作区..." -ForegroundColor Cyan
if (Test-Path $WORKSPACE) {
    Write-Host "  ✅ 工作区已存在：$WORKSPACE" -ForegroundColor Green

    # 检查是否是 Git 仓库
    if (Test-Path "$WORKSPACE\.git") {
        Write-Host "  ✅ Git 仓库已初始化" -ForegroundColor Green
        Write-Host ""
        Write-Host "【3/4】拉取最新代码..." -ForegroundColor Cyan
        Set-Location $WORKSPACE
        git pull origin main 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ 代码拉取成功！" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ 拉取失败，尝试重新克隆..." -ForegroundColor Yellow
            Set-Location ..
            Remove-Item $WORKSPACE -Recurse -Force -ErrorAction SilentlyContinue
            git clone $REPO_URL $WORKSPACE 2>&1
        }
    } else {
        Write-Host "  ⚠️ 目录存在但不是 Git 仓库，重新克隆..." -ForegroundColor Yellow
        Remove-Item $WORKSPACE -Recurse -Force -ErrorAction SilentlyContinue
        Set-Location (Split-Path $WORKSPACE -Parent)
        git clone $REPO_URL (Split-Path $WORKSPACE -Leaf) 2>&1
    }
} else {
    Write-Host "  ⚠️ 工作区不存在，开始克隆..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "【3/4】克隆远程仓库..." -ForegroundColor Cyan
    $ParentDir = Split-Path $WORKSPACE -Parent
    if (!(Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }
    Set-Location $ParentDir
    git clone $REPO_URL (Split-Path $WORKSPACE -Leaf) 2>&1
}

# 完成
Write-Host ""
Write-Host "【4/4】同步完成！" -ForegroundColor Cyan
Write-Host ""
Write-Host "本地文件列表：" -ForegroundColor Yellow
Get-ChildItem $WORKSPACE | Format-Table Name, LastWriteTime -AutoSize
Write-Host ""
Write-Host "工作区路径：$WORKSPACE" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Read-Host "按 Enter 退出"
