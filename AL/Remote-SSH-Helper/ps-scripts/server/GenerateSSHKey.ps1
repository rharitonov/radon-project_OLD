param ($UserEmail, $UserFirstName, $UserLastName, $GitHubEmail)

#$null = ssh -V

$UserName = $UserEmail.Split('@')[0]


# create new user's password
Add-Type -AssemblyName 'System.Web'
$PwdLen = 8 ## characters
$nonAlphaChars = 0
$PwdText = [System.Web.Security.Membership]::GeneratePassword($PwdLen, $nonAlphaChars)
$Password = ConvertTo-SecureString $PwdText -AsPlainText -Force


$UserAccount = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
if ($UserAccount){
	$null = Set-LocalUser $UserAccount -Password $Password
	Write-Host "Password has been changed" -ForegroundColor red -BackgroundColor white

} else {	
	#throw "$UserName $UserFirstName $UserLastName"
	$null = New-LocalUser $UserName -Password $Password -FullName "$UserFirstName $UserLastName" -AccountNeverExpires:$true -PasswordNeverExpires:$true 
	Add-LocalGroupMember -Group "Users" -Member $UserName
	Add-LocalGroupMember -Group "Remote Management Users" -Member $UserName
	Add-LocalGroupMember -Group WinRMRemoteWMIUsers__ -Member $UserName
	
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $Password
	Start-Process cmd /c -Credential $Cred -ErrorAction SilentlyContinue -LoadUserProfile	
	
	Write-Host "Standard Windows user $userName has been created" -ForegroundColor red -BackgroundColor white

	# create ~./.gitconfig 
	#if ($GitHubEmail -ne "NoConfig"){
	#	$config_arg = 'config --global user.name ' + '"' + $UserFirstName + ' ' +  $UserLastName + '"'
	#	Start-Process git -ArgumentList $config_arg  -Credential $Cred -ErrorAction SilentlyContinue
	#	$config_arg = 'config --global user.email ' + $GitHubEmail
	#	Start-Process git -ArgumentList $config_arg  -Credential $Cred -ErrorAction SilentlyContinue
	#}

	# add user to BC
	Import-Module "C:\Program Files\Microsoft Dynamics 365 Business Central\170\Service\NavAdminTool.ps1"
	New-NAVServerUser BC170 -WindowsAccount HOMELAB2\$UserName -LicenseType Full -State Enabled
	New-NAVServerUserPermissionSet BC170 -WindowsAccount HOMELAB2\$UserName -PermissionSetId SUPER	
	
	$Usr = $UserName.ToUpper()
	Write-Host "Windows User HOMELAB2\$Usr has been added to BC170 with LicenseType FULL and PermissionSet SUPER" -ForegroundColor red -BackgroundColor white
}	

# preparation and generate new ssh key
$AdminSSHFolder = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh"
$UserSID = Get-WmiObject -Query "select * from win32_useraccount where name='$UserName'" | Select-Object -ExpandProperty SID
$UserProfilePath = Get-WmiObject -Query "select * from win32_userprofile where sid='$UserSID'"|Select-Object -ExpandProperty Localpath
$UserSSHFolder = Join-Path -Path $UserProfilePath -ChildPath ".ssh" 
$AuthorizedKeysPath = Join-Path -Path $UserSSHFolder -ChildPath "authorized_keys"

if (!(Test-Path -Path $UserSSHFolder)){
	$null = New-Item -Path $UserSSHFolder -ItemType Directory -Force
}

if (!(Test-Path -Path $AdminSSHFolder)){
	New-Item -Path $AdminSSHFolder -ItemType Directory -Force
}

$PubKeyPath = Join-Path -Path $AdminSSHFolder -ChildPath "$UserName.id_rsa.pub"
$PrivateKeyPath = Join-Path -Path $AdminSSHFolder -ChildPath "$UserName.id_rsa"

if (Test-Path -Path $PrivateKeyPath){
	Remove-Item -Path $PrivateKeyPath
}

if (Test-Path -Path $AuthorizedKeysPath) {
	Remove-Item -Path $AuthorizedKeysPath
}
ssh-keygen -q -f $PrivateKeyPath -N """"
Copy-Item -Path $PubKeyPath -Destination $AuthorizedKeysPath

Write-Host "SSH key is generated" -ForegroundColor red -BackgroundColor white

# create folder for al projects
$ALProjectsFolder = Join-Path -Path $UserProfilePath -ChildPath "AL_Projects"
if (!(Test-Path -Path $ALProjectsFolder)){
	$null = New-Item -Path $ALProjectsFolder -ItemType Directory -Force
	Write-Host "Folder $ALProjectsFolder has been created" -ForegroundColor red -BackgroundColor white
}

$PwdText | Out-File -Encoding utf8 -FilePath (Join-Path -Path $AdminSSHFolder -ChildPath "$UserName.pwd") 

"New password: $PwdText"
