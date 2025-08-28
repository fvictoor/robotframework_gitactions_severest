*** Settings ***
Resource    ../../base.robot
Documentation    Nesse arquivo vamos armazenar apenas a usabilidade de Serviços usados para manipular usuários, como criar, editar e excluir usuários no sistema.
*** Keywords ***

GET - Listar Usuários
    [Documentation]    Realiza uma requisição GET para listar todos os usuários cadastrados no sistema.
    [Arguments]        ${URL}    ${USER_ADMIN}=false    ${SEARCH}=false    ${VALUE_SEARCH}=None
    
    ${headers}    Create Dictionary
    ...    Content-Type=application/json
    
    IF  '${SEARCH}' != 'false'
        ${SEARCH_USER}    Set Variable        ${SEARCH}=${VALUE_SEARCH}
        ${response}    GET
        ...    url=${URL}usuarios?${SEARCH_USER}&administrador=${USER_ADMIN}
        ...    headers=${headers}
        ...    expected_status=any 
    ELSE
        ${response}    GET
        ...    url=${URL}usuarios?administrador=${USER_ADMIN}
        ...    headers=${headers}
        ...    expected_status=any 
    END
    Log Requests API    ${response}
    
    ${LIST_USERS}    Set Variable    ${response.json()}
    RETURN    ${response.json()}

POST - Cadastrar Usuário
    [Documentation]    Realiza uma requisição POST para cadastrar um novo usuário no sistema.
    [Arguments]        ${URL}    ${NAME_USUARIO}=aleatórios    ${EMAIL}=aleatórios    ${PASSWORD}=aleatórios    ${ADMINISTRADOR}=false    ${STATUS_CODE}=200    ${VALIDATE}=None    ${MESSAGE_VALIDADE}=None
    
    ${headers}    Create Dictionary
    ...    Content-Type=application/json
    
    Wait Until Keyword Succeeds    3x    2s    Gerar dados Aleatórios de usuarios    ${NAME_USUARIO}    ${EMAIL}    ${PASSWORD}    ${ADMINISTRADOR} 

    ${body_usuario}    Create Dictionary
    ...    nome=${NAME_USUARIO}
    ...    email=${EMAIL}
    ...    password=${PASSWORD}
    ...    administrador=${ADMINISTRADOR}
    Set Test Variable    ${body_usuario}

    ${response}    POST
    ...    url=${URL}usuarios
    ...    headers=${headers}
    ...    json=${body_usuario}
    ...    expected_status=any 

    Log Requests API    ${response}    ${STATUS_CODE}
    Log Many    Informações do Usuário Cadastrados:
    ...         ${body_usuario}
    
    # Verifica se o usuário foi criado com sucesso e captura o ID do usuário
    ${STATUS_MESSAGE}    Run Keyword And Return Status    Should Be Equal As Strings    ${response.json()}[message]    Cadastro realizado com sucesso

    IF  '${STATUS_MESSAGE}' == 'True'
        ${ID_USER}    Set Variable    ${response.json()['_id']}
        Set Test Variable    ${ID_USER}
        Salvar Dados Do Usuário
    ELSE
        ${VALIDATION}    Get Value From Json    ${response.json()}    $.${VALIDATE}
        ${VALIDATION}    Get From List    ${VALIDATION}    0
        Should Be Equal As Strings    ${VALIDATION}    ${MESSAGE_VALIDADE}    msg=Validação diferente do esperado
    END
    RETURN    ${response.json()}

Gerar dados Aleatórios de usuarios
    [Arguments]    ${NAME_USUARIO}=aleatórios    ${EMAIL}=aleatórios    ${PASSWORD}=aleatórios   ${ADMINISTRADOR}=false
    # Gerar Nomes Aleatórios se não fornecidos
    IF    '${NAME_USUARIO}'=='aleatórios'
        ${NAME_USUARIO}=    FakerLibrary.Name
    ELSE IF   '${NAME_USUARIO}'=='${EMPTY}'
        ${NAME_USUARIO}=    Set Variable    ${EMPTY}
    ELSE
        ${NAME_USUARIO}=    Set Variable    ${NAME_USUARIO} 
    END
    # Gerar Emails Aleatórios se não fornecidos
    IF    '${EMAIL}'=='aleatórios'
        ${EMAIL}=    FakerLibrary.Email
    ELSE IF   '${EMAIL}'=='${EMPTY}'
        ${EMAIL}=    Set Variable    ${EMPTY}
    ELSE
        Set Variable    ${EMAIL}
    END
    # Gerar Senhas Aleatórias se não fornecidos
    IF    '${PASSWORD}'=='aleatórios'
        ${PASSWORD}=    FakerLibrary.Password
    ELSE IF   '${PASSWORD}'=='${EMPTY}'
        ${PASSWORD}=    Set Variable    ${EMPTY}
    ELSE
        Set Variable    ${PASSWORD}  
    END

    ${ADMINISTRADOR}    Set Variable    ${ADMINISTRADOR}
    Set Test Variable    ${NAME_USUARIO}
    Set Test Variable    ${EMAIL}
    Set Test Variable    ${PASSWORD}
    Set Test Variable    ${ADMINISTRADOR}

