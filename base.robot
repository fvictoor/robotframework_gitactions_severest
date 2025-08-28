*** Settings ***
Documentation    Nesse arquivo vamos armazenar todos os resources e variáveis padrões do projeto de Testes automação do Site Serverest.
# Importação de Bibliotecas.
Library    Browser
Library    FakerLibrary
Library    Dialogs
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections

# Importação de Recursos.
Resource    ./resources/keywords/CadastroKeywords.robot
Resource    ./resources/keywords/KeywordsDefaut.robot
Resource    ./resources/keywords/LoginKeyword.robot
Resource    ./resources/keywords/ListaComprasKeyword.robot
Resource    ./resources/services/UsuariosService.robot
Resource    ./resources/services/ProdutosServices.robot

### Importação de Page Objects.
Variables    ./resources/locators/Casdastro.yml
Variables    ./resources/locators/Home.yml
Variables    ./resources/locators/ListaCompras.yml
Variables    ./resources/locators/Login.yml

*** Variables ***

# Definição de variáveis Padrões do Sistema.
${BROWSER}                chromium
${RESOLUCAO_BROWSER}      {'width': 1920, 'height': 1080}
${CONFIG_VIDEO}           None    #{'dir': 'video', 'size':{'width': 1920, 'height': 1080}}
${HEADLESS}               ${True}
${URL_FRONTEND}           https://front.serverest.dev/login
${URL_BACKEND}            https://serverest.dev/
${TIMEOUT_DEFAUT}         10s
${DELAY_CLICK}            1s
${DELAY_TEXT}             60ms
${TOKEN}                  None
${DEFAUT_MESSAGE}         Falha ao carregar a página: o elemento "{selector}" não atingiu o estado "{function}" dentro do tempo limite de {timeout}.
@{LIST_USER}
