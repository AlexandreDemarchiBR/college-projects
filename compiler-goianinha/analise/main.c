#include <stdio.h>

extern FILE *yyin;
extern int yylineno;
extern char *yytext;
extern int yyparse();

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
    return 0;
}
