    PREFIX :numeric:num_to_str:
num IS $0
str IS $1
len IS $2

is_negative GREG
neg_char    GREG '-'
pos         GREG
remainder   GREG

:numeric:num_to_str CMP     is_negative,num,0
                    PBNN    is_negative,begin
                    NEGU    num,0,num

begin               SET     pos,len
loop                SUB     pos,pos,1
                    DIVU    num,num,10
                    GET     remainder,:rR
                    INCL    remainder,#30
                    STB     remainder,str,pos
                    PBP     num,loop
                    PBNN    is_negative,end
                    SUB     pos,pos,1
                    STB     neg_char,str,pos

end                 ADD     $0,str,pos
                    POP     1,0
    PREFIX :
