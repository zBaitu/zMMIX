    PREFIX :numeric:unsigned_num_to_str:
num IS $0
str IS $1
len IS $2

pos         GREG
remainder   GREG

:numeric:unsigned_num_to_str JMP @+4
        SET     pos,len
loop    SUB     pos,pos,1
        DIVU    num,num,10
        GET     remainder,:rR
        INCL    remainder,#30
        STB     remainder,str,pos
        PBP     num,loop
        ADD     $0,str,pos
        POP     1,0
    PREFIX :
