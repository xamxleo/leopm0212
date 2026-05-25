# ============================================================
# 家里电脑 WorkBuddy + Gitee 一键配置脚本
# 使用方法：右键此文件 -> 用 PowerShell 运行（以管理员身份）
# ============================================================

# ===== 配置区（修改这些变量）=====
$GITEE_USER  = "你的Gitee用户名"
$REPO_NAME    = "workbuddy-claw"
$HOME_USER     = $env:USERNAME  # 自动获取当前用户名，一般不用改

# WorkBuddy 工作区路径
$WORK_DIR = "C:\Users\$HOME_USER\WorkBuddy\Claw"

# Git 用户信息（第一次配置需要）
$GIT_USER_NAME  = "你的姓名"
$GIT_USER_EMAIL = "你的邮箱"
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  家里电脑 WorkBuddy 工作区一键配置"       -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ===== 第1步：检查/安装 Git =====
Write-Host "[1/5] 检查 Git 安装状态..." -ForegroundColor Yellow
$gitPath = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitPath) {
    Write-Host "  ✗ 未检测到 Git，正在自动安装..." -ForegroundColor Red
    Write-Host "  请稍候，这可能需要 1-2 分钟..." -ForegroundColor Gray
    
    # 下载并安装 Git
    $gitInstaller = "$env:TEMP\Git-Setup.exe"
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile $gitInstaller
    Start-Process -FilePath $gitInstaller -Args "/VERYSILENT /NORESTART" -Wait
    
    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "  ✓ Git 安装完成" -ForegroundColor Green
} else {
    Write-Host "  ✓ Git 已安装: $(git --version)" -ForegroundColor Green
}

# ===== 第2步：配置 Git 用户信息 =====
Write-Host "[2/5] 配置 Git 用户信息..." -ForegroundColor Yellow
$currentName = git config --global user.name 2>$null
$currentEmail = git config --global user.email 2>$null

if (-not $currentName) {
    git config --global user.name "$GIT_USER_NAME"
    Write-Host "  ✓ 设置用户名: $GIT_USER_NAME" -ForegroundColor Green
} else {
    Write-Host "  ⊙ 用户名已配置: $currentName" -ForegroundColor Gray
}

if (-not $currentEmail) {
    git config --global user.email "$GIT_USER_EMAIL"
    Write-Host "  ✓ 设置邮箱: $GIT_USER_EMAIL" -ForegroundColor Green
} else {
    Write-Host "  ⊙ 邮箱已配置: $currentEmail" -ForegroundColor Gray
}

# 配置换行符（Windows 推荐）
git config --global core.autocrlf true
Write-Host "  ✓ 配置换行符处理" -ForegroundColor Green

# ===== 第3步：创建 WorkBuddy 工作区目录 =====
Write-Host "[3/5] 准备工作区目录..." -ForegroundColor Yellow
$parentDir = Split-Path $WORK_DIR
if (-not (Test-Path $parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    Write-Host "  ✓ 创建目录: $parentDir" -ForegroundColor Green
}

if (Test-Path $WORK_DIR) {
    Write-Host "  ⊙ 工作区已存在: $WORK_DIR" -ForegroundColor Gray
    Set-Location $WORK_DIR
} else {
    Write-Host "  ➤ 克隆 Gitee 仓库..." -ForegroundColor Yellow
    Set-Location $parentDir
    git clone "https://gitee.com/$GITEE_USER/$REPO_NAME.git" Claw
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ 克隆成功！" -ForegroundColor Green
        Set-Location $WORK_DIR
    } else {
        Write-Host "  ✗ 克隆失败，请检查：" -ForegroundColor Red
        Write-Host "    1. Gitee 用户名和仓库名是否正确" -ForegroundColor Yellow
        Write-Host "    2. 仓库是否为私有（需要输入账号密码）" -ForegroundColor Yellow
        Write-Host "    3. 网络连接是否正常" -ForegroundColor Yellow
        pause
        exit 1
    }
}

# ===== 第4步：拉取最新代码 =====
Write-Host "[4/5] 拉取最新代码..." -ForegroundColor Yellow
if (Test-Path ".git") {
    git pull origin main 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ 代码已更新到最新" -ForegroundColor Green
    } else {
        Write-Host "  ⊙ 已是最新或首次克隆" -ForegroundColor Gray
    }
}

# ===== 第5步：显示工作区状态 =====
Write-Host "[5/5] 工作区状态：" -ForegroundColor Yellow
Write-Host "  目录: $(Get-Location)" -ForegroundColor Cyan
Write-Host "  最近提交：" -ForegroundColor Cyan
git log --oneline -3 2>$null | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
Write-Host ""
Write-Host "  工作区文件列表：" -ForegroundColor Cyan
Get-ChildItem -Name | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  ✓ 配置完成！" -ForegroundColor Green
Write-Host "  工作区路径: $WORK_DIR" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  1. 打开 WorkBuddy 桌面端" -ForegroundColor Gray
Write-Host "  2. 选择工作区: $WORK_DIR" -ForegroundColor Gray
Write-Host "  3. 开始工作！" -ForegroundColor Gray
Write-Host ""
pause
