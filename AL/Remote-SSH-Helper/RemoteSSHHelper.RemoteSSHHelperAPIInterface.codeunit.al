codeunit 50100 "RemoteSSHHelper API Interface"
{
    trigger OnRun()
    begin

    end;

    procedure GetAccessCode(ForEmail: Text)
    var
        AllowedSSHUser: Record "SSH Allowed User";
        AccessCodeLog: Record "SSH Access Code Log";
        BodyText: Label '<p style="font-family:Verdana,Arial;font-size:9pt"><b>Your Radon access code:</b> %1<BR></p>';
    begin
        if ForEmail = '' then
            Error('Work email must be specified!');

        if not AllowedSSHUser.Get(ForEmail) then
            Error('Soryan bratan.. ne mogu', ForEmail);

        Randomize();
        AccessCodeLog.Reset();
        AccessCodeLog.SetRange(Email, AllowedSSHUser.Email);
        AccessCodeLog.DeleteAll(true);
        AccessCodeLog.Init();
        AccessCodeLog.Email := AllowedSSHUser.Email;
        AccessCodeLog."Access Code" := PadStr(Format(Random(999999)), 6, '0');
        AccessCodeLog."Issue DateTime" := CurrentDateTime;
        AccessCodeLog.Insert(True);

        //AccessCodeLog.Email := 'rkharitonov@navicons.ru'; //debug        
        SendMail(AccessCodeLog.Email,
            'Radon Remote Helper - new access code',
            StrSubstNo(BodyText, AccessCodeLog."Access Code"));

    end;

    procedure GetUserSSHKey(AccessCode: Text[6]; var SSHKey: Text; var SSHKeyFilename: Text; var UserName: Text)
    var
        AccessCodeLog: Record "SSH Access Code Log";
        AllowedUser: Record "SSH Allowed User";
        ExpireDateTime: DateTime;
        Params: list of [text];
        PasswordFile, SSHKeyFile, FileContent : text;
        FM: Codeunit "File Management";
        ff: File;
        SSHKeyInStream: InStream;
        BodyText: Label '<p style="font-family:Verdana,Arial;font-size:10pt"><b>SSH Key has been generated. Check your .ssh folder.</b></p><p style="font-family:Verdana,Arial;font-size:9pt"><b>Your account:</b> HOMELAB2\%1<BR><b>Password:</b> %2</p>';

    begin
        AccessCodeLog.SetRange("Access Code", AccessCode);
        if not AccessCodeLog.FindFirst() then
            Error('Invalid access code');

        AccessCodeLog.Testfield("Issue DateTime");


        ExpireDateTime := AccessCodeLog."Issue DateTime" + (1000 * 60) * 15;
        if ExpireDateTime < CurrentDateTime then
            Error('Access code is expired');

        AllowedUser.Get(AccessCodeLog.Email);


        Params.Add('C:\src\Remote-SSH-Helper\scripts\server\GenerateSSHKey.ps1');
        Params.Add(AllowedUser.Email);
        Params.Add(AllowedUser."First Name");
        Params.Add(AllowedUser."Last Name");
        RunPowershellScript(Params);

        UserName := CopyStr(AccessCodeLog.Email, 1, StrPos(AccessCodeLog.Email, '@') - 1);
        SSHKeyFile := StrSubstNo('C:\Users\Administrator\.ssh\%1.id_rsa', UserName);
        PasswordFile := StrSubstNo('C:\Users\Administrator\.ssh\%1.pwd', UserName);
        if not FM.ServerFileExists(PasswordFile) then
            Error('File %1 not found', PasswordFile);
        if not FM.ServerFileExists(SSHKeyFile) then
            Error('File %1 not found', SSHKeyFile);

        //send mail with password
        ff.TextMode := true;
        ff.Open(PasswordFile, TextEncoding::UTF8);
        ff.Read(FileContent);
        //AccessCodeLog.Email := 'rkharitonov@navicons.ru'; //debug
        SendMail(AccessCodeLog.Email,
            'Radon Remote Helper - new SSH key',
            StrSubstNo(BodyText,
                UserName,
                FileContent));
        ff.Close();
        fm.DeleteServerFile(PasswordFile);

        //get SSH Key
        SSHKeyFilename := FM.GetFileName(SSHKeyFile);
        ff.Open(SSHKeyFile, TextEncoding::UTF8);
        ff.CreateInStream(SSHKeyInStream);
        SSHKeyInStream.Read(SSHKey);
        ff.Close();
        fm.DeleteServerFile(SSHKey);

    end;

    Local procedure SendMail(ToEmail: Text; Subj: Text; Body: Text)
    var
        SMTPMail: Codeunit "SMTP Mail";
        SendToList: List of [Text];
        MailBodyTxt: Label '<p style="font-family:Verdana,Arial;font-size:9pt"><b>Your Radon access code:</b> %1<BR></p>';
    begin
        SendToList.Add(ToEmail);
        SMTPMail.CreateMessage(
          'goodnewscentral@outlook.com',
          'goodnewscentral@outlook.com',
          SendToList,
          Subj,
          Body,
          true);
        SMTPMail.SendShowError();
    end;

    local procedure RunPowershellScript(ArgList: List of [Text])
    var
        PS: DotNet PowerShellRunner;
        PSCmd: Text;
    begin
        PS := PS.CreateInSandbox;
        PS.WriteEventOnError(true);

        PSCmd := StrSubstNo('$ScriptPath = ''%1''; $Arguments = ''%2 %3 %4''; Invoke-Expression "$ScriptPath $Arguments"',
            ArgList.get(1),
            ArgList.get(2),
            ArgList.get(3),
            ArgList.get(4));
        PS.AddCommand('Invoke-Expression');
        PS.AddParameter('Command', PSCmd);
        PS.BeginInvoke();
        if IsNull(PS.Results) then;
        if PS.HadErrors() then
            Error('PS running errors occured. See system log.');
    end;

    var
        myInt: Integer;
}
