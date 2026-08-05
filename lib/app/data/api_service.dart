import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ApiService {
  static const String baseUrl = 'https://siawi.smkwisataindonesia.sch.id/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // In-memory cache and pending request maps for GET requests
  static final Map<String, Future<dynamic>> _pendingRequests = {};
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheDuration = Duration(seconds: 5);

  static final Map<String, Future<String>> _pendingRawRequests = {};
  static final Map<String, _RawCacheEntry> _rawCache = {};

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

  // GET request wrapper with caching and request coalescing
  static Future<dynamic> get(String endpoint, {bool forceRefresh = false}) async {
    final now = DateTime.now();

    // 1. Check Cache
    if (!forceRefresh && _cache.containsKey(endpoint)) {
      final entry = _cache[endpoint]!;
      if (now.difference(entry.timestamp) < _cacheDuration) {
        debugPrint('ApiService: Cache hit for GET $endpoint');
        return entry.data;
      } else {
        _cache.remove(endpoint);
      }
    }

    // 2. Check Coalescing (pending request)
    if (_pendingRequests.containsKey(endpoint)) {
      debugPrint('ApiService: Coalescing concurrent GET request for $endpoint');
      return _pendingRequests[endpoint];
    }

    // 3. Make HTTP request
    final Future<dynamic> requestFuture = () async {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl$endpoint'))
            .timeout(timeoutDuration);
        final processed = _processResponse(response);
        
        // Cache successful response
        _cache[endpoint] = _CacheEntry(processed, DateTime.now());
        return processed;
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
      } finally {
        _pendingRequests.remove(endpoint);
      }
    }();

    _pendingRequests[endpoint] = requestFuture;
    return requestFuture;
  }

  // GET raw request wrapper with caching and request coalescing
  static Future<String> getRaw(String endpoint, {bool forceRefresh = false}) async {
    final now = DateTime.now();

    // 1. Check Cache
    if (!forceRefresh && _rawCache.containsKey(endpoint)) {
      final entry = _rawCache[endpoint]!;
      if (now.difference(entry.timestamp) < _cacheDuration) {
        debugPrint('ApiService: Cache hit for GET RAW $endpoint');
        return entry.data;
      } else {
        _rawCache.remove(endpoint);
      }
    }

    // 2. Check Coalescing (pending request)
    if (_pendingRawRequests.containsKey(endpoint)) {
      debugPrint('ApiService: Coalescing concurrent GET RAW request for $endpoint');
      return _pendingRawRequests[endpoint];
    }

    // 3. Make HTTP request
    final Future<String> requestFuture = () async {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl$endpoint'))
            .timeout(timeoutDuration);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final body = response.body;
          _rawCache[endpoint] = _RawCacheEntry(body, DateTime.now());
          return body;
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
      } finally {
        _pendingRawRequests.remove(endpoint);
      }
    }();

    _pendingRawRequests[endpoint] = requestFuture;
    return requestFuture;
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

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  _CacheEntry(this.data, this.timestamp);
}

class _RawCacheEntry {
  final String data;
  final DateTime timestamp;
  _RawCacheEntry(this.data, this.timestamp);
}
