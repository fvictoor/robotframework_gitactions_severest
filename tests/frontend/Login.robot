*** Settings ***
Resource    ../../base.robot
Documentation    Nesses cenários vamos validar a tela de Login.

*** Test Cases ***
LOGIN - Realizar login com usuário comum
    [Documentation]    DADO que sou um usuário comum cadastrado no sistema QUANDO eu acesso a página de login E preencho minhas credenciais corretas ENTÃO devo ser autenticado com sucesso E redirecionado para a área do usuário comum
    [Tags]     frontend     login    positivo
    [Setup]    POST - Cadastrar Usuário                      ${URL_BACKEND}            ADMINISTRADOR=false          STATUS_CODE=201
    Abrir navegador                                          ${URL_FRONTEND}
    Realizar Login                                           ${body_usuario}[email]    ${body_usuario}[password]    TIPO_USER=comum    SUCESS=true
    [Teardown]    Run Keywords    DELETE - Excluir Usuário    ${URL_BACKEND}    AND
    ...                           Take Screenshot    EMBED

LOGIN - Realizar login com usuário administrador
    [Documentation]    DADO que sou um usuário administrador cadastrado no sistema QUANDO eu acesso a página de login E preencho minhas credenciais corretas ENTÃO devo ser autenticado com sucesso E redirecionado para a área administrativa
    [Tags]     frontend     login    positivo
    [Setup]    POST - Cadastrar Usuário                      ${URL_BACKEND}           ADMINISTRADOR=true           STATUS_CODE=201
    Abrir navegador                                          ${URL_FRONTEND}          
    Realizar Login                                           ${body_usuario}[email]   ${body_usuario}[password]    TIPO_USER=administrador    SUCESS=true
    [Teardown]    Run Keywords    DELETE - Excluir Usuário    ${URL_BACKEND}    AND
    ...                           Take Screenshot    EMBED

LOGIN - Validar mensagem de erro ao tentar realizar login com usuário sem email e sem senha
    [Documentation]    DADO que estou na página de login QUANDO eu tento fazer login sem preencher campos obrigatórios ou com formato inválido ENTÃO devo receber mensagens de erro específicas para cada situação E não devo conseguir acessar o sistema
    [Tags]     frontend    login    negativo
    [Setup]    Abrir navegador    ${URL_FRONTEND}
    [Template]    Realizar Login
    USUARIO=${EMPTY}           SENHA=${EMPTY}       TIPO_USER=Alert    MENSAGEM=Email é obrigatório        SUCESS=false
    USUARIO=${EMPTY}           SENHA=${EMPTY}       TIPO_USER=Alert    MENSAGEM=Password é obrigatório     SUCESS=false
    USUARIO=${EMPTY}           SENHA=teste1234      TIPO_USER=Alert    MENSAGEM=Email é obrigatório        SUCESS=false
    USUARIO=teste.com          SENHA=${EMPTY}       TIPO_USER=Alert    SUCESS=false                        ALERT=Please include an '@' in the email address. 'teste.com' is missing an '@'.
    [Teardown]    Take Screenshot    EMBED
