import 'dart:convert';

import 'package:http/http.dart' as http;

const backendBaseUrl = 'https://edureel-backend-o33b.onrender.com';

class EduReelApi {
  Future<Map<String, dynamic>> getJson(
    String path, {
    String? accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl$path'),
      headers: _headers(accessToken),
    );
    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(String path, {String? accessToken}) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl$path'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Request failed (${response.statusCode}).');
    }
    final body = jsonDecode(response.body);
    if (body is! List) {
      throw const FormatException('Expected a list response.');
    }
    return body;
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body, {
    required String accessToken,
  }) async {
    final response = await http.put(
      Uri.parse('$backendBaseUrl$path'),
      headers: _headers(accessToken, includeJson: true),
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Map<String, String> _headers(
    String? accessToken, {
    bool includeJson = false,
  }) {
    return {
      'Accept': 'application/json',
      if (includeJson) 'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Request failed (${response.statusCode}).');
    }
    final body = jsonDecode(response.body);
    if (body is! Map) {
      throw const FormatException('Expected an object response.');
    }
    return Map<String, dynamic>.from(body);
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.institution,
    required this.skills,
  });

  final String name;
  final String? phone;
  final String email;
  final String? institution;
  final List<String> skills;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name']?.toString() ?? '',
    phone: json['phone']?.toString(),
    email: json['email']?.toString() ?? '',
    institution: json['institution']?.toString(),
    skills: (json['skills'] is List)
        ? (json['skills'] as List).map((skill) => skill.toString()).toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'institution': institution,
    'skills': skills,
  };
}

class QuizOption {
  const QuizOption({required this.id, required this.text});

  final int id;
  final String text;

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
    id: (json['id'] as num).toInt(),
    text: json['text']?.toString() ?? '',
  );
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  final int id;
  final String question;
  final List<QuizOption> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: (json['id'] as num).toInt(),
    question: json['question']?.toString() ?? '',
    options: (json['options'] as List? ?? [])
        .whereType<Map>()
        .map((option) => QuizOption.fromJson(Map<String, dynamic>.from(option)))
        .toList(),
  );
}

class ReelQuiz {
  const ReelQuiz({
    required this.title,
    this.description,
    required this.questions,
  });

  final String title;
  final String? description;
  final List<QuizQuestion> questions;

  factory ReelQuiz.fromJson(Map<String, dynamic> json) => ReelQuiz(
    title: json['title']?.toString() ?? 'Quiz',
    description: json['description']?.toString(),
    questions: (json['questions'] as List? ?? [])
        .whereType<Map>()
        .map(
          (question) =>
              QuizQuestion.fromJson(Map<String, dynamic>.from(question)),
        )
        .toList(),
  );
}
