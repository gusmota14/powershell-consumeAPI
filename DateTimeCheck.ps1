$timeLoad1 = Get-Date
Write-Output "Local Time Start: $($timeLoad1.ToString('HH:mm:ss'))"
$response = Invoke-WebRequest -Uri "https://www.horariodebrasilia.org/" -UseBasicParsing
$serverTime = [datetime]$response.Headers.Date
$timeLoad2 = Get-Date
$timeLoad = ($timeLoad2 - $timeLoad1).TotalMilliseconds

$dataPC1 = Get-Date
$diferenca = ($serverTime - $dataPC1).TotalMilliseconds

Write-Output "Local Time: $($dataPC1.ToString('HH:mm:ss fff'))"
Write-Output "Time Load Site: $($timeLoad) ms"
Write-Output "Time Difference: $($diferenca) ms"
$dataPC1 = $dataPC1.AddMilliseconds($diferenca)
$dataPC1 = $dataPC1.AddMilliseconds($timeLoad)

Write-Output "Site Time: $($serverTime.ToString('HH:mm:ss fff'))"
Write-Output "Local Time Update: $($dataPC1.ToString('HH:mm:ss fff'))"




#$dataPC1 = Get-Date
#$response = Invoke-RestMethod -Uri "https://timeapi.io/api/Time/current/zone?timeZone=America/Sao_Paulo"
#$dataAPI = Get-Date -Date $response.datetime
#
#Write-Output "API: $($dataAPI)"
#Write-Output "PC START 1: $($dataPC1.ToString('HH:mm:ss'))"
#$diferenca = ($dataAPI - $dataPC1).TotalMilliseconds
#$dataPC1 = $dataPC1.AddMilliseconds($diferenca)
#Write-Output "PC START 2: $($dataPC1.ToString('HH:mm:ss'))"
#Write-Output "Diferenca: $($diferenca)"
