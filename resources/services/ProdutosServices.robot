*** Settings ***
Resource    ../../base.robot
Documentation    Nesse arquivo vamos armazenar informações de serviços relacionados a produtos.

*** Keywords ***

GET - Listar Produtos
    [Documentation]    Realiza uma requisição GET para listar todos produtos cadastrados no sistema.
    [Arguments]        ${URL}   ${SEARCH}=false    ${VALUE_SEARCH}=None
    
    ${headers}    Create Dictionary
    ...    Content-Type=application/json
    
    IF  '${SEARCH}' != 'false'
        ${SEARCH_USER}    Set Variable        ${SEARCH}=${VALUE_SEARCH}
        ${response}    GET
        ...    url=${URL}produtos?${SEARCH_USER}
        ...    headers=${headers}
        ...    expected_status=any 
    ELSE
        ${response}    GET
        ...    url=${URL}produtos?
        ...    headers=${headers}
        ...    expected_status=any 
    END
    Log Requests API    ${response}
    
    ${LIST_USERS}    Set Variable    ${response.json()}
    RETURN    ${response.json()}

POST - Cadastrar Produto
    [Documentation]    Realiza uma requisição POST para cadastrar um novo produto no sistema.
    [Arguments]                ${URL}    ${NAME_PRODUTO}=aleatórios    ${PRECO_PRODUTO}=aleatórios    ${DESCRIPTION}=aleatórios    ${QTA_PRODUTO}=aleatórios       ${STATUS_CODE}=201    ${VALIDATE}=None    ${MESSAGE_VALIDADE}=None
    
    ${headers}    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=${TOKEN}

    Wait Until Keyword Succeeds    3x    2s    Gerar dados Aleatórias de Produto    ${NAME_PRODUTO}    ${PRECO_PRODUTO}    ${DESCRIPTION}    ${QTA_PRODUTO}

    ${body_produto}    Create Dictionary
    ...    nome=${NAME_PRODUTO}
    ...    preco=${PRECO_PRODUTO}
    ...    descricao=${DESCRIPTION_PRODUTO}
    ...    quantidade=${QTA_PRODUTO}
    Set Test Variable    ${body_produto}
    ${response}    POST
    ...    url=${URL}produtos
    ...    headers=${headers}
    ...    json=${body_produto}
    ...    expected_status=any 
    Log Requests API    ${response}    ${STATUS_CODE}
    
    Log Many    Informações do Usuário Cadastrados:
    ...         ${body_produto}
    
    # Verifica se o produto foi criado com sucesso e captura o ID do usuário
    ${STATUS_MESSAGE}    Run Keyword And Return Status    Should Be Equal As Strings    ${response.json()}[message]    Cadastro realizado com sucesso

    IF  '${STATUS_MESSAGE}' == 'True'
        ${ID_PRODUTO}    Set Variable    ${response.json()['_id']}
        Set Test Variable    ${ID_PRODUTO}
    
    ELSE
        ${VALIDATION}    Get Value From Json    ${response.json()}    $.${VALIDATE}
        ${VALIDATION}    Get From List    ${VALIDATION}    0
        Should Be Equal As Strings    ${VALIDATION}    ${MESSAGE_VALIDADE}    msg=Validação diferente do esperado
    END

    ${PRODUCT}    Set Variable    ${response.json()}
    RETURN    ${PRODUCT}

Gerar dados Aleatórias de Produto
    [Arguments]     ${NAME_PRODUTO}=aleatórios    ${PRECO_PRODUTO}=aleatórios    ${DESCRIPTION}=aleatórios    ${QTA_PRODUTO}=aleatórios
    # Gerar nome de produto aleatório se não fornecido
    IF    '${NAME_PRODUTO}'=='aleatórios'
        ${NAME_PRODUTO}=    FakerLibrary.Name
    ELSE IF    '${NAME_PRODUTO}'=='${EMPTY}'
        ${NAME_PRODUTO}=    Set Variable    ${EMPTY}
    ELSE
        ${NAME_PRODUTO}=    Set Variable    ${NAME_PRODUTO} 
    END
    # Gerar preço de produto aleatório se não fornecido
    IF    '${PRECO_PRODUTO}'=='aleatórios'
        ${PRECO_PRODUTO}=    FakerLibrary.Random Int    min=1     max=9999
    ELSE IF    '${PRECO_PRODUTO}'=='${EMPTY}'
        ${PRECO_PRODUTO}=    Set Variable    ${EMPTY}
    ELSE
        ${PRECO_PRODUTO}=    Set Variable    ${PRECO_PRODUTO}
    END
   
    # Gerar descrição de produto aleatório se não fornecido
    IF    '${DESCRIPTION}'=='aleatórios'
        ${DESCRIPTION_PRODUTO}=    FakerLibrary.Paragraph
    ELSE IF    '${DESCRIPTION}'=='${EMPTY}'
        ${DESCRIPTION_PRODUTO}=    Set Variable    ${EMPTY}
    ELSE
        ${DESCRIPTION_PRODUTO}=    Set Variable    ${DESCRIPTION}
    END
    
    # Gerar quantidade de produto aleatório se não fornecido
    IF    '${QTA_PRODUTO}'=='aleatórios'
        ${QTA_PRODUTO}    FakerLibrary.Random Int    min=1     max=9999
    ELSE IF    '${QTA_PRODUTO}'=='${EMPTY}'
        ${QTA_PRODUTO}=    Set Variable    ${EMPTY}
    ELSE
        ${QTA_PRODUTO}=    Set Variable    ${QTA_PRODUTO}
    END
    
    Set Test Variable    ${NAME_PRODUTO}
    Set Test Variable    ${PRECO_PRODUTO}
    Set Test Variable    ${DESCRIPTION_PRODUTO}
    Set Test Variable    ${QTA_PRODUTO}

DELETE - Excluir Produto
    [Documentation]    Realiza uma requisição DELETE para excluir um produto do sistema.
    [Arguments]        ${URL}    ${ID_PRODUTO}    ${STATUS_CODE}=200
    
    ${headers}    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=${TOKEN}
    
    ${response}    DELETE
    ...    url=${URL}produtos/${ID_PRODUTO}
    ...    headers=${headers}
    ...    expected_status=any
    Log Requests API    ${response}    ${STATUS_CODE}