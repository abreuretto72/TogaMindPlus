import os
import sys
import json
from fastapi import FastAPI, Header, Body, Form, HTTPException, UploadFile, File
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from dotenv import load_dotenv
import google.generativeai as genai
from pydantic import BaseModel
from colorama import init, Fore

# Custom Toga modules
from toga_rag_manager import TogaRAGManager
from toga_vector_engine import TogaVectorEngine

# PDF Generator
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4

init(autoreset=True)

# -------------------------------------------------------------------
# VALIDAÇÃO DE AMBIENTE (PROTOCOLO 2026)
# -------------------------------------------------------------------
def validar_ambiente_local():
    """Verifica se os arquivos vitais existem na raiz antes de subir o servidor"""
    erros = []
    raiz = os.getcwd()

    if not os.path.exists(os.path.join(raiz, ".env")):
        erros.append("ERRO: Arquivo '.env' nao encontrado na raiz. Insira sua GEMINI_API_KEY.")

    if not os.path.exists(os.path.join(raiz, "config.json")):
        erros.append("ERRO: Arquivo 'config.json' nao encontrado na raiz.")

    web_dir = os.path.join(getattr(sys, '_MEIPASS', raiz), "build", "web")
    if not os.path.exists(web_dir) and not os.path.exists(os.path.join(raiz, "build", "web")):
        erros.append("ERRO: Pasta 'build/web' nao encontrada no executavel nem nativamente.")

    if erros:
        print(Fore.RED + "\n" + "="*50)
        print(Fore.RED + "   FALHA NA INICIALIZACAO DO TOGAMIND+")
        print(Fore.RED + "="*50)
        for erro in erros:
            print(Fore.YELLOW + f" > {erro}")
        print(Fore.RED + "="*50 + "\n")
        
        input("Pressione ENTER para sair...")
        sys.exit(1)
    
    print(Fore.GREEN + "[OK] Integridade do sistema verificada. Iniciando Engine...")

# Executa a validação antes de tudo
validar_ambiente_local()

# Carregar ambiente da raiz
load_dotenv(os.path.join(os.getcwd(), ".env"))
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    print(Fore.RED + "ERRO FATAL: GEMINI_API_KEY não encontrada. Fechando.")
    sys.exit(1)

# Inicializações Base
app = FastAPI(title="TogaMind+ AI Engine")

rag_manager = TogaRAGManager()
vector_engine = TogaVectorEngine()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class RAGDocument(BaseModel):
    content_type: str
    title: str
    content: str
    judge_id: str = "anonimo"

def get_active_model():
    config_path = "config.json" 
    try:
        if os.path.exists(config_path):
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
                return config.get("active_model", "gemini-3-flash")
    except Exception:
        pass
    return "gemini-3-flash"

import hashlib

def hash_password(password: str) -> str:
    salt = os.urandom(16).hex()
    pwd_hash = hashlib.sha256((password + salt).encode('utf-8')).hexdigest()
    return f"{salt}${pwd_hash}"

def verify_password(password: str, hashed_str: str) -> bool:
    try:
        salt, pwd_hash = hashed_str.split("$")
    except ValueError:
        return False
    return hashlib.sha256((password + salt).encode('utf-8')).hexdigest() == pwd_hash

# -------------------------------------------------------------------
# ROTAS DE AUTENTICAÇÃO E REGISTRO (MULTI-TENANCY)
# -------------------------------------------------------------------
@app.post("/register")
async def register_judge(payload: dict = Body(...)):
    judge_id = payload.get("judge_id")
    password = payload.get("password")
    if not judge_id or not password:
        raise HTTPException(status_code=400, detail="Credenciais incompletas")
        
    vault_path = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id)
    os.makedirs(vault_path, exist_ok=True)
    
    config_file = os.path.join(vault_path, "user_config.json")
    if os.path.exists(config_file):
        raise HTTPException(status_code=400, detail="Magistrado já cadastrado.")
        
    pwd_hashed = hash_password(password)
    with open(config_file, "w", encoding="utf-8") as f:
        json.dump({"password_hash": pwd_hashed}, f)
        
    return {"status": "success", "message": "Gabinete criado com sucesso!"}

