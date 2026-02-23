Write-Host "Dokoncz nazwe komputera SP6-48705780-??: "
$inputNumber = Read-Host "Wpisz: "
Rename-Computer -NewName "SP6-487-5780-$inputNumber" -Force -Restart
