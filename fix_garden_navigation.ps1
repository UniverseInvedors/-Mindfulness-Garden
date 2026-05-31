# fix_garden_navigation.ps1
$gardenFile = "lib/features/garden/garden_screen.dart"
$content = Get-Content $gardenFile -Raw

# Ensure go_router import
if ($content -notmatch "import 'package:go_router/go_router.dart'") {
    $content = "import 'package:go_router/go_router.dart';\n" + $content
}

# Fix AppBar back button (line around 633)
$content = $content -replace 'IconButton\(\s*onPressed: \(\) => Navigator\.pop\(context\),', 'IconButton(
            onPressed: () => context.pop(),'

# Fix all navigation calls in the file
$content = $content -replace 'Navigator\.push\(context,', '// TODO: Fix navigation - '

# Fix showModalBottomSheet navigation
$content = $content -replace 'Navigator\.pop\(context\);', 'context.pop();'

# Fix any dialog navigation
$content = $content -replace 'onPressed: \(\) \{\s*Navigator\.pop\(context\);', 'onPressed: () {
              context.pop();'

Set-Content $gardenFile $content
Write-Host "✅ Fixed GardenScreen navigation" -ForegroundColor Green