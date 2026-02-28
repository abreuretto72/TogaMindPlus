class TogaAnonymizationResult {
  final String anonymizedText;
  final Map<String, String> mapping;

  TogaAnonymizationResult(this.anonymizedText, this.mapping);
}

class TogaAnonymizer {
  /// Remove ou mascara dados sensíveis como CPF, CNPJ, RG, Nomes, Endereços,
  /// Telefones, E-mails e qualificações completas retornando um objeto 
  /// contendo o texto e o dicionário de chaves para reversão.
  static TogaAnonymizationResult anonymizeWithMap(String text) {
    if (text.isEmpty) return TogaAnonymizationResult(text, {});
    
    String result = text;
    final Map<String, String> mapping = {};
    
    int cpfCount = 1;
    int cnpjCount = 1;
    int rgCount = 1;
    int qualifCount = 1;
    int endCount = 1;
    int cepCount = 1;
    int emailCount = 1;
    int telCount = 1;
    int regCount = 1;
    int nomeCount = 1;

    // 1. CPF
    result = result.replaceAllMapped(
      RegExp(r'\b(?:CPF[:\s]*)?\d{3}[\.\s]?\d{3}[\.\s]?\d{3}[-\s]?\d{2}\b', caseSensitive: false),
      (match) {
        final key = '[CPF-$cpfCount]';
        mapping[key] = match.group(0)!;
        cpfCount++;
        return key;
      }
    );

    // 2. CNPJ
    result = result.replaceAllMapped(
      RegExp(r'\b(?:CNPJ[:\s]*)?\d{2}[\.\s]?\d{3}[\.\s]?\d{3}[/\s]?\d{4}[-\s]?\d{2}\b', caseSensitive: false),
      (match) {
        final key = '[CNPJ-$cnpjCount]';
        mapping[key] = match.group(0)!;
        cnpjCount++;
        return key;
      }
    );

    // 3. RG
    result = result.replaceAllMapped(
      RegExp(r'\b(?:RG|Registro Geral|Identidade)[:\s]*\d{1,2}[\.\s]?\d{3}[\.\s]?\d{3}[-\s]?[0-9xX]\b|\b\d{1,2}\.\d{3}\.\d{3}-[0-9xX]\b', caseSensitive: false),
      (match) {
        final key = '[RG-$rgCount]';
        mapping[key] = match.group(0)!;
        rgCount++;
        return key;
      }
    );

    // 4. Blocos de Qualificação Completos
    result = result.replaceAllMapped(
      RegExp(r'\b([\p{L}\s]+)(?:,\s*)(brasileir[oa]|solteir[oa]|casad[oa]|divorciad[oa]|viúv[oa]|união estável).*?(?:residente|domiciliado|RG|CPF|CNPJ|CEP|\n)', caseSensitive: false, unicode: true),
      (match) {
        final key = '[QUALIFICAÇÃO-$qualifCount]';
        mapping[key] = match.group(0)!;
        qualifCount++;
        return key;
      }
    );

    // 5. Endereço explícito
    result = result.replaceAllMapped(
      RegExp(r'\b(?:Residente e domiciliado\s*|Endereço[:\s]*|Localizado[:\s]*)?(?:na|no|em)?\s*(?:Rua|Avenida|Av\.|Praça|Travessa|Rodovia|Alameda|Estrada)\s+[\p{L}0-9\s.,]+(?:nº|n°|número|num)?\s*\d+.*?(?:CEP[:\s]*\d{5}-?\d{3}|\n|\.|$)', caseSensitive: false, unicode: true),
      (match) {
        final key = '[ENDEREÇO-$endCount]';
        mapping[key] = match.group(0)!;
        endCount++;
        return key;
      }
    );
    // CEP solto
    result = result.replaceAllMapped(
      RegExp(r'\b(?:CEP[:\s]*\d{5}-?\d{3})\b|\b(\d{5}-\d{3})\b', caseSensitive: false),
      (match) {
        final key = '[CEP-$cepCount]';
        mapping[key] = match.group(0)!;
        cepCount++;
        return key;
      }
    );

    // 6. E-mail
    result = result.replaceAllMapped(
      RegExp(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'),
      (match) {
        final key = '[EMAIL-$emailCount]';
        mapping[key] = match.group(0)!;
        emailCount++;
        return key;
      }
    );

    // 7. Telefone
    result = result.replaceAllMapped(
      RegExp(r'\b(?:Tel|Telefone|Cel|Celular)[:\s]*\(?\d{2}\)?\s*(?:9?\d{4})[-.\s]*\d{4}\b', caseSensitive: false),
      (match) {
        final key = '[TELEFONE-$telCount]';
        mapping[key] = match.group(0)!;
        telCount++;
        return key;
      }
    );
    result = result.replaceAllMapped(
      RegExp(r'\b\(?\d{2}\)?\s*9?\d{4}[-.\s]\d{4}\b'),
      (match) {
        final key = '[TELEFONE-$telCount]';
        mapping[key] = match.group(0)!;
        telCount++;
        return key;
      }
    );

    // 8. OAB / Outros Registros
    result = result.replaceAllMapped(
      RegExp(r'\b(oab|crm|cro)[/\s-]*([a-z]{2})?[/\s-]*(\d+)\b', caseSensitive: false),
      (match) {
        final key = '[REGISTRO-$regCount]';
        mapping[key] = match.group(0)!;
        regCount++;
        return key;
      }
    );

    // 9. Nomes acompanhados de pronomes/títulos ou identificadores de parte do processo
    result = result.replaceAllMapped(
      RegExp(r'\b(Autor[ea]?|Réu|Ré|Requerente|Requerid[oa]|Paciente|Vítima|Testemunha|Sr\.|Sra\.|Dr\.|Dra\.|nome(?: de| da| do)?|chamad[oa]|promovid[oa])\s+((?:[\p{Lu}][\p{L}]+(?:\s+(?:de|da|do|dos|das|e))?\s*)+)\b', caseSensitive: false, unicode: true),
      (match) {
        final prefix = match.group(1)!;
        final name = match.group(2)!.trim();
        final key = '[NOME-$nomeCount]';
        mapping[key] = name;
        nomeCount++;
        return '$prefix $key';
      }
    );

    // 10. Nomes em CAIXA ALTA (muito comum em peças jurídicas para identificar as partes)
    result = result.replaceAllMapped(
      RegExp(r'\b(?:[\p{Lu}]{3,}\s+(?:DE|DA|DO|DOS|DAS|E\s+)?)+[\p{Lu}]{3,}\b', unicode: true),
      (match) {
        String phrase = match.group(0)!;
        final ignoreWords = [
          'VARA', 'JUIZADO', 'TRIBUNAL', 'EXCELENTÍSSIMO', 'DIREITO', 'AÇÃO', 
          'RECURSO', 'APELAÇÃO', 'AGRAVO', 'HABEAS', 'CORPUS', 'DANO', 'MORAL',
          'ESTADO', 'MINISTÉRIO', 'PÚBLICO', 'JUSTIÇA', 'PODER', 'JUDICIÁRIO',
          'SUPREMO', 'SUPERIOR', 'CÓDIGO', 'PENAL', 'CIVIL', 'LEI', 'ARTIGO',
          'TURMA', 'CÂMARA', 'COMARCA', 'SEÇÃO', 'PROCESSO', 'EMENTA', 'ACÓRDÃO',
          'FEDERAL', 'ESTADUAL', 'TRABALHO', 'MANDADO', 'SEGURANÇA', 'PETIÇÃO',
          'INICIAL', 'LIMITADA', 'LTDA', 'S/A', 'SA', 'ALVARÁ', 'JUDICIAL', 
          'DECISÃO', 'SENTENÇA', 'LIMINAR', 'MÉRITO', 'AUTOS', 'JUNTADA', 
          'DOCUMENTO', 'PARECER', 'DESPACHO', 'RELATÓRIO', 'VOTO', 'EMBARGOS',
          'DECLARAÇÃO', 'CONSTITUIÇÃO', 'REPÚBLICA', 'SECRETARIA'
        ];
        bool shouldIgnore = ignoreWords.any((word) => phrase.contains(word));
        if (shouldIgnore) return phrase;
        
        final key = '[NOME-$nomeCount]';
        mapping[key] = phrase;
        nomeCount++;
        return key;
      }
    );

    return TogaAnonymizationResult(result, mapping);
  }

  /// Método de conveniência para quando não se precisa do mapa (apenas envio descartável).
  static String anonymize(String text) {
    return anonymizeWithMap(text).anonymizedText;
  }

  /// Restaura os dados originais no texto de resposta da IA usando o dicionário.
  static String deanonymize(String text, Map<String, String> mapping) {
    if (text.isEmpty || mapping.isEmpty) return text;
    String result = text;
    mapping.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }
}
