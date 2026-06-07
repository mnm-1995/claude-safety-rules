# Claude Code 安全ガイドライン セットアップ（Windows用）
# 実行方法: このファイルを右クリック →「PowerShellで実行」

$RuleUrl = "https://raw.githubusercontent.com/mnm-1995/claude-safety-rules/main/CLAUDE.md"
$TargetDir = "$env:USERPROFILE\.claude"
$TargetFile = "$TargetDir\CLAUDE.md"
$ProfilePath = $PROFILE

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " Claude Code 安全ルール セットアップ" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# .claude フォルダを作成
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# 最新のCLAUDE.mdを今すぐ取得
Write-Host "▶ 安全ルールを取得しています..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $RuleUrl -OutFile $TargetFile -UseBasicParsing
    Write-Host "✅ 取得完了しました" -ForegroundColor Green
} catch {
    Write-Host "❌ 取得に失敗しました。インターネット接続を確認してください" -ForegroundColor Red
    exit 1
}

# PowerShellプロファイルに claude 起動時の自動更新を登録
$WrapperCode = @'

# Claude Code 起動時に安全ルールを自動更新
function claude {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/mnm-1995/claude-safety-rules/main/CLAUDE.md" `
        -OutFile "$env:USERPROFILE\.claude\CLAUDE.md" -UseBasicParsing -ErrorAction SilentlyContinue
    & claude.exe @args
}
'@

# プロファイルフォルダがなければ作成
$ProfileDir = Split-Path $ProfilePath
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir | Out-Null
}

# すでに登録済みでなければ追加
$ProfileContent = if (Test-Path $ProfilePath) { Get-Content $ProfilePath -Raw } else { "" }
if ($ProfileContent -notlike "*claude-safety-rules*") {
    Add-Content -Path $ProfilePath -Value $WrapperCode
    Write-Host "✅ Claude Code起動時に自動更新する設定が完了しました" -ForegroundColor Green
} else {
    Write-Host "✅ 自動更新の設定はすでに済んでいます" -ForegroundColor Green
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host " セットアップ完了！" -ForegroundColor Cyan
Write-Host " PowerShellを再起動してから claude を起動してください" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
