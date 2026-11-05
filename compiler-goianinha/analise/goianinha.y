%{
#include <stdio.h>

/* Declaração de funções externas */
int yylex(void);
extern int yylineno;
void yyerror(const char *s);
%}

/* --- Declaração de tokens --- */
%token TK_CADEIA
%token TK_PROGRAMA TK_CAR TK_INT TK_RETORNE TK_LEIA TK_ESCREVA TK_NOVALINHA TK_SE TK_ENTAO TK_SENAO TK_ENQUANTO TK_EXECUTE
%token TK_IGUAL TK_DIFERENTE TK_MAIORIGUAL TK_MENORIGUAL TK_ATRIBUICAO TK_MAIOR TK_MENOR
%token TK_SOMA TK_SUBTRACAO TK_MULTIPLICACAO TK_DIVISAO
%token  TK_ABREPARENTESES TK_FECHAPARENTESES TK_ABRECHAVES TK_FECHACHAVES TK_VIRGULA TK_PONTOVIRGULA
%token TK_OU TK_E TK_NAO
%token TK_INTEIRO TK_CARACTERE TK_IDENTIFICADOR

%%

/* --- Regras de derivação (gramática) --- */
Programa:
    DeclFuncVar DeclProg
;

DeclFuncVar:
    Tipo TK_IDENTIFICADOR DeclVar TK_PONTOVIRGULA DeclFuncVar
    | Tipo TK_IDENTIFICADOR DeclFunc DeclFuncVar
    | /* epsilon */
;

DeclProg:
    TK_PROGRAMA Bloco
;

DeclVar:
    TK_VIRGULA TK_IDENTIFICADOR DeclVar
    | /* epsilon */
;

DeclFunc:
    TK_ABREPARENTESES ListaParametros TK_FECHAPARENTESES Bloco
;

ListaParametros:
    /* epsilon */
    | ListaParametrosCont
;

ListaParametrosCont:
    Tipo TK_IDENTIFICADOR
    | Tipo TK_IDENTIFICADOR TK_VIRGULA ListaParametrosCont
;

Bloco:
    TK_ABRECHAVES ListaDeclVar ListaComando TK_FECHACHAVES
;

ListaDeclVar:
    /* epsilon */
    | Tipo TK_IDENTIFICADOR DeclVar TK_PONTOVIRGULA ListaDeclVar
;

Tipo:
    TK_INT
    | TK_CAR
;

ListaComando:
    Comando
    | Comando ListaComando
;

Comando:
    TK_PONTOVIRGULA
    | Expr TK_PONTOVIRGULA
    | TK_RETORNE Expr TK_PONTOVIRGULA
    | TK_LEIA TK_IDENTIFICADOR TK_PONTOVIRGULA
    | TK_ESCREVA Expr TK_PONTOVIRGULA
    | TK_ESCREVA TK_CADEIA TK_PONTOVIRGULA
    | TK_NOVALINHA TK_PONTOVIRGULA
    | TK_SE TK_ABREPARENTESES Expr TK_FECHAPARENTESES TK_ENTAO Comando
    | TK_SE TK_ABREPARENTESES Expr TK_FECHAPARENTESES TK_ENTAO Comando TK_SENAO Comando
    | TK_ENQUANTO TK_ABREPARENTESES Expr TK_FECHAPARENTESES TK_EXECUTE Comando
    | Bloco
;

Expr:
    OrExpr
    | TK_IDENTIFICADOR TK_ATRIBUICAO Expr
;

OrExpr:
    OrExpr TK_OU AndExpr
    | AndExpr
;

AndExpr:
    AndExpr TK_E EqExpr
    | EqExpr
;

EqExpr:
    EqExpr TK_IGUAL DesigExpr
    | EqExpr TK_DIFERENTE DesigExpr
    | DesigExpr
;

DesigExpr:
    DesigExpr TK_MENOR AddExpr
    | DesigExpr TK_MAIOR AddExpr
    | DesigExpr TK_MAIORIGUAL AddExpr
    | DesigExpr TK_MENORIGUAL AddExpr
    | AddExpr
;

AddExpr:
    AddExpr TK_SOMA MulExpr
    | AddExpr TK_SUBTRACAO MulExpr
    | MulExpr
;

MulExpr:
    MulExpr TK_MULTIPLICACAO UnExpr
    | MulExpr TK_DIVISAO UnExpr
    | UnExpr
;

UnExpr:
    TK_SUBTRACAO PrimExpr
    | TK_NAO PrimExpr
    | PrimExpr
;

PrimExpr:
    TK_IDENTIFICADOR TK_ABREPARENTESES ListExpr TK_FECHAPARENTESES
    | TK_IDENTIFICADOR TK_ABREPARENTESES TK_FECHAPARENTESES
    | TK_IDENTIFICADOR
    | TK_CARACTERE
    | TK_INTEIRO
    | TK_ABREPARENTESES Expr TK_FECHAPARENTESES
;

ListExpr:
    Expr
    | ListExpr TK_VIRGULA Expr
;

%%

/* --- Função de erro --- */
void yyerror(const char *s) {
    fprintf(stderr, "ERRO: %s linha %d\n", s, yylineno);
    exit(1);
}
