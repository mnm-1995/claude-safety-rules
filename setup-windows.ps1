# Claude Code 安全ガイドライン 自動取得セットアップ（Windows用）
# 実行方法: PowerShellを開いて setup-windows.ps1 を実行

$RuleUrl = "https://raw.githubusercontent.com/mnm-1995/claude-safety-rules/main/CLAUDE.md"
$TargetDir = "$env:USERPROFILE\.claude"
$TargetFile = "$TargetDir\CLAUDE.md"

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " Claude Code 安全ルール セットアップ" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# .claude フォルダを作成
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# 最新のCLAUDE.mdを取得
Write-Host "▶ 安全ルールを取得しています..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $RuleUrl -OutFile $TargetFile -UseBasicParsing
    Write-Host "✅ 取得完了しました" -ForegroundColor Green
} catch {
    Write-Host "❌ 取得に失敗しました。インターネット接続を確認してください" -ForegroundColor Red
    exit 1
}

# 毎朝9時に自動更新するタスクを登録
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -Command `"Invoke-WebRequest -Uri '$RuleUrl' -OutFile '$TargetFile' -UseBasicParsing`""

$Trigger = New-ScheduledTaskTrigger -Daily -At "09:00"

$Settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "ClaudeSafetyRulesUpdate" `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -Description "Claude Code安全ルールを毎朝GitHubから自動取得" `
    -Force | Out-Null

Write-Host "✅ 毎朝9時に自動更新する設定が完了しました" -ForegroundColor Green
Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host " セットアップ完了！" -ForegroundColor Cyan
Write-Host " Claude Codeを再起動すると有効になります" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
