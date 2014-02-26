    PREFIX :testing:assertion:assert_str:
actual_value_addr   IS $0
expected_value_addr IS $1
param               IS $2

                GREG @
STR_EQ_STR      BYTE "ASSERT_STR_EQ",#a,0
STR_NE_STR      BYTE "ASSERT_STR_NE",#a,0
STR_LT_STR      BYTE "ASSERT_STR_LT",#a,0
STR_LE_STR      BYTE "ASSERT_STR_LE",#a,0
STR_GT_STR      BYTE "ASSERT_STR_GT",#a,0
STR_GE_STR      BYTE "ASSERT_STR_GE",#a,0

STR_IC_EQ_STR   BYTE "ASSERT_STR_IC_EQ",#a,0
STR_IC_NE_STR   BYTE "ASSERT_STR_IC_NE",#a,0
STR_IC_LT_STR   BYTE "ASSERT_STR_IC_LT",#a,0
STR_IC_LE_STR   BYTE "ASSERT_STR_IC_LE",#a,0
STR_IC_GT_STR   BYTE "ASSERT_STR_IC_GT",#a,0
STR_IC_GE_STR   BYTE "ASSERT_STR_IC_GE",#a,0
                    LOC (@+7)&-8
ASSERTION_STR_TABLE GREG @
                    OCTA STR_EQ_STR,STR_NE_STR,STR_LT_STR,STR_LE_STR,STR_GT_STR,STR_GE_STR
                    OCTA STR_IC_EQ_STR,STR_IC_NE_STR,STR_IC_LT_STR,STR_IC_LE_STR,STR_IC_GT_STR,STR_IC_GE_STR

case            GREG
comparer        GREG
actual_value    GREG
expected_value  GREG
pos             GREG
entry           GREG
result          GREG
rj_bak          GREG
tmp             GREG

:testing:assertion:assert_str JMP @+4
        PBZ     case,begin
        GET     rj_bak,:rJ 
        SET     param+1,actual_value_addr
        PUSHJ   param,:string:tolower
        SET     param+1,expected_value_addr
        PUSHJ   param,:string:tolower
        PUT     :rJ,rj_bak

begin   SLU     entry,comparer,3
        SET     tmp,@+(7<<2)
        ADDU    entry,entry,tmp

        SET     pos,0
loop    LDBU    actual_value,actual_value_addr,pos
        LDBU    expected_value,expected_value_addr,pos
        CMP     result,actual_value,expected_value
        GO      tmp,entry

        BZ      result,next
        JMP     failed
        BNZ     result,next
        JMP     failed
        BN      result,next
        JMP     failed
        BNP     result,next
        JMP     failed
        BP      result,next
        JMP     failed
        BNN     result,next
        JMP     failed

next    ADDU    pos,pos,1
        CMP     result,actual_value,0
        PBNZ    result,loop
        SET     $0,0
        POP     1,0

failed  GET     rj_bak,:rJ
        4ADDU   entry,case,entry
        2ADDU   entry,case,entry
        ADDU    entry,entry,comparer
        SLU     entry,entry,3
        LDO     param+1,ASSERTION_STR_TABLE,entry
        SET     param+2,actual_value_addr
        SET     param+3,expected_value_addr
        SET     param+4,pos
        PUSHJ   param,:testing:printer:print_str_assertion_fail
        PUT     :rJ,rj_bak
        SET     $0,1
        POP     1,0
    PREFIX :
