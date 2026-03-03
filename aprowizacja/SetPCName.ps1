# TODO: Zmiana nazwy komputera w zaleznosci czy to windows 10 czy windows 11
# Jesli ma to znaczenie XD
Write-Host "Skrypt SetPCName v0.1"
$inputNumber = Read-Host " - Podaj nowa nazwe komputera:"
Write-Host " - Zmieniam nazwe komputera na $inputNumber "
#Rename-Computer -NewName "$inputNumber" -Force -Restart
Rename-Computer -NewName "$inputNumber" -Force
Write-Host "Zakonczono SetPCName."
