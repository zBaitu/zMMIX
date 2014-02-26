    PREFIX :io:print_num:
num     IS $0
sign    IS $1

param IS $1

        GREG @
str     BYTE "                    ",#a,0
rj_bak  GREG

:io:print_num   GET     rj_bak,:rJ
                SET     param+1,num
                SET     param+2,sign
                LDA     param+3,str
                SET     param+4,20
                PUSHJ   param,:numeric:num_to_str
                SET     $255,param
                TRAP    0,:Fputs,:StdOut
                PUT     :rJ,rj_bak
                POP     0,0
    PREFIX :
