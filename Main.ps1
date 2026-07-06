param(
    [string]$courtName = "PADEL-5 ",
    [string]$bookDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd"),
    [string]$initialTime = "20:45",
    [string]$finalTime = "22:00"
)
try {
    . "$PSScriptRoot\Login.ps1"
    . "$PSScriptRoot\Functions.ps1"
    
    Write-Output "Starting application $(Get-Location)"
    Write-Output "Set-InitialParameters $($courtName) $($bookDate) $($initialTime) $($finalTime)"
    Set-InitialParameters -courtName $courtName -bookDate $bookDate -initialTime $initialTime -finalTime $finalTime
    Start-Sleep -Milliseconds 500
    Write-Output "Set-LogContext"
    Set-LogContext
    Start-Sleep -Milliseconds 100
    Write-Output "Get-TimeDifference"
    $timeDifference = Get-TimeDifference
    [Console]::ForegroundColor = "Red"
    Write-Output "Time Difference: $($timeDifference) ms"
    [Console]::ResetColor()
    Write-Log "Time Difference: $($timeDifference) ms"
    Start-Sleep -Milliseconds 100

    #Waiting to run at 13H59M55s
    $target = Get-Next-13h59m55s -timeDifference $timeDifference
    if ($null -ne $target) {
        $waitMs = [int][Math]::Ceiling(($target - (Get-Date)).TotalMilliseconds)
        Write-Log "Waiting to start -Milliseconds: $waitMs"
        Start-Sleep -Milliseconds $waitMs
    }

    $fileTokenLogin = "response\responseLogin.json"
    $loginCredential = [Login]::new("*", "e10adc3949ba59abbe56e057f20f883e")
    if(Test-Path $fileTokenLogin)
    {
        if ((Get-Item $fileTokenLogin).LastWriteTime -le (Get-Date).AddMinutes(-15)) 
        {
            Write-Output "New-Token"
            New-Token -Login $loginCredential
            Start-Sleep -Milliseconds 100
        }
    }
    else
    {
        Write-Output "New-Token"
        New-Token -Login $loginCredential
        Start-Sleep -Milliseconds 100
    }
    Write-Output "Get-RequestBook"
    Get-RequestBook
    Start-Sleep -Milliseconds 100
    Write-Output "New-CourtBook"
    New-CourtBook -timeDifference $timeDifference
    Write-Output "Application completed"
    Read-Host "Pressione qualquer tecla para sair"
    exit 0
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}