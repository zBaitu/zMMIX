    PREFIX :print_unsigned_assertion_fail
assertion_str   IS $0
actual_value    IS $1
expected_value  IS $2
max_str_len     IS $3
param           IS $4
num             IS param+1
str             IS param+2
str_len         IS param+3
                    
                    GREG @
actual_str_begin    GREG
expected_str_begin  GREG
rj_bak              GREG
ACTURAL_STR         BYTE "actual:   ",0
EXPECTED_STR        BYTE "expected: ",0
NEW_LINE            BYTE #a,0
actual_value_str    BYTE "                    ",#a,0
expected_value_str  BYTE "                    ",#a,0

:print_unsigned_assertion_fail  GET     rj_bak,:rJ
                                SET     num,actual_value
                                LDA     str,actual_value_str
                                SET     str_len,max_str_len
                                PUSHJ   param,:unsigned_num_to_str
                                SET     actual_str_begin,param
                                SET     num,expected_value
                                LDA     str,expected_value_str
                                SET     str_len,max_str_len
                                PUSHJ   param,:unsigned_num_to_str
                                SET     expected_str_begin,param

                                LDA     $255,NEW_LINE
                                TRAP    0,:Fputs,:StdOut
                                LDA     $255,assertion_str
                                TRAP    0,:Fputs,:StdOut
                                LDA     $255,ACTURAL_STR
                                TRAP    0,:Fputs,:StdOut
                                LDA     $255,actual_str_begin
                                TRAP    0,:Fputs,:StdOut
                                LDA     $255,EXPECTED_STR
                                TRAP    0,:Fputs,:StdOut
                                LDA     $255,expected_str_begin
                                TRAP    0,:Fputs,:StdOut

                                PUT     :rJ,rj_bak
                                POP     0,0
    PREFIX :
