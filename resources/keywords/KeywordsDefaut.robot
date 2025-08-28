*** Settings ***
Resource         ../../base.robot
Documentation    Nesse arquivo vamos armazenar apenas Keyqords genéricas onde não estão atreladas a nenhuma tela em especifico do sistema, essas keywords podem ser ultilizadas em qualquer teste que necessite de uma ação genérica, como abrir o navegador, clicar em um botão, escrever em um campo, etc.
*** Keywords ***
Abrir navegador
    [Documentation]    Nessa Keyword, criamos um browser onde ele é definido na sua chamada e abrimos a pagina com a URL desejada, temos a variável HEADLES que pode 
    ...                ser True ou False, onde isso possibilita ver o navegador ou deixar ele em segundo plano.
    [Arguments]         ${URL}        ${HEADLESS}=${HEADLESS}    ${BROWSER}=${BROWSER}
    Montar Navegador    ${BROWSER}    ${HEADLESS}
    Montar Contexto
    New Page            ${URL}
    Wait Element        ${Login.TITULO_LOGIN}

Montar Navegador
    [Arguments]    ${BROWSER}=${BROWSER}    ${HEADLESS}=${HEADLESS}    ${TIMEOUT_BROWSER}=${TIMEOUT_DEFAUT}
    @{ARGS_BROWSER}   Create List    
    ...    --window-position=0,0
    ...    --disable-notifications
    ...    --disable-infobars
    ...    --disable-extensions
    ...    --arc-disable-locale-sync=${True}
    ...    --force-time-zone=America/Sao_Paulo
    ...    --font-render-hinting=none
    
    IF    ${HEADLESS} == ${True}
        Append To List    ${ARGS_BROWSER}
        ...    --headless
        ...    --no-sandbox
        ...    --disable-dev-shm-usage
        ...    --disable-gpu
    END

    New Browser    
    ...            browser=${BROWSER}
    ...            headless=${HEADLESS}
    ...            args=${ARGS_BROWSER}
    ...            timeout=${TIMEOUT_BROWSER}

Montar Contexto
    [Arguments]    ${viewport}=${RESOLUCAO_BROWSER}  ${recordVideo}=${CONFIG_VIDEO}     ${timezoneId}=America/Sao_Paulo 
    &{CONTEXT_DIC}    Create Dictionary
    ...               viewport=${viewport}     
    ...               recordVideo=${recordVideo}       
    ...               timezoneId=${timezoneId} 
    Log                ${CONTEXT_DIC}
    New Context        &{CONTEXT_DIC}

Clicar em:
    [Documentation]   Aguarda até que o elemento identificado esteja visível na tela e, em seguida, realiza o clique com um pequeno atraso.
    [Arguments]                ${selector}    ${timeout}=${DELAY_CLICK}    ${DELAY_CLICKED}=${DELAY_CLICK}    ${CLICKCOUNT}=1    ${FORCE}=${False}    ${TRIAL}=${False}      ${STATUS}=visible
    Wait For Elements State    ${selector}    ${STATUS}     timeout=${TIMEOUT_DEFAUT}    message=${DEFAUT_MESSAGE}
    Click With Options         ${selector}    delay=${DELAY_CLICKED}    force=${FORCE}    clickCount=${CLICKCOUNT}    trial=${TRIAL}

Escrever em:
    [Documentation]   Aguarda até que o elemento identificado esteja visível na tela e, em seguida, realiza a escrita do texto com um pequeno atraso.
    [Arguments]                ${selector}    ${TEXTO}
    Wait For Elements State    ${selector}    visible     timeout=${TIMEOUT_DEFAUT}    message=${DEFAUT_MESSAGE}
    Wait For Elements State    ${selector}    enabled     timeout=${TIMEOUT_DEFAUT}    message=${DEFAUT_MESSAGE}
    Type Text                  ${selector}    ${TEXTO}    delay=${DELAY_TEXT}

Marcar ou Desmarcar Checkbox
    [Documentation]     Verifica o estado atual do checkbox localizado por `${seletor}` e executa a ação somente se necessário, evitando interações redundantes.
    ...   `             ${estado_desejado}`: Deve ser 'checked' ou 'unchecked'
    [Arguments]    ${seletor}    ${estado_desejado}
    
    IF    '${estado_desejado}' not in ['checked', 'unchecked']
        Fail    Estado desejado inválido: "${estado_desejado}". Use "checked" ou "unchecked".
    END

    ${estado_atual}=    Get Checkbox State    ${seletor}

    IF    '${estado_desejado}' == 'checked'
        IF    '${estado_atual}' == 'False'
            Check Checkbox    ${seletor}
            Log    Ação: O checkbox '${seletor}' foi MARCADO.
        ELSE
            Log    Nenhuma ação necessária: o checkbox '${seletor}' já está MARCADO.
        END
    ELSE IF    '${estado_desejado}' == 'unchecked'
        IF    '${estado_atual}' == 'True'
            Uncheck Checkbox    ${seletor}
            Log    Ação: O checkbox '${seletor}' foi DESMARCADO.
        ELSE
            Log    Nenhuma ação necessária: o checkbox '${seletor}' já está DESMARCADO.
        END
    END

Wait Element
    [Arguments]    ${SELECTOR}    ${STATE}=visible    ${TIMEOUT}=${TIMEOUT_DEFAUT}    ${MESSAGE}=${DEFAUT_MESSAGE}
    Wait For Elements State    selector=${SELECTOR}
    ...                        state=${STATE}
    ...                        timeout=${TIMEOUT}    
    ...                        message=${MESSAGE}

Log Requests API
    [Arguments]        ${response}    ${STATUS_CODE}=200
    Log    Response Body: ${response.text}
    Should Be Equal As Strings
    ...    ${response.status_code}
    ...    ${STATUS_CODE}
    ...    msg=Status code inesperado! Esperado: 200, Recebido: ${response.status_code}. Corpo da Resposta: ${response.text}
