    PREFIX :testing:assertion:ASSERT_OCTA_ARRAY_EQU
actual_array    IS $0
expected_array  IS $1
len_addr        IS $2

param   IS $3

                    GREG @
ASSERTION_STR       BYTE    "ASSERT_OCTA_ARRAY_EQU",#a,0
MAX_NUM_STR_LEN     IS      20

len                 GREG
pos                 GREG
offset              GREG
actual_value        GREG
expected_value      GREG
result              GREG
rj_bak              GREG

:testing:assertion:ASSERT_OCTA_ARRAY_EQU JMP @+4
        LDO     len,len_addr
        SET     pos,0
loop    CMP     result,pos,len
        BNN     result,end
        SLU     offset,pos,3
        LDOU    actual_value,actual_array,offset
        LDOU    expected_value,expected_array,offset
        CMP     result,actual_value,expected_value
        BNZ     result,failed
        ADDU    pos,pos,1
        JMP     loop

end     SET     $0,0
        POP     1,0

failed  GET     rj_bak,:rJ
        LDA     param+1,ASSERTION_STR
        SET     param+2,actual_value
        SET     param+3,expected_value
        SET     param+4,MAX_NUM_STR_LEN
        SET     param+5,pos
        PUSHJ   param,:testing:printer:print_array_unsigned_assertion_fail
        PUT     :rJ,rj_bak
        SET     $0,result
        POP     1,0
    PREFIX :
