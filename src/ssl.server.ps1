param ($loc,$creds)

if($loc -eq "upper"){
    [string]$loc = Get-Location
    $linloc = $loc -ireplace '\\','/'
}else{
    [string]$loc_s = Get-Location
    $loc = Split-Path -Path $loc_s -Parent
    $linloc = $loc -ireplace '\\','/'
}

if($creds -ne "default"){
    $pass = $creds
    Write-Host "[+] Using Custom password"
}else{
    $pass = "P@ssw0rd"
    Write-Host "[+] Using default password"
}

$root_conf = Get-Content -path "$loc\conf\root\ca.conf" | Out-String
$root_conf = $root_conf -ireplace '(dir\s{1,}=\s{1,})(.*)',"`$1$linloc/ROOT"
$root_conf -ireplace '(new_certs_dir\s{1,}=\s{1,})(.*)',"`$1`$dir/newcerts" | Set-Content -Path "$loc\conf\root\ca.conf"
$inter_conf = Get-Content -path "$loc\conf\int\ca.conf" | Out-String
$inter_conf = $inter_conf -ireplace '(dir\s{1,}=\s{1,})(.*)',"`$1$linloc/INT"
$inter_conf -ireplace '(new_certs_dir\s{1,}=\s{1,})(.*)',"`$1`$dir/newcerts" | Set-Content -Path "$loc\conf\int\ca.conf"

$CA_CONF_DIR = "$loc\conf\int"
$CA_HOME = "$loc\int"
$CA_NAME = "IntermediateCA"
$ROOT_CA_NAME = "RootCA"
$ROOT_CA_HOME= "$loc\ROOT"


Remove-Item -path "$CA_HOME\temp" -recurse -ErrorAction Ignore
New-Item -Path "$CA_HOME\temp" -ItemType Directory 
openssl req -new -config $CA_CONF_DIR/ssl.server.conf -out $CA_HOME/temp/ssl.server.pem.csr -keyout $CA_HOME/temp/ssl.server.pem.key
openssl ca -config $CA_CONF_DIR/ca.conf -in $CA_HOME/temp/ssl.server.pem.csr -out $CA_HOME/temp/ssl.server.pem.crt -policy extern_pol -extensions server_ext -notext
$out = openssl x509 -in $CA_HOME/temp/ssl.server.pem.crt -serial -noout
$path = ([regex]"serial=([\d]{1,})").Matches($out)[0].Groups[1].Value
$randomstr = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
$path = $path + $randomstr
$OUT_FOLDER= "$linloc/int/out/$path"
$OUT_FOLDER_B = "$CA_HOME\out\$path"
New-Item -Path "$OUT_FOLDER_B" -ItemType Directory
Move-Item -Path "$CA_HOME\temp\*" -Destination "$OUT_FOLDER_B"
openssl x509 -outform DER -in $OUT_FOLDER/ssl.server.pem.crt -out $OUT_FOLDER/ssl.server.der.crt

Get-Content $ROOT_CA_HOME\certs\$ROOT_CA_NAME.pem.crt, $CA_HOME\certs\$CA_NAME.pem.crt | out-file $OUT_FOLDER_B\ca.chain.pem.crt

openssl pkcs12 -export -name "SSL server certificate" -inkey $OUT_FOLDER/ssl.server.pem.key -in $OUT_FOLDER/ssl.server.pem.crt -CAfile $OUT_FOLDER/ca.chain.pem.crt -out $OUT_FOLDER/ssl.server.full.pfx -password pass:$pass
openssl pkcs12 -export -name "SSL server certificate" -inkey $OUT_FOLDER/ssl.server.pem.key -in $OUT_FOLDER/ssl.server.pem.crt -out $OUT_FOLDER/ssl.server.brief.pfx -password pass:$pass
openssl pkcs12 -in $OUT_FOLDER/ssl.server.full.pfx -out $OUT_FOLDER/ssl.server.full.pem -passin pass:$pass -passout pass:$pass
openssl pkcs12 -in $OUT_FOLDER/ssl.server.brief.pfx -out $OUT_FOLDER/ssl.server.brief.pem -passin pass:$pass -passout pass:$pass

Set-Location -Path "$linloc"