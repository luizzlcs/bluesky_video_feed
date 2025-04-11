import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/session_model.dart';

class BlueskyDatasource {
  SessionModel? _session;

  // Autenticação na API do Bluesky
  Future<SessionModel> createSession({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      _session = SessionModel.fromJson(jsonDecode(response.body));
      return _session!;
    } else {
      throw Exception('Falha na autenticação: ${response.statusCode} - ${response.body}');
    }
  }

  // Busca a timeline do usuário
  Future<List<Map<String, dynamic>>> getTimeline({int limit = 50}) async {
    if (_session == null) {
      throw Exception('Não autenticado. Chame createSession() primeiro.');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.timelineEndpoint}?limit=$limit'),
      headers: {
        'Authorization': 'Bearer ${_session!.accessJwt}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['feed'] ?? []);
    } else {
      throw Exception('Falha ao carregar timeline: ${response.statusCode} - ${response.body}');
    }
  }
}