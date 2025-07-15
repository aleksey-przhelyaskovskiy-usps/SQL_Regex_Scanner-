param (
  [string]$RulesFile,
  [string]$ZipFile,
  [string]$OutputFile = "scan_report.json"
)

$WorkDir = "sql_scan_tmp"
Remove-Item -Recurse -Force $WorkDir -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $WorkDir | Out-Null

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $WorkDir)

$rules = Get-Content $RulesFile | Where-Object { $_ -and $_ -notmatch '^\s*#' }
$matches = @()
$found = $false

Write-Host "🔍 Scanning SQL files using rules from $RulesFile..."

Get-ChildItem -Path $WorkDir -Recurse -Filter *.sql | ForEach-Object {
  $file = $_.FullName
  $lines = Get-Content $file
  for ($i = 0; $i -lt $lines.Count; $i++) {
    foreach ($rule in $rules) {
      if ($lines[$i] -match $rule) {
        $found = $true
        $matches += [PSCustomObject]@{
          file = $file
          line = $i + 1
          rule = $rule
        }
        Write-Host "❗ Match in $file:$($i+1) — $($lines[$i])"
      }
    }
  }
}

$matches | ConvertTo-Json -Depth 3 | Set-Content $OutputFile -Encoding UTF8
Write-Host "📄 Report written to: $OutputFile"

if ($found) {
  Write-Host "❌ Violations found"
  exit 1
} else {
  Write-Host "✅ No matches found"
  exit 0
}
