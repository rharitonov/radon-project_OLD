param($AccessCodeForEmail)
if (!$AccessCodeForEmail){
	Throw "User work email must be specified!"
}
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList "wsuser", (ConvertTo-SecureString "ets{>^5S"  -AsPlainText -Force)
$WS = New-WebServiceProxy "http://nav.rharitonov.ru:7047/BC170/WS/CRONUS%20%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D1%8F%20%D0%97%D0%90%D0%9E/Codeunit/SSHHelperAPI"  -Credential $cred 
$WS.Timeout = [System.Int32]::MaxValue

$WS.GetAccessCode($AccessCodeForEmail)
