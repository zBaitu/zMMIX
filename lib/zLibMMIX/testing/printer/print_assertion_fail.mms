    PREFIX :testing:printer:print_assertion_fail
assertion_str   IS $0
actual_value    IS $1
expected_value  IS $2
max_str_len     IS $3
sign            IS $4

param IS $5

                    GREG @
actual_str_begin    GREG
expected_str_begin  GREG
actual_value_str    BYTE "                    ",#a,0
expected_value_str  BYTE "                    ",#a,0
rj_bak              GREG

:testing:printer:print_assertion_fail JMP @+4
    GET     rj_bak,:rJ
    SET     param+1,actual_value
    SET     param+2,sign
    LDA     param+3,actual_value_str
    SET     param+4,max_str_len
    PUSHJ   param,:numeric:num_to_str
    SET     actual_str_begin,param
    SET     param+1,expected_value
    SET     param+2,sign
    LDA     param+3,expected_value_str
    SET     param+4,max_str_len
    PUSHJ   param,:numeric:num_to_str
    SET     expected_str_begin,param

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

    PUT     :rJ,rj_bak
    POP     0,0
    PREFIX :
