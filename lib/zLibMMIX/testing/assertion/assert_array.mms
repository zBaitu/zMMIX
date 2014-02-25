    PREFIX :testing:assertion:assert_array:
actual_value_addr   IS $0
expected_value_addr IS $1
len_addr            IS $2

param IS $3

                GREG @
BYTE_EQ_STR     BYTE "ASSERT_BYTE_ARRAY_EQ",#a,0
BYTE_NE_STR     BYTE "ASSERT_BYTE_ARRAY_NE",#a,0
BYTE_LT_STR     BYTE "ASSERT_BYTE_ARRAY_LT",#a,0
BYTE_LE_STR     BYTE "ASSERT_BYTE_ARRAY_LE",#a,0
BYTE_GT_STR     BYTE "ASSERT_BYTE_ARRAY_GT",#a,0
BYTE_GE_STR     BYTE "ASSERT_BYTE_ARRAY_GE",#a,0
BYTE_EQU_STR    BYTE "ASSERT_BYTE_ARRAY_EQU",#a,0
BYTE_NEU_STR    BYTE "ASSERT_BYTE_ARRAY_NEU",#a,0
BYTE_LTU_STR    BYTE "ASSERT_BYTE_ARRAY_LTU",#a,0
BYTE_LEU_STR    BYTE "ASSERT_BYTE_ARRAY_LEU",#a,0
BYTE_GTU_STR    BYTE "ASSERT_BYTE_ARRAY_GTU",#a,0
BYTE_GEU_STR    BYTE "ASSERT_BYTE_ARRAY_GEU",#a,0

WYDE_EQ_STR     BYTE "ASSERT_WYDE_ARRAY_EQ",#a,0
WYDE_NE_STR     BYTE "ASSERT_WYDE_ARRAY_NE",#a,0
WYDE_LT_STR     BYTE "ASSERT_WYDE_ARRAY_LT",#a,0
WYDE_LE_STR     BYTE "ASSERT_WYDE_ARRAY_LE",#a,0
WYDE_GT_STR     BYTE "ASSERT_WYDE_ARRAY_GT",#a,0
WYDE_GE_STR     BYTE "ASSERT_WYDE_ARRAY_GE",#a,0
WYDE_EQU_STR    BYTE "ASSERT_WYDE_ARRAY_EQU",#a,0
WYDE_NEU_STR    BYTE "ASSERT_WYDE_ARRAY_NEU",#a,0
WYDE_LTU_STR    BYTE "ASSERT_WYDE_ARRAY_LTU",#a,0
WYDE_LEU_STR    BYTE "ASSERT_WYDE_ARRAY_LEU",#a,0
WYDE_GTU_STR    BYTE "ASSERT_WYDE_ARRAY_GTU",#a,0
WYDE_GEU_STR    BYTE "ASSERT_WYDE_ARRAY_GEU",#a,0

TETRA_EQ_STR    BYTE "ASSERT_TETRA_ARRAY_EQ",#a,0
TETRA_NE_STR    BYTE "ASSERT_TETRA_ARRAY_NE",#a,0
TETRA_LT_STR    BYTE "ASSERT_TETRA_ARRAY_LT",#a,0
TETRA_LE_STR    BYTE "ASSERT_TETRA_ARRAY_LE",#a,0
TETRA_GT_STR    BYTE "ASSERT_TETRA_ARRAY_GT",#a,0
TETRA_GE_STR    BYTE "ASSERT_TETRA_ARRAY_GE",#a,0
TETRA_EQU_STR   BYTE "ASSERT_TETRA_ARRAY_EQU",#a,0
TETRA_NEU_STR   BYTE "ASSERT_TETRA_ARRAY_NEU",#a,0
TETRA_LTU_STR   BYTE "ASSERT_TETRA_ARRAY_LTU",#a,0
TETRA_LEU_STR   BYTE "ASSERT_TETRA_ARRAY_LEU",#a,0
TETRA_GTU_STR   BYTE "ASSERT_TETRA_ARRAY_GTU",#a,0
TETRA_GEU_STR   BYTE "ASSERT_TETRA_ARRAY_GEU",#a,0

OCTA_EQ_STR     BYTE "ASSERT_OCTA_ARRAY_EQ",#a,0
OCTA_NE_STR     BYTE "ASSERT_OCTA_ARRAY_NE",#a,0
OCTA_LT_STR     BYTE "ASSERT_OCTA_ARRAY_LT",#a,0
OCTA_LE_STR     BYTE "ASSERT_OCTA_ARRAY_LE",#a,0
OCTA_GT_STR     BYTE "ASSERT_OCTA_ARRAY_GT",#a,0
OCTA_GE_STR     BYTE "ASSERT_OCTA_ARRAY_GE",#a,0
OCTA_EQU_STR    BYTE "ASSERT_OCTA_ARRAY_EQU",#a,0
OCTA_NEU_STR    BYTE "ASSERT_OCTA_ARRAY_NEU",#a,0
OCTA_LTU_STR    BYTE "ASSERT_OCTA_ARRAY_LTU",#a,0
OCTA_LEU_STR    BYTE "ASSERT_OCTA_ARRAY_LEU",#a,0
OCTA_GTU_STR    BYTE "ASSERT_OCTA_ARRAY_GTU",#a,0
OCTA_GEU_STR    BYTE "ASSERT_OCTA_ARRAY_GEU",#a,0
                    LOC (@+7)&-8
