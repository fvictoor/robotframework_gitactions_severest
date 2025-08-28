*** Settings ***
Resource    ../../base.robot
Documentation    Nesses cenários vamos validar o funcionamento do carrinho de compras no site.

*** Test Cases ***
LISTA COMPRAS - Incluir produtos na Lista de Compras
    [Documentation]    DADO que sou um usuário comum logado no sistema 
    ...                E existem produtos cadastrados 
    ...                QUANDO eu pesquiso por um produto E adiciono ele à minha lista de compras 
    ...                ENTÃO o produto deve aparecer na minha lista de compras
    [Tags]     frontend     produto    positivo  
    [Setup]   Run Keywords   POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=true          STATUS_CODE=201                               AND
    ...                      POST - Realizar Login           ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200    AND                  
    ...                      POST - Cadastrar Produto        ${URL_BACKEND}    STATUS_CODE=201                                                           AND
    ...                      POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=false          STATUS_CODE=201 
    Abrir navegador                                          ${URL_FRONTEND}
    Realizar Login                                           ${body_usuario}[email]    ${body_usuario}[password]    TIPO_USER=comum    SUCESS=true
    Pesquisar produto na home                                ${NAME_PRODUTO}
    Adicionar produto a Lista de Compras                     ${NAME_PRODUTO}
    Validar produto na lista de compras                      ${NAME_PRODUTO}    
    [Teardown]    Run Keywords   DELETE - Excluir Produto    ${URL_BACKEND}         ${ID_PRODUTO}        AND
    ...                          DELETE - Excluir todos os Usuarios cadastrados     ${URL_BACKEND}       AND
    ...                          Take Screenshot    EMBED

LISTA COMPRAS - Validação Função de Limpar Lista de Compras
    [Documentation]    DADO que sou um usuário comum logado no sistema 
    ...                E tenho produtos na minha lista de compras 
    ...                QUANDO eu utilizo a função de limpar lista 
    ...                ENTÃO todos os produtos devem ser removidos da minha lista de compras
    [Tags]     frontend     produto    positivo  
    [Setup]   Run Keywords   POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=true          STATUS_CODE=201                               AND
    ...                      POST - Realizar Login           ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200    AND                  
    ...                      POST - Cadastrar Produto        ${URL_BACKEND}    STATUS_CODE=201                                                           AND
    ...                      POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=false          STATUS_CODE=201 
    Abrir navegador                                          ${URL_FRONTEND}
    Realizar Login                                           ${body_usuario}[email]    ${body_usuario}[password]    TIPO_USER=comum    SUCESS=true
    Pesquisar produto na home                                ${NAME_PRODUTO}
    Adicionar produto a Lista de Compras                     ${NAME_PRODUTO}
    Validar produto na lista de compras                      ${NAME_PRODUTO}    
    Limpar lista de compras
    [Teardown]    Run Keywords   DELETE - Excluir Produto    ${URL_BACKEND}         ${ID_PRODUTO}        AND
    ...                          DELETE - Excluir todos os Usuarios cadastrados     ${URL_BACKEND}       AND
    ...                          Take Screenshot    EMBED