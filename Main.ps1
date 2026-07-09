param(
    [string]$courtName = "PADEL-1 ",
    [string]$bookDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd"),
    [string]$initialTime = "20:45",
    [string]$finalTime = "22:00"
)
try {
    . "$PSScriptRoot\Login.ps1"
    . "$PSScriptRoot\Functions.ps1"
    
    Write-Host "Starting application $(Get-Location)"
    Write-Host "Set-InitialParameters $($courtName) $($bookDate) $($initialTime) $($finalTime)"
    Set-InitialParameters -courtName $courtName -bookDate $bookDate -initialTime $initialTime -finalTime $finalTime
    Start-Sleep -Milliseconds 500
    Write-Host "Set-LogContext"
    Set-LogContext
    Start-Sleep -Milliseconds 100
    Write-Host "Get-TimeDifference"
    $timeDifference = Get-TimeDifference
    [Console]::ForegroundColor = "Red"
    Write-Host "Time Difference: $($timeDifference) ms"
    [Console]::ResetColor()
    Start-Sleep -Milliseconds 100

    #Waiting to run at 13H59M45s
    $target = Get-Next-13h59m45s
    if ($null -ne $target) {
        $waitMs = [int][Math]::Ceiling(($target - (Get-Date)).TotalMilliseconds)
        Write-Log "Waiting to start -Milliseconds: $waitMs"
        Write-Host "Waiting to start -Milliseconds: $waitMs"
        Start-Sleep -Milliseconds $waitMs
    }

    $fileTokenLogin = "response\responseLogin.json"
    $loginCredential = [Login]::new("82098700091", "e10adc3949ba59abbe56e057f20f883e")
    if(Test-Path $fileTokenLogin)
    {
        if ((Get-Item $fileTokenLogin).LastWriteTime -le (Get-Date).AddMinutes(-15)) 
        {
            Write-Host "New-Token"
            New-Token -Login $loginCredential
            Start-Sleep -Milliseconds 100
        }
    }
    else
    {
        Write-Host "New-Token"
        New-Token -Login $loginCredential
        Start-Sleep -Milliseconds 100
    }
    Write-Host "Get-RequestBook"
    Get-RequestBook
    Start-Sleep -Milliseconds 100
    Write-Host "New-CourtBook"
    New-CourtBook -timeDifference $timeDifference
    Write-Host "Application completed"
    Read-Host "Pressione qualquer tecla para sair"
    exit 0
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}