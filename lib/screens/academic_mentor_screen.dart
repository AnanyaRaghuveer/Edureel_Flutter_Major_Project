import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../app_theme.dart';
import '../models/rag_response.dart';
import '../services/rag_api_service.dart';

class AcademicMentorScreen extends StatefulWidget {
  const AcademicMentorScreen({super.key});

  @override
  State<AcademicMentorScreen> createState() => _AcademicMentorScreenState();
}

class _AcademicMentorScreenState extends State<AcademicMentorScreen> {
  final _questionController = TextEditingController();
  final _api = RagApiService();
  RagResponse? _response;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() => _error = 'Please enter a question.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.askQuestion(
        documentId: 'string3',
        question: question,
      );
      if (mounted) setState(() => _response = response);
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _message(Object error) {
    if (error is FormatException) return error.message;
    if (error is StateError) return error.message;
    return error.toString().contains('TimeoutException')
        ? 'The backend took too long to respond.'
        : 'Backend unavailable. Check the backend URL and try again.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appBackground,
    appBar: AppBar(title: const Text('AI Academic Mentor')),
    body: AppVisualBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Text(
            'Ask a question about your module',
            style: TextStyle(
              color: context.appText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _questionController,
            minLines: 2,
            maxLines: 5,
            style: TextStyle(color: context.appText),
            decoration: InputDecoration(
              hintText: 'What is normalization?',
              hintStyle: TextStyle(color: context.appSubtleText),
              prefixIcon: Icon(
                Icons.question_answer_outlined,
                color: context.appAccent,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _ask,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Asking AI...' : 'Ask AI'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 18),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 26),
          Text(
            'AI Answer',
            style: TextStyle(
              color: context.appText,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          GlassPanel(
            padding: const EdgeInsets.all(18),
            radius: 18,
            child: _response == null
                ? Text(
                    'Your answer will appear here.',
                    style: TextStyle(color: context.appSubtleText, height: 1.5),
                  )
                : MarkdownBody(
                    data: _response!.answer,
                    styleSheet: MarkdownStyleSheet(
                      blockSpacing: 12,
                      p: TextStyle(color: context.appText, height: 1.65),
                      h1: TextStyle(
                        color: context.appText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      h2: TextStyle(
                        color: context.appText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                      h3: TextStyle(
                        color: context.appText,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      listBullet: TextStyle(color: context.appAccent),
                      strong: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shrinkWrap: true,
                  ),
          ),
        ],
      ),
    ),
  );
}
