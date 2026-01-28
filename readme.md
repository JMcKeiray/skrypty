Możesz użyć poniższej komendy, aby wykonać skrypt bezpośrednio z GitHuba:

powershell -ExecutionPolicy Bypass -Command ^
 "iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/JMcKeiray/skrypty/refs/heads/main/bootstrap.ps1'))"

Linux: curl -s https://raw.githubusercontent.com/eriktron/MojeRepo/main/skrypt.sh | bash

Windows PS: iwr -Uri "https://raw.githubusercontent.com/uzytkownik/repozytorium/main/skrypt.ps1" -OutFile "$env:TEMP\skrypt.ps1" -Encoding UTF8; powershell -ExecutionPolicy Bypass -File "$env:TEMP\skrypt.ps1"
