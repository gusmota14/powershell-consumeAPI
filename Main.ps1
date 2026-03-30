param(
    [string]$courtName = "PADEL-4 ",
    [string]$bookDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd"),
    [string]$initialTime = "19:30",
    [string]$finalTime = "20:45"
)
try {
    . "$PSScriptRoot\Functions.ps1"

    Write-Output "Starting application"
    Write-Output "Set-InitialParameters $($courtName) $($bookDate) $($initialTime) $($finalTime)"
    Set-InitialParameters -courtName $courtName -bookDate $bookDate -initialTime $initialTime -finalTime $finalTime
    Start-Sleep -Milliseconds 500
    Write-Output "Set-LogContext"
    Set-LogContext
    Start-Sleep -Milliseconds 100
    Write-Log "Set-InitialParameters $($courtName) $($bookDate) $($initialTime) $($finalTime)"
    Start-Sleep -Milliseconds 100

    #Waiting to run at 13H59M55s
    $target = Get-Next-13h59m55s
    if ($null -ne $target) {
        $waitMs = [int][Math]::Ceiling(($target - (Get-Date)).TotalMilliseconds)
        Write-Log "Waiting to start -Milliseconds: $waitMs"
        Start-Sleep -Milliseconds $waitMs
    }

    Write-Output "New-Token"
    New-Token
    Start-Sleep -Milliseconds 100
    Write-Output "Get-RequestBook"
    Get-RequestBook
    Start-Sleep -Milliseconds 100
    Write-Output "New-CourtBook"
    New-CourtBook
    Write-Output "Application completed"
    exit 0
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}