ASSERTION_STR_TABLE GREG @
                    OCTA BYTE_EQ_STR,BYTE_NE_STR,BYTE_LT_STR,BYTE_LE_STR,BYTE_GT_STR,BYTE_GE_STR
                    OCTA BYTE_EQU_STR,BYTE_NEU_STR,BYTE_LTU_STR,BYTE_LEU_STR,BYTE_GTU_STR,BYTE_GEU_STR
                    OCTA WYDE_EQ_STR,WYDE_NE_STR,WYDE_LT_STR,WYDE_LE_STR,WYDE_GT_STR,WYDE_GE_STR
                    OCTA WYDE_EQU_STR,WYDE_NEU_STR,WYDE_LTU_STR,WYDE_LEU_STR,WYDE_GTU_STR,WYDE_GEU_STR
                    OCTA TETRA_EQ_STR,TETRA_NE_STR,TETRA_LT_STR,TETRA_LE_STR,TETRA_GT_STR,TETRA_GE_STR
                    OCTA TETRA_EQU_STR,TETRA_NEU_STR,TETRA_LTU_STR,TETRA_LEU_STR,TETRA_GTU_STR,TETRA_GEU_STR
                    OCTA OCTA_EQ_STR,OCTA_NE_STR,OCTA_LT_STR,OCTA_LE_STR,OCTA_GT_STR,OCTA_GE_STR
                    OCTA OCTA_EQU_STR,OCTA_NEU_STR,OCTA_LTU_STR,OCTA_LEU_STR,OCTA_GTU_STR,OCTA_GEU_STR

BYTE_MAX_NUM_STR_LEN    BYTE 4
UBYTE_MAX_NUM_STR_LEN   BYTE 3
WYDE_MAX_NUM_STR_LEN    BYTE 6
UWYDE_MAX_NUM_STR_LEN   BYTE 5
TETRA_MAX_NUM_STR_LEN   BYTE 11
UTETRA_MAX_NUM_STR_LEN  BYTE 10
OCTA_MAX_NUM_STR_LEN    BYTE 20
UOCTA_MAX_NUM_STR_LEN   BYTE 20
                        LOC (@+7)&-8
MAX_NUM_STR_LEN_TABLE   GREG @
                        OCTA BYTE_MAX_NUM_STR_LEN,UBYTE_MAX_NUM_STR_LEN
                        OCTA WYDE_MAX_NUM_STR_LEN,UWYDE_MAX_NUM_STR_LEN
                        OCTA TETRA_MAX_NUM_STR_LEN,UTETRA_MAX_NUM_STR_LEN
                        OCTA OCTA_MAX_NUM_STR_LEN,UOCTA_MAX_NUM_STR_LEN

data_type       GREG
sign            GREG
comparer        GREG
actual_value    GREG
expected_value  GREG
len             GREG
pos             GREG
offset          GREG
load_entry      GREG
cmp_entry       GREG
table_entry     GREG
result          GREG
rj_bak          GREG
tmp             GREG

:testing:assertion:assert_array JMP @+4
        SLU     load_entry,data_type,3
        4ADDU   load_entry,sign,load_entry
        SLU     load_entry,load_entry,2
        SET     tmp,@+(7<<2)
        ADDU    load_entry,load_entry,tmp

        LDO     len,len_addr
        SET     pos,0
loop    CMP     result,pos,len
        BNN     result,passed
        GO      tmp,load_entry

        SLU     offset,pos,0
        LDB     actual_value,actual_value_addr,offset
        LDB     expected_value,expected_value_addr,offset
        JMP     compare
        SLU     offset,pos,0
        LDBU    actual_value,actual_value_addr,offset
        LDBU    expected_value,expected_value_addr,offset
        JMP     compare
        SLU     offset,pos,1
        LDW     actual_value,actual_value_addr,offset
        LDW     expected_value,expected_value_addr,offset
        JMP     compare
        SLU     offset,pos,1
        LDWU    actual_value,actual_value_addr,offset
        LDWU    expected_value,expected_value_addr,offset
        JMP     compare
        SLU     offset,pos,2
        LDT     actual_value,actual_value_addr,offset
        LDT     expected_value,expected_value_addr,offset
        JMP     compare
        SLU     offset,pos,2
        LDTU    actual_value,actual_value_addr,offset
        LDTU    expected_value,expected_value_addr,offset
        JMP     compare
        SLU     offset,pos,3
        LDO     actual_value,actual_value_addr,offset
        LDO     expected_value,expected_value_addr,offset
        JMP     compare
        SLU     offset,pos,3
        LDOU    actual_value,actual_value_addr,offset
        LDOU    expected_value,expected_value_addr,offset
        JMP     compare

compare CMP     result,actual_value,expected_value
        SLU     cmp_entry,comparer,3
        SET     tmp,@+12
        ADDU    cmp_entry,cmp_entry,tmp
        GO      tmp,cmp_entry

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

next    ADDU    pos,pos,1
        JMP     loop

failed  GET     rj_bak,:rJ
        SLU     table_entry,data_type,3
        4ADDU   table_entry,data_type,table_entry
        4ADDU   table_entry,sign,table_entry
        2ADDU   table_entry,sign,table_entry
        ADDU    table_entry,table_entry,comparer
        SLU     table_entry,table_entry,3
        LDO     param+1,ASSERTION_STR_TABLE,table_entry

        SLU     table_entry,data_type,1
        ADDU    table_entry,table_entry,sign
        SLU     table_entry,table_entry,3
        LDO     tmp,MAX_NUM_STR_LEN_TABLE,table_entry
        LDB     param+4,tmp

        SET     param+2,actual_value
        SET     param+3,expected_value
        SET     param+5,pos

        BP      sign,0F
        PUSHJ   param,:testing:printer:print_array_assertion_fail
        JMP     1F
0H      PUSHJ   param,:testing:printer:print_array_unsigned_assertion_fail
1H      PUT     :rJ,rj_bak
        SET     $0,1
        POP     1,0

passed  SET     $0,0
        POP     1,0
   PREFIX :
