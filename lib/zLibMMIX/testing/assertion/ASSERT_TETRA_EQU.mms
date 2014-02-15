    PREFIX :testing:assertion:ASSERT_TETRA_EQU
actual_value_addr   IS $0
expected_value_addr IS $1

param   IS $2

                    GREG @
ASSERTION_STR       BYTE    "ASSERT_TETRA_EQU",#a,0
MAX_NUM_STR_LEN     IS      10

actual_value        GREG
expected_value      GREG
result              GREG
rj_bak              GREG

:testing:assertion:ASSERT_TETRA_EQU JMP @+4
        LDTU    actual_value,actual_value_addr
        LDTU    expected_value,expected_value_addr
        CMP     result,actual_value,expected_value
        BNZ     result,failed
        SET     $0,result
        POP     1,0

failed  GET     rj_bak,:rJ
        LDA     param+1,ASSERTION_STR
        SET     param+2,actual_value
        SET     param+3,expected_value
        SET     param+4,MAX_NUM_STR_LEN
        PUSHJ   param,:testing:printer:print_unsigned_assertion_fail
        PUT     :rJ,rj_bak
        SET     $0,result
        POP     1,0
    PREFIX :
