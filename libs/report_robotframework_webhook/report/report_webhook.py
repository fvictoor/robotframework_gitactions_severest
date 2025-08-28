import sys
import os
import requests
import json
import argparse
from robot.api import ExecutionResult
from dotenv import load_dotenv

CONTEUDO_MINIMO_XML = """<?xml version="1.0" encoding="UTF-8"?>
<robot generator="Robot 7.0" generated="2025-01-01T14:41:03.934898" rpa="false" schemaversion="4">
<suite id="s1" name="Tests">
</suite>
<statistics>
<total>
<stat pass="0" fail="0" skip="0">All Tests</stat>
</total>
<tag>
</tag>
<suite>
<stat pass="0" fail="0" skip="0" id="s1" name="Tests">Tests</stat>
</suite>
</statistics>
<errors>
</errors>
</robot>
"""

def verificar_ou_criar_xml(caminho):
    """Verifica se um arquivo XML existe. Se não, cria um com conteúdo mínimo."""
    if not os.path.exists(caminho):
        print(f"[AVISO] Arquivo não encontrado: {caminho}. Criando um arquivo vazio para continuar.")
        os.makedirs(os.path.dirname(caminho), exist_ok=True)
        with open(caminho, "w", encoding="utf-8") as f:
            f.write(CONTEUDO_MINIMO_XML)
        print(f"[CRIADO] Arquivo de log vazio criado em: {caminho}")

def coletar_testes_falhos(suite):
    """Percorre recursivamente uma suíte de testes e retorna uma lista de testes que falharam."""
    failed_list = []
    for test in suite.tests:
        if test.status == 'FAIL':
            failed_list.append(test.name)
    for subsuite in suite.suites:
        failed_list.extend(coletar_testes_falhos(subsuite))
    return failed_list

def formatar_lista_falhas(lista):
    """Formata uma lista de falhas para exibição."""
    if not lista:
        return "Nenhum teste falhou 🎉"
    return "\n".join(f"- {item}" for item in lista)

def formatar_tempo(ms):
    """Converte milissegundos para o formato 'XmYs'."""
    if ms is None:
        return "0m0s"
    segundos = int(ms / 1000)
    minutos = segundos // 60
    segundos %= 60
    return f"{minutos}m{segundos}s"

def coletar_dados_por_tag(suite, tags_alvo):
    """Coleta estatísticas de testes para um conjunto específico de tags."""
    tags_info = {tag.lower(): {"total": 0, "passed": 0, "failed": 0, "elapsed": 0} for tag in tags_alvo}

    for test in suite.tests:
        for tag in test.tags:
            tag_lower = tag.lower()
            if tag_lower in tags_info:
                tags_info[tag_lower]["total"] += 1
                if test.status == "PASS":
                    tags_info[tag_lower]["passed"] += 1
                else:
                    tags_info[tag_lower]["failed"] += 1
                tags_info[tag_lower]["elapsed"] += test.elapsedtime
    
    for subsuite in suite.suites:
        dados_subsuite = coletar_dados_por_tag(subsuite, tags_alvo)
        for tag, data in dados_subsuite.items():
            tags_info[tag]["total"] += data["total"]
            tags_info[tag]["passed"] += data["passed"]
            tags_info[tag]["failed"] += data["failed"]
            tags_info[tag]["elapsed"] += data["elapsed"]
            
    return tags_info

def notificar_slack(link_webhook, texto):
    """Envia uma mensagem de texto para um webhook do Slack."""
    if not link_webhook:
        raise ValueError("A variável 'WEBHOOK_URL' não foi definida no seu arquivo .env.")
    
    headers = {"Content-Type": "application/json"}
    body = {"content": texto}
    
    print("\nEnviando relatório para o Slack...")
    try:
        response = requests.post(url=link_webhook, headers=headers, data=json.dumps(body), timeout=10)
        response.raise_for_status()
        print("Relatório enviado com sucesso para o Slack!")
    except requests.RequestException as e:
        raise Exception(f"Erro ao enviar notificação para o Slack: {e}")


