    PREFIX :numeric:num_to_str:
num     IS $0
sign    IS $1 
str     IS $2
len     IS $3

NEG_CHAR    GREG '-'

is_neg      GREG
pos         GREG
remainder   GREG

:numeric:num_to_str SET     is_neg,0
                    BP      sign,begin
                    CMP     is_neg,num,0
                    PBNN    is_neg,begin
                    NEGU    num,0,num

begin               SET     pos,len
loop                SUB     pos,pos,1
                    DIVU    num,num,10
                    GET     remainder,:rR
                    INCL    remainder,#30
                    STB     remainder,str,pos
                    PBP     num,loop
                    PBNN    is_neg,end
                    SUB     pos,pos,1
                    STB     NEG_CHAR,str,pos

end                 ADD     $0,str,pos
                    POP     1,0
    PREFIX :
