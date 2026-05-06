param(
    [string]$researchDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
)
try {
    . "$PSScriptRoot\Login.ps1"
    . "$PSScriptRoot\Functions.ps1"

    $fileLogin = "response\responseLogin.json"
    $loginCredential = [Login]::new("00021519013", "e10adc3949ba59abbe56e057f20f883e")

    Write-Output "Set-LogContext"
    Set-LogContext
    Start-Sleep -Milliseconds 100
    if(Test-Path $fileLogin)
    {
        if ((Get-Item $fileLogin).LastWriteTime -le (Get-Date).AddMinutes(-15)) 
        {
            Write-Output "New-Token"
            New-Token -Login $loginCredential
            Start-Sleep -Milliseconds 100
        }
    }
    else{
        Write-Output "New-Token"
        New-Token -Login $loginCredential
        Start-Sleep -Milliseconds 100
    }
    Write-Output "Get-ScheduleCourts $($researchDate)"
    Get-ScheduleCourts -DateSearch "$($researchDate)T00:00:00"
    Write-Output "Application completed"
    Read-Host "Pressione qualquer tecla para sair"
    exit 0
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}