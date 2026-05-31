Write-Host "🔧 Fixing Mindfulness Garden App Issues" -ForegroundColor Cyan

# -------------------------------
# 1. Fix Hive Adapter Registration
# -------------------------------

$mainFile = "lib/main.dart"

if (Test-Path $mainFile) {

    Write-Host "📝 Checking Hive adapter registration..." -ForegroundColor Yellow
    $content = Get-Content $mainFile -Raw

    if ($content -notmatch "UserPreferencesAdapter\(\)") {

        $pattern = '(?s)Hive\s*\.\.registerAdapter\(UserModelAdapter\(\)\)\s*\.\.registerAdapter\(SessionModelAdapter\(\)\)\s*\.\.registerAdapter\(MoodModelAdapter\(\)\)\s*\.\.registerAdapter\(AchievementModelAdapter\(\)\)\s*;?'

        $replacement = @"
Hive
  ..registerAdapter(UserModelAdapter())
  ..registerAdapter(SessionModelAdapter())
  ..registerAdapter(MoodModelAdapter())
  ..registerAdapter(AchievementModelAdapter())
  ..registerAdapter(UserPreferencesAdapter());
"@

        $content = $content -replace $pattern, $replacement
        Set-Content $mainFile $content
        Write-Host "  ✅ UserPreferencesAdapter added" -ForegroundColor Green
    }
}

# -------------------------------
# 2. Fix Garden Screen Back Button
# -------------------------------

$gardenFile = "lib/features/garden/garden_screen.dart"

if (Test-Path $gardenFile) {

    Write-Host "🔙 Fixing garden screen navigation..." -ForegroundColor Yellow
    $gardenContent = Get-Content $gardenFile -Raw

    if ($gardenContent -notmatch "go_router") {
        $gardenContent = "import 'package:go_router/go_router.dart';`r`n" + $gardenContent
    }

    $gardenContent = $gardenContent -replace 'Navigator\.pop\(context\)', 'context.pop()'
    Set-Content $gardenFile $gardenContent

    Write-Host "  ✅ Garden screen fixed" -ForegroundColor Green
}

# -------------------------------
# 3. Add Missing Providers
# -------------------------------

if (Test-Path $mainFile) {

    Write-Host "🔄 Adding missing providers..." -ForegroundColor Yellow
    $content = Get-Content $mainFile -Raw

    $importsToAdd = @(
        "import 'package:mindfulness_garden/presentation/providers/challenge_provider.dart';",
        "import 'package:mindfulness_garden/presentation/providers/achievement_provider.dart';",
        "import 'package:mindfulness_garden/presentation/providers/mood_provider.dart';",
        "import 'package:mindfulness_garden/presentation/providers/session_provider.dart';",
        "import 'package:mindfulness_garden/presentation/providers/subscription_provider.dart';"
    )

    foreach ($import in $importsToAdd) {
        if ($content -notmatch [regex]::Escape($import)) {
            $content = $content -replace "(import.*app_router.*;)", "`$1`r`n$import"
        }
    }

    $providersPattern = '(?s)providers:\s*\[(.*?)\],'

    $providersReplacement = @"
providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
"@

    $content = $content -replace $providersPattern, $providersReplacement
    Set-Content $mainFile $content

    Write-Host "  ✅ Providers updated" -ForegroundColor Green
}

# -------------------------------
# 4. Create Asset Directories
# -------------------------------

Write-Host "📁 Ensuring asset folders exist..." -ForegroundColor Yellow

$directories = @(
    "assets/images",
    "assets/sounds",
    "assets/animations",
    "assets/fonts"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  ✅ Created $dir" -ForegroundColor Green
    }
}

# -------------------------------
# 5. Clean & Reinstall Flutter
# -------------------------------

Write-Host ""
Write-Host "🧹 Cleaning Flutter project..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "🚀 Running App..." -ForegroundColor Yellow
flutter run

Write-Host ""
Write-Host "✅ All fixes applied successfully!" -ForegroundColor Green