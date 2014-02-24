    PREFIX :testing:assertion:assert:
actual_value_addr   IS $0
expected_value_addr IS $1

param                   IS $2
param_assertion_str     IS param+1
param_actual_value      IS param+2
param_expected_value    IS param+3
param_max_num_str_len   IS param+4

BYTE_EQ_STR     BYTE "ASSERT_BYTE_EQ",#a,0
BYTE_NE_STR     BYTE "ASSERT_BYTE_NE",#a,0
BYTE_LT_STR     BYTE "ASSERT_BYTE_LT",#a,0
BYTE_LE_STR     BYTE "ASSERT_BYTE_LE",#a,0
BYTE_GT_STR     BYTE "ASSERT_BYTE_GT",#a,0
BYTE_GE_STR     BYTE "ASSERT_BYTE_GE",#a,0
BYTE_EQU_STR    BYTE "ASSERT_BYTE_EQU",#a,0
BYTE_NEU_STR    BYTE "ASSERT_BYTE_NEU",#a,0
                LOC (@+7)&-8
DATA_TYPE_TABLE GREG @
                OCTA BYTE_EQ_STR,BYTE_NE_STR,BYTE_LT_STR,BYTE_LE_STR,BYTE_GT_STR,BYTE_GE_STR
                OCTA BYTE_EQU_STR,BYTE_NEU_STR

BYTE_MAX_NUM_STR_LEN    BYTE 4
UBYTE_MAX_NUM_STR_LEN   BYTE 3
                        LOC (@+7)&-8
MAX_NUM_STR_LEN_TABLE   GREG @
                        OCTA BYTE_MAX_NUM_STR_LEN,UBYTE_MAX_NUM_STR_LEN

data_type       GREG
sign            GREG
comparer        GREG
actual_value    GREG
expected_value  GREG
entry           GREG
result          GREG
rj_bak          GREG
tmp             GREG

:testing:assertion:assert JMP @+4
        SLU     entry,data_type,2
        2ADDU   entry,data_type,entry
        2ADDU   entry,sign,entry
        ADDU    entry,entry,sign
        SLU     entry,entry,2
        SET     tmp,@+12
        ADDU    entry,entry,tmp
        GO      tmp,entry

        LDB     actual_value,actual_value_addr
        LDB     expected_value,expected_value_addr
        JMP     compare
        LDBU    actual_value,actual_value_addr
        LDBU    expected_value,expected_value_addr

compare CMP     result,actual_value,expected_value
        SLU     entry,comparer,3
        SET     tmp,@+12
        ADDU    entry,entry,tmp
        GO      tmp,entry

        BZ      result,passed
        JMP     failed
        BNZ     result,passed
        JMP     failed
        BN      result,passed
        JMP     failed
        BNP     result,passed
        JMP     failed
        BP      result,passed
        JMP     failed
        BNN     result,passed

failed  GET     rj_bak,:rJ
        SLU     entry,data_type,2
        2ADDU   entry,sign,entry
        ADDU    entry,entry,comparer
        SLU     entry,entry,3
        LDO     param_assertion_str,DATA_TYPE_TABLE,entry

        SLU     entry,data_type,2
        ADDU    entry,entry,sign
        SLU     entry,entry,3
        LDO     tmp,MAX_NUM_STR_LEN_TABLE,entry
        LDB     param_max_num_str_len,tmp

        SET     param_actual_value,actual_value
        SET     param_expected_value,expected_value

        BP      sign,0F
        PUSHJ   param,:testing:printer:print_assertion_fail
        JMP     1F
0H      PUSHJ   param,:testing:printer:print_unsigned_assertion_fail
1H      PUT     :rJ,rj_bak
        SET     $0,1
        POP     1,0

passed  SET     $0,0
        POP     1,0
   PREFIX :
