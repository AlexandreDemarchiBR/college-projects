#include "tabelaSimbolos.h"
#include <iostream>

int main() {
    TabelaSimbolos ts;

    // 1. Criar escopo global
    ts.iniciar_pilha(); // redundante, mas chamado por clareza
    ts.adicionar_escopo();

    // 2. Inserir função no escopo global
    ts.inserir_funcao_escopo_atual("soma", 2, INT);
    ItemSimbolo* f = ts.pesquisar_lexema("soma");
    if (f) {
        std::cout << "Função 'soma' encontrada. Tipo: " << (f->tipo == INT ? "INT" : "CAR")
                    << ", Nº parâmetros: " << f->contagem_parametros << "\n";
    }

    // 3. Adicionar escopo da função
    ts.adicionar_escopo();

    // 4. Inserir parâmetros
    ts.inserir_parametro_escopo_atual("a", INT, 0, f);
    ts.inserir_parametro_escopo_atual("b", INT, 1, f);

    // 5. Inserir variável local
    ts.inserir_variavel_escopo_atual("resultado", INT, 0);

    // 6. Pesquisar parâmetro
    ItemSimbolo* p = ts.pesquisar_lexema("a");
    if (p && p->categoria == PARAMETRO) {
        std::cout << "Parâmetro 'a' encontrado. Tipo: " << (p->tipo == INT ? "INT" : "CAR")
                    << ", Posição: " << p->posicao_parametro << "\n";
    }

    // 7. Remover escopo da função
    ts.remover_escopo();

    // 8. Verificar se variável local sumiu
    if (!ts.pesquisar_lexema("resultado")) {
        std::cout << "Variável 'resultado' não está acessível fora do escopo.\n";
    }

    // 9. Testar conflito de nome no escopo atual (global)
    ts.inserir_variavel_escopo_atual("x", INT, 0);
    try {
        ts.inserir_variavel_escopo_atual("x", CAR, 1);
    } catch (const std::exception& e) {
        std::cout << "Erro esperado ao inserir variável duplicada: " << e.what();
    }

    // 10. Testar inserir parâmetro em escopo global (válido mas conceitualmente incomum)
    try {
        ts.inserir_parametro_escopo_atual("paramGlobal", CAR, 0, f);
    } catch (const std::exception& e) {
        std::cout << "Erro: " << e.what();
    }

    // 11. Eliminar toda a pilha
    ts.eliminar_pilha();

    // 12. Verificar que nenhum símbolo resta
    if (!ts.pesquisar_lexema("soma")) {
        std::cout << "Pilha de símbolos eliminada com sucesso. Nenhum símbolo encontrado.\n";
    }

    return 0;
}
