import os
import smtplib
import argparse 
from datetime import datetime
from dotenv import load_dotenv
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

load_dotenv()

def enviar_email_com_anexo(assunto, corpo_email, destinatario, caminho_anexo):
    """Monta e envia um e-mail com corpo de texto e um arquivo em anexo."""
    
    remetente = os.getenv('EMAIL_REMETENTE')
    senha = os.getenv('EMAIL_SENHA')
    smtp_servidor = os.getenv('SMTP_SERVIDOR')
    smtp_porta = int(os.getenv('SMTP_PORTA', 587))

    if not all([remetente, senha, smtp_servidor]):
        print("ERRO: Configure as variáveis de ambiente no arquivo .env")
        return

    msg = MIMEMultipart()
    msg['Subject'] = assunto
    msg['From'] = remetente
    msg['To'] = destinatario

    msg.attach(MIMEText(corpo_email, 'plain'))

    try:
        with open(caminho_anexo, "rb") as attachment:
            part = MIMEBase("application", "octet-stream")
            part.set_payload(attachment.read())
        
        encoders.encode_base64(part)
        
        nome_arquivo = os.path.basename(caminho_anexo)
        part.add_header(
            "Content-Disposition",
            f"attachment; filename= {nome_arquivo}",
        )
        msg.attach(part)
    except FileNotFoundError:
        print(f"ERRO: O arquivo de anexo não foi encontrado em: {caminho_anexo}")
        return
    except Exception as e:
        print(f"Erro ao processar o anexo: {e}")
        return

    server = None
    try:
        server = smtplib.SMTP(smtp_servidor, smtp_porta)
        server.starttls()
        server.login(remetente, senha)
        server.sendmail(remetente, destinatario, msg.as_string())
        print(f"E-mail com relatório em anexo enviado para: {destinatario}")
    except smtplib.SMTPAuthenticationError:
        print("Erro de autenticação. Verifique seu email/senha ou configuração.")
    except Exception as e:
        print(f"Ocorreu um erro ao enviar o e-mail: {e}")
    finally:
        if server:
            server.quit()


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Envia um relatório HTML por e-mail como anexo.")
    parser.add_argument("caminho_do_relatorio", help="O caminho para o arquivo de relatório .html a ser enviado.")
    args = parser.parse_args()

    caminho_arquivo_html = args.caminho_do_relatorio
    
    corpo = """Prezados,

Teste Automatizado executado com sucesso.
Em anexo há as informações de logs detalhadas!

Atenciosamente,
Sistema de Automação de Testes."""

    data_hoje = datetime.now().strftime("%d/%m/%Y")
    assunto = f"Relatório de Execução de Testes Automatizados - {data_hoje}"
    
    destinatarios_str = os.getenv('EMAIL_DESTINATARIOS', '')
    lista_de_emails = [email.strip() for email in destinatarios_str.split(',') if email.strip()]

    if not lista_de_emails:
        print("ERRO: A variável 'EMAIL_DESTINATARIOS' não foi encontrada ou está vazia no arquivo .env.")
    else:
        # Envia o e-mail para cada destinatário
        for email in lista_de_emails:
            enviar_email_com_anexo(assunto, corpo, email, caminho_arquivo_html)