Salvar Dados Do Usuário
    [Arguments]    ${NAME_USUARIO}=${NAME_USUARIO}    ${EMAIL}=${EMAIL}    ${PASSWORD}=${PASSWORD}    ${ID_USER}=${ID_USER}    ${ADMINISTRADOR}=${ADMINISTRADOR}
    &{USER_INFO}    Create Dictionary
    ...    nome=${NAME_USUARIO}
    ...    email=${EMAIL}
    ...    password=${PASSWORD}
    ...    id=${ID_USER}
    ...    administrador=${ADMINISTRADOR}
    
    Append To List    ${LIST_USER}    ${USER_INFO}
    #
    Set Test Variable    ${LIST_USER}
    Log    Dados do Usuário Salvo na Lista: ${LIST_USER}

DELETE - Excluir todos os Usuarios cadastrados
    [Arguments]    ${URL}
    ${LIST_IDS}=    Buscar ID de Usuario Cadastrado

    FOR    ${ID_USER}    IN    @{LIST_IDS}
        DELETE - Excluir Usuário    ${URL}    ${ID_USER}    200
    END

Buscar ID de Usuario Cadastrado
    ${LIST_IDS}=    Get Value From Json    ${LIST_USER}    $..id
    RETURN    ${LIST_IDS}

DELETE - Excluir Usuário
    [Documentation]    Realiza uma requisição DELETE para excluir um usuário do sistema.
    [Arguments]        ${URL}    ${ID_USER}=${ID_USER}    ${STATUS_CODE}=200    ${ID_USER}=${ID_USER}
    
    ${headers}    Create Dictionary
    ...    Content-Type=application/json
    
    ${response}    DELETE
    ...    url=${URL}usuarios/${ID_USER}
    ...    headers=${headers}
    ...    expected_status=any

    Log Requests API    ${response}    ${STATUS_CODE}

POST - Realizar Login
    [Documentation]    Realiza uma requisição POST para realizar o login de um usuário no sistema.
    [Arguments]        ${URL}    ${EMAIL}    ${PASSWORD}    ${STATUS_CODE}=200    ${VALIDATE}=None    ${MESSAGE_VALIDADE}=None
    
    IF  '${TOKEN}' == 'None'
        ${headers}    Create Dictionary
        ...    Content-Type=application/json
    
        ${body}    Create Dictionary
        ...    email=${EMAIL}
        ...    password=${PASSWORD}
    
        ${response}    POST
        ...    url=${URL}login
        ...    headers=${headers}
        ...    json=${body}
        ...    expected_status=any 
    
        Log Requests API    ${response}    ${STATUS_CODE}
        
        # Verifica se o login foi realizado com sucesso e captura o token do usuário
        ${STATUS_MESSAGE}    Run Keyword And Return Status    Should Be Equal As Strings    ${response.json()}[message]    Login realizado com sucesso
    
        IF  '${STATUS_MESSAGE}' == 'True'
            ${TOKEN}    Set Variable    ${response.json()}[authorization]
            Set Test Variable    ${TOKEN}
        ELSE
            ${VALIDATION}    Get Value From Json    ${response.json()}    $.${VALIDATE}
            ${VALIDATION}    Get From List          ${VALIDATION}    0
            Should Be Equal As Strings    ${VALIDATION}    ${MESSAGE_VALIDADE}    msg=Validação diferente do esperado
        END
    
        RETURN    ${response.json()}
    ELSE
        Log    Token já existe e Logado, reutilizando: ${TOKEN}
    END

PUT - Editar Usuário
    [Documentation]    Realiza uma requisição PUT para editar um usuário no sistema.
    [Arguments]        ${URL}    ${NAME_USUARIO}=aleatórios    ${EMAIL}=aleatórios    ${PASSWORD}=aleatórios    ${ADMINISTRADOR}=false    ${STATUS_CODE}=200     ${ID_USER}=${ID_USER}
    
    ${headers}    Create Dictionary
    ...    Content-Type=application/json
    
    Wait Until Keyword Succeeds    3x    2s    Gerar dados Aleatórios de usuarios    ${NAME_USUARIO}    ${EMAIL}    ${PASSWORD}    ${ADMINISTRADOR} 
    
    ${body_usuario}    Create Dictionary
    ...    nome=${NAME_USUARIO}
    ...    email=${EMAIL}
    ...    password=${PASSWORD}
    ...    administrador=${ADMINISTRADOR}
    Set Test Variable    ${body_usuario}

    ${response}    PUT
    ...    url=${URL}usuarios/${ID_USER}
    ...    headers=${headers}
    ...    json=${body_usuario}
    ...    expected_status=any 

    Log Requests API    ${response}    ${STATUS_CODE}
    Log Many    Informações do Usuário Cadastrados:
    ...         ${body_usuario}
    
    # Verifica se o usuário foi Editado com Sucesso.
    ${STATUS_MESSAGE}    Run Keyword And Return Status    Should Be Equal As Strings    ${response.json()}[message]    Registro alterado com sucesso
    Salvar Dados Do Usuário
    RETURN    ${response.json()}