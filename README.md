<div align="center">
  <h1 translate="no">TogaMind+</h1>
  <p translate="no"><strong>Assistente de Gabinete Judicial com IA Local Integrada</strong></p>
</div>

---

<p align="center" translate="no">
  <i>Nota: O nome <b><span translate="no">TogaMindPlus</span></b> é uma marca registrada da aplicação e não deve ser traduzido pelo navegador.</i>
</p>

## 🏛️ Sobre o Projeto

O **<span translate="no">TogaMind+</span>** é um sistema autônomo e isolado projetado para modernizar o fluxo de trabalho de um gabinete de Magistratura. Construído sob o rigoroso **Protocolo 2026**, ele combina a Inteligência Artificial Generativa do Google Gemini com a indexação local de RAG (Retrieval-Augmented Generation) para conversar diretamente com os autos processuais, de forma totalmente privada e criptografada.

Diferente de sistemas web em nuvem, o TogaMind+ roda **localmente na máquina do Juíz (notebook ou PC). Sem acesso ao mundo externo**, garantindo que processos em segredo de justiça e certificados digitais nunca deixem o ambiente seguro do Tribunal.

## ✨ Principais Funcionalidades

### 1. 🔐 Integração Direta via Token (.pfx)
- O magistrado pode vincular seu Certificado Digital (E-CPF/E-CNPJ) diretamente ao TogaMind+.
- Baixa o processo judicial na íntegra dos painéis de Justiça Estadual diretamente para o Repositório pessoal local do Magistrado.

### 2. 🧠 RAG Pessoal (Isolado)
- Diferente de IAs genéricas, o TogaMind+ cria uma base de dados vetorial (`FAISS`) exclusiva para o *Judge ID* autenticado.
- As decisões, rascunhos e autos anteriores formam o "**Cérebro do Gabinete**", e a IA aprende a julgar e redigir usando a sua jurisprudência passada e estilo pessoal.

### 3. 💬 Chat Contextual de Precisão
- Não é um chat livre comum: o Chat Contextual é restrito à leitura daquele processo em específico, evitando alucinações.
- **Citação Direta (Anchor Point):** Toda resposta da Inteligência Artificial sobre o processo contém com exatidão a **Página do Processo Físico (PDF)** onde ela encontrou a evidência.

### 4. 📝 Minuta de Decisão Automática (Fundamentação)
- Transforma a evidência cirúrgica achada e elabora argumentos com profunda retórica técnico-jurídica, poupando a redação manual.
- Ferramenta nativa em interface com margem reduzida (`600px`), ergonomicamente validada para as telas dos gabinetes (incl. Samsung A25).

### 5. 🖨️ Exportação de Ofício Assinado (PDF Timbrado)
- Encerra o fluxo despachando a Minuta validada diretamente em uma folha formato A4 (`ReportLab` nativo).
- O backend em Python injeta o cabeçalho oficial de "Poder Judiciário" ao arquivo físico para inclusão direta no e-SAJ/PJe.

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
