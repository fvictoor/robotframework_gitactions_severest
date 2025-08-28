![Dashboard demo](https://github.com/fvictoor/robot_report_dashboard/blob/main/dashboard.gif?raw=true)

# 🤖 Robot Framework Dashboard Generator

Bem-vindo ao **Robot Framework Dashboard Generator**!

Esta ferramenta transforma os arquivos de saída brutos (`output.xml`) do Robot Framework em um dashboard **HTML interativo, moderno e elegante**. Analise os resultados dos seus testes de forma visual, identifique falhas, acompanhe o tempo de execução e filtre testes por tags com facilidade.

---

## ✨ Principais Funcionalidades

- 📊 **Dashboard Interativo**: Visualize métricas de execução de forma clara e organizada.
- 🎨 **Temas Dark & Light**: Alterne entre os temas para melhor conforto visual.
- 📈 **Gráficos Detalhados**: Analise a distribuição de testes por suíte, tempo de execução e performance por tags.
- 🔍 **Análise de Re-execução (Rerun)**: Diferencia falhas iniciais, testes recuperados e falhas definitivas.
- 📂 **Detalhes Expansíveis**: Navegue por suítes e testes para ver detalhes, documentação e mensagens de erro.
- ⚙️ **Execução Flexível**: Personalize a análise por tags, o diretório de saída e o nome do arquivo final via linha de comando.

---

## 🚀 Começando

### 1. Pré-requisitos

Certifique-se de que você tem o **Python 3** instalado. As seguintes bibliotecas Python são necessárias:

- `robotframework` (para gerar os arquivos `output.xml`)
- `pandas`
- `Jinja2`

Você pode instalar as dependências com um único comando:

```bash
pip install pandas Jinja2
```

### 2. Estrutura de Arquivos

Para que o script funcione corretamente, seus arquivos devem seguir a estrutura abaixo. O arquivo `report_template.html` deve estar dentro de uma subpasta chamada `templates`.

```
/seu-projeto-de-testes/
|
└── libs/
    └── robot_report_dashboard/
        ├── main.py                   # O script principal
        └── templates/
            └── report_template.html  # O template do dashboard
```

---

## 🏃‍♀️ Como Usar (Execução)

Execute o script `main.py` via linha de comando, fornecendo os caminhos para os arquivos XML de resultado.

### Estrutura do Comando

```bash
python /caminho/para/main.py <output.xml> <rerun.xml> [OPÇÕES]
```

### Argumentos

| Argumento     | Descrição                                                                 | Obrigatório |
|---------------|---------------------------------------------------------------------------|-------------|
| `output.xml`  | Caminho para o arquivo `output.xml` da execução principal.                | Sim         |
| `rerun.xml`   | Caminho para o arquivo `output.xml` da re-execução (rerun) das falhas.    | Sim         |
| `--tags`      | Lista de tags para análise nos gráficos, separadas por vírgula. Padrão: `alta,media,baixa` | Não |
| `--output_dir`| Pasta onde o relatório HTML será salvo. Padrão: diretório atual.          | Não         |
| `--filename`  | Nome do arquivo HTML gerado. Padrão: `report.html`                        | Não         |

---

## 🧪 Exemplos Práticos

💡 *Dica: Use caminhos relativos ou absolutos conforme sua necessidade.*

### Execução Básica

Gera um `report.html` no diretório atual, analisando as tags `alta`, `media` e `baixa`.

```bash
python .\libs\robot_report_dashboard\main.py C:\Logs\output.xml C:\Logs\rerun.xml --tags "alta,media,baixa"
```

### Execução Personalizada

Gera um relatório chamado `dashboard_smoke_tests.html` na pasta `C:\Resultados`, analisando apenas as tags `critico` e `smoke`.

```bash
python .\libs\robot_report_dashboard\main.py C:\Logs\output.xml C:\Logs\rerun.xml --tags "critico,smoke" --output_dir "C:\Resultados" --filename "dashboard_smoke_tests.html"
```

---

## 📊 Entendendo o Dashboard

O relatório gerado oferece uma visão completa da sua execução de testes:

- **Cards de Resumo**: 
  - Total de Testes
  - Aprovados
  - Falhas Iniciais
  - Recuperados (falhou no 1º run, passou no rerun)
  - Falhas Definitivas

- **Gráficos**:
  - **Distribuição por Suíte**: Gráfico de pizza com a proporção de testes por suíte.
  - **Tempo de Execução por Suíte**: Gráfico de barras mostrando quais suítes são mais demoradas.
  - **Testes e Tempo por Tag**: Análise de quantidade e tempo por prioridade/tag.

- **Detalhamento por Suíte**:
  - Lista interativa com cada suíte expansível.
  - Exibe status, tempo, tags, documentação e mensagens de erro de cada teste.
  - Suítes com falhas definitivas são destacadas em vermelho.

---

