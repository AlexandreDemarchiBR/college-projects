#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

#include <string>
#include <unordered_map>
#include <vector>

enum Categoria { VARIAVEL, FUNCAO, PARAMETRO };
enum TipoVariavel { CAR = 0, INT = 1 };

class ItemSimbolo {
public:
    Categoria categoria;
    std::string nome;

    TipoVariavel tipo = (TipoVariavel)-1;
    int posicao_variavel = -1;
    int contagem_parametros = 0;
    int posicao_parametro = -1;

    ItemSimbolo* funcao_pai = nullptr;
};

class TabelaSimbolos {
private:
    std::vector<std::unordered_map<std::string, ItemSimbolo>> pilha_tabela;

public:
    void iniciar_pilha();
    void adicionar_escopo();
    ItemSimbolo* pesquisar_lexema(const std::string nome);
    void remover_escopo();
    void inserir_funcao_escopo_atual(const std::string nome, int contagem_parametros, TipoVariavel tipo);
    void inserir_variavel_escopo_atual(const std::string nome, TipoVariavel tipo, int posicao_variavel);
    void inserir_parametro_escopo_atual(const std::string nome, TipoVariavel tipo, int posicao_parametro, ItemSimbolo* funcao_pai);
    void eliminar_pilha();
};

#endif // TABELA_SIMBOLOS_H
