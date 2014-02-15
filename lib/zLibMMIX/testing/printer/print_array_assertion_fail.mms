    PREFIX :testing:printer:print_array_assertion_fail
assertion_str   IS $0
actual_value    IS $1
expected_value  IS $2
max_str_len     IS $3
pos             IS $4

param   IS $5
num     IS param+1
str     IS param+2
str_len IS param+3

actual_str_begin    GREG
expected_str_begin  GREG
actual_value_str    BYTE    "                    ",#a,0
expected_value_str  BYTE    "                    ",#a,0
pos_str_begin       GREG
pos_str             BYTE    "                    ",#a,0
pos_str_len         IS      20
rj_bak              GREG

:testing:printer:print_array_assertion_fail JMP @+4
    GET     rj_bak,:rJ
    SET     num,actual_value
    LDA     str,actual_value_str
    SET     str_len,max_str_len
    PUSHJ   param,:numeric:num_to_str
    SET     actual_str_begin,param
    SET     num,expected_value
    LDA     str,expected_value_str
    SET     str_len,max_str_len
    PUSHJ   param,:numeric:num_to_str
    SET     expected_str_begin,param
    SET     num,pos
    LDA     str,pos_str
    SET     str_len,pos_str_len
    PUSHJ   param,:numeric:num_to_str
    SET     pos_str_begin,param

    LDA     $255,:testing:printer:NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,assertion_str
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:ACTURAL_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,actual_str_begin
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:EXPECTED_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,expected_str_begin
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:POS_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,pos_str_begin
    TRAP    0,:Fputs,:StdOut

    PUT     :rJ,rj_bak
    POP     0,0
    PREFIX :
