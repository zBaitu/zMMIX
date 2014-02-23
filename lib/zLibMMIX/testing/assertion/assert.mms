    PREFIX :testing:assertion:assert:
actual_value_addr   IS $0
expected_value_addr IS $1

param                   IS $2
param_assertion_str     IS param+1
param_actual_value      IS param+2
param_expected_value    IS param+3
param_max_num_str_len   IS param+4

                GREG @
BYTE_EQ_STR     BYTE "ASSERT_BYTE_EQ",#a,0
BYTE_NE_STR     BYTE "ASSERT_BYTE_NE",#a,0
BYTE_EQU_STR    BYTE "ASSERT_BYTE_EQU",#a,0
BYTE_NEU_STR    BYTE "ASSERT_BYTE_NEU",#a,0
DATA_TYPE_TABLE GREG @
                OCTA BYTE_EQ_STR,BYTE_NE_STR,BYTE_EQU_STR,BYTE_NEU_STR

BYTE_MAX_NUM_STR_LEN    BYTE 4
MAX_NUM_STR_LEN_TABLE   GREG @
                        OCTA BYTE_MAX_NUM_STR_LEN

data_type       GREG
is_signed       GREG
is_equal        GREG
actual_value    GREG
expected_value  GREG
entry           GREG
result          GREG
rj_bak          GREG
tmp             GREG

:testing:assertion:assert JMP @+4
        % goto load data entry
        SLU     entry,data_type,2
        SLU     tmp,is_signed,1
        ADDU    entry,entry,tmp 
        ADDU    entry,entry,is_equal
        SET     tmp,@+12
        ADDU    entry,entry,tmp
        GO      tmp,entry

        LDB     actual_value,actual_value_addr
        LDB     expected_value,expected_value_addr
        JMP     compare
        LDBU    actual_value,actual_value_addr
        LDBU    expected_value,expected_value_addr

compare CMP     result,actual_value,expected_value
        BP      is_equal,ne_cmp
eq_cmp  BZ      result,passed
        JMP     failed
ne_cmp  BNZ     result,passed

failed  GET     rj_bak,:rJ
        SLU     entry,data_type,2
        SLU     tmp,is_signed,1
        ADDU    entry,entry,tmp 
        ADDU    entry,entry,is_equal
        LDO     param_assertion_str,DATA_TYPE_TABLE,entry

        SLU     entry,data_type,2
        SLU     tmp,is_signed,1
        ADDU    entry,entry,tmp 
        LDO     tmp,MAX_NUM_STR_LEN_TABLE,entry
        LDB     param_max_num_str_len,tmp

        SET     param_actual_value,actual_value
        SET     param_expected_value,expected_value
        PUSHJ   param,:testing:printer:print_assertion_fail
        PUT     :rJ,rj_bak

passed  SET     $0,result
        POP     1,0
   PREFIX :
