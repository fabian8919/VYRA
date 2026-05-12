import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vyra/core/constants/api_constants.dart';
import 'package:vyra/services/auth_service.dart';

class PostService {
  final _authService = AuthService();

  // ──────────────────────────────────────────
  // Headers comunes
  // ──────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await _authService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ──────────────────────────────────────────
  // Subir imágenes a Supabase Storage
  // ──────────────────────────────────────────

  /// Sube una lista de imágenes al bucket 'images' en la carpeta del usuario.
  /// Retorna la lista de URLs públicas.
  Future<List<String>> uploadImages(
    List<XFile> images, {
    List<Uint8List>? webBytes,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('No hay sesión activa');
    }

    final supabase = Supabase.instance.client;
    final uploadedUrls = <String>[];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final filePath = '${user.id}/$fileName';

      try {
        if (kIsWeb) {
          final bytes = webBytes != null && i < webBytes.length
              ? webBytes[i]
              : await image.readAsBytes();
          await supabase.storage.from('images').uploadBinary(
                filePath,
                bytes,
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
        } else {
          await supabase.storage.from('images').upload(
                filePath,
                File(image.path),
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
        }

        final url = supabase.storage.from('images').getPublicUrl(filePath);
        // URL limpia sin query params
        final cleanUrl = Uri.parse(url).replace(queryParameters: {}).toString();
        uploadedUrls.add(cleanUrl);
      } on StorageException catch (e) {
        debugPrint('[uploadImages] StorageException: ${e.message}');
        rethrow;
      } catch (e) {
        debugPrint('[uploadImages] Error: $e');
        rethrow;
      }
    }

    return uploadedUrls;
  }

  // ──────────────────────────────────────────
  // Obtener mis publicaciones
  // ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyPosts() async {
    final response = await http.get(
      Uri.parse(ApiConstants.myPosts),
      headers: await _headers(auth: true),
    ).timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Error al obtener publicaciones');
    }

    final data = body['data'] as List<dynamic>?;
    return data?.cast<Map<String, dynamic>>() ?? [];
  }

  // ──────────────────────────────────────────
  // Crear publicación
  // ──────────────────────────────────────────

  /// Crea un nuevo post con descripción e imágenes.
  Future<Map<String, dynamic>> createPost({
    required String description,
    required List<String> imageUrls,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.posts),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'descripcion': description,
        'imageUrls': imageUrls,
      }),
    ).timeout(const Duration(seconds: 30));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw Exception(body['error'] ?? 'Error al crear la publicación');
    }

    return body['data'] as Map<String, dynamic>;
  }
}
