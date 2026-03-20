
function Get-LogFileName {
    $LogFile = "logs\api-$(Get-Date -Format 'yyyy-MM-dd').log"
    return $LogFile
}
function Write-Log {
    param([string]$Message)
    $LogFile = Get-LogFileName
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    Add-Content -Path $LogFile -Value "[$timestamp] $Message"
}

function Set-LogContext {
    $LogFile = Get-LogFileName
    $logDir = Split-Path $LogFile -Parent
    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }
}

function Set-InitialParameters{
    param([string]$courtName,
    [string]$bookDate,
    [string]$initialTime,
    [string]$finalTime
    )
    $requestBookFile = "payload\requestBook.json"
    
    Write-Log "Read Request Book file $($requestBookFile)"
    $payloadRequestBook = Get-Content $requestBookFile -Raw | ConvertFrom-Json
    $payloadRequestBook.dependencia = $courtName
    $payloadRequestBook.horarioInicio = "$($bookDate)T$($initialTime):00"
    $payloadRequestBook.horarioFim = "$($bookDate)T$($finalTime):00"

    $json = $payloadRequestBook | ConvertTo-Json -Depth 50
    Set-Content -Path $requestBookFile -Value $json -Encoding UTF8

    $requestCourtBookFile = "payload\requestCourtBook.json"
    Write-Log "Read Request Book file $($requestCourtBookFile)"
    $payloadRequestCourtBook = Get-Content $requestCourtBookFile -Raw | ConvertFrom-Json
    $payloadRequestCourtBook.codigoDependencia = $courtName
    $payloadRequestCourtBook.dia = $bookDate
    $payloadRequestCourtBook.horaInicio = $initialTime
    $payloadRequestCourtBook.horaFim = $finalTime

    $json = $payloadRequestCourtBook | ConvertTo-Json -Depth 50
    Set-Content -Path $requestCourtBookFile -Value $json -Encoding UTF8
}

function Get-Header {
    $Headers = @{
        "Accept"       = "application/json"
        "Content-Type" = "application/json"
        "Tenant"       = "uniaocorinthians"
        "Referer"      = "https://uniaocorinthians.areadosocio.com.br/"
    }
    return $Headers
}

function Get-HeaderToken {
    param([string]$Token)
    $Headers = @{
        "Authorization" = "Bearer $Token"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
        "Tenant"        = "uniaocorinthians"
        "Referer"       = "https://uniaocorinthians.areadosocio.com.br/"
    }
    return $Headers
}

function Read-Token {
    $InputFileToken = "response\responseLogin.json"
    Write-Log "Reading Token from file: $($InputFileToken)"
    $Json = Get-Content $InputFileToken -Raw | ConvertFrom-Json
    $Token = $json.retorno.token.valor
    return $Token
}

function New-Token {
    $ApiUrl = "https://api-associados.areadosocio.com.br/api/Logins"
    $OutputFile = "response\responseLogin.json"
    $TimeoutSec = 30

    $response = $null
    try {
        $loginFileCredentials = "payload\login.json"
        Write-Log "Read Login Credentials from file $($loginFileCredentials)"
        $jsonBody = Get-Content $loginFileCredentials -Raw
        Write-Log "Attempt Calling API..."
        $Headers = Get-Header
        $response = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -Method POST -TimeoutSec $TimeoutSec -Body $jsonBody
        Write-Log "API call succeeded."
    }
    catch {
        Write-Log "Error: $($_.Exception.Message)"
        Start-Sleep -Seconds 5
    }

    if ($response) {
        $json = $response | ConvertTo-Json -Depth 50
        Set-Content -Path $OutputFile -Value $json -Encoding UTF8
        Write-Log "Response saved to $OutputFile"
    }
    else {
        Write-Log "API call failed after attempts."
    }
}

function Get-ScheduleCourts {
    param([string]$DateSearch)


    $OutputFile = "response\responseHorarios.json"
    $TimeoutSec = 30

    Set-LogContext
    $Token = Read-Token

    Write-Log "Calling API using Token: $Token"
    $HeadersHorarios = Get-HeaderToken -Token $Token
    $Uri = "https://api-associados.areadosocio.com.br/api/GruposDeDependencia/01/Horarios?data=$($DateSearch)"
    Write-Log "Uri: $Uri"
    $ResponseHorarios = Invoke-RestMethod -Uri $Uri -Headers $HeadersHorarios -Method GET -TimeoutSec $TimeoutSec
    $JsonHorarios = $ResponseHorarios | ConvertTo-Json -Depth 50
    Set-Content -Path $OutputFile -Value $JsonHorarios -Encoding UTF8
    Write-Log "Response Horarios saved to $OutputFile"
}

