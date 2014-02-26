    PREFIX :testing:printer:print_array_assertion_fail
assertion_str   IS $0
actual_value    IS $1
expected_value  IS $2
max_str_len     IS $3
pos             IS $4
sign            IS $5
param           IS $6

                GREG    @
pos_str_begin   GREG
pos_str         BYTE    "                    ",#a,0
pos_str_len     IS      20
rj_bak          GREG

:testing:printer:print_array_assertion_fail JMP @+4
    GET     rj_bak,:rJ
    SET     param+1,assertion_str
    SET     param+2,actual_value
    SET     param+3,expected_value
    SET     param+4,max_str_len
    SET     param+5,sign
    PUSHJ   param,:testing:printer:print_assertion_fail

    SET     param+1,pos
    SET     param+2,:numeric:SIGNED
    LDA     param+3,pos_str
    SET     param+4,pos_str_len
    PUSHJ   param,:numeric:num_to_str
    SET     pos_str_begin,param

    LDA     $255,:testing:printer:POS_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,pos_str_begin
    TRAP    0,:Fputs,:StdOut

    PUT     :rJ,rj_bak
    POP     0,0
    PREFIX :
