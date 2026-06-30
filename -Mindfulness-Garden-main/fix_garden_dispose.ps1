# fix_garden_dispose.ps1
$gardenFile = "lib/features/garden/garden_screen.dart"
$content = Get-Content $gardenFile -Raw

# Add proper cleanup in dispose method
if ($content -match "void dispose\(\) \{[^}]*\}") {
    $disposePattern = 'void dispose\(\) \{(.*?)\}'
    $disposeReplacement = 'void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _updateTimer?.cancel();
    _inspirationTimer?.cancel();
    _audioService.stopAll();
    _saveGardenState();
    super.dispose();
  }'
    $content = $content -replace $disposePattern, $disposeReplacement
}

Set-Content $gardenFile $content
Write-Host "✅ Fixed GardenScreen dispose method" -ForegroundColor Green