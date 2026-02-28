# ⚖️ TogaMind+ (Protocolo ScanNut 2026)
**Manual de Operação do Gabinete Digital**

Bem-vindo(a) ao **TogaMind+**, a plataforma de Gestão de Audiências e Memória RAG construída rigorosamente sob o Protocolo ScanNut. Este sistema foi desenhado para rodar **100% Offline** no seu equipamento (ex: SM A256E ou Notebook do Tribunal), garantindo a proteção e a privacidade absoluta dos dados judiciais.

---

## 🚀 1. Inicialização do Sistema
Seu Gabinete já conta com o empacotamento definitivo.
1. Navegue até a pasta `TogaMindPlus_Release_Final`.
2. Acesse a pasta `app` e execute o **`toga_mind_plus.exe`**.
3. O servidor de Inteligência Artificial Local (FastAPI + RAG Python) será ligado silenciosamente no fundo para prover o "Cérebro" do seu assistente na porta `8000`.

---

## 📋 2. Pauta do Dia (Gestão de Audiências)
Ao abrir o TogaMind+, você verá o **Dashboard Central (Pauta do Dia)**. Esta interface exibe a fila de atas a serem realizadas.
- Cada Audiência exibe de imediato um "Overview" extraído nativamente das petições iniciais (PyMuPDF).
- Se houver necessidade de interagir com o "Cérebro RAG", clique em **"Análisar Autos (Gemini)"**. O motor lerá o PDF em profundidade e fará uma previsão rica da causa.
- Para adentrar na elaboração, clique em **"Abrir Sala Digital"**.

---

## 💻 3. Sala de Audiência Digital (Editor e DOCX)
A Sala de Celebração de Ata, desenvolvida com o máximo de ergonomia ocular, é dividida em dois painéis (Side-by-Side):

* **[Painel Esquerdo - RAG Local]**: Exibe os *Pontos Controvertidos* gerados automaticamente pelo Assistente baseados na peça. 
   - **Chip Verde da Memória Ativa**: Se o motor Python detectar que você já prolatou sentenças semelhantes (através do diretório histórico `brain`), o RAG incorporará a "Sua Mão/Assinatura" na proposta, e um indicador *Contexto de Decisões Anteriores Aplicado* brilhará.
* **[Painel Direito - Ocorrências e Ata]**: Editor texto livre responsivo (`SingleChildScrollView`). Digite o fechamento da instrução ou os acordos.
* **Salvar Termo (.docx)**: Ao clicar, o sistema não apenas encerra a ata na UI, mas também:
   1. Compila um `.docx` oficial.
   2. Move fisicamente para o seu HD em `~\Desktop\Relatorios_Assistente\Para_Assinar`.

---

## 🛡️ 4. Segurança de Dados, Backup e Resiliência Automática
O TogaMind+ trabalha para você e protege seu fluxo.
- **Backup Invisível**: Toda vez que o aplicativo inicia, ele realiza sozinho o backup das rotinas SQLite e de seu Banco Vetorial. O status aparece cintilando em Verde-Gabinete no Rodapé da Tela inicial: *"Backup realizado no Desktop"*.
- **Pilar Zero Interno**: O código do Sistema é banhado com o selo *Zero Hardcode*. Isso significa que toda a interface em Português-BR (`l10n`) é padronizada garantindo isenção de artefatos soltos de programação.

*- Desenhado e Lapidado Magistralmente para a Judicância Moderna.*
