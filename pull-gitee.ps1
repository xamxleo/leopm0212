# ============================================================
# WorkBuddy Claw 项目 -> 从 Gitee 拉取更新脚本
# 使用方法：在家里电脑上，右键此文件 -> 用 PowerShell 运行
# ============================================================

# 配置区 —— 和上传脚本保持一致
$GITEE_USER = "你的Gitee用户名"
$REPO_NAME   = "workbuddy-claw"

# 家里电脑的项目路径（根据实际情况修改！）
$WORK_DIR = "C:\Users\$env:USERNAME\WorkBuddy\Claw"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  WorkBuddy Claw -> 从 Gitee 拉取最新代码" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查目录是否存在
if (Test-Path $WORK_DIR) {
    Write-Host "[1/3] 进入项目目录..." -ForegroundColor Yellow
    Set-Location $WORK_DIR
    Write-Host "  ✓ 目录存在: $WORK_DIR" -ForegroundColor Green

    Write-Host "[2/3] 拉取最新代码..." -ForegroundColor Yellow
    git pull origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ 拉取成功！" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 拉取失败，可能本地有冲突" -ForegroundColor Red
    }
} else {
    Write-Host "[1/3] 首次克隆项目..." -ForegroundColor Yellow
    $PARENT_DIR = Split-Path $WORK_DIR
    if (-not (Test-Path $PARENT_DIR)) { New-Item -ItemType Directory -Path $PARENT_DIR | Out-Null }
    Set-Location $PARENT_DIR
    git clone "https://gitee.com/$GITEE_USER/$REPO_NAME.git" Claw
    Write-Host "  ✓ 克隆完成！" -ForegroundColor Green
}

Write-Host "[3/3] 最新文件状态：" -ForegroundColor Yellow
git log --oneline -5 2>$null
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  完成！项目路径: $WORK_DIR" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
pause
