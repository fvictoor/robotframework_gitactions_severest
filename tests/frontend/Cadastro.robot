*** Settings ***
Resource    ../../base.robot
Documentation    Nesses cenários vamos validar a tela de Login e cadastro no Site
Test Teardown    Take Screenshot    EMBED

*** Test Cases ***
CADASTRO - Realizar um cadastro de um usuário comum
    [Documentation]    DADO que sou um visitante do site QUANDO eu acesso a página de cadastro 
    ...                E preencho todos os dados obrigatórios para usuário comum 
    ...                ENTÃO meu cadastro deve ser realizado com sucesso 
    ...                E devo receber uma mensagem de confirmação
    [Tags]    frontend     cadastro    positivo
    Abrir navegador                        ${URL_FRONTEND}
    Clicar em:                             ${Login.LINK_CADASTRO}
    Preencher as informações de cadastro   USER_ADMIN=unchecked    MENSAGEM=Cadastro realizado com sucesso    SUCESS=true 

CADASTRO - Realizar um cadastro de um usuário administrador
    [Documentation]    DADO que sou um visitante do site 
    ...                QUANDO eu acesso a página de cadastro 
    ...                E preencho todos os dados obrigatórios marcando a opção administrador 
    ...                ENTÃO meu cadastro deve ser realizado com sucesso 
    ...                E devo receber uma mensagem de confirmação
    [Tags]    frontend     cadastro    positivo
    Abrir navegador                        ${URL_FRONTEND}
    Clicar em:                             ${Login.LINK_CADASTRO}
    Preencher as informações de cadastro   USER_ADMIN=checked    MENSAGEM=Cadastro realizado com sucesso  SUCESS=true  

CADASTRO - Validar mensagem de erro ao tentar cadastrar um usuário sem nome, sem email e sem senha
    [Documentation]    DADO que estou na página de cadastro 
    ...                QUANDO eu tento me cadastrar sem preencher campos obrigatórios ou com formato inválido 
    ...                ENTÃO devo receber mensagens de erro específicas para cada campo 
    ...                E o cadastro não deve ser realizado
    [Tags]     frontend    cadastro    negativo
    [Setup]    Run Keywords        Abrir navegador    ${URL_FRONTEND}    AND
    ...                            Clicar em:         ${Login.LINK_CADASTRO}
    [Template]        Preencher as informações de cadastro
    EMAIL=teste.com    USER_ADMIN=unchecked    MENSAGEM=Email não pode ficar em branco              ALERT=Please include an '@' in the email address. 'teste.com' is missing an '@'.
    NAME_USUARIO=${EMPTY}     USER_ADMIN=unchecked    MENSAGEM=Nome não pode ficar em branco        SUCESS=false
    EMAIL=${EMPTY}            USER_ADMIN=unchecked    MENSAGEM=Email não pode ficar em branco       SUCESS=false
    SENHA=${EMPTY}            USER_ADMIN=unchecked    MENSAGEM=Password não pode ficar em branco    SUCESS=false
