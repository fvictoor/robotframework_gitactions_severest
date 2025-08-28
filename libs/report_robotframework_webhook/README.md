# 📋Relatório de Testes para Webhook

Este documento detalha o funcionamento e o uso do script `report_webhook.py`, projetado para processar os resultados de testes do Robot Framework, gerar um relatório consolidado e enviá-lo para um endpoint de webhook.

## 🌐 Visão Geral

O script `report_webhook.py` automatiza o processo de notificação dos resultados de testes automatizados. Ele realiza as seguintes ações:
1.  **Processa dois arquivos de resultado** do Robot Framework (`output.xml`): um da execução principal e outro de uma re-execução (rerun).
2.  **Coleta estatísticas detalhadas**, como número total de testes, aprovados, reprovados e a lista de testes que falharam na re-execução.
3.  **Agrega resultados por tags** específicas, permitindo uma análise segmentada da suíte de testes.
4.  **Formata um relatório de texto** claro e informativo com todas as métricas coletadas.
5.  **Envia o relatório** para um URL de webhook configurado via variáveis de ambiente.

## ⚡Requisitos de Execução

Para que o script funcione corretamente, é necessário ter o Python instalado e as seguintes bibliotecas. Você pode instalá-las usando `pip`.

-   **requests**: Para realizar as chamadas HTTP para o webhook.
    ```bash
    pip install requests
    ```

-   **robotframework**: Para processar os arquivos de resultado (`output.xml`).
    ```bash
    pip install robotframework
    ```

-   **python-dotenv**: Para carregar as variáveis de ambiente do arquivo `.env`.
    ```bash
    pip install python-dotenv
    ```

Você pode também instalar todas de uma vez com o comando:
```bash
pip install requests robotframework python-dotenv
```

## 🧪 Pré-requisitos (.env)

Antes de executar o script, é necessário configurar um arquivo `.env` na raiz do projeto para armazenar as variáveis de ambiente.

### 🏷️ Variáveis de Ambiente

Crie um arquivo chamado `.env` e adicione as seguintes variáveis:

| Variável            | Descrição                                                                                               | Exemplo                                                              |
| ------------------- | ------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `WEBHOOK_URL` | **(Obrigatório)** O URL completo do webhook para onde o relatório será enviado.                           | `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX` |
| `TAGS`              | **(Obrigatório)** Uma lista de tags (separadas por vírgula) que devem ser analisadas individualmente no relatório. | `smoke,regression,critical`                                          |

**Exemplo de arquivo `.env`:**
```bash
WEBHOOK_URL="https://hooks.your-webhook-provider.com/services/"
TAGS="smoke,regression,api"
```

## 🛠️ Uso

O script é executado através da linha de comando e requer a especificação dos caminhos para os arquivos de resultado.

### 🏷️ Argumentos da Linha de Comando

| Argumento         | Descrição                                                                               | Obrigatório |
| ----------------- | --------------------------------------------------------------------------------------- | ----------- |
| `execucao_xml`    | Caminho para o arquivo `output.xml` da execução principal dos testes.                   | Sim         |
| `rerun_xml`       | Caminho para o arquivo `output.xml` da re-execução (rerun) dos testes.                  | Sim         |
| `--titulo`        | Título personalizado para o cabeçalho do relatório. Se não for fornecido, um valor padrão será usado. | Não         |

### 📚 Exemplo de Execução
```bash
python report_webhook.py ./logs/output.xml ./logs/rerun_output.xml --titulo "🚀 Relatório de Testes - Projeto Phoenix"
```

### 📚 Estrutura do Body para o Webhook

O script envia uma requisição `POST` para o `WEBHOOK_URL` configurado. O corpo (body) da requisição é um JSON simples contendo uma única chave: `content`.

### 🛠️ Formato do JSON

```json
{
  "content": "..."
}
```

-   `content` (string): Contém o relatório completo formatado como texto puro, com quebras de linha (`\n`) para estruturação.

### 🔤 Exemplo de Conteúdo do Body

O conteúdo da chave `content` será uma string formatada similar ao exemplo abaixo:

```
📋 RELATÓRIO DE TESTES AUTOMATIZADOS
🚀 Qtd. Total de Testes: 150
✅ Qtd. Testes Aprovados (final): 145
❌ Qtd. Testes Reprovados (inicial): 10
🔁 Qtd. Testes que persistiram no erro (Rerun): 5

⚠️ Testes que falharam no Rerun:
- Cenário de Login com Credenciais Inválidas
- Validar API de Criação de Usuário
- Teste de Conexão com Banco de Dados
- Submeter Formulário sem Preencher Campos Obrigatórios
- Verificar Geração de Relatório em PDF

📌 Resultados por TAG (Execução Principal):

- Tag: `Smoke`
  • Total: 20
  • Aprovados: 18
  • Falharam: 2
  • Duração: 5m12s

- Tag: `Regression`
  • Total: 130
  • Aprovados: 122
  • Falharam: 8
  • Duração: 45m30s

📊 Tempos de Execução:
🕐 Tempo Execução Principal: 50m42s
🔄 Tempo Execução Rerun: 8m15s
⏳ Tempo Total (soma): 58m57s
```