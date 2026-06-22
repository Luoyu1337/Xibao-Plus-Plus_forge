# Scan repository for Fabric API usages and mixins
# Outputs: fabric_usage.txt, mixins_list.txt

$root = Get-Location
$patterns = @("net.fabricmc","fabric.api","ClientModInitializer","ModContainer","fabric.mod.json","@Mixin","mixins.json","@Environment","EnvType")

$outFabric = Join-Path $root 'fabric_usage.txt'
$outMixins = Join-Path $root 'mixins_list.txt'

if (Test-Path $outFabric) { Remove-Item $outFabric }
if (Test-Path $outMixins) { Remove-Item $outMixins }

Write-Output "Scanning for Fabric patterns in $root..."

Get-ChildItem -Recurse -File -Include *.java,*.kt,*.gradle,*.json,*.md,*.xml | ForEach-Object {
    $file = $_.FullName
    foreach ($p in $patterns) {
        $matches = Select-String -Path $file -Pattern $p -SimpleMatch -Quiet
        if ($matches) {
            Add-Content -Path $outFabric -Value "$p -> $file"
        }
    }
}

# Find mixin-related files
Get-ChildItem -Recurse -File -Include mixins.*.json,mixins.json,*.java,*.kt | ForEach-Object {
    $file = $_.FullName
    $hasMixin = Select-String -Path $file -Pattern '@Mixin|mixin' -Quiet
    if ($hasMixin) { Add-Content -Path $outMixins -Value $file }
}

Write-Output "Scan complete. Results saved to fabric_usage.txt and mixins_list.txt in $root."