param ($loc)
if($loc -eq "upper"){
    [string]$loc = Get-Location
    $linloc = $loc -ireplace '\\','/'
}else{
    [string]$loc_s = Get-Location
    $loc = Split-Path -Path $loc_s -Parent
    $linloc = $loc -ireplace '\\','/'
}
Write-Host $loc

$root_conf = Get-Content -path "$loc\conf\root\ca.conf" | Out-String
$root_conf = $root_conf -ireplace '(dir\s{1,}=\s{1,})(.*)',"`$1$linloc/ROOT"
$root_conf -ireplace '(new_certs_dir\s{1,}=\s{1,})(.*)',"`$1`$dir/newcerts" | Set-Content -Path "$loc\conf\root\ca.conf"
$inter_conf = Get-Content -path "$loc\conf\int\ca.conf" | Out-String
$inter_conf = $inter_conf -ireplace '(dir\s{1,}=\s{1,})(.*)',"`$1$linloc/INT"
$inter_conf -ireplace '(new_certs_dir\s{1,}=\s{1,})(.*)',"`$1`$dir/newcerts" | Set-Content -Path "$loc\conf\int\ca.conf"


$ca_home = "$loc\int"
$ca_name="IntermediateCA"
$ca_keylen=4096
$ca_conf_dir = "$loc\conf"


Remove-Item -path "$ca_home\private" -recurse -ErrorAction Ignore
Remove-Item -path "$ca_home\certs" -recurse -ErrorAction Ignore
Remove-Item -path "$ca_home\newcerts" -recurse -ErrorAction Ignore
Remove-Item -path "$ca_home\db" -recurse -ErrorAction Ignore
Remove-Item -path "$ca_home\out" -recurse -ErrorAction Ignore
Remove-Item -path "$ca_home\*"  -include *.crl -ErrorAction Ignore
New-Item -Path "$ca_home\private" -ItemType Directory 
New-Item -Path "$ca_home\certs" -ItemType Directory 
New-Item -Path "$ca_home\newcerts" -ItemType Directory 
New-Item -Path "$ca_home\db" -ItemType Directory
New-Item -Path "$ca_home\out" -ItemType Directory 

$uuid = '0000'
write-host $uuid
New-Item "$ca_home\db\$ca_name.crt.srl"
Set-Content "$ca_home\db\$ca_name.crt.srl" $uuid
$uuid1 = '00'
write-host $uuid1 
New-Item "$ca_home\db\$ca_name.crl.srl"
Set-Content "$ca_home\db\$ca_name.crl.srl" $uuid1
New-Item "$ca_home\db\$ca_name.db"
New-Item "$ca_home\db\$ca_name.db.attr"

openssl genrsa -out $ca_home\private\$ca_name.pem.key $ca_keylen
openssl req -new -config $ca_conf_dir\int\ca.conf -out $ca_home\$ca_name.pem.csr -key $ca_home\private\$ca_name.pem.key
openssl ca -config $ca_conf_dir\root\ca.conf -in $ca_home\$ca_name.pem.csr -out $ca_home\certs\$ca_name.pem.crt -extensions signing_ca_ext -policy extern_pol -notext
openssl x509 -outform DER -in $ca_home\certs\$ca_name.pem.crt -out $ca_home\certs\$ca_name.der.crt
openssl ca -gencrl -config $ca_conf_dir\int\ca.conf -out $ca_home\$ca_name.pem.crl
openssl crl -in $ca_home\$ca_name.pem.crl -outform DER -out $ca_home\$ca_name.der.crl
remove-item   -path "$ca_home\$ca_name.pem.csr"


