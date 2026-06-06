import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class ApiService {
  // URL base de JSONPlaceholder (Fake REST API de pruebas)
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// GET /posts/{id} — Consulta un post por ID
  static Future<Post> getPost(int id) async {
    final url = Uri.parse('$_baseUrl/posts/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodifica el JSON y crea el objeto Post
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Post.fromJson(json);
    } else {
      throw Exception('Error al obtener post: ${response.statusCode}');
    }
  }

  /// PUT /posts/{id} — Actualiza un post con título y cuerpo nuevos
  static Future<bool> updatePost(Post post) async {
    final url = Uri.parse('$_baseUrl/posts/${post.id}');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(post.toJson()),
    );

    // JSONPlaceholder retorna 200 OK si la operación fue exitosa
    return response.statusCode == 200;
  }
}