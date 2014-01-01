               LOC Data_Segment
               GREG @
case_result    GREG
suite_result   GREG
test_result    GREG
tmp_reg        GREG
NEW_LINE       BYTE #a,0
TEST_ALL_STR   BYTE "  TEST_ALL",0
TEST_SUITE_STR BYTE "  TEST_SUITE",0
TEST_CASE_STR  BYTE "  TEST_CASE ",0
BLANK_STR      BYTE "        ",0
PASSED_STR     BYTE "[PASSED]",0
FAILED_STR     BYTE "[FAILED]",0

    GREG @
    PREFIX :test_EXPECT_WYDE_EQ:
suite_name    BYTE " test_EXPECT_WYDE_EQ ",0
    PREFIX :test_EXPECT_WYDE_EQ:eq:
case_name    BYTE " eq ",0
left    WYDE 12345
right   WYDE 12345

    PREFIX :test_EXPECT_WYDE_EQ:ne:
case_name    BYTE " ne ",0
left    WYDE #8000
right   WYDE #8001

    PREFIX :


    LOC #100
    PREFIX :NumToStr
num IS $0
str IS $1
len IS $2

is_negative GREG
neg_char    GREG '-'
pos         GREG
remainder   GREG

:NumToStr   CMP     is_negative,num,0
            PBNN    is_negative,begin
            NEG     num,0,num

begin       SET     pos,len
loop        SUB     pos,pos,1
            DIV     num,num,10
            GET     remainder,:rR
            INCL    remainder,#30
            STB     remainder,str,pos
            PBP     num,loop
            PBNN    is_negative,end
            SUB     pos,pos,1
            STB     neg_char,str,pos

end         ADD     $0,str,pos
            POP     1,0
    PREFIX :

    PREFIX :UnsignedNumToStr
num IS $0
str IS $1
len IS $2

neg_char    GREG '-'
pos         GREG
remainder   GREG

:UnsignedNumToStr   SET     pos,len
loop                SUB     pos,pos,1
                    DIVU    num,num,10
                    GET     remainder,:rR
                    INCL    remainder,#30
                    STB     remainder,str,pos
                    PBP     num,loop
                    ADD     $0,str,pos
                    POP     1,0
    PREFIX :

    PREFIX :PrintAssetionFail
assertion_str   IS $0
actual_value    IS $1
expected_value  IS $2
max_str_len     IS $3
param           IS $4
num             IS param+1
str             IS param+2
str_len         IS param+3

                    GREG @
actual_str_begin    GREG
expected_str_begin  GREG
rj_bak              GREG
ACTURAL_STR         BYTE "actual:   ",0
EXPECTED_STR        BYTE "expected: ",0
NEW_LINE            BYTE #a,0
actual_value_str    BYTE "                    ",#a,0
expected_value_str  BYTE "                    ",#a,0

:PrintAssetionFail  GET     rj_bak,:rJ
                    SET     num,actual_value
                    LDA     str,actual_value_str
                    SET     str_len,max_str_len
                    PUSHJ   param,:NumToStr
                    SET     actual_str_begin,param
                    SET     num,expected_value
                    LDA     str,expected_value_str
                    SET     str_len,max_str_len
                    PUSHJ   param,:NumToStr
                    SET     expected_str_begin,param

                    LDA     $255,NEW_LINE
                    TRAP    0,:Fputs,:StdOut
                    LDA     $255,assertion_str
                    TRAP    0,:Fputs,:StdOut
                    LDA     $255,ACTURAL_STR
                    TRAP    0,:Fputs,:StdOut
                    LDA     $255,actual_str_begin
                    TRAP    0,:Fputs,:StdOut
                    LDA     $255,EXPECTED_STR
                    TRAP    0,:Fputs,:StdOut
                    LDA     $255,expected_str_begin
                    TRAP    0,:Fputs,:StdOut

                    PUT     :rJ,rj_bak
                    POP     0,0
    PREFIX :

    PREFIX :PrintUnsignedAssetionFail
assertion_str   IS $0
actual_value    IS $1
expected_value  IS $2
max_str_len     IS $3
param           IS $4
num             IS param+1
str             IS param+2
str_len         IS param+3
                    
                    GREG @
