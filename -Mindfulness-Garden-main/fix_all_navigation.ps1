# fix_all_navigation.ps1
Write-Host "🚀 Applying All Navigation Fixes" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Run all fix scripts
Write-Host "`n1. Fixing general navigation issues..." -ForegroundColor Cyan
& .\fix_navigation.ps1

Write-Host "`n2. Fixing GardenScreen..." -ForegroundColor Cyan
& .\fix_garden_navigation.ps1

Write-Host "`n3. Fixing MainMenu..." -ForegroundColor Cyan
& .\fix_main_menu.ps1

Write-Host "`n4. Updating router..." -ForegroundColor Cyan
& .\update_router.ps1

Write-Host "`n5. Fixing GardenScreen dispose..." -ForegroundColor Cyan
& .\fix_garden_dispose.ps1

Write-Host "`n✅ All navigation fixes applied!" -ForegroundColor Green
Write-Host "Now run: flutter clean && flutter pub get && flutter run" -ForegroundColor Cyan