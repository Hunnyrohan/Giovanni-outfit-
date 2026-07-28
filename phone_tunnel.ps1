# Keeps the phone->PC backend tunnel alive across USB reconnects.
#
# OPTIONAL. The app no longer depends on this tunnel: ApiHostResolver probes
# 10.0.2.2 (emulator), 127.0.0.1 (this tunnel) and the LAN IP at startup, and
# re-probes whenever a request can't reach the backend. Losing the tunnel is
# no longer what caused "No internet connection or server unreachable".
#
# It is still the fastest path for a real phone tethered over USB, where
#   adb reverse tcp:3000 tcp:3000   (phone's 127.0.0.1:3000 -> PC's :3000)
# avoids depending on the LAN IP and the Windows firewall. That mapping dies
# every time the USB connection drops. Run this script in its own terminal and
# leave it running - it re-creates the tunnel automatically on every reconnect.
#
#   powershell -ExecutionPolicy Bypass -File .\phone_tunnel.ps1

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

Write-Host "Watching for the phone; tunnel will be (re)created automatically." -ForegroundColor Cyan
Write-Host "Leave this window open while developing. Ctrl+C to stop." -ForegroundColor Cyan

while ($true) {
    & $adb wait-for-device 2>$null
    & $adb reverse tcp:3000 tcp:3000 2>$null | Out-Null
    $list = (& $adb reverse --list 2>$null)
    if ($list -match 'tcp:3000') {
        Write-Host "[$(Get-Date -Format HH:mm:ss)] tunnel active (phone 127.0.0.1:3000 -> PC :3000)" -ForegroundColor Green
    }
    # Block until the device drops, then loop back to wait-for-device.
    while ((& $adb get-state 2>$null) -eq 'device') {
        Start-Sleep -Seconds 2
    }
    Write-Host "[$(Get-Date -Format HH:mm:ss)] phone disconnected - waiting for it to come back..." -ForegroundColor Yellow
}