def main():
    load_dotenv()

    parser = argparse.ArgumentParser(
        description="Processa logs do Robot Framework, gera um relatório e envia para o Slack."
    )
    parser.add_argument("execucao_xml", help="Caminho para o arquivo output.xml da execução principal.")
    parser.add_argument("rerun_xml", help="Caminho para o arquivo output.xml da re-execução (rerun).")
    parser.add_argument(
        "--titulo", 
        default="📋 RELATÓRIO DE TESTES AUTOMATIZADOS", 
        help="Título personalizado para o relatório."
    )
    args = parser.parse_args()

    WEBHOOK_URL = os.getenv("WEBHOOK_URL")
    tags_str = os.getenv("TAGS")

    if not WEBHOOK_URL:
        print("[ERRO] A variável WEBHOOK_URL não foi encontrada. Verifique seu arquivo .env.")
        sys.exit(1)
        
    if not tags_str:
        print("[ERRO] A variável TAGS não foi encontrada. Verifique seu arquivo .env.")
        sys.exit(1)

    tags_alvo = [tag.strip() for tag in tags_str.split(',')]
    print(f"Analisando as seguintes tags: {tags_alvo}")

    verificar_ou_criar_xml(args.execucao_xml)
    verificar_ou_criar_xml(args.rerun_xml)

    print("\nProcessando arquivos de resultado...")
    result_execucao = ExecutionResult(args.execucao_xml)
    result_rerun = ExecutionResult(args.rerun_xml)

    falhas_execucao = coletar_testes_falhos(result_execucao.suite)
    falhas_rerun = coletar_testes_falhos(result_rerun.suite)

    stats_execucao = result_execucao.statistics
    dados_por_tag = coletar_dados_por_tag(result_execucao.suite, tags_alvo)

    tempo_execucao_ms = result_execucao.suite.elapsedtime
    tempo_rerun_ms = result_rerun.suite.elapsedtime
    tempo_total_ms = tempo_execucao_ms + tempo_rerun_ms

    print("Montando o corpo do relatório...")
    
    info_gerais = {
        "🚀 Qtd. Total de Testes": stats_execucao.total.total,
        "✅ Qtd. Testes Aprovados (final)": stats_execucao.total.passed,
        "❌ Qtd. Testes Reprovados (inicial)": len(falhas_execucao),
        "🔁 Qtd. Testes que persistiram no erro (Rerun)": len(falhas_rerun),
    }

    tempos = {
        "🕐 Tempo Execução Principal": formatar_tempo(tempo_execucao_ms),
        "🔄 Tempo Execução Rerun": formatar_tempo(tempo_rerun_ms),
        "⏳ Tempo Total (soma)": formatar_tempo(tempo_total_ms),
    }

    partes_relatorio = [f"*{args.titulo}*\n"]
    for key, value in info_gerais.items():
        partes_relatorio.append(f"*{key}:* {value}")

    partes_relatorio.append(f"\n*⚠️ Testes que falharam no Rerun:*\n{formatar_lista_falhas(falhas_rerun)}")
    
    partes_relatorio.append("\n*📌 Resultados por TAG (Execução Principal):*")
    if not any(dados_por_tag.values()):
        partes_relatorio.append("Nenhuma das tags especificadas foi encontrada nos testes.")
    else:
        for tag, info in dados_por_tag.items():
            if info['total'] > 0:
                tempo = formatar_tempo(info["elapsed"])
                partes_relatorio.append(
                    f"\n- *Tag: `{tag.capitalize()}`*\n"
                    f"  • Total: {info['total']}\n"
                    f"  • Aprovados: {info['passed']}\n"
                    f"  • Falharam: {info['failed']}\n"
                    f"  • Duração: {tempo}"
                )

    partes_relatorio.append("\n*📊 Tempos de Execução:*")
    for key, value in tempos.items():
        partes_relatorio.append(f"*{key}:* {value}")

    relatorio_final = "\n".join(partes_relatorio)

    notificar_slack(WEBHOOK_URL, relatorio_final)

if __name__ == "__main__":
    main()