class RagSource {
  const RagSource({required this.value});

  final String value;
}

class RagResponse {
  const RagResponse({
    required this.answer,
    required this.sources,
    required this.raw,
  });

  final String answer;
  final List<RagSource> sources;
  final Map<String, dynamic> raw;

  factory RagResponse.fromJson(Map<String, dynamic> json) {
    final answer = _firstText(json, const [
      'answer',
      'generated_answer',
      'generatedAnswer',
      'response',
      'content',
      'result',
    ]);
    final sourceValue =
        json['sources'] ??
        json['source_information'] ??
        json['sourceInformation'] ??
        json['citations'];
    final sources = <RagSource>[];
    if (sourceValue is List) {
      for (final item in sourceValue) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final text = _firstText(map, const [
            'source',
            'content',
            'text',
            'document_id',
            'documentId',
          ]);
          if (text.isNotEmpty) sources.add(RagSource(value: text));
        } else if (item != null) {
          sources.add(RagSource(value: item.toString()));
        }
      }
    } else if (sourceValue != null) {
      sources.add(RagSource(value: sourceValue.toString()));
    }
    if (answer.isEmpty)
      throw const FormatException(
        'The backend response did not contain an answer.',
      );
    return RagResponse(answer: answer, sources: sources, raw: json);
  }

  static String _firstText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty)
        return value.toString().trim();
    }
    return '';
  }
}
