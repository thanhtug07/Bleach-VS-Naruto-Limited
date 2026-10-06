# Hien dia chi Cloudflare Tunnel cong khai cho server netplay (port 21337).
# Chay tren MAY CHU sau khi mo game. Gi nguyen cua so nay mo trong luc choi.
$ErrorActionPreference = 'SilentlyContinue'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $dir 'tools\cloudflared.exe'
$out = Join-Path $dir 'server.txt'
if (!(Test-Path $exe)) {
  Write-Host 'Thieu tools\cloudflared.exe. Tai tai: https://github.com/cloudflare/cloudflared/releases'
  pause; exit 1
}
# Server phai dang chay (launcher tu mo) - doi toi da 20s
for ($i = 0; $i -lt 20; $i++) {
  try {
    $c = New-Object Net.Sockets.TcpClient
    $c.Connect('127.0.0.1', 21337)
    $c.Close()
    break
  } catch { Start-Sleep -Seconds 1 }
}
Write-Host 'Dang mo tunnel... (giu cua so nay mo)'
& $exe tunnel --url tcp://127.0.0.1:21337 2>&1 | ForEach-Object {
  $line = $_.ToString()
  Write-Host $line
  if ($line -match 'tcp://([A-Za-z0-9.\-]+):(\d+)') {
    ($Matches[1] + ':' + $Matches[2]) | Out-File -Encoding ASCII -NoNewline $out
    Write-Host ''
    Write-Host ('>>> DIA CHI CONG KHAI: ' + $Matches[1] + ':' + $Matches[2])
    Write-Host '>>> Gui dia chi nay cho ban. Ban nhap vao o IP roi bam Tim phong.'
  }
}
