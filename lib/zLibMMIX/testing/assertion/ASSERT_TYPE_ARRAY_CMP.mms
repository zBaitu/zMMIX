    PREFIX :testing:assertion:
ASSERT_BYTE_ARRAY_EQ    SET assert_array:data_type,BYTE_TYPE
                        SET assert_array:sign,SIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array

ASSERT_BYTE_ARRAY_EQU   SET assert_array:data_type,BYTE_TYPE
                        SET assert_array:sign,UNSIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array

ASSERT_WYDE_ARRAY_EQ    SET assert_array:data_type,WYDE_TYPE
                        SET assert_array:sign,SIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array

ASSERT_WYDE_ARRAY_EQU   SET assert_array:data_type,WYDE_TYPE
                        SET assert_array:sign,UNSIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array

ASSERT_TETRA_ARRAY_EQ   SET assert_array:data_type,TETRA_TYPE
                        SET assert_array:sign,SIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array

ASSERT_TETRA_ARRAY_EQU  SET assert_array:data_type,TETRA_TYPE
                        SET assert_array:sign,UNSIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array

ASSERT_OCTA_ARRAY_EQ    SET assert_array:data_type,OCTA_TYPE
                        SET assert_array:sign,SIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array

ASSERT_OCTA_ARRAY_EQU   SET assert_array:data_type,OCTA_TYPE
                        SET assert_array:sign,UNSIGNED
                        SET assert_array:comparer,EQ
                        JMP assert_array
    PREFIX :
