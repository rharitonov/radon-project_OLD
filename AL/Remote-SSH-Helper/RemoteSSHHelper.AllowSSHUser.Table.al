table 50100 "SSH Allowed User"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Email; code[40])
        {
            DataClassification = ToBeClassified;

        }
        field(10; "First Name"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(11; "Last Name"; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(30; "GitHub Email"; Text[40])
        {
            DataClassification = ToBeClassified;
        }


    }

    keys
    {
        key(PK; email)
        {
            Clustered = true;
        }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}