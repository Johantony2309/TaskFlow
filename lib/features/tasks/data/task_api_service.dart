import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/task.dart';

class TaskApiService {
  static const int userId = 1;

  TaskApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://jsonplaceholder.typicode.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  final Dio _dio;

  Future<List<Task>> getTasks() async {
    final response = await _dio.get<List<dynamic>>(
      '/todos',
      queryParameters: {'userId': userId},
    );

    debugPrint('GET /todos?userId=$userId → HTTP ${response.statusCode}');
    final rows = response.data;
    if (rows == null) {
      throw const FormatException('La respuesta no contiene una lista.');
    }

    return rows.map((row) {
      final json = Map<String, dynamic>.from(row as Map);
      return Task.fromJson(json);
    }).toList();
  }

  Future<Task> createTask(Task task) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/todos',
      data: task.toJson(),
    );
    debugPrint('POST /todos → HTTP ${response.statusCode}');
    final json = response.data;
    if (json == null) {
      throw const FormatException('La respuesta no contiene un objeto.');
    }
    return Task.fromJson(json);
  }

  Future<Task> updateTask(Task task) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/todos/${task.id}',
      data: task.toJson(),
    );
    debugPrint('PATCH /todos/${task.id} → HTTP ${response.statusCode}');
    final json = response.data;
    if (json == null) {
      throw const FormatException('La respuesta no contiene un objeto.');
    }
    return Task.fromJson(json);
  }

  Future<void> deleteTask(int id) async {
    final response = await _dio.delete('/todos/$id');
    debugPrint('DELETE /todos/$id → HTTP ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}
