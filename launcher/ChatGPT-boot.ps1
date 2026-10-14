# ChatGPT Boot Overlay Launcher (ASCII only, UTF-8 BOM)
param(
  [ValidateSet("simple","full","off")][string]$Mode = "full",
  [string]$DelaySec = "1"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

function Get-CodexAumid {
  # AppUserModelID of the packaged ChatGPT desktop (OpenAI.Codex).
  $pkg = Get-AppxPackage -Name "OpenAI.Codex" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($pkg) { return ($pkg.Name + "_" + $pkg.PublisherId + "!App") }
  $sa = Get-StartApps -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq "ChatGPT" -and $_.AppID -like "OpenAI.Codex_*!App" } |
        Select-Object -First 1
  if ($sa) { return $sa.AppID }
  return $null
}

function Resolve-Codex {
  # UWP/Store app (this machine ships Codex inside the ChatGPT desktop app):
  # no .exe alias exists, so resolve via InstallLocation first, then WindowsApps aliases.
  $pkg = Get-AppxPackage -Name "OpenAI.Codex" -ErrorAction SilentlyContinue | Where-Object { $_.InstallLocation } | Select-Object -First 1
  if ($pkg -and $pkg.InstallLocation) {
    $exe = Join-Path $pkg.InstallLocation "app\ChatGPT.exe"
    if (Test-Path -LiteralPath $exe) { return $exe }
    $exe = Join-Path $pkg.InstallLocation "app\resources\codex.exe"
    if (Test-Path -LiteralPath $exe) { return $exe }
  }
  $candidates = @(
    (Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps\OpenAI.Codex.exe"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps\ChatGPT.exe")
  )
  foreach ($c in $candidates) { if (Test-Path -LiteralPath $c) { return $c } }
  return $null
}

function Launch-Codex {
  param([string]$Path)
  # Prefer launching by AppUserModelID via shell:AppsFolder: the packaged app
  # keeps its correct taskbar icon and grouping. Launching the raw WindowsApps
  # exe directly makes Windows show a blank taskbar icon.
  $aumid = Get-CodexAumid
  if ($aumid) {
    try {
      Start-Process -FilePath "explorer.exe" -ArgumentList ("shell:AppsFolder\" + $aumid) | Out-Null
      return $true
    } catch { }
  }
  # Fallback: if we resolved a real exe, Start-Process it.
  if ($Path -and (Test-Path -LiteralPath $Path)) {
    Start-Process -FilePath $Path | Out-Null
    return $true
  }
  return $false
}

function Launch-Overlay {
  param([string]$Url, [string]$Profile)
  $chrome = @(
    'C:\Program Files\Google\Chrome\Application\chrome.exe',
    'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
    'C:\Program Files\Microsoft\Edge\Application\msedge.exe'
  ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
  if (-not $chrome) { return $null }
  $browserArgs = @('--new-window','--kiosk','--start-maximized','--no-first-run','--no-default-browser-check',('--user-data-dir=' + $Profile),$Url)
  return Start-Process -FilePath $chrome -ArgumentList $browserArgs -PassThru
}

# ---- resolve target once ----
$exe = Resolve-Codex

# ---- Mode "off": no animation, just launch ChatGPT ----
if ($Mode -eq "off") {
  $launched = $false
  try { $launched = Launch-Codex -Path $exe } catch { }
  if (-not $launched) {
    [System.Windows.Forms.MessageBox]::Show("ChatGPT (OpenAI.Codex) not found.","ChatGPT Boot") | Out-Null
  }
  exit 0
}

# ---- open overlay in a clean fullscreen browser window ----
$overlay = Join-Path $PSScriptRoot '..\550c-overlay.html'
if (-not (Test-Path -LiteralPath $overlay)) {
  [System.Windows.Forms.MessageBox]::Show("Missing 550c-overlay.html.","ChatGPT Boot") | Out-Null
  try { [void](Launch-Codex -Path $exe) } catch { }
  exit 1
}

$url = ([System.Uri]$overlay).AbsoluteUri + '?mode=' + [uri]::EscapeDataString($Mode)
$profile = Join-Path $env:TEMP ('chatgpt-boot-' + [guid]::NewGuid().ToString('N'))
$p = Launch-Overlay -Url $url -Profile $profile

if (-not $p) {
  # No browser available: degrade gracefully, still open ChatGPT.
  [System.Windows.Forms.MessageBox]::Show("Chrome/Edge not found. Launching ChatGPT directly.","ChatGPT Boot") | Out-Null
  try { [void](Launch-Codex -Path $exe) } catch { }
  exit 0
}

# ---- wait for the animation to finish, then launch ChatGPT ----
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern int GetWindowText(System.IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);' -Name U32 -Namespace W -ErrorAction SilentlyContinue

$deadline = (Get-Date).AddSeconds(150)
$done = $false
while ((Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds 200
  if ($p.HasExited) { $done = $true; break }
  try {
    $w = $p.MainWindowHandle
    if ($w -ne [IntPtr]::Zero) {
      $sb = New-Object System.Text.StringBuilder 256
      [W.U32]::GetWindowText($w, $sb, 256) | Out-Null
      if ($sb.ToString() -like "*__550C_DONE__*") { $done = $true; break }
    }
  } catch { }
}

# Animation finished (done, skipped via Esc/click, or browser closed).
# Close the overlay first, then bring up ChatGPT so it appears only after the animation ends.
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds ([double]$DelaySec)
try { $codexLaunched = Launch-Codex -Path $exe } catch { $codexLaunched = $false }
if (-not $codexLaunched) {
  [System.Windows.Forms.MessageBox]::Show("ChatGPT (OpenAI.Codex) not found.","ChatGPT Boot") | Out-Null
}

Remove-Item -LiteralPath $profile -Recurse -Force -ErrorAction SilentlyContinue
