*** Settings ***
Resource    ../../base.robot
Documentation    Nesse arquivo vamos estar criando Keyword relaciona ao Login do site.

*** Keywords ***
Realizar Login
    [Arguments]     ${USUARIO}    ${SENHA}    ${TIPO_USER}=comum    ${ALERT}=false    ${SUCESS}=    ${MENSAGEM}=
    Wait Element    ${Login.TITULO_LOGIN}
    Escrever em:    ${Login.CAMPO_EMAIL}    ${USUARIO}
    Escrever em:    ${Login.CAMPO_SENHA}    ${SENHA}
    Clicar em:      ${Login.BOTAO_ENTRAR}
    IF    '${TIPO_USER}' == 'comum'
        Wait Element    ${Home.TITULO_PAGINA}
    ELSE IF   '${TIPO_USER}' == 'administrador'    
        Wait Element    ${Home.TITULO_PAGINA_ADM}
    END
    
    IF  "${ALERT}" != "false"
        ${MENSAGEM}    Get Property    ${Cadastro.CAMPO_EMAIL_CADASTRO}    property=validationMessage
        Should Be Equal As Strings    ${MENSAGEM}    ${ALERT}    msg=Mensagem de alerta diferente da validação    collapse_spaces=true     strip_spaces=true
    ELSE IF    '${SUCESS}'=='false' 
        Wait Until Keyword Succeeds     2x    2s    Validar mensagem de cadastro    ${MENSAGEM}    ${SUCESS}
        Reload
    END