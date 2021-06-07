
[string]$loc = Get-Location
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[+] Admin Rights OK"
    try {
        Write-Host "[!] Downloading installer -----> $loc\sslinstaller.exe"
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("https://slproweb.com/download/Win64OpenSSL-1_1_1k.exe", "$loc\sslinstaller.exe")
        Write-Host "[+] Installer downloaded"
        Write-Host "[!] Running installer"
        Start-Process $loc\sslinstaller.exe -NoNewWindow -Wait
        Write-Host "[+] OpenSSL installed"
        Write-Host "[+] Cheching Installation"
        if (Test-Path -Path "C:\Program Files\OpenSSL-Win64\bin"){
            Remove-Item -Path $loc\sslinstaller.exe -Force
            Write-Host "[!] Patching Path"
            [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\OpenSSL-Win64\bin", "Machine")
            Write-Host "[+] Path Patched"
        }else{
            Remove-Item -Path $loc\sslinstaller.exe -Force
            Write-Host "[-] Canceled istallation or custom path"
            Write-Host 'in case with custom path execute with admin rights: [Environment]::SetEnvironmentVariable("Path", $env:Path + ";<YOUR PATH TO INSTALLATION>", "Machine")'
            Break
        }
    }
    catch [System.Net.WebException], [System.IO.IOException] {
        Write-host "[-] Unable to download from slproweb"
        Write-host "[!] Insntall it manually from https://slproweb.com/products/Win32OpenSSL.html or other source"
        Write-Host 'Then Execute with admin rights: [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\OpenSSL-Win64\bin", "Machine")'
        Break
    }
    catch {
        Write-Host "Unexpected error"
        Write-Host $_
        Break
    }
    Write-host "[+] Your PC is ready to use Wizzard"
}else{
    Write-Host "[-] Local admin Rights needed for patching path executable"
    Break
}
