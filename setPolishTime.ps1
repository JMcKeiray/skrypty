# Skrypt

Write-host Ustawienie usługi automatycznej strefy czasowej jako Automatyczna (bez ręcznego startu)
sc.exe config tzautoupdate start=auto
Start-Service tzautoupdate

Write-host Sprawdzenie statusu
sc.exe query tzautoupdate

Write-host Wymuszenie synchronizacji czasu
net stop w32time
net start w32time
w32tm /resync /force

Write-host Uśpienie komputera po 1h (AC i DC)
powercfg /change standby-timeout-ac 60
powercfg /change standby-timeout-dc 60

Write-host Wyłączenie ekranu po 45 min (AC i DC)
powercfg /change monitor-timeout-ac 45
powercfg /change monitor-timeout-dc 45

Write-host Wyłączenie szybkiego uruchamiania
powercfg /hibernate off

Write-host Zakonczono.
