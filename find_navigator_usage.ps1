# find_navigator_usage.ps1
Write-Host "🔍 Finding Navigator usage..." -ForegroundColor Cyan

$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"
$navigatorCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "Navigator\.") {
        $matches = [regex]::Matches($content, "Navigator\.[a-zA-Z]+")
        if ($matches.Count -gt 0) {
            Write-Host "`n📄 $($file.FullName):" -ForegroundColor Yellow
            foreach ($match in $matches | Select -Unique) {
                Write-Host "  - $match" -ForegroundColor Red
                $navigatorCount++
            }
        }
    }
}

Write-Host "`nFound $navigatorCount Navigator usages that need to be converted to GoRouter" -ForegroundColor Red