$o = @()
$o += '---ADMIN-API-JS-FULL---'
foreach ($f in @('admin\src\services\api.js','admin\src\services\api.jsx')) {
  if (Test-Path $f) { $o += ('=== ' + $f); $o += (Get-Content $f) }
}
$o += '---TOKEN-KEYS-USED-IN-ADMIN---'
Get-ChildItem admin\src -Recurse -Include *.js,*.jsx -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'node_modules' } | ForEach-Object {
  $m = Select-String -Path $_.FullName -Pattern 'localStorage\.(get|set|remove)Item' -ErrorAction SilentlyContinue
  if ($m) {
    $o += ('=== ' + ($_.FullName -replace '.*Merging\\',''))
    $o += ($m | ForEach-Object { '  ' + $_.LineNumber.ToString() + ':' + ($_.Line.Trim() -replace '\s+',' ') } | Select-Object -First 10)
  }
}
$o += '---LOGIN-PAGE-TOKEN-SAVE---'
Get-ChildItem admin\src -Recurse -Include *.jsx -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'node_modules' -and $_.Name -match 'ogin' } | ForEach-Object {
  $o += ('=== ' + ($_.FullName -replace '.*Merging\\',''))
  $o += (Select-String -Path $_.FullName -Pattern 'token|localStorage|role' -ErrorAction SilentlyContinue | ForEach-Object { '  ' + $_.LineNumber.ToString() + ':' + ($_.Line.Trim() -replace '\s+',' ') } | Select-Object -First 15)
}
$o | Out-File -Encoding utf8 probe_del8.txt
Write-Output DONE
