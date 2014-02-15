    PREFIX :char:toupper:
char    IS $0

cmp_result  GREG

:char:toupper   CMP cmp_result,char,:char:LOWER_A
                BN  cmp_result,return
                CMP cmp_result,char,:char:LOWER_Z
                BP  cmp_result,return
                SUB char,char,:char:UPPER_LOWER_DIFF

return          POP 1,0
    PREFIX :
