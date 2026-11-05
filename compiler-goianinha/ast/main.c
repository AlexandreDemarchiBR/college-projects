#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern FILE *yyin;
extern int yylineno;
extern char *yytext;
extern int yyparse();
extern ASTNode *root;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s arquivo.g\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Erro ao abrir o arquivo");
        return 1;
    }

    yyparse();

    fclose(yyin);
    if(root != NULL) {
        printf("\n--- AST ---\n\n");
        imprimir_AST(root, 0);
        liberar_AST(root);
    } else {
        printf("Aviso: A arvore gerada esta vazia.\n");
    }

    return 0;
}
