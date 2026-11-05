%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* Variáveis externas e funções do Flex */
int yylex(void);
extern int yylineno;
extern char *yytext;
void yyerror(const char *s);

/* Raiz da árvore sintática acessível externamente */
ASTNode *root;

%}

/* Tipos de dados da pilha do parser */
%union {
    int ival;
    char *sval;
    struct ASTNode *node;
}

/* Tokens que carregam valor */
%token <sval> TK_CADEIA
%token <ival> TK_INTEIRO
%token <sval> TK_IDENTIFICADOR
%token <ival> TK_CARACTERE 

/* Tokens de palavras reservadas e símbolos */
%token TK_PROGRAMA TK_CAR TK_INT TK_RETORNE TK_LEIA TK_ESCREVA TK_NOVALINHA TK_SE TK_ENTAO TK_SENAO TK_ENQUANTO TK_EXECUTE
%token TK_IGUAL TK_DIFERENTE TK_MAIORIGUAL TK_MENORIGUAL TK_ATRIBUICAO TK_MAIOR TK_MENOR
%token TK_SOMA TK_SUBTRACAO TK_MULTIPLICACAO TK_DIVISAO
%token TK_ABREPARENTESES TK_FECHAPARENTESES TK_ABRECHAVES TK_FECHACHAVES TK_VIRGULA TK_PONTOVIRGULA
%token TK_OU TK_E TK_NAO

/* Definição dos Tipos dos Não-Terminais */
%type <node> Programa DeclFuncVar DeclProg DeclVar DeclFunc
%type <node> ListaParametros ListaParametrosCont Bloco ListaDeclVar Tipo
%type <node> ListaComando Comando
%type <node> Expr OrExpr AndExpr EqExpr DesigExpr AddExpr MulExpr UnExpr PrimExpr ListExpr

/* Tratamento do Se ... Senao */
%expect 1

%%

/* Regras de derivação e Construção da AST */

Programa:
    DeclFuncVar DeclProg
    {
        /* Nó raiz do programa:
           Filho 0: Declarações Globais/Funções
           Filho 1: Programa Principal (Main) */
        root = novo_no(AST_PROGRAMA);
        adicionar_filho(root, $1);
        adicionar_filho(root, $2);
    }
;

DeclFuncVar:
    Tipo TK_IDENTIFICADOR DeclVar TK_PONTOVIRGULA DeclFuncVar
    {
        /* Cria nó de declaração de variável */
        $$ = novo_no(AST_DECL_VAR);
        adicionar_filho($$, $1); /* Tipo  */
        /* O identificador principal */
        adicionar_filho($$, novo_no_str($2, AST_IDENTIFICADOR)); 
        /* Outras variáveis na mesma linha (ex: int a, b, c;) */
        adicionar_filho($$, $3);
        
        /* Encadeia com o resto das declarações */
        $$->proximo = $5;
    }
    | Tipo TK_IDENTIFICADOR DeclFunc DeclFuncVar
    {
        /* Cria nó de declaração de função */
        $$ = novo_no(AST_DECL_FUNC);
        adicionar_filho($$, $1); /* Tipo de retorno */
        adicionar_filho($$, novo_no_str($2, AST_IDENTIFICADOR)); /* Nome da função */
        adicionar_filho($$, $3); /* Corpo/Parâmetros da função */
        
        /* Encadeia */
        $$->proximo = $4;
    }
    | /* epsilon */
    {
        $$ = NULL;
    }
;

DeclProg:
    TK_PROGRAMA Bloco
    {
        /* Não precisamos de um nó específico para 'PROGRAMA' aqui, apenas retornamos o Bloco principal */
        $$ = $2;
    }
;

DeclVar:
    TK_VIRGULA TK_IDENTIFICADOR DeclVar
    {
        /* Recursão para lista de variáveis: int a, b, c */
        /* Cria um nó ID para esta variável extra */
        $$ = novo_no_str($2, AST_IDENTIFICADOR);
        /* Encadeia a próxima variável na lista 'proximo' */
        $$->proximo = $3;
    }
    | /* epsilon */
    {
        $$ = NULL;
    }
;

