page 50100 "SSH Allowed User"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SSH Allowed User";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(email; Rec.Email)
                {
                    ApplicationArea = All;

                }
                field("GitHub Email"; Rec."GitHub Email")
                {
                    ApplicationArea = All;

                }

                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;

                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;

                }

            }
        }

    }

    actions
    {
        area(Processing)
        {
            action("Import SSH Users From CSV File")
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    CSVBuffer: Record "CSV Buffer" temporary;
                    SSHUser: Record "SSH Allowed User";
                    FileName: Text;
                    InStream1: InStream;
                    MaxRowNo, R : Integer;
                begin
                    If not UploadIntoStream('Select SCV File', '%USERPROFILE%', '(*.csv)|*.csv', FileName, InStream1) then
                        exit;
                    CSVBuffer.LoadDataFromStream(InStream1, ';');
                    MaxRowNo := CSVBuffer.GetNumberOfLines();
                    for R := 1 to MaxRowNo Do begin
                        SSHUser.Init();
                        SSHUser.email := CSVBuffer.GetValue(R, 3);
                        SSHUser."First Name" := CSVBuffer.GetValue(R, 2);
                        SSHUser."Last Name" := CSVBuffer.GetValue(R, 1);
                        SSHUser.Insert(true);
                    end;

                end;



            }

        }
    }
}