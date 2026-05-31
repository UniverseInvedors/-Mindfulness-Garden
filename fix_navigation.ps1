# fix_navigation.ps1
Write-Host "🧭 Fixing Navigation Issues" -ForegroundColor Cyan

# Function to fix a file
function Fix-Navigation($filePath) {
    Write-Host "Checking $filePath..." -ForegroundColor Yellow
    $content = Get-Content $filePath -Raw
    $modified = $false
    
    # Add go_router import if missing and using context.pop
    if ($content -match "context\.pop\(\)" -and $content -notmatch "import 'package:go_router/go_router.dart'") {
        $content = "import 'package:go_router/go_router.dart';\n" + $content
        $modified = $true
        Write-Host "  ✅ Added go_router import" -ForegroundColor Green
    }
    
    # Replace Navigator.pop with context.pop
    if ($content -match "Navigator\.pop\(context\)") {
        $content = $content -replace 'Navigator\.pop\(context\)', 'context.pop()'
        $modified = $true
        Write-Host "  ✅ Replaced Navigator.pop with context.pop" -ForegroundColor Green
    }
    
    # Replace Navigator.pushNamed with context.go or context.push
    if ($content -match "Navigator\.pushNamed\(context, '([^']+)'\)") {
        $content = $content -replace 'Navigator\.pushNamed\(context, ''([^'']+)''\)', 'context.push(''$1'')'
        $modified = $true
        Write-Host "  ✅ Replaced Navigator.pushNamed with context.push" -ForegroundColor Green
    }
    
    # Replace Navigator.pushReplacementNamed with context.go
    if ($content -match "Navigator\.pushReplacementNamed\(context, '([^']+)'\)") {
        $content = $content -replace 'Navigator\.pushReplacementNamed\(context, ''([^'']+)''\)', 'context.go(''$1'')'
        $modified = $true
        Write-Host "  ✅ Replaced Navigator.pushReplacementNamed with context.go" -ForegroundColor Green
    }
    
    # Replace Navigator.popUntil with context.go
    if ($content -match "Navigator\.popUntil\(context, (.*)\)") {
        $content = $content -replace 'Navigator\.popUntil\(context, (.*)\)', '// TODO: Replace with proper navigation'
        $modified = $true
        Write-Host "  ⚠️ Found Navigator.popUntil - needs manual review" -ForegroundColor Yellow
    }
    
    if ($modified) {
        Set-Content $filePath $content
        Write-Host "  ✅ Updated $filePath" -ForegroundColor Green
    } else {
        Write-Host "  ✅ No navigation issues found" -ForegroundColor Green
    }
}

# Find all Dart files
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object { $_.Name -ne "app_router.dart" }

foreach ($file in $dartFiles) {
    Fix-Navigation $file.FullName
}

Write-Host "`n✅ Navigation fixes applied!" -ForegroundColor Green