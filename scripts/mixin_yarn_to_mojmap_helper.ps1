# Extract mixin targets and produce a replacement checklist for Yarn -> Mojmap mapping
# Outputs: mixin_targets_raw.txt, mixin_targets_checklist.csv
# Run from repository root: \scripts\mixin_yarn_to_mojmap_helper.ps1

$root = Get-Location
$rawOut = Join-Path $root 'mixin_targets_raw.txt'
$csvOut = Join-Path $root 'mixin_targets_checklist.csv'

if (Test-Path $rawOut) { Remove-Item $rawOut }
if (Test-Path $csvOut) { Remove-Item $csvOut }

Write-Output "Scanning for mixin target strings..."

# Patterns to scan: mixins JSON 'target' fields, @Mixin annotations, INVOKE/target strings in code
Get-ChildItem -Recurse -File -Include mixins.*.json,mixins.json,*.java,*.kt,*.json | ForEach-Object {
    $file = $_.FullName
    try {
        $text = Get-Content -Raw -Path $file -ErrorAction Stop
    } catch { continue }
    # JSON 'target' fields and similar
    $jsonTargets = Select-String -InputObject $text -Pattern '"target"":?\s*"([^"]+)"' -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value }
    foreach ($t in $jsonTargets) { Add-Content -Path $rawOut -Value "$file : $t" }

    # mixin-style string tokens like net/minecraft/... or net.minecraft....
    $classLike = Select-String -InputObject $text -Pattern '(net\/minecraft\/[\w\/]+|net\.minecraft\.[\w\.]+)' -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
    foreach ($c in $classLike) { Add-Content -Path $rawOut -Value "$file : $c" }

    # @Mixin annotations targets: @Mixin(TargetClass.class)
    $annotation = Select-String -InputObject $text -Pattern '@Mixin\s*\(\s*([A-Za-z0-9_\.]+)\s*\.class' -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value }
    foreach ($a in $annotation) { Add-Content -Path $rawOut -Value "$file : $a" }
}

# Deduplicate and create CSV checklist
$entries = Get-Content $rawOut | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } | Sort-Object -Unique
"SourceFile,OriginalName,MojmapName,Status,Notes" | Out-File -FilePath $csvOut -Encoding UTF8
foreach ($e in $entries) {
    $parts = $e -split ' : '\n    $src = $parts[0]
    $orig = $parts[1]
    # Prepare CSV line: leave MojmapName empty for manual fill
    $line = '"' + ($src -replace '"','""') + '","' + ($orig -replace '"','""') + '",,"pending","Requires Yarn->Mojmap mapping"'
    Add-Content -Path $csvOut -Value $line
}

Write-Output "Done. Raw targets: $rawOut ; Checklist: $csvOut"
Write-Output "Next: provide a Yarn->Mojmap mapping table (CSV with columns Yarn,Mojmap) and I can generate patch replacements."