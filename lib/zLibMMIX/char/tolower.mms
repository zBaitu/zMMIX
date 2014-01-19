    PREFIX :char:tolower:
char                IS $0
cmp_result          GREG
UPPER_LOWER_DIFF    IS #20

:char:tolower   CMP cmp_result,char,#41
                BN  cmp_result,return
                CMP cmp_result,char,#5a
                BP  cmp_result,return
                ADD char,char,UPPER_LOWER_DIFF
return          POP 1,0
    PREFIX :
