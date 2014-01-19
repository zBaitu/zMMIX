    PREFIX :print_str_assertion_fail
assertion_str   IS $0
actual_str      IS $1
expected_str    IS $2
pos             IS $3
param           IS $4
num             IS param+1
str             IS param+2
str_len         IS param+3
pos_str_begin   GREG
rj_bak          GREG

                GREG @
ACTURAL_STR     BYTE "actual:   ",0
EXPECTED_STR    BYTE "expected: ",0
POS_STR         BYTE "pos:      ",0
NEW_LINE        BYTE #a,0
pos_str         BYTE "                    ",#a,0


:print_str_assertion_fail GET rj_bak,:rJ
    SET     num,pos
    LDA     str,pos_str
    SET     str_len,20
    PUSHJ   param,:num_to_str
    SET     pos_str_begin,param
    PUT     :rJ,rj_bak

    LDA     $255,NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,assertion_str
    TRAP    0,:Fputs,:StdOut
    LDA     $255,ACTURAL_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,actual_str
    TRAP    0,:Fputs,:StdOut
    LDA     $255,NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,EXPECTED_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,expected_str
    TRAP    0,:Fputs,:StdOut
    LDA     $255,NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,POS_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,pos_str_begin
    TRAP    0,:Fputs,:StdOut

    POP     0,0
    PREFIX :
