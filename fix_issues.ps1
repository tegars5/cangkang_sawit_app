# PowerShell script untuk memperbaiki semua issues dengan best practices
# Jalankan di root project

Write-Host "Starting comprehensive fixes..." -ForegroundColor Green

# 1. Fix CacheException message parameter (change 'message' to positional parameter)
Write-Host "`n1. Fixing CacheException calls..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'CacheException\(message:') {
        $content = $content -replace 'CacheException\(message:\s*([^)]+)\)', 'CacheException($1)'
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "  Fixed: $($_.FullName)" -ForegroundColor Cyan
    }
}

# 2. Fix unnecessary imports (state_notifier)
Write-Host "`n2. Removing unnecessary state_notifier imports..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*_notifier.dart" -Recurse | ForEach-Object {
    (Get-Content $_.FullName) | Where-Object { $_ -notmatch "import 'package:state_notifier/state_notifier.dart';" } | Set-Content $_.FullName
}

# 3. Remove unused imports
Write-Host "`n3. Removing specific unused imports..." -ForegroundColor Yellow
# Remove unused flutter_riverpod import from product_notifier
$file = "lib\features\products\presentation\providers\product_notifier.dart"
if (Test-Path $file) {
    (Get-Content $file) | Where-Object { $_ -notmatch "import 'package:flutter_riverpod/flutter_riverpod.dart';" } | Set-Content $file
}

# 4. Fix deprecated Radio activeColor
Write-Host "`n4. Fixing deprecated Radio activeColor..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    (Get-Content $_.FullName) -replace 'activeColor:', 'activeThumbColor:' | Set-Content $_.FullName
}

# 5. Fix deprecated TextFormField value
Write-Host "`n5. Fixing deprecated TextFormField value parameter..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'value:') {
        $content = $content -replace '(\s+)value:', '$1initialValue:'
        Set-Content -Path $_.FullName -Value $content -NoNewline
    }
}

# 6. Add super_parameters where applicable (failures.dart)
Write-Host "`n6. Converting to super parameters in failures.dart..." -ForegroundColor Yellow
$failuresFile = "lib\core\error\failures.dart"
if (Test-Path $failuresFile) {
    $content = Get-Content $failuresFile -Raw
    $content = $content -replace '(\w+Failure)\(\{[\r\n\s]*required String message,[\r\n\s]*\}\)\s*:\s*super\(message\);', '$1({required super.message});'
    Set-Content -Path $failuresFile -Value $content -NoNewline
}

# 7. Add curly braces to single-line if statements in core/repositories
Write-Host "`n7. Adding curly braces to if statements..." -ForegroundColor Yellow
$coreRepoFile = "lib\core\repositories\shipment_repository.dart"
if (Test-Path $coreRepoFile) {
    $lines = Get-Content $coreRepoFile
    $newLines = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*if\s*\([^)]+\)\s*[^{]') {
            # Single line if without braces
            $nextLine = $lines[$i+1]
            if ($nextLine -notmatch '^\s*{') {
                $newLines += $line -replace '(if\s*\([^)]+\))\s*(.+)', '$1 { $2 }'
                continue
            }
        }
        $newLines += $line
    }
    $newLines | Set-Content $coreRepoFile
}

Write-Host "`n✓ All fixes applied!" -ForegroundColor Green
Write-Host "`nPlease run flutter analyze again to see remaining issues." -ForegroundColor Cyan
