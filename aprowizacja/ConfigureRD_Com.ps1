# ==========================================
# RustDesk - migracja do własnego serwera
# ==========================================

$IDServer = "rd.competens.pl"
$Key = "AaZoQbR4W6eqOMXykW5dvSvxFJYfe2PcVuwgplIWfEA="

# Sprawdzenie uprawnień administratora
$Admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $Admin) {
    Write-Host "Uruchom PowerShell jako administrator!" -ForegroundColor Red
    exit 1
}

# Potwierdzenie
Write-Host "`nKonfiguracja RustDesk zostanie zmieniona." -ForegroundColor Yellow
Write-Host "Nowy ID Server: $IDServer"

# Wyszukanie RustDesk
$Paths = @(
    "$env:ProgramFiles\RustDesk\rustdesk.exe",
    "${env:ProgramFiles(x86)}\RustDesk\rustdesk.exe"
)

$RustDesk = $Paths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $RustDesk) {
    Write-Host "Nie znaleziono zainstalowanego RustDesk." -ForegroundColor Red
    exit 1
}

# Konfiguracja serwera
Write-Host "`nUstawianie ID Server..."
Write-Host "$IDServer"
& $RustDesk --option custom-rendezvous-server $IDServer

Write-Host "Ustawianie Key..."
& $RustDesk --option key $Key

Write-Host "`nKonfiguracja zapisana." -ForegroundColor Green
