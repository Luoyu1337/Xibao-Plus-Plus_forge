<#
PowerShell script to run Gradle wrapper build and collect logs.
Usage:
  - Place this script at repo root and run in PowerShell:
    .\scripts\build_and_collect_logs.ps1 -ProjectPath . -ModulePath 'Forge-1.20.1' -LogFile build_log.txt

It will run gradlew if present, otherwise instruct user to install gradle or create wrapper.
#>
param(
    [string]$ProjectPath = ".",
    [string]$ModulePath = "Forge-1.20.1",
    [string]$LogFile = "build_log.txt"
)

Push-Location $ProjectPath
try {
    if (Test-Path "./gradlew" -PathType Leaf -or Test-Path "./gradlew.bat") {
        Write-Output "Using existing Gradle wrapper. Running build..."
        $cmd = ".\gradlew :$ModulePath:build --no-daemon"
    }
    else {
        Write-Output "No gradle wrapper found. Checking for system gradle..."
        $g = Get-Command gradle -ErrorAction SilentlyContinue
        if ($null -ne $g) {
            Write-Output "System Gradle found. Generating wrapper..."
            gradle wrapper --gradle-version 8.3
            $cmd = ".\gradlew :$ModulePath:build --no-daemon"
        }
        else {
            Write-Error "Neither gradle wrapper nor system gradle found. Please install Gradle or generate wrapper locally. See README.forge-migration.md"
            exit 2
        }
    }

    Write-Output "Running: $cmd"
    # Run and capture output
    $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -RedirectStandardOutput "$LogFile" -RedirectStandardError "$LogFile" -Wait -PassThru
    if ($proc.ExitCode -eq 0) { Write-Output "Build finished successfully. Log: $LogFile" } else { Write-Output "Build failed (exit $($proc.ExitCode)). See log: $LogFile" }
}
finally {
    Pop-Location
}
