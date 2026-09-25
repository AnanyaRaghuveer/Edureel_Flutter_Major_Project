import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/rag_response.dart';

class RagApiService {
  RagApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<bool> testConnection() async {
    final response = await _client
        .get(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/health'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<RagResponse> askQuestion({
    required String documentId,
    required String question,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/questions/ask'),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'document_id': documentId, 'question': question}),
        )
        .timeout(const Duration(seconds: 90));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Backend request failed (${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map)
      throw const FormatException('The backend returned an invalid response.');
    return RagResponse.fromJson(Map<String, dynamic>.from(decoded));
  }
}
