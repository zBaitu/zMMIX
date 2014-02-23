    PREFIX :io:print_num:
num IS $0

param           IS $1
param_num       IS param+1
param_str       IS param+2
param_str_len   IS param+3

            GREG @
str         BYTE "                    ",#a,0
rj_bak      GREG

:io:print_num   GET     rj_bak,:rJ
                SET     param_num,num
                LDA     param_str,str
                SET     param_str_len,20
                PUSHJ   param,:numeric:num_to_str
                SET     $255,param
                TRAP    0,:Fputs,:StdOut
                PUT     :rJ,rj_bak
                POP     0,0
    PREFIX :
