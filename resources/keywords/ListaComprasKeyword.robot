*** Settings ***
Resource         ../../base.robot
Documentation    Nesse arquivo vamos armazenar keywords relacionada a carrinho de compras.

*** Keywords ***

Pesquisar produto na home
    [Arguments]     ${NOME_PRODUTO}
    Wait Element    ${Home.TITULO_PAGINA}
    Escrever em:    ${Home.CAMPO_PESQUISAR}    ${NOME_PRODUTO}
    Clicar em:      ${Home.BOTAO_PESQUISAR}
    Wait Element    ${Home.PRODUTO_LISTA.format(text='${NOME_PRODUTO}')} 

Adicionar produto a Lista de Compras
    [Arguments]    ${NOME_PRODUTO}
    Clicar em:      ${ListaCompras.ADC_PRODUTO_LISTA.format(text='${NOME_PRODUTO}')}

Validar produto na lista de compras
    [Arguments]     ${NOME_PRODUTO}
    Clicar em:      ${Home.LINK_LISTA_COMPRAS}
    Wait Element    ${ListaCompras.PRODUTO_LISTA.format(text='${NOME_PRODUTO}')}
    
Limpar lista de compras
    Clicar em:      ${ListaCompras.BOTAO_LIMPAR_LISTA}
    Wait Element    ${ListaCompras.LISTA_COMPRAS_VAZIA}
