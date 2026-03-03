# Skrypt
Write-Host "Skrypt SetPolishTime v1.0"

# TODO: Ustawienie na sztywno polskiej strefy czasowej
Write-Host " - Ustawienie usługi automatycznej strefy czasowej jako Automatyczna"
sc.exe config tzautoupdate start=auto
Start-Service tzautoupdate

Write-Host " - Sprawdzenie statusu"
sc.exe query tzautoupdate

Write-Host " - Wymuszenie synchronizacji czasu"
net stop w32time
net start w32time
w32tm /resync /force

Write-Host "Zakonczono SetPolishTime."
