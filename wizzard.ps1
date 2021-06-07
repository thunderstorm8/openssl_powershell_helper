
param ($root, $inter, $client, $server, $acl, $pass)
[string]$loc1 = Get-Location

if ($root -or $client -or $server -or $inter -or $acl){
    if($acl -eq 1){
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-host "[-] Admin Rights required"
            Break
        }else{
            Write-Host "Under Development"
            break
            #Start-Process -FilePath "Icacls" -ArgumentList "$loc1 /grant /q /c `"everyone`":(OI)(CI)F /T"
        }
    }elseif($root -eq 1){
        Start-Process -FilePath "notepad" -ArgumentList "$loc1\conf\root\ca.conf" -NoNewWindow -Wait
        invoke-expression -Command "& '$loc1\src\ROOT.ps1' -loc upper"
    }elseif ($inter -eq 1) {
        Start-Process -FilePath "notepad" -ArgumentList "$loc1\conf\int\ca.conf" -NoNewWindow -Wait
        invoke-expression -Command "& '$loc1\src\INTER.ps1' -loc upper"
    }elseif ($client -eq 1) {
        if ($pass -eq 1){
            $pass1 = Read-Host -assecurestring "[!] Enter password"
            $pass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass1))
            $pass2 = Read-Host -assecurestring "[!] Enter password once more"
            $pass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass2))
            if ($pass1 -eq $pass2){
                Start-Process -FilePath "notepad" -ArgumentList "$loc1\conf\int\ssl.client.conf" -NoNewWindow -Wait
                invoke-expression -Command "& '$loc1\src\ssl.client.ps1' -loc upper -creds $pass1"
            }else {
                Write-Host "[-]Passwords don't match"
            }
        }else{
            Start-Process -FilePath "notepad" -ArgumentList "$loc1\conf\int\ssl.client.conf" -NoNewWindow -Wait
            invoke-expression -Command "& '$loc1\src\ssl.client.ps1' -loc upper -creds default"
        }
    }elseif ($server -eq 1) {
        if ($pass -eq 1){
            $pass1 = Read-Host -assecurestring "[!] Enter password"
            $pass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass1))
            $pass2 = Read-Host -assecurestring "[!] Enter password once more"
            $pass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass2))
            if ($pass1 -eq $pass2){
                Start-Process -FilePath "notepad" -ArgumentList "$loc1\conf\int\ssl.server.conf" -NoNewWindow -Wait
                invoke-expression -Command "& '$loc1\src\ssl.server.ps1' -loc upper -creds $pass1"
            }else {
                Write-Host "[-]Passwords don't match"
            }
        }else{
            Start-Process -FilePath "notepad" -ArgumentList "$loc1\conf\int\ssl.server.conf" -NoNewWindow -Wait
            invoke-expression -Command "& '$loc1\src\ssl.server.ps1' -loc upper -creds default"
        }
    }
}
else{
  Write-Host 'Usage: .\wizzard.ps1 -[root|inter|client|server] 1 -pass[optional] 1'
}
 
