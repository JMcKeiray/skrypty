$Base  = "C:\Windows\Temp\provision"
$Flags = "$Base\flags"
$Log   = "$Base\provision.log"

New-Item -ItemType Directory -Path $Flags -Force | Out-Null
Start-Transcript $Log

function Step {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    $flag = "$Flags\$Name.done"

    if (Test-Path $flag) {
        Write-Host "SKIP: $Name"
        return
    }

    Write-Host "RUN: $Name"
    & $Action

    New-Item -ItemType File -Path $flag -Force | Out-Null
}

# ---------------- ETAP 1 ----------------
Step "01_users" {

    $protected = @(
        "Administrator","Guest","DefaultAccount","WDAGUtilityAccount"
    )

    Get-LocalUser | Where-Object {
        $protected -notcontains $_.Name
    } | ForEach-Object {
        try { Remove-LocalUser $_.Name -ErrorAction Stop } catch {}
    }

    if (-not (Get-LocalUser serwis -ErrorAction SilentlyContinue)) {
        $pwdSerwis = ConvertTo-SecureString 'sp6#jkSD&^23' -AsPlainText -Force
        New-LocalUser -Name "serwis" -FullName "SerwisIT" -Password $pwdSerwis -PasswordNeverExpires
        Add-LocalGroupMember -Group "Administrators" -Member "serwis"
    }

    if (-not (Get-LocalUser uczen -ErrorAction SilentlyContinue)) {
        $pwdUczen = ConvertTo-SecureString 'sp6#kjDS@#78' -AsPlainText -Force
        New-LocalUser -Name "uczen" -FullName "Uczeń" -Password $pwdUczen -PasswordNeverExpires
    }

    if (-not (Get-LocalUser nauczyciel -ErrorAction SilentlyContinue)) {
        $pwdNauczyciel = ConvertTo-SecureString 'sp6laziska' -AsPlainText -Force
        New-LocalUser -Name "nauczyciel" -FullName "Nauczyciel" -Password $pwdNauczyciel -PasswordNeverExpires
        Add-LocalGroupMember -Group "Administrators" -Member "nauczyciel"
    }
}

# ---------------- ETAP 2 ----------------
Step "02_software" {
    winget install TheDocumentFoundation.LibreOffice --silent
    winget install Mozilla.Firefox.pl --silent
}
# Etap 98
Step "98_beep" {
    [console]::beep(900, 200)
    Start-Sleep -Milliseconds 100
    [console]::beep(1200, 200)
    Start-Sleep -Milliseconds 100
    [console]::beep(1500, 400)
}


# ---------------- ETAP 99 ----------------
Step "99_cleanup" {
    schtasks /delete /tn "ProvisionUsersAtBoot" /f
    Restart-Computer -Force
}

Stop-Transcript
