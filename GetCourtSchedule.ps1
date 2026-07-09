param(
    [string]$researchDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
)
try {
    . "$PSScriptRoot\Login.ps1"
    . "$PSScriptRoot\Functions.ps1"

    $fileTokenLogin = "response\responseLogin.json"
    $loginCredential = [Login]::new("82098700091", "e10adc3949ba59abbe56e057f20f883e")

    Write-Host "Set-LogContext $(Get-Location)"
    Set-LogContext
    Start-Sleep -Milliseconds 100
    Get-TimeDifference
    if(Test-Path $fileTokenLogin)
    {
        if ((Get-Item $fileTokenLogin).LastWriteTime -le (Get-Date).AddMinutes(-15)) 
        {
            Write-Host "New-Token"
            New-Token -Login $loginCredential
            Start-Sleep -Milliseconds 100
        }
    }
    else{
        Write-Host "New-Token"
        New-Token -Login $loginCredential
        Start-Sleep -Milliseconds 100
    }
    Write-Host "Get-ScheduleCourts $($researchDate)"
    Get-ScheduleCourts -DateSearch "$($researchDate)T00:00:00"
    Write-Host "Application completed"
    Read-Host "Pressione qualquer tecla para sair"
    exit 0
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}