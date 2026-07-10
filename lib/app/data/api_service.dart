import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ApiService {
  static const String baseUrl = 'https://siawi.smkwisataindonesia.sch.id/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Helper to handle response status and potential non-JSON formats
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw const FormatException('Format respons dari server tidak valid (bukan JSON).');
      }
    } else {
      print('API Failure on: ${response.request?.url} with status code ${response.statusCode}');
      print('API Response Body: ${response.body}');
      // Try to parse error message from JSON, default to status code info
      String errorMsg = 'Error ${response.statusCode}';
      try {
        final data = json.decode(response.body);
        errorMsg = data['message'] ?? errorMsg;
      } catch (_) {
        // If not JSON (e.g. HTML 500 error page), use default message
        errorMsg = 'Terjadi kesalahan pada server (Error ${response.statusCode})';
      }
      throw HttpException(errorMsg);
    }
  }

  // GET request wrapper
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      _showToast('Koneksi internet bermasalah. Periksa koneksi Anda.');
      throw const SocketException('Koneksi internet terputus.');
    } on TimeoutException {
      _showToast('Koneksi ke server habis (Timeout). Coba lagi nanti.');
      throw TimeoutException('Request timeout.');
    } on HttpException catch (e) {
      _showToast(e.message);
      rethrow;
    } catch (e) {
      _showToast('Terjadi kesalahan: ${e.toString()}');
      rethrow;
    }
  }

  // GET raw request wrapper (returns String body instead of decoded JSON)
  static Future<String> getRaw(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(timeoutDuration);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        print('API Failure on: ${response.request?.url} with status code ${response.statusCode}');
        throw HttpException('Error ${response.statusCode}');
      }
    } on SocketException {
      _showToast('Koneksi internet bermasalah. Periksa koneksi Anda.');
      throw const SocketException('Koneksi internet terputus.');
    } on TimeoutException {
      _showToast('Koneksi ke server habis (Timeout). Coba lagi nanti.');
      throw TimeoutException('Request timeout.');
    } on HttpException catch (e) {
      _showToast(e.message);
      rethrow;
    } catch (e) {
      _showToast('Terjadi kesalahan: ${e.toString()}');
      rethrow;
    }
  }

  // POST request wrapper
  static Future<dynamic> post(String endpoint, Map<String, String> body) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl$endpoint'), body: body)
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      _showToast('Koneksi internet bermasalah. Periksa koneksi Anda.');
      throw const SocketException('Koneksi internet terputus.');
    } on TimeoutException {
      _showToast('Koneksi ke server habis (Timeout). Coba lagi nanti.');
      throw TimeoutException('Request timeout.');
    } on HttpException catch (e) {
      _showToast(e.message);
      rethrow;
    } catch (e) {
      _showToast('Terjadi kesalahan: ${e.toString()}');
      rethrow;
    }
  }

  static void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
