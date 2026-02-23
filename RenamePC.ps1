param(
    [Parameter(Mandatory=$true)]
    [string]$Number
)
Write-Host "Zmieniam nazwe omputera na SP6-48705780-$Number: "
Rename-Computer -NewName "SP6-487-5780-$Number" -Force -Restart
