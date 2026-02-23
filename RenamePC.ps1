Write-Host "Zmieniam nazwe omputera na SP6-4870-5780-?? "
$inputNumber = Read-Host "Podaj numer:"
Rename-Computer -NewName "SP6-487-5780-$inputNumber" -Force -Restart
