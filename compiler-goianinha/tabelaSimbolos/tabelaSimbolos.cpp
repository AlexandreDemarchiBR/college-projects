#include <vector>
#include <unordered_map>
#include <string>
#include <iostream>
#include "tabelaSimbolos.h"

void TabelaSimbolos::iniciar_pilha()
{
    // metodo redundante: pilha já vem na instanciação
}

// criar uma nova tabela de sı́mbolos (novo escopo) e empilhá-la na pilha de tabela de sı́mbolos
void TabelaSimbolos::adicionar_escopo()
{
    pilha_tabela.emplace_back();
}

// pesquisar por um nome (lexema de identificador) na pilha de tabelas de sı́mbolos
ItemSimbolo* TabelaSimbolos::pesquisar_lexema(const std::string nome)
{
    for(int i = pilha_tabela.size() -1; i >=0; i--){
        auto it = pilha_tabela[i].find(nome);
        if (it != pilha_tabela[i].end()) {
            return &(it->second);
        }
    }
    return nullptr;
}

// remover escopo atual - essa função elimina a tabela de sı́mbolos que está no topo da pilha de tabelas
void TabelaSimbolos::remover_escopo()
{
    pilha_tabela.pop_back();
}

// inserir um nome de função na tabela de sı́mbolos atual
void TabelaSimbolos::inserir_funcao_escopo_atual(const std::string nome, int contagem_parametros, TipoVariavel tipo)
{
    ItemSimbolo i;
    if(pilha_tabela.empty())
    {
        throw std::runtime_error("Erro: pilha de tabela de símbolos está vazia.\n");
    }
    auto it = pilha_tabela.back().find(nome);
    if (it != pilha_tabela.back().end()) {
        throw std::runtime_error("Erro: lexema já existe no escopo atual.\n");
    }
    i.categoria = FUNCAO;
    i.nome = nome;
    i.tipo = tipo;
    i.contagem_parametros = contagem_parametros;
    pilha_tabela.back().insert({nome, i});
}

// inserir um nome de variável na tabela de sı́mbolos atual
void TabelaSimbolos::inserir_variavel_escopo_atual(const std::string nome, TipoVariavel tipo, int posicao_variavel)
{
    ItemSimbolo i;
    if(pilha_tabela.empty())
    {
        throw std::runtime_error("Erro: pilha de tabela de símbolos está vazia.\n");
    }
    auto it = pilha_tabela.back().find(nome);
    if (it != pilha_tabela.back().end()) {
        throw std::runtime_error("Erro: lexema já existe no escopo atual.\n");
    }
    i.categoria = VARIAVEL;
    i.nome = nome;
    i.tipo = tipo;
    i.posicao_variavel = posicao_variavel;
    pilha_tabela.back().insert({nome, i});
}

// inserir o nome de um parâmetro na tabela de sı́mbolos atual
void TabelaSimbolos::inserir_parametro_escopo_atual(const std::string nome, TipoVariavel tipo, int posicao_parametro, ItemSimbolo* funcao_pai)
{
    ItemSimbolo i;
    if(pilha_tabela.empty())
    {
        throw std::runtime_error("Erro: pilha de tabela de símbolos está vazia.\n");
    }
    auto it = pilha_tabela.back().find(nome);
    if (it != pilha_tabela.back().end()) {
        throw std::runtime_error("Erro: lexema já existe no escopo atual.\n");
    }
    i.categoria = PARAMETRO;
    i.nome = nome;
    i.tipo = tipo;
    i.posicao_parametro = posicao_parametro;
    i.funcao_pai = funcao_pai;
    pilha_tabela.back().insert({nome, i});
}

// eliminar a pilha de tabelas de sı́mbolos
void TabelaSimbolos::eliminar_pilha()
{
    pilha_tabela.clear();
}

