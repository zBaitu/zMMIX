    PREFIX :testing:assertion:ASSERT_STR_EQ
actual_value_addr   IS $0
expected_value_addr IS $1

param   IS $2

                    GREG @
ASSERTION_STR       BYTE "ASSERT_STR_EQ",#a,0

pos                 GREG
actual_value        GREG
expected_value      GREG
result              GREG
rj_bak              GREG

:testing:assertion:ASSERT_STR_EQ JMP @+4
        SET     pos,0
loop    LDBU    actual_value,actual_value_addr,pos
        LDBU    expected_value,expected_value_addr,pos
        CMP     result,actual_value,expected_value
        BNZ     result,failed
        ADDU    pos,pos,1
        CMP     result,actual_value,0
        PBNZ    result,loop
        SET     $0,0
        POP     1,0

failed  GET     rj_bak,:rJ
        LDA     param+1,ASSERTION_STR
        SET     param+2,actual_value_addr
        SET     param+3,expected_value_addr
        SET     param+4,pos
        PUSHJ   param,:testing:printer:print_str_assertion_fail
        PUT     :rJ,rj_bak
        SET     $0,result
        POP     1,0
    PREFIX :
