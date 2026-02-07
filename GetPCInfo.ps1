# Wiadomosc powitalna
Clear-Host
Write-Host ===================================
Write-Host ========== GetPCInfo.ps1 ==========
Write-Host ============ Ver: 0.6v ============
Write-Host 

# Zmienne
$separator = ";"
$apps = @("firefox","chrome","libre","thunderbird","Office","ose","adobe","dell","rustdesk","anydesk","synology")

# Wrapper funkcji dla kompatybilnosci ze starszymi wersjami powershelld
function Get-SystemObject {
    param([String]$ClassName)

    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        Get-CimInstance -CimSession $cimSession -ClassName $ClassName -ErrorAction SilentlyContinue
    } else {
        Get-WmiObject -Class $ClassName
    }
}
# Jakby tak powershell jednak byl nowszy, ustaw zmienna globalna dla Cim
$script:cimSession = ""
if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        $cimSession = New-CimSession
    } else {
        Write-Host ! Wykryto starsza wersje Powershell !
        Write-Host ! Nie wszystkie funkcje mogą zadziałać !
    }

# Uruchomienie skryptu
Write-Host "* Trwa zbieranie informacji..."
# Utworzenie pliku
$OutFile = '.\' + (Get-SystemObject CIM_ComputerSystem).Name + '_(' + (Get-Date -Format "yyyy-MM-dd") + ').txt'
Out-File $OutFile

# Zbieranie Informacji
Write-Host " - o sprzecie..."
$infoTable = [ordered]@{}
$infoTable["Nazwa Komputera"] = (Get-SystemObject CIM_ComputerSystem).Name
$infoTable["Lokalizacja"] = ""
$infoTable["Typ"] = if ((Get-SystemObject Win32_SystemEnclosure).ChassisTypes -match '8|9|10|14|30') { "Przenosny" } else { "Stacjonarny" }
$infoTable["Producent"] = (Get-SystemObject CIM_ComputerSystem).Manufacturer
$infoTable["Model"] = (Get-SystemObject CIM_ComputerSystem).Model
$infoTable["Serial / ServiceTag"] = (Get-SystemObject CIM_BIOSElement).SerialNumber
$infoTable["Procesor"] = (Get-SystemObject Win32_Processor | Select-Object -First 1).Name
$infoTable["Karta Graficzna"] = (Get-SystemObject Win32_VideoController | Select-Object -ExpandProperty Name) -join ", "
$infoTable["RAM"] = [math]::Round((((Get-SystemObject Win32_ComputerSystem).TotalPhysicalMemory) / 1GB), 0).ToString() + " GB"
$infoTable["System"] = (Get-SystemObject Win32_OperatingSystem).Caption + " " + (Get-SystemObject Win32_OperatingSystem).OSArchitecture
$infoTable["Grupa / Domena"] = (Get-SystemObject CIM_ComputerSystem).Domain
$infoTable["Adres IP"] = "{0} ({1})" -f ((Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.*' -and $_.InterfaceAlias -notmatch 'Loopback|isatap' } | Select-Object -First 1).IPAddress), ($(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway }).DhcpEnabled -contains $true | ForEach-Object { if ($_){'Statyczny'} else {'DHCP'} })
if (@(Get-SystemObject Win32_DiskDrive).Count -gt 0) {
    foreach ($disk in (@(Get-SystemObject Win32_DiskDrive) | Where-Object {$_.InterfaceType -ne "USB"})  ) {
        $infoTable["Dysk$($disk.index)"] = "$($disk.Model) ($([math]::Round($disk.Size/1GB))GB)"
    }
}
if ((Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams | Select-Object -ExpandProperty VideoOutputTechnology) -contains 5) {
    $infoTable["Monitor"] = "Wbudowany"
} elseif ((Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams | Select-Object -ExpandProperty VideoOutputTechnology) -match 4294967295) {
    $infoTable["Monitor"] = "Wirtualny"
} else {
    $infoTable["Monitor"] = (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | ForEach-Object {
        "{0} {1}" -f
        ([System.Text.Encoding]::ASCII.GetString($_.ManufacturerName).Trim([char]0)),
        ([System.Text.Encoding]::ASCII.GetString($_.UserFriendlyName).Trim([char]0))
    })
}
$infoTable["Klawiatura"] = ""
$infoTable["Mysz"] = ""

# Oprogramowanie
Write-Host " - o aplikacjach..."
$paths = @(
"HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
"HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$appTable = Get-ItemProperty $paths | Where-Object {
    $name = $_.DisplayName
    $name -and ($apps | Where-Object { $name -like "*$_*" })
} | Select-Object -ExpandProperty DisplayName | Sort-Object -Unique

# Lista Uzytkownikow
Write-Host " - o uzytkownikach..."
$userTable = @{}
$i = 1

Get-SystemObject Win32_UserAccount -Filter "LocalAccount=True AND Disabled=False" |
Where-Object { $_.Name -notin @('Administrator','Gość','DefaultAccount','WDAGUtilityAccount') } |
ForEach-Object {
    $userTable[$i] = if ([string]::IsNullOrWhiteSpace($_.FullName) -or $_.FullName -eq $_.Name) {
        $_.Name
    } else {
        "$($_.Name) ($($_.FullName))"
    }
    $i++
}


# Informacje Sprzetowe
foreach ($item in $infoTable.Keys) {
    #Write-Host $item = $infoTable[$item]
    $info = $item + $separator + $infoTable[$item] + $separator + " "
    $info | Out-File $OutFile -Append
}
# Informacje o zainstalowanych aplikacjach
" ; ; " | Out-File $OutFile -Append
"Oprogramowanie; ; " | Out-File $OutFile -Append

foreach ($item in $appTable) {
    #Write-Host $item = $appTable[$item]
    $info = $item + $separator + $separator
    $info | Out-File $OutFile -Append
}

# Informacje o drukarkach
Write-Host " - o drukarkach..."
" ; ; " | Out-File $OutFile -Append
"Drukarki; ; " | Out-File $OutFile -Append

Get-SystemObject Win32_Printer |
Where-Object {
    $_.Name -notin @(
        "Microsoft XPS Document Writer",
        "Microsoft Print to PDF",
        "Fax",
        "OneNote",
	"RustDesk Printer",
	"RustDesk Printer",
	"RustDesk v4 Printer Driver"
    )
} |
ForEach-Object {
    "$($_.Name);$($_.PortName);$($_.DriverName)"
} | Out-File $OutFile -Append

# Informacje o Dyskach/Zasobach Sieciowych
Write-Host " - o dyskach sieciowych..."
" ; ; " | Out-File $OutFile -Append
"Lokalizacje Sieciowe; ; " | Out-File $OutFile -Append
Get-SystemObject Win32_MappedLogicalDisk | ForEach-Object {
    "$($_.DeviceID);$($_.ProviderName)"
} | Out-File $OutFile -Append

# Informacje o uzytkownikach
" ; ; " | Out-File $OutFile -Append
"Uzytkownicy Lokalni; ; " | Out-File $OutFile -Append
"Uzytkownik;Haslo;PIN" | Out-File $OutFile -Append
foreach ($item in $userTable.Keys) {
    #Write-Host "User$item = $($userTable[$item])"
    $info = $userTable[$item] + $separator + $separator
    $info | Out-File $OutFile -Append
}

Write-Host "* Gotowe! Informacje zapisane: $OutFile "
