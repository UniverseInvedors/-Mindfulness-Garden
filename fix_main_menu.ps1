# fix_main_menu.ps1
$mainMenuFile = "lib/presentation/screens/main_menu.dart"
$content = Get-Content $mainMenuFile -Raw

# Ensure go_router import (it should already be there)
if ($content -notmatch "import 'package:go_router/go_router.dart'") {
    $content = "import 'package:go_router/go_router.dart';\n" + $content
}

# Fix the modal bottom sheet navigation
$content = $content -replace 'onPressed: \(\) \{\s*Navigator\.pop\(context\);', 'onPressed: () {
                          context.pop();'

# Fix the dialog navigation
$content = $content -replace 'onPressed: \(\) => Navigator\.pop\(context\)', 'onPressed: () => context.pop()'

Set-Content $mainMenuFile $content
Write-Host "✅ Fixed MainMenu navigation" -ForegroundColor Green