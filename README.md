zMMIX ---- MMIX Unit Test Framework
===============================

https://github.com/zBaitu/zMMIX

Overview
--------


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
zmmix_gt test_mmix.mmt
mmixal -b 120 test_mmix.mms
mmix  test_mmix
```


## Test Structure

```

```


# Assertion
Assertion prototype is:  
**ASSERT\_[TYPE|TYPE_ARRAY]\_COMPARE[actual_value,expected_value,[len]]**
```

```


## MISC
For more detail, please see tests/lib/zLibMMIX for demo, or https://github.com/zBaitu/TAOCP for practical.
Sample result output:  
