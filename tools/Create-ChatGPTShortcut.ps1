# Create-ChatGPTShortcut.ps1
# 在桌面创建「ChatGPT」快捷方式：指向本项目启动器，并设置 ChatGPT 图标。
# 任何人从 GitHub 下载本项目后，双击（或运行）本脚本即可生成带图标的桌面快捷方式。
# 用法:
#   powershell -NoProfile -ExecutionPolicy Bypass -File "Create-ChatGPTShortcut.ps1"
#   powershell -NoProfile -ExecutionPolicy Bypass -File "Create-ChatGPTShortcut.ps1" -Desktop

param(
  # 快捷方式放到哪个位置: Desktop(桌面) 或 Taskbar(任务栏，仅固定启动器 cmd，图标可自定义)
  [ValidateSet("Desktop","Taskbar")][string]$Location = "Desktop"
)

$ErrorActionPreference = "Stop"

# 项目根目录：本脚本位于 <repo>\tools 下
$root = Split-Path -Parent $PSScriptRoot
$cmd  = Join-Path $root "launcher\ChatGPT.cmd"
$icon = Join-Path $root "icons\icon-chatgpt.ico"

if (-not (Test-Path -LiteralPath $cmd)) {
  Write-Host "未找到启动器: $cmd" -ForegroundColor Red
  exit 1
}
if (-not (Test-Path -LiteralPath $icon)) {
  Write-Host "未找到图标: $icon" -ForegroundColor Yellow
  $icon = "$env:SystemRoot\System32\shell32.dll"
}

$shell = New-Object -ComObject WScript.Shell

if ($Location -eq "Desktop") {
  $desktop = [Environment]::GetFolderPath("Desktop")
  $lnkPath = Join-Path $desktop "ChatGPT.lnk"
  $sc = $shell.CreateShortcut($lnkPath)
  $sc.TargetPath = $env:ComSpec
  $sc.Arguments = "/c `"`"$cmd`"`""
  $sc.WorkingDirectory = $root
  $sc.IconLocation = "$icon,0"
  $sc.Description = "ChatGPT 550C Boot - 播放 550C 开机动画后启动 ChatGPT"
  $sc.Save()
  Write-Host "已创建桌面快捷方式: $lnkPath" -ForegroundColor Green
} else {
  # 任务栏固定比较特殊：直接把启动器 cmd 固定上去，图标取自 .ico 有限，这里给出提示
  $taskbar = Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
  if (-not (Test-Path -LiteralPath $taskbar)) { New-Item -ItemType Directory -Path $taskbar -Force | Out-Null }
  $lnkPath = Join-Path $taskbar "ChatGPT.lnk"
  $sc = $shell.CreateShortcut($lnkPath)
  $sc.TargetPath = $env:ComSpec
  $sc.Arguments = "/c `"`"$cmd`"`""
  $sc.WorkingDirectory = $root
  $sc.IconLocation = "$icon,0"
  $sc.Description = "ChatGPT 550C Boot"
  $sc.Save()
  Write-Host "已创建任务栏快捷方式: $lnkPath" -ForegroundColor Green
  Write-Host "若任务栏未显示，请重启资源管理器或手动固定。" -ForegroundColor Yellow
}

Write-Host "完成！双击桌面「ChatGPT」即可播放 550C 动画后启动 ChatGPT。" -ForegroundColor Cyan