DeclFunc:
    TK_ABREPARENTESES ListaParametros TK_FECHAPARENTESES Bloco
    {
        /* Estrutura da função interna:
           Filho 0: Parâmetros
           Filho 1: Bloco de código */
        /* O Tipo e o Nome já foram tratados em DeclFuncVar */
        $$ = novo_no(AST_DECL_FUNC); /* Nó auxiliar ou reuso */
        /* Mas para simplificar a árvore, vou retornar apenas os parametros e bloco
           e deixar o pai (DeclFuncVar) organizar. Vamos usar um container temporário */
           
        /* Vamos encapsular parametros e bloco em um nó genérico para retornar ao pai */
        $$ = novo_no(AST_DECL_FUNC); 
        adicionar_filho($$, $2); /* Parametros */
        adicionar_filho($$, $4); /* Bloco */
    }
;

ListaParametros:
    /* epsilon */
    { $$ = NULL; }
    | ListaParametrosCont
    { $$ = $1; }
;

ListaParametrosCont:
    Tipo TK_IDENTIFICADOR
    {
        $$ = novo_no(AST_LISTA_PARAM);
        adicionar_filho($$, $1);
        adicionar_filho($$, novo_no_str($2, AST_IDENTIFICADOR));
    }
    | Tipo TK_IDENTIFICADOR TK_VIRGULA ListaParametrosCont
    {
        $$ = novo_no(AST_LISTA_PARAM);
        adicionar_filho($$, $1);
        adicionar_filho($$, novo_no_str($2, AST_IDENTIFICADOR));
        $$->proximo = $4;
    }
;

Bloco:
    TK_ABRECHAVES ListaDeclVar ListaComando TK_FECHACHAVES
    {
        $$ = novo_no(AST_BLOCO);
        adicionar_filho($$, $2); /* Declarações locais */
        adicionar_filho($$, $3); /* Comandos */
    }
;

ListaDeclVar:
    /* epsilon */
    { $$ = NULL; }
    | Tipo TK_IDENTIFICADOR DeclVar TK_PONTOVIRGULA ListaDeclVar
    {
        $$ = novo_no(AST_DECL_VAR);
        adicionar_filho($$, $1);
        adicionar_filho($$, novo_no_str($2, AST_IDENTIFICADOR));
        adicionar_filho($$, $3); /* Variaveis extras (b, c...) */
        $$->proximo = $5;
    }
;

Tipo:
    TK_INT
    { $$ = novo_no(AST_TIPO_INT); }
    | TK_CAR
    { $$ = novo_no(AST_TIPO_CAR); }
;

ListaComando:
    Comando
    { $$ = $1; }
    | Comando ListaComando
    {
        if ($1 != NULL) {
            $1->proximo = $2;
            $$ = $1;
        } else {
            $$ = $2;
        }
    }
;

Comando:
    TK_PONTOVIRGULA
    { $$ = NULL; }
    | Expr TK_PONTOVIRGULA
    { $$ = $1; } /* Expressão como comando (ex: i = i + 1;) */
    | TK_RETORNE Expr TK_PONTOVIRGULA
    {
        $$ = novo_no(AST_RETORNE);
        adicionar_filho($$, $2);
    }
    | TK_LEIA TK_IDENTIFICADOR TK_PONTOVIRGULA
    {
        $$ = novo_no(AST_LEIA);
        adicionar_filho($$, novo_no_str($2, AST_IDENTIFICADOR));
    }
    | TK_ESCREVA Expr TK_PONTOVIRGULA
    {
        $$ = novo_no(AST_ESCREVA);
        adicionar_filho($$, $2);
    }
    | TK_ESCREVA TK_CADEIA TK_PONTOVIRGULA
    {
        $$ = novo_no_str($2, AST_ESCREVA_STR);
    }
    | TK_NOVALINHA TK_PONTOVIRGULA
    {
        $$ = novo_no(AST_NOVALINHA);
    }
    | TK_SE TK_ABREPARENTESES Expr TK_FECHAPARENTESES TK_ENTAO Comando
    {
        $$ = novo_no(AST_IF);
        adicionar_filho($$, $3); /* Condição */
        adicionar_filho($$, $6); /* Bloco Entao */
    }
    | TK_SE TK_ABREPARENTESES Expr TK_FECHAPARENTESES TK_ENTAO Comando TK_SENAO Comando
    {
        $$ = novo_no(AST_IF_ELSE);
        adicionar_filho($$, $3); /* Condição */
        adicionar_filho($$, $6); /* Bloco Entao */
        adicionar_filho($$, $8); /* Bloco Senao */
    }
    | TK_ENQUANTO TK_ABREPARENTESES Expr TK_FECHAPARENTESES TK_EXECUTE Comando
    {
        $$ = novo_no(AST_WHILE);
        adicionar_filho($$, $3); /* Condição */
        adicionar_filho($$, $6); /* Bloco */
    }
    | Bloco
    { $$ = $1; }
