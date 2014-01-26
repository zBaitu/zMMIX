    PREFIX :EXPECT_WYDE_EQ
value_addr          IS $0
expected_value_addr IS $1
MAX_NUM_STR_LEN     IS 6

                    GREG @
ASSERTION_STR       BYTE "EXPECT_WYDE_EQ",#a,0
value               GREG
expected_value      GREG
result              GREG
rj_bak              GREG

:EXPECT_WYDE_EQ LDW     value,value_addr
                LDW     expected_value,expected_value_addr
                CMP     result,value,expected_value
                BNZ     result,failed
                SET     $0,result
                POP     1,0

failed          GET     rj_bak,:rJ
                LDA     $1,ASSERTION_STR
                SET     $2,value
                SET     $3,expected_value
                SET     $4,MAX_NUM_STR_LEN
                PUSHJ   $0,:print_assertion_fail
                PUT     :rJ,rj_bak
                SET     $0,result
                POP     1,0
    PREFIX :