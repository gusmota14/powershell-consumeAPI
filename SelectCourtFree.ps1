param(
    [string]$horario = "20:45"
)

try {
    . "$PSScriptRoot\Functions.ps1"

    Write-Output "Set-LogContext"
    Set-LogContext
    $responseHorarioFile = "response\responseHorarios.json"
    # Carrega o JSON
    $elementos = Get-Content $responseHorarioFile -Raw | ConvertFrom-Json
    # Filtra elementos que tenham pelo menos um horário com status "livre"
    $resultado =
    $elementos.gradeHorarios |
    Where-Object {
        $_.horarios | Where-Object { 
            $_.status -ieq 'Livre' -and
            $_.horaInicial -ieq $horario
        }
    } |
    Select-Object  @{ Name = 'codigo'; Expression = { $_.dependencia.codigo } },
    @{ Name = 'data'; Expression = { $_.data } }
                
    Write-Output "Horario: $($horario)" 
    Write-Output $resultado
    Write-Log "Horario: $($horario)" 
    $resultado | ForEach-Object {
        $linha = "codigo={0} data={1}" -f 
        $_.codigo,
        $_.data
        Write-Log $linha
    }
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}
