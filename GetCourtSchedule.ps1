param(
    [string]$researchDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
)
try {
    . "$PSScriptRoot\Functions.ps1"

    Write-Output "Set-LogContext"
    Set-LogContext
    Start-Sleep -Milliseconds 100
    Write-Output "New-Token"
    New-Token
    Start-Sleep -Milliseconds 100
    Write-Output "Get-ScheduleCourts $($researchDate)"
    Get-ScheduleCourts -DateSearch "$($researchDate)T00:00:00"
    Start-Sleep -Milliseconds 100
    exit 0
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}