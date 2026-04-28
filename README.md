# powershell-consumeAPI
Scripts to consume a API via powerShell scripts

## What it must be do before to try to run the scripts
It is necessary to change the files below:
-   login.json
-   requestBook.json
-   requestCourtBook.json

In the `login.json` file the properties `username`, `senha` and `senhaSociety` will need to replace with your informations.
In the `requestBook.json` and `requestCourtBook.json` the property `matricula` will need to replace with your information.

## How to use the scripts
You need to have install the PowerShell before and use the bellow scripts:

### Command to get the game court scheduler by date:
#### Step 1
```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Desenv\Controle\powershell-consumeAPI\GetCourtSchedule.ps1" -researchDate "2026-03-22"
```
#### Step 2 (Command to check what game courts are free)
```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Desenv\Controle\powershell-consumeAPI\SelectCourtFree.ps1" -initialTime "20:45"
```
### Command to book a game court at the time choice:
```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Desenv\Controle\powershell-consumeAPI\Main.ps1" -courtName "PADEL-1 " -initialTime "19:30" -finalTime "20:45"
```