;

Expr:
    OrExpr
    { $$ = $1; }
    | TK_IDENTIFICADOR TK_ATRIBUICAO Expr
    {
        $$ = novo_no(AST_ATRIBUICAO);
        adicionar_filho($$, novo_no_str($1, AST_IDENTIFICADOR)); /* L-Value */
        adicionar_filho($$, $3); /* R-Value */
    }
;

OrExpr:
    OrExpr TK_OU AndExpr
    {
        $$ = novo_no(AST_OU);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | AndExpr
    { $$ = $1; }
;

AndExpr:
    AndExpr TK_E EqExpr
    {
        $$ = novo_no(AST_E);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | EqExpr
    { $$ = $1; }
;

EqExpr:
    EqExpr TK_IGUAL DesigExpr
    {
        $$ = novo_no(AST_IGUAL);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | EqExpr TK_DIFERENTE DesigExpr
    {
        $$ = novo_no(AST_DIF);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | DesigExpr
    { $$ = $1; }
;

DesigExpr:
    DesigExpr TK_MENOR AddExpr
    {
        $$ = novo_no(AST_MENOR);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | DesigExpr TK_MAIOR AddExpr
    {
        $$ = novo_no(AST_MAIOR);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | DesigExpr TK_MAIORIGUAL AddExpr
    {
        $$ = novo_no(AST_MAIOR_IGUAL);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | DesigExpr TK_MENORIGUAL AddExpr
    {
        $$ = novo_no(AST_MENOR_IGUAL);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | AddExpr
    { $$ = $1; }
;

AddExpr:
    AddExpr TK_SOMA MulExpr
    {
        $$ = novo_no(AST_SOMA);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | AddExpr TK_SUBTRACAO MulExpr
    {
        $$ = novo_no(AST_SUB);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | MulExpr
    { $$ = $1; }
;

MulExpr:
    MulExpr TK_MULTIPLICACAO UnExpr
    {
        $$ = novo_no(AST_MULT);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | MulExpr TK_DIVISAO UnExpr
    {
        $$ = novo_no(AST_DIV);
        adicionar_filho($$, $1);
        adicionar_filho($$, $3);
    }
    | UnExpr
    { $$ = $1; }
;

UnExpr:
    TK_SUBTRACAO PrimExpr
    {
        $$ = novo_no(AST_NEGATIVO);
        adicionar_filho($$, $2);
    }
    | TK_NAO PrimExpr
    {
        $$ = novo_no(AST_NAO);
        adicionar_filho($$, $2);
    }
    | PrimExpr
    { $$ = $1; }
;

PrimExpr:
    TK_IDENTIFICADOR TK_ABREPARENTESES ListExpr TK_FECHAPARENTESES
    {
        $$ = novo_no(AST_CHAMADA_FUNC);
        adicionar_filho($$, novo_no_str($1, AST_IDENTIFICADOR)); /* Nome da função */
        adicionar_filho($$, $3); /* Argumentos */
    }
    | TK_IDENTIFICADOR TK_ABREPARENTESES TK_FECHAPARENTESES
    {
        $$ = novo_no(AST_CHAMADA_FUNC);
        adicionar_filho($$, novo_no_str($1, AST_IDENTIFICADOR));
        /* Sem argumentos */
    }
    | TK_IDENTIFICADOR
    {
        $$ = novo_no_str($1, AST_IDENTIFICADOR);
    }
    | TK_CARACTERE
    {
        $$ = novo_no_int($1);
    }
    | TK_INTEIRO
    {
        $$ = novo_no_int($1);
    }
    | TK_ABREPARENTESES Expr TK_FECHAPARENTESES
    {
        $$ = $2;
    }
;

ListExpr:
    Expr
    {
        $$ = $1; /* O Expr deve ter seu proximo = NULL (garantido pelo novo_no) */
    }
    | ListExpr TK_VIRGULA Expr
    {
        /* Encadeia argumentos da função (arg1, arg2...) */
        /* Precisamos ir ao fim da lista $1 para anexar $3 */
        /* Como ASTNode* não tem cauda rapida, percorremos */
        ASTNode *temp = $1;
        while (temp->proximo != NULL) {
            temp = temp->proximo;
        }
        temp->proximo = $3;
        $$ = $1;
    }
;

%%
void yyerror(const char *s) {
    fprintf(stderr, "ERRO: %s linha %d\n", s, yylineno);
    exit(1);
}