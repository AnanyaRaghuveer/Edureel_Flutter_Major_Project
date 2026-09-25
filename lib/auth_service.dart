import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

// Supply this with --dart-define=GOOGLE_WEB_CLIENT_ID=... . This is a public
// OAuth client ID, never a client secret.
const _googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
const _storedSessionKey = 'edureel_auth_session';
const _secureStorage = FlutterSecureStorage();

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String accessToken;
  final int userId;
  final String name;
  final String email;
  final String? photoUrl;

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'user': {'id': userId, 'name': name, 'email': email, 'photoUrl': photoUrl},
  };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = Map<String, dynamic>.from(json['user'] as Map);
    return AuthSession(
      accessToken: json['accessToken'] as String,
      userId: (user['id'] as num).toInt(),
      name: user['name'] as String,
      email: user['email'] as String,
      photoUrl: user['photoUrl'] as String?,
    );
  }
}

class GoogleAuthService {
  GoogleAuthService()
    : _googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        clientId: _googleWebClientId.isEmpty ? null : _googleWebClientId,
        // The web implementation rejects serverClientId. Android needs the
        // Web OAuth client ID here so the ID token can be verified by the API.
        serverClientId: kIsWeb || _googleWebClientId.isEmpty
            ? null
            : _googleWebClientId,
      );

  final GoogleSignIn _googleSignIn;

  Future<AuthSession> signIn() async {
    if (_googleWebClientId.isEmpty) {
      throw StateError(
        'Google OAuth is not configured. Start the app with '
        '--dart-define=GOOGLE_WEB_CLIENT_ID=your-client-id.',
      );
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw StateError('Google sign-in was cancelled.');
    }
    return _createSession(account);
  }

  Future<void> saveSession(AuthSession session) async {
    await _secureStorage.write(
      key: _storedSessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<AuthSession?> loadSavedSession() async {
    final storedSession = await _secureStorage.read(key: _storedSessionKey);
    if (storedSession == null) return null;

    try {
      return AuthSession.fromJson(
        Map<String, dynamic>.from(jsonDecode(storedSession) as Map),
      );
    } catch (_) {
      await clearSavedSession();
      return null;
    }
  }

  Future<void> clearSavedSession() async {
    await _secureStorage.delete(key: _storedSessionKey);
  }

  Future<AuthSession> _createSession(GoogleSignInAccount account) async {
    final idToken = (await account.authentication).idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google did not return an ID token.');
    }

    final response = await http.post(
      Uri.parse('$backendBaseUrl/api/auth/google'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    if (response.statusCode != 200) {
      throw StateError('Sign-in failed (${response.statusCode}).');
    }
    return AuthSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<Set<String>> fetchLikedReelIds(String accessToken) {
    return _fetchReelIds(accessToken, '/api/users/me/liked-reels');
  }

  Future<Set<String>> fetchSavedReelIds(String accessToken) {
    return _fetchReelIds(accessToken, '/api/users/me/saved-reels');
  }

  Future<Set<String>> _fetchReelIds(String accessToken, String path) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl$path'),
      headers: _authHeaders(accessToken),
    );
    if (response.statusCode != 200) {
      throw StateError(
        'Could not load reel preferences (${response.statusCode}).',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! List) {
      throw const FormatException(
        'The reel preferences response must be a list.',
      );
    }
    return body
        .whereType<Map>()
        .map((item) => item['id'])
        .whereType<num>()
        .map((id) => id.toInt().toString())
        .toSet();
  }

  Future<void> setReelLiked({
    required String accessToken,
    required String reelId,
    required bool liked,
  }) {
    return _setReelPreference(
      accessToken: accessToken,
      reelId: reelId,
      path: 'like',
      enabled: liked,
    );
  }

  Future<void> setReelSaved({
    required String accessToken,
    required String reelId,
    required bool saved,
  }) {
    return _setReelPreference(
      accessToken: accessToken,
      reelId: reelId,
      path: 'save',
      enabled: saved,
    );
  }

  Future<void> _setReelPreference({
    required String accessToken,
    required String reelId,
    required String path,
    required bool enabled,
  }) async {
    final uri = Uri.parse('$backendBaseUrl/api/reels/$reelId/$path');
    final response = enabled
        ? await http.post(uri, headers: _authHeaders(accessToken))
        : await http.delete(uri, headers: _authHeaders(accessToken));
    if (response.statusCode != 200) {
      throw StateError(
        'Could not update reel preference (${response.statusCode}).',
      );
    }
  }

  Map<String, String> _authHeaders(String accessToken) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Future<UserProfile> fetchProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/api/users/me/profile'),
      headers: _authHeaders(accessToken),
    );
    if (response.statusCode != 200) {
      throw StateError('Could not load profile (${response.statusCode}).');
    }
    final body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    return UserProfile.fromJson(
      Map<String, dynamic>.from(body['profile'] as Map),
    );
  }

  Future<UserProfile> updateProfile({
    required String accessToken,
    required UserProfile profile,
  }) async {
    final response = await http.put(
      Uri.parse('$backendBaseUrl/api/users/me/profile'),
      headers: {
        ..._authHeaders(accessToken),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profile.toJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Could not save profile (${response.statusCode}).');
    }
    final body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    return UserProfile.fromJson(
      Map<String, dynamic>.from(body['profile'] as Map),
    );
  }
}
