param(
    [string]$horario = "20:45"
)

try {
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
    @{ Name = 'horario'; Expression = { $_.data } }
                
    Write-Output "Horario: $($horario)" 
    Write-Output $resultado
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    exit 1
}
