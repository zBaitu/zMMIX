    PREFIX :ASSERT_STR_IC_EQ
actual_value_addr   IS $0
expected_value_addr IS $1
param               IS $2

                    GREG @
ASSERTION_STR       BYTE "ASSERT_STR_IC_EQ",#a,0
pos                 GREG
actual_value        GREG
expected_value      GREG
result              GREG
rj_bak              GREG

:ASSERT_STR_IC_EQ   GET     rj_bak,:rJ
                    SET     pos,0
loop                LDBU    actual_value,actual_value_addr,pos
                    SET     param+1,actual_value
                    PUSHJ   param,:char:tolower
                    SET     actual_value,param

                    LDBU    expected_value,expected_value_addr,pos
                    SET     param+1,expected_value
                    PUSHJ   param,:char:tolower
                    SET     expected_value,param

                    CMP     result,actual_value,expected_value
                    BNZ     result,failed
                    ADDU    pos,pos,1
                    CMP     result,actual_value,0
                    PBNZ    result,loop
                    PUT     :rJ,rj_bak
                    SET     $0,0
                    POP     0,0

failed              LDA     param+1,ASSERTION_STR
                    SET     param+2,actual_value_addr
                    SET     param+3,expected_value_addr
                    SET     param+4,pos
                    PUSHJ   param,:print_str_assertion_fail
                    PUT     :rJ,rj_bak
                    SET     $0,result
                    POP     1,0
    PREFIX :