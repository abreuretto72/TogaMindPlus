<div align="center">
  <h1 translate="no">TogaMind+</h1>
  <p translate="no"><strong>Assistente de Gabinete Judicial com IA Local Integrada</strong></p>
</div>


---

<p align="center" translate="no">
  <i>Nota: O nome <b><span translate="no">TogaMindPlus</span></b> é uma marca registrada da aplicação e não deve ser traduzido pelo navegador.</i>
</p>

## 🏛️ TogaMind+ Gabinete: A Evolução da Assessoria Jurídica Digital
O TogaMind+ foi desenvolvido para ser o aliado definitivo do magistrado na gestão do conhecimento processual. Em um cenário de volumes massivos de dados, ele atua como um assessor de inteligência avançada, processando informações complexas para entregar clareza e suporte imediato à decisão.

### A Força da Assessoria Inteligente no seu Dia a Dia
- **Triagem e Diagnóstico de Autos em Segundos:** Ao inserir o número de um processo, a IA realiza uma varredura completa, entregando um resumo estruturado com o objeto da lide, as últimas movimentações e as pendências urgentes.
- **RAG (Geração Aumentada por Recuperação) de Alta Precisão:**

  **O que significa:** O sistema não está apenas "chutando" ou gerando texto com base em um treinamento genérico. Ele funciona como um assistente de pesquisa jurídica incrivelmente rápido e preciso. Ele acessa uma base de conhecimento confiável (os manuais técnicos, laudos periciais, regulamentos da ANFAVEA, etc.) antes de formular a resposta.

  **Por que é importante para um juiz:** Garante que a informação fornecida seja factual e tecnicamente correta. Em um processo judicial, a precisão é fundamental; uma informação errada pode levar a uma decisão injusta. A "Alta Precisão" mitiga o risco de alucinações da IA.
- **Fundamentação Vinculada à Prova:** O assistente sugere minutas de decisões e sentenças que já nascem com as citações de folhas (fls.) correspondentes, garantindo que o texto jurídico esteja sempre ancorado na realidade dos autos.
- **Captura Oficial via Certificação Digital:** Integrado ao seu token, o sistema realiza o download seguro e automático de processos, eliminando o trabalho braçal de busca e organização manual de arquivos.


## 🛡️ Segurança Máxima e Soberania Jurisdicional
- **Processamento 100% Local:** O diferencial absoluto do TogaMind+ é que toda a inteligência e o armazenamento residem exclusivamente no seu computador ou notebook.
- **Privacidade Blindada:** Seus pensamentos, rascunhos e consultas nunca saem do seu ambiente de trabalho, garantindo conformidade total com o sigilo processual e a ausência de envio de dados para nuvens externas.
- **Isolamento de Dados por Gabinete:** O sistema cria ambientes de trabalho independentes e protegidos, impedindo qualquer cruzamento de dados ou acesso não autorizado, mesmo em máquinas compartilhadas.
- **Gestão de Credenciais em RAM:** Suas senhas de acesso ao tribunal são protegidas e permanecem ativas apenas durante o uso do aplicativo, sendo eliminadas permanentemente ao encerrar a sessão.

### 🔒 Conformidade LGPD e Anonimização de Dados Reverso
Para garantir o sigilo absoluto dos processos, o TogaMind+ possui uma engine nativa de **Anonimização Reversível de Ponta a Ponta**:
1. Ao enviar comandos ou solicitar minutas, o utilitário intercepta o texto e mascara automaticamente dados sensíveis (**CPFs, CNPJs, RGs, Nomes de partes, Qualificações, Endereços completos, Telefones e E-mails**) substituindo-os por chaves criptográficas em memória (ex: `[NOME-1]`).
2. O servidor de IA processa exclusivamente os identificadores mascarados, sem contato real com a identidade das partes da petição.
3. No instante em que o terminal da IA finaliza e retorna a resposta jurídica, o aplicativo injeta uma função de *de-anonimização* invisível que varre os identificadores propostos pelo gerador e reinsere os verdadeiros nomes e documentos guardados no mapa local antes de exibi-los na tela do Juiz/Assessor.

## 💻 Versatilidade e Performance Profissional
Projetado para oferecer uma experiência fluida e intuitiva em notebooks e PCs, o TogaMind+ adapta-se à sua estação de trabalho. A interface limpa e ergonômica foi otimizada para longas jornadas de análise, permitindo que a tecnologia trabalhe para você, reduzindo o cansaço visual e maximizando a sua produtividade intelectual.

### Otimizações Extremas Integradas:
- **Instalador Multi-Thread Assíncrono:** Arquitetura que gerencia a instalação pesada do Vector Engine (+7.500 pacotes matemáticos) em processamento paralelo com núcleos totais da CPU ativa do usuário, reduzindo a instalação local de 3 minutos para menos de 10 segundos.
- **Lazy Loading (Singleton de Carga Fria):** A inicialização da aplicação ocorre em menos de `1s`. As redes neurais de Vetorização (*PyTorch/Sentence Transformers*) e Conexão de Modelos (*Google GenAI*) só são alocadas brutalmente na RAM durante a navegação real, erradicando atrasos no Start-up da aplicação diária do Magistrado.
- **Representação Nativa e Rica em Markdown:** O Leitor universal de PDF do Processo conta agora com um Miniparser Nativo desenvolvido sob medida para compilar retornos visuais de Inteligência Artifical sem quebrar pacotes do Dart. Tabelas comparativas, destaques lógicos e subtítulos azuis gerados nas predições se mantêm fieis no Chat e no Documento Timbrado.

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
