# Skrypt

# Ustawienie usługi automatycznej strefy czasowej jako Automatyczna (bez ręcznego startu)
sc.exe config tzautoupdate start=auto
Start-Service tzautoupdate

# Sprawdzenie statusu
sc.exe query tzautoupdate

# Wymuszenie synchronizacji czasu
net stop w32time
net start w32time
w32tm /resync /force

# Uśpienie komputera po 1h (AC i DC)
powercfg /change standby-timeout-ac 60
powercfg /change standby-timeout-dc 60

# Wyłączenie ekranu po 45 min (AC i DC)
powercfg /change monitor-timeout-ac 45
powercfg /change monitor-timeout-dc 45

# Wyłączenie szybkiego uruchamiania
powercfg /hibernate off
