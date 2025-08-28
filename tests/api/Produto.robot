*** Settings ***
Resource    ../../base.robot
Documentation    Nesse arquivo vamos armazenar testes relacionado a produtos.

*** Test Cases **

PRODUTO_API - Teste realizando um cadastro de produto e listagem como usuário Administrador
    [Documentation]    DADO que sou um usuário administrador autenticado no sistema 
    ...                QUANDO eu envio uma requisição para cadastrar um novo produto 
    ...                ENTÃO o produto deve ser criado com sucesso E deve aparecer na listagem de produtos
    [Tags]    api    produto    positivo
    [Setup]    Run Keywords      POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=true    STATUS_CODE=201    AND
    ...                          POST - Realizar Login           ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200
    POST - Cadastrar Produto     ${URL_BACKEND}    STATUS_CODE=201
    GET - Listar Produtos        ${URL_BACKEND}    _id    ${ID_PRODUTO}
    [Teardown]    Run Keywords   DELETE - Excluir Produto     ${URL_BACKEND}    ${ID_PRODUTO}    AND
    ...                          DELETE - Excluir Usuário      ${URL_BACKEND}    ${ID_USER}                                       

PRODUTO_API - Teste realizando um cadastro de produto e listagem como usuário comum
    [Documentation]    DADO que sou um usuário comum autenticado no sistema 
    ...                QUANDO eu tento enviar uma requisição para cadastrar um produto 
    ...                ENTÃO devo receber uma mensagem de erro de permissão E o produto não deve ser criado
    [Tags]    api    produto    negativo
    [Setup]    Run Keywords        POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=false    STATUS_CODE=201    AND
    ...                            POST - Realizar Login           ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200
    POST - Cadastrar Produto       ${URL_BACKEND}    STATUS_CODE=403    VALIDATE=message    MESSAGE_VALIDADE=Rota exclusiva para administradores
    [Teardown]                     DELETE - Excluir Usuário      ${URL_BACKEND}    ${ID_USER}

PRODUTO_API - Teste realizando um cadastro de produto sem token
    [Documentation]    DADO que não estou autenticado no sistema 
    ...                QUANDO eu tento enviar uma requisição para cadastrar um produto 
    ...                ENTÃO devo receber uma mensagem de erro de autenticação E o produto não deve ser criado
    [Tags]    api    produto    negativo
    POST - Cadastrar Produto                   ${URL_BACKEND}    STATUS_CODE=401    VALIDATE=message    MESSAGE_VALIDADE=Token de acesso ausente, inválido, expirado ou usuário do token não existe mais

PRODUTO_API - Teste realizando um cadastro de produto com o mesmo nome
    [Documentation]    DADO que sou um usuário administrador autenticado no sistema 
    ...                E já existe um produto cadastrado com um determinado nome 
    ...                QUANDO eu tento cadastrar outro produto com o mesmo nome 
    ...                ENTÃO devo receber uma mensagem de erro de duplicação 
    ...                E o segundo produto não deve ser criado
    [Tags]    api    produto    negativo
    [Setup]    Run Keywords                    POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=true    STATUS_CODE=201                     AND
    ...                                        POST - Realizar Login           ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200    AND
    ...                                        POST - Cadastrar Produto        ${URL_BACKEND}    STATUS_CODE=201
    POST - Cadastrar Produto                   ${URL_BACKEND}    STATUS_CODE=400    NAME_PRODUTO=${body_produto}[nome]    VALIDATE=message    MESSAGE_VALIDADE=Já existe produto com esse nome
    [Teardown]    Run Keywords                 DELETE - Excluir Produto        ${URL_BACKEND}    ${ID_PRODUTO}    AND
    ...                                        DELETE - Excluir Usuário         ${URL_BACKEND}    ${ID_USER}

PRODUTO_API - Validação dos Campos de Cadastro de Produto
    [Documentation]    DADO que sou um usuário administrador autenticado no sistema 
    ...                E já existe um produto cadastrado com um determinado nome 
    ...                QUANDO eu tento cadastrar um produto sem preencher campos obrigatórios 
    ...                ENTÃO devo receber mensagens de erro específicas para cada campo 
    ...                E o produto não deve ser criado
    [Tags]    api    produto    negativo
    [Setup]    Run Keywords      POST - Cadastrar Usuário        ${URL_BACKEND}    ADMINISTRADOR=true    STATUS_CODE=201    AND
    ...                          POST - Realizar Login           ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200
    [Template]    POST - Cadastrar Produto
    ${URL_BACKEND}    QTA_PRODUTO=${EMPTY}       STATUS_CODE=400    VALIDATE=quantidade   MESSAGE_VALIDADE=quantidade deve ser um número
    ${URL_BACKEND}    DESCRIPTION=${EMPTY}       STATUS_CODE=400    VALIDATE=descricao    MESSAGE_VALIDADE=descricao não pode ficar em branco
    ${URL_BACKEND}    PRECO_PRODUTO=${EMPTY}     STATUS_CODE=400    VALIDATE=preco        MESSAGE_VALIDADE=preco deve ser um número
    ${URL_BACKEND}    NAME_PRODUTO=${EMPTY}      STATUS_CODE=400    VALIDATE=nome         MESSAGE_VALIDADE=nome não pode ficar em branco
    [Teardown]                   DELETE - Excluir Usuário         ${URL_BACKEND}    ${ID_USER}