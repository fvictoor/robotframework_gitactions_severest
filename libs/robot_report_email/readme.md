
# 📬 Disparador de E-mail com Anexo - Robot Framework

Este script realiza o envio automático de e-mails contendo o **relatório HTML de testes automatizados** como anexo. Ideal para pipelines de CI/CD que executam testes com Robot Framework e precisam comunicar os resultados por e-mail de forma automática e simples.

---

## 🆕 O que há de novo?

- ✅ Recebe o caminho do relatório como argumento via linha de comando (`argparse`)
- ✅ Melhoria no tratamento de erros, incluindo falhas na leitura do anexo
- ✅ Reutilização do mesmo corpo para múltiplos destinatários
- ✅ Variáveis de configuração 100% externas via `.env`

---

## 📁 Estrutura dos Arquivos

- `disparador_email.py`: Script principal de envio.
- `.env`: Arquivo com variáveis de ambiente (credenciais e destinatários).

---

## ⚙️ Configuração do `.env`

```env
# Configuração do remetente
EMAIL_REMETENTE="seu_email@dominio.com"
EMAIL_SENHA="sua_senha_de_app"
SMTP_SERVIDOR="smtp.gmail.com"
SMTP_PORTA="587"

# Lista de destinatários (separados por vírgula)
EMAIL_DESTINATARIOS="email1@dominio.com,email2@dominio.com"
```

> ⚠️ *Use uma [senha de app](https://support.google.com/accounts/answer/185833?hl=pt-BR) para envio com Gmail.*

---

## 🚀 Como Usar

Execute o script passando o caminho do relatório `.html` como argumento:

```bash
python disparador_email.py ./caminho/para/relatorio.html
```

---

## 📨 Corpo do E-mail

```text
Prezados,

Teste Automatizado executado com sucesso.
Em anexo há as informações de logs detalhadas!

Atenciosamente,
Sistema de Automação de Testes.
```

---

## 📦 Requisitos

- Python 3.x
- Dependências:

```bash
pip install python-dotenv
```

---

## 💡 Boas Práticas

- Nunca versionar o arquivo `.env` com informações sensíveis.
- Automatize esse disparador ao final do processo de execução de testes na pipeline (ex: via GitHub Actions, Jenkins, GitLab CI).
- Certifique-se de que o relatório HTML está finalizado antes de enviar.

---

## ✅ Exemplo Completo

```bash
python disparador_email.py report.html
```

---

## 📫 Resultado Esperado

- Um e-mail será enviado para todos os destinatários definidos.
- O relatório HTML será anexado.
- O corpo será fixo e padronizado para facilitar a comunicação.

---

