<div align="center">
  <h1 translate="no">TogaMind+</h1>
  <p translate="no"><strong>Assistente de Gabinete Judicial com IA Local Integrada</strong></p>
</div>

<p align="center">
  <img src="assets/toga_login.png" alt="Tela de Login do TogaMind+ Gabinete" width="800">
  <br><br>
  <img src="assets/toga_google_login.png" alt="Autenticação Segura via Google" width="400">
</p>

---

<p align="center" translate="no">
  <i>Nota: O nome <b><span translate="no">TogaMindPlus</span></b> é uma marca registrada da aplicação e não deve ser traduzido pelo navegador.</i>
</p>

## 🏛️ TogaMind+ Gabinete: A Evolução da Assessoria Jurídica Digital
O TogaMind+ foi desenvolvido para ser o aliado definitivo do magistrado na gestão do conhecimento processual. Em um cenário de volumes massivos de dados, ele atua como um assessor de inteligência avançada, processando informações complexas para entregar clareza e suporte imediato à decisão.

### A Força da Assessoria Inteligente no seu Dia a Dia
- **Triagem e Diagnóstico de Autos em Segundos:** Ao inserir o número de um processo, a IA realiza uma varredura completa, entregando um resumo estruturado com o objeto da lide, as últimas movimentações e as pendências urgentes.
- **RAG (Geração Aumentada por Recuperação) de Alta Precisão:** Interrogue os autos em linguagem natural e receba respostas fundamentadas com a indicação exata da página do PDF onde a prova se encontra.
- **Fundamentação Vinculada à Prova:** O assistente sugere minutas de decisões e sentenças que já nascem com as citações de folhas (fls.) correspondentes, garantindo que o texto jurídico esteja sempre ancorado na realidade dos autos.
- **Captura Oficial via Certificação Digital:** Integrado ao seu token, o sistema realiza o download seguro e automático de processos, eliminando o trabalho braçal de busca e organização manual de arquivos.

<p align="center">
  <img src="assets/toga_analise_pdf.png" alt="Análise de Processos em Lote" width="45%">
  &nbsp;
  <img src="assets/toga_import_token.png" alt="Importação via PFX" width="45%">
</p>
<p align="center">
  <img src="assets/toga_rag_chat.png" alt="Motor RAG e Chat com os Autos" width="45%">
  &nbsp;
  <img src="assets/toga_minuta_editor.png" alt="Redação de Minuta Judicial" width="45%">
</p>

## 🛡️ Segurança Máxima e Soberania Jurisdicional
- **Processamento 100% Local:** O diferencial absoluto do TogaMind+ é que toda a inteligência e o armazenamento residem exclusivamente no seu computador ou notebook.
- **Privacidade Blindada:** Seus pensamentos, rascunhos e consultas nunca saem do seu ambiente de trabalho, garantindo conformidade total com o sigilo processual e a ausência de envio de dados para nuvens externas.
- **Isolamento de Dados por Gabinete:** O sistema cria ambientes de trabalho independentes e protegidos, impedindo qualquer cruzamento de dados ou acesso não autorizado, mesmo em máquinas compartilhadas.
- **Gestão de Credenciais em RAM:** Suas senhas de acesso ao tribunal são protegidas e permanecem ativas apenas durante o uso do aplicativo, sendo eliminadas permanentemente ao encerrar a sessão.

## 💻 Versatilidade e Performance Profissional
Projetado para oferecer uma experiência fluida e intuitiva em notebooks e PCs, o TogaMind+ adapta-se à sua estação de trabalho. A interface limpa e ergonômica foi otimizada para longas jornadas de análise, permitindo que a tecnologia trabalhe para você, reduzindo o cansaço visual e maximizando a sua produtividade intelectual.

## 🛠️ Tecnologias Utilizadas

A pilha corporativa do TogaMind+ é construída para resiliência no modo *Standalone* (Offline-First local):

* **Frontend:** Flutter Web (`SfPdfViewer`, Components Material3).
* **Backend Bridge:** Python FastApi.
* **Intrínsecos e IA:** `google-generativeai`, `sentence-transformers`, `faiss-cpu`, `cryptography` e `reportlab`.
* **Empacotamento:** Executável `TogaEngine.exe` Único (via PyInstaller) com a UI injetada no `_MEIPASS` em RAM.

## 🚀 Como Iniciar

Por ser desenhado para segurança governamental, não dependemos de servidores Docker e Nodes globais. O Magistrado acessa o executável standalone do diretório isolado:

1. Extraia a base consolidada do TogaMind+.
2. Insira sua chave no arquivo oculto `.env` (`GEMINI_API_KEY=xxx`).
3. Dê clique-duplo em `Abrir_TogaMind.bat` (O script irá subir o micro-serviço Uvicorn e abrir o navegador Chrome de forma segura limitando o cache).

## 🗄️ Estrutura de Cofre (Storage Vault)
Nenhum dado sensível trafega pela rede ou fica no banco de dados. Os documentos são ancorados da seguinte forma:
```
E:\
└── antigravity_projetos\
    └── toga_mind_plus\
        └── storage\
            └── rag_vault\
                └── {numero_matricula_juiz}\
                    ├── credentials/ (Token PFX Isolado)
                    ├── processos/ (PDFs Baixados Localmente)
                    ├── index/ (Vetores Matemáticos da IA)
                    └── decisoes/ (PDFs em A4 Timbrados)
```

<br>

---
<p align="center">
  &copy; 2026 ScanNut Multiverso Digital
</p>
