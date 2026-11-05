%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "goianinha.sintatico.h"
extern void yyerror(const char *s);

%}
%option noyywrap
%x COMENTARIO

%%
"/*"                     { BEGIN(COMENTARIO); }
<COMENTARIO>"*/"         { BEGIN(INITIAL); }
<COMENTARIO>\n           {}
<COMENTARIO>.|\n         ;  /* ignora qualquer outro caractere, incluindo \n */

<COMENTARIO><<EOF>>      { yyerror("Comentario nao termina"); }


\"[^"\n]*\"            { return TK_CADEIA; }  /* cadeia de caracteres */
\"[^"\n]*\n            { yyerror("Cadeia de caracteres ocupa mais de uma linha"); }

"programa"               { return TK_PROGRAMA; }
"car"                    { return TK_CAR; }
"int"                    { return TK_INT; }
"retorne"                { return TK_RETORNE; }
"leia"                   { return TK_LEIA; }
"escreva"                { return TK_ESCREVA; }
"novalinha"              { return TK_NOVALINHA; }
"se"                     { return TK_SE; }
"entao"                  { return TK_ENTAO; }
"senao"                  { return TK_SENAO; }
"enquanto"               { return TK_ENQUANTO; }
"execute"                { return TK_EXECUTE; }

"=="                     { return TK_IGUAL; }
"!="                     { return TK_DIFERENTE; }
">="                     { return TK_MAIORIGUAL; }
"<="                     { return TK_MENORIGUAL; }
"="                      { return TK_ATRIBUICAO; }
">"                      { return TK_MAIOR; }
"<"                      { return TK_MENOR; }

"+"                      { return TK_SOMA; }
"-"                      { return TK_SUBTRACAO; }
"*"                      { return TK_MULTIPLICACAO; }
"/"                      { return TK_DIVISAO; }

"("                      { return TK_ABREPARENTESES; }
")"                      { return TK_FECHAPARENTESES; }
"{"                      { return TK_ABRECHAVES; }
"}"                      { return TK_FECHACHAVES; }
","                      { return TK_VIRGULA; }
";"                      { return TK_PONTOVIRGULA; }

"ou"                     { return TK_OU; }
"e"                      { return TK_E; }
"!"                      { return TK_NAO; }

[0-9]+                   { return TK_INTEIRO; }  /* intconst */
\'[a-zA-Z0-9 ]\'         { return TK_CARACTERE; }  /* carconst */
[a-zA-Z_][a-zA-Z0-9_]*   { return TK_IDENTIFICADOR; }  /* id */

[ \t\r]+                 ;   /* ignora espaços */
\n                       { /*yylineno++;*/ }

.                        { yyerror("Caractere invalido"); }
<<EOF>>                  { return -1;}
%%

