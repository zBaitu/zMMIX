zMMIX ---- MMIX Unit Test Framework
===============================

https://github.com/zBaitu/zMMIX

Overview
--------
zMMIX is an unit test framwork for [MMIX](http://mmix.cs.hm.edu/).  
It can help you to test mms program without writing a :Main routine. The framework use data-driven testing, you only need to care about the input and output.

Make, Install, Use
------------------

### make and install
```
mkdir build
cd build
cmake ..
make
make install
```

### use
```
% test for demo.mms
zmmix_gt test_demo.mmt
mmixal -b 120 test_demo.mms
mmix test_demo
```
For usual, test source use **mmt** as suffix. **For current, .mms and .mmt must be PUT IN THE SAME DIRECTORY.**  
Because the original mmixal use **72** for default line buffer size, so it must specify the buffersize option. 
Of course, you can modify the mmixal.w or mmixal.c source and recompile it.  


## Test Structure
There 4 pair test label:  
**[TEST_TARGET mms_file_name]**  
**[TEST_SUITE test_suite_name]**  
**[TEST_SUITE_END]**  
**[TEST_BODY]**  
**[TEST_BODY_END]**  
**[TEST_CASE test_case_name]**  
**[TEST_CASE_END]**
* [TEST_TARGET] use to specify the testing mms program. **mms_file_name only contains file name, WITHOUT SUFFIX.**
* [TEST_SUITE] use to define a test suite, it can contains only one [TEST_BODY] or none, and it can contains zero or more [TEST_CASE].
* [TEST_BODY] use to define a call routine. It use test data from every [TEST_CASE] and make them as parameter of calling function. It can contains more than one assertion. Like mms program, instruction must be written on second column.
* [TEST_CASE] use to define test data, instruction is not allowed. **BE CAREFUL, for easy implemention of the assertion of the framework, data defined in [TEST_CASE] that will use in assertion must has real address in memory. So the presudo-instruction IS, GREG is not allowed to define data that will be use in assertion. Use only for parameter is OK.**  

**!!!NO SPACE ALLOWD NEAR [], AND ONE TEST LABEL ONE LINE!!!**

The following is a part of [test_e24_ori.mmt](https://github.com/zBaitu/TAOCP/blob/master/1.3.2/exercises/test_e24_ori.mmt) program testing for [e24_ori.mms](https://github.com/zBaitu/TAOCP/blob/master/1.3.2/exercises/e24_ori.mms).

```
[TEST_TARGET e24_ori]                        
    
[TEST_SUITE test_e24_ori]                    
    
[TEST_BODY]                                  
    LDA     $1,in                            
    LDA     $2,out                           
    PUSHJ   $0,:StrCpy                       
    [ASSERT_STR_EQ out,expected]             
[TEST_BODY_END]                              
    
[TEST_CASE 0_len]                            
in          BYTE 0                           
out         BYTE 1                           
expected    BYTE 0                           
[TEST_CASE_END]                              

[TEST_CASE 1_len]
in          BYTE "a",0
out         BYTE 0,0
expected    BYTE "a",0
[TEST_CASE_END]

[TEST_CASE 4_len]
in          BYTE "abcd",0
out         TETRA
            BYTE
expected    BYTE "abcd",0
[TEST_CASE_END]

[TEST_CASE 7_len]
in          BYTE "abcdefg",0
out         OCTA
expected    BYTE "abcdefg",0
[TEST_CASE_END]

[TEST_CASE 8_len]
in          BYTE "abcdefgh",0
out         OCTA
            BYTE
expected    BYTE "abcdefgh",0
[TEST_CASE_END]

[TEST_SUITE_END]
```


# Assertion
Assertion prototype is:  
**ASSERT\_[TYPE|TYPE_ARRAY]\_COMPARE[actual_value,expected_value,[len]]**
```
% BYTE assertion
ASSERT_BYTE_XX[actual_value, expected_value]    % signed assertion
ASSERT_BYTE_EQ  % equal
ASSERT_BYTE_NE  % not equal
ASSERT_BYTE_LT  % less than
ASSERT_BYTE_LE  % less than or equal
ASSERT_BYTE_GT  % greater than
ASSERT_BYTE_NE  % greater than or equal

% same as above, only a 'U' more at the end.
ASSERT_BYTE_XXU[actual_value, expected_value]   % unsigned assertion
...

% WYDE assertion
ASSERT_WYDE_XX[actual_value, expected_value]
ASSERT_WYDE_XXU[actual_value, expected_value]

% TETRA assertion
ASSERT_TETRA_XX[actual_value, expected_value]
ASSERT_TETRA_XXU[actual_value, expected_value]

% OCTA assertion
ASSERT_OCTA_XX[actual_value, expected_value]
ASSERT_OCTA_XXU[actual_value, expected_value]

% string assertion, only EQ compare
ASSERT_STR_EQ[actual_value, expected_value]     % string equal
ASSERT_STR_IC_EQ[actual_value, expected_value]  % string equal, ignore case

% array assertion, only EQ, EQU compare
ASSERT_BYTE_ARRAY_EQ[actual_value, expected_value, len] 
ASSERT_BYTE_ARRAY_EQU[actual_value, expected_value, len] 
ASSERT_WYDE_ARRAY_EQ[actual_value, expected_value, len] 
ASSERT_WYDE_ARRAY_EQU[actual_value, expected_value, len] 
ASSERT_TETRA_ARRAY_EQ[actual_value, expected_value, len] 
ASSERT_TETRA_ARRAY_EQU[actual_value, expected_value, len] 
ASSERT_OCTA_ARRAY_EQ[actual_value, expected_value, len] 
ASSERT_OCTA_ARRAY_EQU[actual_value, expected_value, len] 
```


## MISC
For more detail, please see [tests/lib/zLibMMIX](/tests/lib/zLibMMIX) for demo, or https://github.com/zBaitu/TAOCP for practical.  
Sample result output:  
![sample result](https://raw.github.com/zBaitu/assets/master/zMMIX/img/test_e24_ori.png)
