*** Settings ***
Resource    ../../base.robot
Documentation    Nesse arquivo vamos armazenar testes relacionados a usuários.

*** Test Cases ***

USUARIO_API - Teste realizando um cadastro de usuário e exclusão
    [Documentation]    DADO que sou um visitante do sistema 
    ...                QUANDO eu preencho os dados para cadastro de usuário comum 
    ...                ENTÃO meu cadastro deve ser realizado com sucesso 
    ...                E eu devo conseguir fazer login 
    ...                E meus dados devem aparecer na listagem
    [Tags]    api    cadastro    positivo 
    POST - Cadastrar Usuário                   ${URL_BACKEND}    ADMINISTRADOR=false    STATUS_CODE=201
    GET - Listar Usuários                      ${URL_BACKEND}    false    _id    ${ID_USER}
    POST - Realizar Login                      ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200
    [Teardown]    DELETE - Excluir Usuário      ${URL_BACKEND}    ${ID_USER}

USUARIO_API - Teste realizando um cadastro de usuário administrador e exclusão
    [Documentation]    DADO que sou um visitante do sistema 
    ...                QUANDO eu preencho os dados para cadastro de usuário administrador 
    ...                ENTÃO meu cadastro deve ser realizado com sucesso 
    ...                E eu devo conseguir fazer login 
    ...                E meus dados devem aparecer na listagem
    [Tags]    api    cadastro    positivo 
    POST - Cadastrar Usuário                   ${URL_BACKEND}    ADMINISTRADOR=true    STATUS_CODE=201
    GET - Listar Usuários                      ${URL_BACKEND}    true    _id    ${ID_USER}
    POST - Realizar Login                      ${URL_BACKEND}    ${body_usuario}[email]    ${body_usuario}[password]    STATUS_CODE=200
    [Teardown]    DELETE - Excluir Usuário      ${URL_BACKEND}    ${ID_USER}

USUARIO_API - Teste realizando um cadastro de usuário sem nome
    [Documentation]    DADO que sou um visitante do sistema 
    ...                QUANDO eu tento me cadastrar sem preencher campos obrigatórios 
    ...                ENTÃO devo receber mensagens de erro específicas para cada campo 
    ...                E o cadastro não deve ser realizado
    [Tags]    api    cadastro    negativo
    [Template]    POST - Cadastrar Usuário
    ${URL_BACKEND}    NAME_USUARIO=${EMPTY}   STATUS_CODE=400    VALIDATE=nome      MESSAGE_VALIDADE=nome não pode ficar em branco
    ${URL_BACKEND}    EMAIL=${EMPTY}          STATUS_CODE=400    VALIDATE=email     MESSAGE_VALIDADE=email não pode ficar em branco                 
    ${URL_BACKEND}    PASSWORD=${EMPTY}       STATUS_CODE=400    VALIDATE=password  MESSAGE_VALIDADE=password não pode ficar em branco
    
USUARIO_API - Teste realizando Login com informações incorretas    
    [Documentation]    DADO que estou na página de login 
    ...                QUANDO eu tento fazer login com credenciais incorretas ou incompletas 
    ...                ENTÃO devo receber mensagens de erro apropriadas 
    ...                E não devo conseguir acessar o sistema
    [Tags]    api    login    negativo
    [Setup]       POST - Cadastrar Usuário     ${URL_BACKEND}    NAME_USUARIO=${EMPTY}       STATUS_CODE=400    VALIDATE=nome      MESSAGE_VALIDADE=nome não pode ficar em branco
    [Template]    POST - Realizar Login
    ${URL_BACKEND}    EMAIL=${EMPTY}                  PASSWORD=${body_usuario}[password]    STATUS_CODE=400    VALIDATE=email       MESSAGE_VALIDADE=email não pode ficar em branco
    ${URL_BACKEND}    EMAIL=${body_usuario}[email]    PASSWORD=${EMPTY}                     STATUS_CODE=400    VALIDATE=password    MESSAGE_VALIDADE=password não pode ficar em branco
    ${URL_BACKEND}    EMAIL=${body_usuario}[email]    PASSWORD=${body_usuario}[password]    STATUS_CODE=401    VALIDATE=message     MESSAGE_VALIDADE=Email e/ou senha inválidos
   
USUARIO_API - Teste realizando um cadastro de usuário com o mesmo email
    [Documentation]    DADO que já existe um usuário cadastrado no sistema 
    ...                QUANDO eu tento cadastrar outro usuário com o mesmo email 
    ...                ENTÃO devo receber uma mensagem de erro informando que o email já está sendo usado 
    ...                E o segundo cadastro não deve ser realizado
    [Tags]    api    cadastro    negativo
    [Setup]       POST - Cadastrar Usuário     ${URL_BACKEND}    ADMINISTRADOR=false    STATUS_CODE=201
    POST - Cadastrar Usuário                   ${URL_BACKEND}    EMAIL=${body_usuario}[email]    STATUS_CODE=400    VALIDATE=message    MESSAGE_VALIDADE=Este email já está sendo usado
    [Teardown]    DELETE - Excluir Usuário      ${URL_BACKEND}    ${ID_USER}

USUARIO_API - Teste realizando a edição de um usuário
    [Documentation]    DADO que sou um usuário cadastrado no sistema 
    ...                QUANDO eu edito meus dados pessoais 
    ...                ENTÃO os dados devem ser atualizados com sucesso 
    ...                E devem aparecer corretamente na listagem de usuários
    [Tags]    api    edição    positivo
    [Setup]       POST - Cadastrar Usuário     ${URL_BACKEND}    ADMINISTRADOR=false    STATUS_CODE=201
    PUT - Editar Usuário                       ${URL_BACKEND}    STATUS_CODE=200    ID_USER=${ID_USER}
    GET - Listar Usuários                      ${URL_BACKEND}    false    _id    ${ID_USER}
    [Teardown]    DELETE - Excluir Usuário      ${URL_BACKEND}    ${ID_USER}