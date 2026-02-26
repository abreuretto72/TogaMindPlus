import os
from sentence_transformers import SentenceTransformer
import faiss
import numpy as np

class TogaVectorEngine:
    def __init__(self, model_name='paraphrase-multilingual-MiniLM-L12-v2', base_vault_path=None):
        if base_vault_path is None:
            base_vault_path = os.path.join(os.getcwd(), "storage", "vector_db")
        self.model = SentenceTransformer(model_name)
        self.dimension = 384
        self.base_vault_path = base_vault_path
        self.indices = {} # judge_id -> faiss index
        self.documents = {} # judge_id -> list of texts
        os.makedirs(self.base_vault_path, exist_ok=True)

    def _get_or_create_judge_space(self, judge_id):
        if judge_id not in self.indices:
            self.indices[judge_id] = faiss.IndexFlatL2(self.dimension)
            self.documents[judge_id] = []
            
            # Isolamento Físico de Pasta
            judge_vault = os.path.join(self.base_vault_path, judge_id)
            os.makedirs(judge_vault, exist_ok=True)

    def add_document(self, text, judge_id="juiz_01"):
        """Transforma o texto em vetor e adiciona ao índice FAISS do juiz"""
        self._get_or_create_judge_space(judge_id)
        embedding = self.model.encode([text])
        self.indices[judge_id].add(np.array(embedding).astype('float32'))
        self.documents[judge_id].append(text)

    def search_similar(self, query, top_k=3, judge_id="juiz_01"):
        """Busca os trechos mais parecidos com a dúvida na subpasta do juiz logado"""
        self._get_or_create_judge_space(judge_id)
        
        index = self.indices[judge_id]
        docs = self.documents[judge_id]
        
        if index.ntotal == 0:
            return []
            
        query_vector = self.model.encode([query])
        distances, indices = index.search(np.array(query_vector).astype('float32'), top_k)
        
        results = [docs[i] for i in indices[0] if i != -1]
        return results

# Instalação necessária: pip install sentence-transformers faiss-cpu
