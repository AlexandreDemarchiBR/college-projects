#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Enumeração para os tipos de nós da AST
typedef enum {
    // Estruturas de Programa
    AST_PROGRAMA,
    AST_DECL_VAR,
    AST_DECL_FUNC,
    AST_LISTA_PARAM,
    AST_BLOCO,

    // Tipos de Dados usados em declarações
    AST_TIPO_INT,
    AST_TIPO_CAR,

    // Comandos
    AST_ATRIBUICAO,
    AST_RETORNE,
    AST_LEIA,
    AST_ESCREVA,
    AST_ESCREVA_STR,
    AST_NOVALINHA,
    AST_IF,
    AST_IF_ELSE,
    AST_WHILE,

    // Operações Aritméticas
    AST_SOMA,
    AST_SUB,
    AST_MULT,
    AST_DIV,

    // Operações Lógicas e Relacionais
    AST_IGUAL,
    AST_DIF,
    AST_MAIOR,
    AST_MENOR,
    AST_MAIOR_IGUAL,
    AST_MENOR_IGUAL,
    AST_E,
    AST_OU,
    AST_NAO,

    // Operações Unárias e Chamadas
    AST_NEGATIVO,
    AST_CHAMADA_FUNC,

    // Literais e Identificadores
    AST_LITERAL_INT,
    AST_LITERAL_CHAR,
    AST_IDENTIFICADOR
} node_type;

// Estrutura principal do Nó da AST
typedef struct ASTNode {
    node_type type;              // Tipo do nó (ver enum acima)
    
    // Dados associados ao nó
    int int_value;
    char char_value;
    char *string_value;

    // Estrutura da Árvore
    struct ASTNode *filhos[4];  // Ponteiros para filhos (ex: IF precisa de condicao, then, else)
    struct ASTNode *proximo;    // Ponteiro para o próximo comando (lista encadeada de comandos)
    
} ASTNode;

// Cria um novo nó genérico
ASTNode* novo_no(node_type type);

// Cria nós folhas (terminais)
ASTNode* novo_no_int(int valor);
ASTNode* novo_no_char(char valor);
ASTNode* novo_no_str(char *valor, node_type type); // Para ID e Strings

// Adiciona um filho a um nó pai e retorna o pai
void adicionar_filho(ASTNode *pai, ASTNode *filho);

// Função para imprimir a árvore
void imprimir_AST(ASTNode *node, int nivel);

// Função para liberar a memória da árvore
void liberar_AST(ASTNode *node);

#endif