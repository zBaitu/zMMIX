    PREFIX :testing:assertion:
ASSERT_STR_EQ       SET assert_str:case,DO_CASE
                    SET assert_str:comparer,EQ
                    JMP assert_str

ASSERT_STR_IC_EQ    SET assert_str:case,IGNORE_CASE
                    SET assert_str:comparer,EQ
                    JMP assert_str
    PREFIX :
