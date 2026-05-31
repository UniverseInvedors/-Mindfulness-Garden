# fix_alert_dialog.ps1
$friendsFile = "lib/features/community/friends_screen.dart"
$content = Get-Content $friendsFile -Raw

# Fix the AlertDialog at line 649 - ensure all required parameters are provided
$pattern = 'AlertDialog\(\s*title: Text\([^)]+\),'
$replacement = 'AlertDialog(
        title: Text("Add Friend"),
        content: Text("Enter friend\s email:"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Add friend logic here
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],'
$content = $content -replace $pattern, $replacement
Set-Content $friendsFile $content
Write-Host "✅ Fixed AlertDialog in friends_screen.dart"