actual_str_begin    GREG
expected_str_begin  GREG
rj_bak              GREG
ACTURAL_STR         BYTE "actual:   ",0
EXPECTED_STR        BYTE "expected: ",0
NEW_LINE            BYTE #a,0
actual_value_str    BYTE "                    ",#a,0
expected_value_str  BYTE "                    ",#a,0

:PrintUnsignedAssetionFail  GET     rj_bak,:rJ
                            SET     num,actual_value
                            LDA     str,actual_value_str
                            SET     str_len,max_str_len
                            PUSHJ   param,:UnsignedNumToStr
                            SET     actual_str_begin,param
                            SET     num,expected_value
                            LDA     str,expected_value_str
                            SET     str_len,max_str_len
                            PUSHJ   param,:UnsignedNumToStr
                            SET     expected_str_begin,param

                            LDA     $255,NEW_LINE
                            TRAP    0,:Fputs,:StdOut
                            LDA     $255,assertion_str
                            TRAP    0,:Fputs,:StdOut
                            LDA     $255,ACTURAL_STR
                            TRAP    0,:Fputs,:StdOut
                            LDA     $255,actual_str_begin
                            TRAP    0,:Fputs,:StdOut
                            LDA     $255,EXPECTED_STR
                            TRAP    0,:Fputs,:StdOut
                            LDA     $255,expected_str_begin
                            TRAP    0,:Fputs,:StdOut

                            PUT     :rJ,rj_bak
                            POP     0,0
    PREFIX :

    PREFIX :PrintStrAssetionFail
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


:PrintStrAssetionFail GET rj_bak,:rJ
    SET     num,pos
    LDA     str,pos_str
    SET     str_len,20
    PUSHJ   param,:NumToStr
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
                PUSHJ   $0,:PrintAssetionFail
                PUT     :rJ,rj_bak
                SET     $0,result
                POP     1,0
    PREFIX :

Main   JMP @+4
    PREFIX :test_EXPECT_WYDE_EQ:
    LDA     $255,:BLANK_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:TEST_SUITE_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,suite_name
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:NEW_LINE
    TRAP    0,:Fputs,:StdOut

    PREFIX :test_EXPECT_WYDE_EQ:eq:
    LDA     $1,left
    LDA     $2,right
    PUSHJ   $0,:EXPECT_WYDE_EQ
    CSNZ    :case_result,$0,1
    CSNZ    :suite_result,$0,1
    CSNZ    :test_result,$0,1
    LDA     $255,:FAILED_STR
    LDA     :tmp_reg,:PASSED_STR
    CMP     $0,:case_result,0
    CSZ     $255,$0,:tmp_reg
    TRAP    0,:Fputs,:StdOut
    SET     :case_result,0
    LDA     $255,:TEST_CASE_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,case_name
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:NEW_LINE
    TRAP    0,:Fputs,:StdOut

    PREFIX :test_EXPECT_WYDE_EQ:ne:
    LDA     $1,left
    LDA     $2,right
    PUSHJ   $0,:EXPECT_WYDE_EQ
    CSNZ    :case_result,$0,1
    CSNZ    :suite_result,$0,1
    CSNZ    :test_result,$0,1
    LDA     $255,:FAILED_STR
    LDA     :tmp_reg,:PASSED_STR
    CMP     $0,:case_result,0
    CSZ     $255,$0,:tmp_reg
    TRAP    0,:Fputs,:StdOut
    SET     :case_result,0
    LDA     $255,:TEST_CASE_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,case_name
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:NEW_LINE
    TRAP    0,:Fputs,:StdOut

    PREFIX :test_EXPECT_WYDE_EQ:
    LDA     $255,:FAILED_STR
    LDA     :tmp_reg,:PASSED_STR
    CMP     $0,:suite_result,0
    CSZ     $255,$0,:tmp_reg
    TRAP    0,:Fputs,:StdOut
    SET     :suite_result,0
    LDA     $255,:TEST_SUITE_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,suite_name
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:NEW_LINE
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:NEW_LINE
    TRAP    0,:Fputs,:StdOut
    PREFIX :

    LDA     $255,:FAILED_STR
    LDA     :tmp_reg,:PASSED_STR
    CMP     $0,:test_result,0
    CSZ     $255,$0,:tmp_reg
    TRAP    0,:Fputs,:StdOut
    SET     :test_result,0
    LDA     $255,:TEST_ALL_STR
    TRAP    0,:Fputs,:StdOut
    LDA     $255,:NEW_LINE
    TRAP    0,:Fputs,:StdOut
