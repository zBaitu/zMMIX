    PREFIX :string:toupper:
string IS $0

char    GREG
pos     GREG
result  GREG

:string:toupper SET     pos,0
loop            LDBU    char,string,pos
                BZ      char,return
                CMP     result,char,:char:LOWER_A
                BN      result,next
                CMP     result,char,:char:LOWER_Z
                BP      result,next
                SUB     char,char,:char:UPPER_LOWER_DIFF
                STBU    char,string,pos
next            ADDU    pos,pos,1
                JMP     loop

return          POP 0,0
    PREFIX :
