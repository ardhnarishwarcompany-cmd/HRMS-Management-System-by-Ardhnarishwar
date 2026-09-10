foreach ($p in 5000,5173,5174,5175,5176,5177,5178,5179,5180,8000) {
  try {
    $conn = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction Stop | Select-Object -First 1
    $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$($conn.OwningProcess)"
    $cwd = ""
    try { $cwd = (Get-Process -Id $conn.OwningProcess).Path } catch {}
    $title = ""
    try {
      $h = (Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 "http://localhost:$p/").Content
      $title = [regex]::Match($h, '<title>(.*?)</title>').Groups[1].Value
    } catch { $title = "no-html" }
    Write-Output ("{0} | pid {1} | {2} | {3}" -f $p, $conn.OwningProcess, $title, $proc.CommandLine)
  } catch {
    Write-Output ("{0} | not listening" -f $p)
  }
}
