table 50101 "SSH Access Code Log"
{
    DataClassification = ToBeClassified;
    LookupPageId = "SSH Access Code Log";

    fields
    {
        field(1; Email; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "SSH Allowed User";

        }
        field(2; "Access Code"; Text[6])
        {
            DataClassification = ToBeClassified;

        }
        field(10; "Issue DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;

        }

    }

    keys
    {
        key(PK; Email, "Access Code")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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