@app.post("/login")
async def login_judge(payload: dict = Body(...)):
    judge_id = payload.get("judge_id")
    password = payload.get("password")
    if not judge_id or not password:
        raise HTTPException(status_code=400, detail="Credenciais incompletas")
        
    config_file = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "user_config.json")
    if not os.path.exists(config_file):
        raise HTTPException(status_code=401, detail="Magistrado não encontrado.")
        
    with open(config_file, "r", encoding="utf-8") as f:
        data = json.load(f)
        
    hashed_str = data.get("password_hash")
    if not hashed_str or not verify_password(password, hashed_str):
        raise HTTPException(status_code=401, detail="Senha incorreta.")
        
    return {"status": "success", "message": "Autenticado"}

# -------------------------------------------------------------------
# ROTAS DE IA E RAG
# -------------------------------------------------------------------

@app.post("/analyze")
async def analyze_process(
    file: UploadFile = File(...),
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado. Credenciais ausentes.")

    try:
        pdf_content = await file.read()
        active_model = get_active_model()
        genai.configure(api_key=api_key)
        
        model = genai.GenerativeModel(
            model_name=active_model,
            system_instruction=(
                "Você é o TogaMind+, assistente jurídico de elite do Multiverso Digital. "
                "Sua tarefa é analisar processos em PDF e extrair: "
                "1. Resumo dos Fatos. 2. Pedidos do Autor. 3. Argumentos do Réu. 4. Tempestividade. "
                "Use linguagem clara, objetiva e profissional. Nunca emita juízo de valor ou sentenças."
            ),
            generation_config={
                "candidate_count": 1,
                "temperature": 0.2,
            }
        )

        response = model.generate_content([
            "Analise este processo judicial e destaque os pontos críticos para o magistrado:",
            {'mime_type': 'application/pdf', 'data': pdf_content}
        ])

        analysis_text = response.text
        
        rag_manager.save_for_rag(
            content_type="peticao_analisada",
            title=file.filename or "processo",
            content=analysis_text,
            judge_id=judge_id
        )

        return {"analysis": analysis_text, "model_used": active_model}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/ask-toga")
async def ask_toga(
    payload: dict = Body(...),
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado. Credenciais ausentes.")

    query = payload.get("query")
    if not query:
        raise HTTPException(status_code=400, detail="Pergunta inválida.")

    try:
        # Recupera os contextos arquivados isolados por judge_id no drive local
        context_docs = vector_engine.search_similar(query, top_k=3, judge_id=judge_id)
        context_text = "\n\n".join(context_docs)

        active_model = get_active_model()
        genai.configure(api_key=api_key)
        
        model = genai.GenerativeModel(
            model_name=active_model,
            system_instruction=(
                "Você é o TogaMind+, o assistente pessoal deste Magistrado. "
                "Abaixo, forneço o contexto de rascunhos e decisões anteriores do próprio juiz. "
                "Sua resposta deve ser baseada nesse estilo e jurisprudência pessoal. "
                "Se o contexto for insuficiente, use a lei brasileira, mas sempre cite que está baseando-se no histórico."
            ),
            generation_config={"candidate_count": 1, "temperature": 0.2}
        )

        full_prompt = (
            f"CONTEXTO DO JUIZ:\n{context_text}\n\n"
            f"PERGUNTA ATUAL: {query}\n\n"
            "Responda de forma técnica, curta e em Português (Brasil)."
        )

        response = model.generate_content(full_prompt)

        return {
            "answer": response.text,
            "used_context": len(context_docs) > 0,
            "model": active_model
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/process_pdf")
async def get_process_pdf(path: str):
    if not os.path.exists(path) or not path.lower().endswith(".pdf"):
        raise HTTPException(status_code=404, detail="Arquivo PDF não encontrado.")
    return FileResponse(path, media_type="application/pdf")

@app.post("/chat-contextual")
async def chat_contextual(
    payload: dict = Body(...),
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado. Credenciais ausentes.")

    query = payload.get("query")
    processo_numero = payload.get("processo_numero")
    
    if not query or not processo_numero:
        raise HTTPException(status_code=400, detail="Pergunta ou número do processo inválido.")

    # 1. Definir o escopo da busca no Drive E:
    caminho_processo = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "processos", f"{processo_numero}.pdf")
    
    if not os.path.exists(caminho_processo):
         raise HTTPException(status_code=404, detail="Autos do processo não encontrados na base local.")

    try:
        active_model = get_active_model()
        genai.configure(api_key=api_key)
        
        model = genai.GenerativeModel(
            model_name=active_model,
            system_instruction=(
                "Você é o TogaMind+, assistente de inteligência do Magistrado. "
                "Responda à pergunta do usuário baseando-se EXCLUSIVAMENTE nos autos do processo fornecido no anexo PDF. "
                "CITE A PÁGINA do documento em sua resposta obrigatoriamente, se aplicável. "
                "Retorne os dados estritamente no esquema: {'texto': 'Sua resposta aqui.', 'pagina': 12}. "
                "Se não encontrar o número da página exato, retorne -1 no campo pagina."
            ),
            generation_config={
                "temperature": 0.2,
                "response_mime_type": "application/json",
            }
        )

        with open(caminho_processo, "rb") as f:
            pdf_data = f.read()

        full_prompt = (
            f"PERGUNTA ATUAL referente a este processo: {query}\n\n"
            "Responda de forma técnica, inserindo o número da página no campo 'pagina'."
        )

        response = model.generate_content([
            full_prompt,
            {'mime_type': 'application/pdf', 'data': pdf_data}
        ])
        
        # Deserializar a resposta assegurada pelo JSON MimeType
        response_data = json.loads(response.text)

        return {
            "resposta": response_data.get("texto", "Não foi possível estruturar a resposta."),
            "pagina": response_data.get("pagina", -1),
            "arquivo": caminho_processo,
            "model": active_model
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/gerar-minuta")
async def gerar_minuta(
    payload: dict = Body(...),
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado. Credenciais ausentes.")

    ponto_decisao = payload.get("ponto_decisao")
    processo_numero = payload.get("processo_numero")

    if not ponto_decisao or not processo_numero:
        raise HTTPException(status_code=400, detail="Ponto ou processo inválido.")

    # 1. Recupera as citações e páginas já indexadas no Drive E:
    caminho_processo = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "processos", f"{processo_numero}.pdf")
    if not os.path.exists(caminho_processo):
         raise HTTPException(status_code=404, detail="Autos do processo não encontrados na base local.")

    try:
        active_model = get_active_model()
        genai.configure(api_key=api_key)
        
        model = genai.GenerativeModel(
            model_name=active_model,
            system_instruction=(
                "Você é o TogaMind+, assistente de inteligência do Magistrado. "
                "Redija parágrafos de fundamentação (minutas de decisão) baseadas unicamente na evidência do anexo PDF. "
                "Regra: Use citação direta indicando a página do PDF entre parênteses (ex: fls. X). "
                "Estilo: Sóbrio, impessoal e estritamente técnico e jurídico."
            ),
            generation_config={"temperature": 0.2}
        )

        with open(caminho_processo, "rb") as f:
            pdf_data = f.read()

        full_prompt = (
            f"Com base nos autos {processo_numero}, redija um parágrafo de fundamentação "
            f"sobre '{ponto_decisao}'."
        )

        response = model.generate_content([
            full_prompt,
            {'mime_type': 'application/pdf', 'data': pdf_data}
        ])

        return {"minuta": response.text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/exportar-pdf-decisao")
async def exportar_pdf(
    payload: dict = Body(...),
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado. Credenciais ausentes.")

    conteudo = payload.get("conteudo")
    processo_numero = payload.get("processo_numero")

    if not conteudo or not processo_numero:
        raise HTTPException(status_code=400, detail="Conteúdo ou número do processo inválido.")

    # 1. Definir caminho de saída no Drive E:
    output_path = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "decisoes", f"Decisao_{processo_numero}.pdf")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # 2. Criar o PDF com Padrão 2026
    c = canvas.Canvas(output_path, pagesize=A4)
    c.setFont("Helvetica-Bold", 12)
    c.drawString(100, 800, "PODER JUDICIÁRIO - ESTADO DE SÃO PAULO")
    
    c.setFont("Helvetica", 11)
    # Quebra de linha automática (Primitiva) para a minuta gerada
    textobject = c.beginText(100, 750)
    for line in conteudo.split('\n'):
        textobject.textLine(line)
        # Handle long lines primitively by wrapping if extremely long (Simpler implementation given ReportLab canvas.textLine restrictions)
        
    c.drawText(textobject)
    
    # 3. Rodapé Obrigatório (Protocolo 2026)
    c.setFont("Helvetica-Oblique", 8)
    footer_text = "Página 1 | © 2026 ScanNut Multiverso Digital"
    c.drawString(200, 50, footer_text)
    
    c.save()
    return {"status": "success", "file_url": output_path}

@app.post("/save-rag")
async def save_to_rag(
    doc: RAGDocument,
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado.")
        
    try:
        saved_path = rag_manager.save_for_rag(
            content_type=doc.content_type,
            title=doc.title,
            content=doc.content,
            judge_id=judge_id
        )
        return {"status": "success", "saved_path": saved_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/sync-rag")
async def sync_rag(
    payload: dict = Body(...),
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado.")

    text = payload.get("content")
    if text:
        vector_engine.add_document(text, judge_id=judge_id)
        return {"status": "Sincronizado com a memória RAG"}
    return {"status": "Conteúdo vazio"}

@app.get("/config.json")
async def get_config():
    config_path = "config.json"
    if os.path.exists(config_path):
        return FileResponse(config_path)
    raise HTTPException(status_code=404, detail="config.json não encontrado")

import shutil
from services.court_integration import download_processo_com_token

active_sessions = {}

@app.get("/token-status")
async def token_status(judge_id: str = Header(None)):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Usuário não identificado.")
    pfx_path = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "credentials", "token_magistrado.pfx")
    registered = os.path.exists(pfx_path)
    unlocked = judge_id in active_sessions
    return {"registered": registered, "unlocked": unlocked}

@app.post("/register-token")
async def register_token(
    certificate: UploadFile = File(...), 
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Usuário não identificado.")
    
    target_dir = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "credentials")
    os.makedirs(target_dir, exist_ok=True)
    file_path = os.path.join(target_dir, "token_magistrado.pfx")
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(certificate.file, buffer)
        
    return {"status": "success", "path": file_path}

@app.post("/unlock-token")
async def unlock_token(
    password: str = Body(embed=True), 
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Usuário não identificado.")

    pfx_path = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "credentials", "token_magistrado.pfx")
    
    if not os.path.exists(pfx_path):
        return {"status": "error", "message": "Token não encontrado no gabinete."}

    try:
        from cryptography.hazmat.primitives.serialization import pkcs12
        from cryptography.hazmat.backends import default_backend
        with open(pfx_path, "rb") as f:
            pkcs12.load_key_and_certificates(f.read(), password.encode(), default_backend())
        
        active_sessions[judge_id] = password
        return {"status": "success", "message": "Token desbloqueado com sucesso."}
    except Exception:
        return {"status": "error", "message": "Senha do certificado incorreta."}

@app.post("/import-process")
async def import_process(
    process_number: str = Form(...),
    judge_id: str = Header(None)
):
    if not judge_id:
        raise HTTPException(status_code=401, detail="Acesso Negado.")

    if judge_id not in active_sessions:
        raise HTTPException(status_code=401, detail="Sessão de token não validada.")

    pfx_path = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "credentials", "token_magistrado.pfx")
    password = active_sessions[judge_id]

    try:
        success = download_processo_com_token(judge_id, pfx_path, password, process_number)
        
        if success:
            pdf_dest = os.path.join(os.getcwd(), "storage", "rag_vault", judge_id, "processos", f"{process_number}.pdf")
            resumo = await gerar_resumo_imediato(pdf_dest)
            
            return {
                "status": "success", 
                "message": "Autos importados com sucesso na sua base pessoal.",
                "summary": resumo
            }
        else:
            raise HTTPException(status_code=500, detail="Falha ao baixar autos com o token fornecido.")
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro de processamento do token: {str(e)}")

async def gerar_resumo_imediato(pdf_path: str) -> str:
    prompt = """
    Analise os autos recém-capturados e forneça um resumo em 3 pontos:
    1. Objeto principal da ação.
    2. Última movimentação relevante (decisão ou petição).
    3. Pendência imediata (prazo ou conclusão).
    Seja conciso e use linguagem jurídica sóbria.
    """
    try:
        active_model = get_active_model()
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel(
            model_name=active_model,
            generation_config={"candidate_count": 1, "temperature": 0.2}
        )
        with open(pdf_path, "rb") as f:
            pdf_data = f.read()
            
        response = model.generate_content([
            prompt,
            {'mime_type': 'application/pdf', 'data': pdf_data}
        ])
        return response.text
    except Exception as e:
        return f"Não foi possível gerar o resumo automático: {str(e)}"

# -------------------------------------------------------------------
# MONTAGEM DA INTERFACE WEB ESTÁTICA (DEVE SER O ÚLTIMO)
# -------------------------------------------------------------------
WEB_PATH = os.path.join(getattr(sys, '_MEIPASS', os.getcwd()), "build", "web")
if os.path.exists(WEB_PATH):
    app.mount("/", StaticFiles(directory=WEB_PATH, html=True), name="ui")
else:
    fallback_path = r"E:\antigravity_projetos\toga_mind_plus\build\web"
    if os.path.exists(fallback_path):
        app.mount("/", StaticFiles(directory=fallback_path, html=True), name="ui")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
