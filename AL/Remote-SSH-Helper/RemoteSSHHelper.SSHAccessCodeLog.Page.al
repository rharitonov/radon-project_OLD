page 50102 "SSH Access Code Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SSH Access Code Log";


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;

                }

                field("Access Code"; Rec."Access Code")
                {
                    ApplicationArea = All;

                }

                field("Issue DateTime"; Rec."Issue DateTime")
                {
                    ApplicationArea = All;

                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {

        }
    }
}