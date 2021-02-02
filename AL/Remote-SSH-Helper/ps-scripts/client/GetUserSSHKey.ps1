param($AccessCode)
if (!$AccessCode){
	Throw "Access code must be specified!"
}

$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList "wsuser", (ConvertTo-SecureString "ets{>^5S"  -AsPlainText -Force)
$WS = New-WebServiceProxy "http://nav.rharitonov.ru:7047/BC170/WS/CRONUS%20%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D1%8F%20%D0%97%D0%90%D0%9E/Codeunit/SSHHelperAPI"  -Credential $cred 
$WS.Timeout = [System.Int32]::MaxValue

$SSHKeyConent = ""
$SSHKeyFilename = ""
$UserName = ""
$WS.GetUserSSHKey($AccessCode, [ref]$SSHKeyConent, [ref]$SSHKeyFilename, [ref]$UserName)


#debug
#$UserSSHFolder = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh2"
$UserSSHFolder = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh"
if (!(Test-Path -Path $UserSSHFolder)){
	$null = New-Item -Path $UserSSHFolder -ItemType Directory -Force
}

$SSHKey = Join-Path -Path $UserSSHFolder -ChildPath $SSHKeyFilename
Set-Content -Path $SSHKey -Value $SSHKeyConent

$configFile = Join-Path -Path $UserSSHFolder -ChildPath "config"
if (Test-Path -Path $configFile){
	Copy-Item -Path $configFile -Destination "$configFile.backup"
}

"Host bcdev`n   User $UserName`n   HostName nav.rharitonov.ru`n   IdentityFile ~/.ssh/$SSHKeyFilename" | Out-File -Encoding utf8 -FilePath $configFile
