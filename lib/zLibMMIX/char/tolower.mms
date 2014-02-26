    PREFIX :char:tolower:
char IS $0

cmp_result GREG

:char:tolower   CMP cmp_result,char,:char:UPPER_A
                BN  cmp_result,return
                CMP cmp_result,char,:char:UPPER_Z
                BP  cmp_result,return
                ADD char,char,:char:UPPER_LOWER_DIFF

return          POP 1,0
    PREFIX :
