# Skrypt do automatycznego ustawienia czasu wyłączenia ekranów i przejścia w tryb uśpienia
# Jak i wyłączenia hybridboot/fastboot

Write-Host "Skrypt SetSleepTime v1.0"

Write-Host " - Uśpienie komputera po 1h"
powercfg /change standby-timeout-ac 60
powercfg /change standby-timeout-dc 60

Write-Host " - Wyłączenie ekranu po 45 min"
powercfg /change monitor-timeout-ac 45
powercfg /change monitor-timeout-dc 45

Write-Host " - Wyłączenie szybkiego uruchamiania"
powercfg /hibernate off
