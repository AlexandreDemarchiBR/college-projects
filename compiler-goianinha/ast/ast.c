#include "ast.h"

// Função auxiliar para converter o enum em string para debug
const char* get_node_type_string(node_type type) {
    switch (type) {
        case AST_PROGRAMA:      return "PROGRAMA";
        case AST_DECL_VAR:      return "DECL_VAR";
        case AST_DECL_FUNC:     return "DECL_FUNC";
        case AST_LISTA_PARAM:   return "PARAMETROS";
        case AST_BLOCO:         return "BLOCO";
        case AST_TIPO_INT:      return "TIPO_INT";
        case AST_TIPO_CAR:      return "TIPO_CAR";
        case AST_ATRIBUICAO:    return "ATRIBUICAO";
        case AST_RETORNE:       return "RETORNE";
        case AST_LEIA:          return "LEIA";
        case AST_ESCREVA:       return "ESCREVA";
        case AST_ESCREVA_STR:   return "ESCREVA_STR";
        case AST_NOVALINHA:     return "NOVALINHA";
        case AST_IF:            return "IF";
        case AST_IF_ELSE:       return "IF_ELSE";
        case AST_WHILE:         return "WHILE";
        case AST_SOMA:          return "+";
        case AST_SUB:           return "-";
        case AST_MULT:          return "*";
        case AST_DIV:           return "/";
        case AST_IGUAL:         return "==";
        case AST_DIF:           return "!=";
        case AST_MAIOR:         return ">";
        case AST_MENOR:         return "<";
        case AST_MAIOR_IGUAL:   return ">=";
        case AST_MENOR_IGUAL:   return "<=";
        case AST_E:             return "&&";
        case AST_OU:            return "||";
        case AST_NAO:           return "!";
        case AST_NEGATIVO:      return "- (unario)";
        case AST_CHAMADA_FUNC:  return "CHAMADA_FUNC";
        case AST_LITERAL_INT:   return "LIT_INT";
        case AST_LITERAL_CHAR:  return "LIT_CHAR";
        case AST_IDENTIFICADOR: return "ID";
        default:                return "DESCONHECIDO";
    }
}

ASTNode* novo_no(node_type type) {
    ASTNode* node = (ASTNode*) calloc(1, sizeof(ASTNode));
    if (node == NULL) {
        fprintf(stderr, "Erro: Falha na alocacao de memoria para novo no.\n");
        exit(1);
    }
    node->type = type;
    return node;
}

ASTNode* novo_no_int(int valor) {
    ASTNode* node = novo_no(AST_LITERAL_INT);
    node->int_value = valor;
    return node;
}

ASTNode* novo_no_char(char valor) {
    ASTNode* node = novo_no(AST_LITERAL_CHAR);
    node->char_value = valor;
    return node;
}

ASTNode* novo_no_str(char *valor, node_type type) {
    ASTNode* node = novo_no(type);
    if (valor != NULL) {
        node->string_value = strdup(valor); 
    }
    return node;
}

void adicionar_filho(ASTNode *pai, ASTNode *filho) {
    if (pai == NULL || filho == NULL) return;

    for (int i = 0; i < 4; i++) {
        if (pai->filhos[i] == NULL) {
            pai->filhos[i] = filho;
            return;
        }
    }
    fprintf(stderr, "Erro: Tentativa de adicionar mais de 4 filhos ao no do tipo %s\n", get_node_type_string(pai->type));
}

void imprimir_AST(ASTNode *node, int nivel) {
    if (node == NULL) return;

    // Indentação visual baseada no nível da árvore
    for (int i = 0; i < nivel; i++) printf("  ");
    
    printf("|-- %s", get_node_type_string(node->type));

    // Imprime payload se houver
    if (node->type == AST_LITERAL_INT) {
        printf(": %d", node->int_value);
    } else if (node->type == AST_LITERAL_CHAR) {
        printf(": '%c'", node->char_value);
    } else if (node->type == AST_IDENTIFICADOR || node->type == AST_ESCREVA_STR) {
        printf(": \"%s\"", node->string_value ? node->string_value : "null");
    }
    printf("\n");

    // Recursão para os filhos
    for (int i = 0; i < 4; i++) {
        imprimir_AST(node->filhos[i], nivel + 1);
    }

    // Processa o próximo comando da lista encadeada (sem aumentar o nível) 
    // Isso mantém a estrutura visual de bloco alinhada
    if (node->proximo != NULL) {
        imprimir_AST(node->proximo, nivel);
    }
}

void liberar_AST(ASTNode *node) {
    if (node == NULL) return;

    // Libera filhos recursivamente
    for (int i = 0; i < 4; i++) {
        liberar_AST(node->filhos[i]);
    }

    // Libera o próximo da lista
    liberar_AST(node->proximo);

    // Libera memória da string se foi alocada
    if (node->string_value != NULL) {
        free(node->string_value);
    }

    free(node);
}