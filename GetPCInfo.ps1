# ===============================
# Konfiguracja słów kluczowych
# ===============================
$keywords = @("firefox", "thunderbird", "libreoffice", "7-zip", "chrome", "rustdesk", "anydesk", "wireguard" )

# ===============================
# Funkcja: Zbieranie informacji
# ===============================
function Get-BasicInfo {
    $info = [ordered]@{}

    $hostname = $env:COMPUTERNAME
    $info["Urzadzenie"] = $hostname

    # ===== Rodzaj (Laptop / Desktop) =====
    $chassisTypes = (Get-CimInstance -ClassName Win32_SystemEnclosure -ErrorAction SilentlyContinue).ChassisTypes
    $isLaptop = $false
    if ($chassisTypes) {
        foreach ($ct in $chassisTypes) {
            if ($ct -in 8,9,10,14,30) { $isLaptop = $true; break }
        }
    }
    $info["Rodzaj"] = if ($isLaptop) { "Laptop" } else { "Desktop" }

    $bios = Get-WmiObject -Class Win32_BIOS
    $cs = Get-WmiObject -Class Win32_ComputerSystem
    $info["Producent"] = $cs.Manufacturer
    $info["Model"] = $cs.Model
    $info["ServiceTag/SN"] = $bios.SerialNumber

    $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
    $info["Procesor"] = $cpu.Name.Trim()

    $ramGB = [math]::Round(($cs.TotalPhysicalMemory / 1GB), 0)
    $info["RAM"] = "$ramGB GB"

    $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
        "$($_.FriendlyName) ($([math]::Round($_.Size / 1GB))GB)"
    } | Sort-Object

    # Zapisz dyski jako tablicę, żeby wypisać je w kolumnie później
    $info["Dyski"] = @($disks)  # upewniamy się, że to tablica nawet jeśli jeden element

    $os = Get-WmiObject -Class Win32_OperatingSystem
    $info["System"] = "$($os.Caption) $($os.OSArchitecture)"

    $domain = if ($cs.PartOfDomain) { $cs.Domain } else { $cs.Workgroup }
    $info["Domena/Grupa"] = $domain

    $ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notlike "169.*" -and $_.InterfaceAlias -notmatch "Loopback|isatap" } |
        Select-Object -First 1).IPAddress
    $dhcp = (Get-NetIPConfiguration -ErrorAction SilentlyContinue | Where-Object { $_.IPv4DefaultGateway }).DhcpEnabled
    $dhcpStatus = if ($dhcp) { "DHCP" } else { "Statyczny" }
    $info["Adres IP"] = "$ip ($dhcpStatus)"

    return $info
}

# ===============================
# Funkcja: Filtrowanie programów
# ===============================
function Get-InstalledSoftware {
    param([string[]]$Keywords)

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $apps = foreach ($path in $paths) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -and $_.DisplayName -ne "" } |
            Select-Object -ExpandProperty DisplayName
    }

    $filtered = $apps | Where-Object {
        foreach ($kw in $Keywords) {
            if ($_.ToLower() -like "*$($kw.ToLower())*") { return $true }
        }
        return $false
    } | Sort-Object -Unique

    return $filtered
}

# ===============================
# Funkcja: Lista użytkowników
# ===============================
function Get-FilteredUsers {
    # Pomija konta wyłączone
    $users = Get-LocalUser -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Enabled
        }
    return $users
}

# ===============================
# Funkcja: Drukowanie informacji
# ===============================
function Print-BasicInfo($info, $keywords) {
    foreach ($key in $info.Keys) {
        $val = $info[$key]
        if ($val -is [System.Array]) {
            # jeśli tablica - wypisz pierwszy w linii z kluczem, resztę w nowych liniach zaczynających się od " ;"
            if ($val.Count -gt 0) {
                Write-Host "$key;$($val[0])"
                for ($i = 1; $i -lt $val.Count; $i++) {
                    Write-Host " ;$($val[$i])"
                }
            } else {
                Write-Host "$key;"
            }
        } else {
            Write-Host "$key;$val"
        }
    }

    Write-Host " ; ; `n ; ; "
    Write-Host "Oprogramowanie"
    $programs = Get-InstalledSoftware -Keywords $keywords
    foreach ($p in $programs) {
        Write-Host "$p"
    }

    Write-Host " ; ; `n ; ; `nUzytkownicy;Haslo;PIN"
    $users = Get-FilteredUsers
    foreach ($u in $users) {
        Write-Host "$($u.Name); ; "
    }
}

# ===============================
# Funkcja: Zapis do pliku
# ===============================
function Save-BasicInfo($info, $keywords) {
    $date = Get-Date -Format "yyyy-MM-dd"
    $filename = "$($env:COMPUTERNAME)_($date).txt"
    $path = Join-Path -Path (Get-Location) -ChildPath $filename

    $lines = @()
    foreach ($key in $info.Keys) {
        $val = $info[$key]
        if ($val -is [System.Array]) {
            if ($val.Count -gt 0) {
                $lines += "$key;$($val[0])"
                for ($i = 1; $i -lt $val.Count; $i++) {
                    $lines += " ;$($val[$i])"
                }
            } else {
                $lines += "$key;"
            }
        } else {
            $lines += "$key;$val"
        }
    }

    $lines += " ; ; ", " ; ; ", "Oprogramowanie"

    $programs = Get-InstalledSoftware -Keywords $keywords
    foreach ($p in $programs) {
        $lines += "$p"
    }

    $lines += " ; ; ", " ; ; ", "Uzytkownicy;Haslo;PIN"

    $users = Get-FilteredUsers
    foreach ($u in $users) {
        $lines += "$($u.Name); ; "
    }

    $lines | Out-File -FilePath $path -Encoding UTF8
    Write-Host "Zapisano do pliku: $path"
}

# ===============================
# Główne wywołanie
# ===============================
$info = Get-BasicInfo
Print-BasicInfo $info $keywords
Save-BasicInfo $info $keywords
