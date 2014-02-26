    PREFIX :testing:printer:print_str_assertion_fail
assertion_str   IS $0
actual_str      IS $1
expected_str    IS $2
pos             IS $3
param           IS $4

                GREG @
pos_str_begin   GREG
pos_str         BYTE    "                    ",#a,0
pos_str_len     IS      20
rj_bak          GREG

:testing:printer:print_str_assertion_fail JMP @+4
    GET     rj_bak,:rJ
    SET     param+1,pos
    SET     param+2,:numeric:SIGNED
    LDA     param+3,pos_str
    SET     param+4,pos_str_len
    PUSHJ   param,:numeric:num_to_str
    SET     pos_str_begin,param

    LDA     $255,:testing:printer:NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,assertion_str
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:ACTURAL_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,actual_str
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:EXPECTED_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,expected_str
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:testing:printer:POS_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,pos_str_begin
    TRAP    0,:Fputs,:StdOut

    PUT     :rJ,rj_bak
    POP     0,0
    PREFIX :