function Get-RequestBook {
    $ApiUrl = "https://api-associados.areadosocio.com.br/api/PedidosReserva"
    $OutputFile = "response\responseReqBook.json"
    $TimeoutSec = 30

    $Token = Read-Token

    $response = $null
    try {
        $requestBookFile = "payload\requestBook.json"
        Write-Log "Read Request Book file $($requestBookFile)"
        $jsonBody = Get-Content $requestBookFile -Raw
        Write-Log "Attempt Calling API..."
        $Headers = Get-HeaderToken -Token $Token
        $response = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -Method POST -TimeoutSec $TimeoutSec -Body $jsonBody
        Write-Log "API call succeeded."
    }
    catch {
        Write-Log "Error: $($_.Exception.Message)"
        Start-Sleep -Seconds 5
    }

    if ($response) {
        $json = $response | ConvertTo-Json -Depth 50
        Set-Content -Path $OutputFile -Value $json -Encoding UTF8
        Write-Log "Response saved to $OutputFile"
    }
    else {
        Write-Log "API call failed after attempts."
    }
}

function New-CourtBook {
    $ApiUrl = "https://api-associados.areadosocio.com.br/api/Reservas"
    $OutputFile = "response\responseCourtBook.json"
    $TimeoutSec = 30

    $Token = Read-Token
    $response = $null

    try {
        $resquestCourtBookFile = "payload\requestCourtBook.json"
        Write-Log "Reading IdPedido from response: $($resquestCourtBookFile)"
        $payload = Get-Content $resquestCourtBookFile -Raw | ConvertFrom-Json

        $responseReqBookFile = "response\responseReqBook.json"
        Write-Log "Reading IdPedido from response: $($responseReqBookFile)"
        $JsonResponseReqBook = Get-Content $responseReqBookFile -Raw | ConvertFrom-Json
        $idPedido = $JsonResponseReqBook.idPedido
        Write-Log "IdPedido: $($idPedido)"
        $payload.idPedido = $idPedido

        $jsonBody = $payload | ConvertTo-Json -Depth 50
        $Headers = Get-HeaderToken -Token $Token
        Write-Log "Payload: $($jsonBody)"

        #Waiting to run at 14H
        $target = Get-Next-14h
        $waitMs = [int][Math]::Ceiling(($target - (Get-Date)).TotalMilliseconds)
        Write-Log "Waiting -Milliseconds: $waitMs"
        Start-Sleep -Milliseconds $waitMs

        Write-Log "Attempt Calling API..."
        $response = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -Method POST -TimeoutSec $TimeoutSec -Body $jsonBody
        Write-Log "API call succeeded."
    }
    catch {
        Write-Log "Error: $($_.Exception.Message)"
        if($_.ErrorDetails){
            Write-Log "Error: $($_.ErrorDetails.Message)"
        }
    }

    if ($response) {
        $json = $response | ConvertTo-Json -Depth 50
        Set-Content -Path $OutputFile -Value $json -Encoding UTF8
        Write-Log "Response saved to $OutputFile"
    }
    else {
        Write-Log "API call failed after attempts."
    }
}
function Get-Next-14h {
    # Calcula o tempo em milliseconds que deve ser aguardado até as 14 horas
    $now   = Get-Date
    $today14 = Get-Date -Hour 14 -Minute 00 -Second 0 -Millisecond 0
    if ($now -lt $today14) { 
        return $today14 
    }
    else { 
        return $today14.AddDays(1) 
    }
}

function Get-Next-13h59m55s {
    # Calcula o tempo em milliseconds que deve ser aguardado até as 13 horas 59m 45s
    $now   = Get-Date
    $today14 = Get-Date -Hour 13 -Minute 59 -Second 45 -Millisecond 0
    if ($now -lt $today14) { 
        return $today14 
    }
    else { 
        return $today14.AddDays(1) 
    }
}
