import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// One error type for the whole UI: a human message + optional HTTP code.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// true -> network problem (offline / timeout), false -> server/data problem
  final bool isOffline;

  const ApiException(this.message, {this.statusCode, this.isOffline = false});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ProductApi {
  static final Uri endpoint = Uri.parse('https://fakestoreapi.com/products');

  final http.Client _client;
  final Duration timeout;

  /// [client] and [timeout] are injectable so the class can be unit-tested.
  ProductApi({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(endpoint).timeout(timeout);

      if (response.statusCode == 200) {
        return _parse(response.body);
      } else if (response.statusCode == 404) {
        throw const ApiException(
          'Products were not found (404).',
          statusCode: 404,
        );
      } else if (response.statusCode >= 500) {
        throw ApiException(
          'Server error (${response.statusCode}). Please try again later.',
          statusCode: response.statusCode,
        );
      } else {
        throw ApiException(
          'Unexpected response (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'The request timed out after 10 seconds.',
        isOffline: true,
      );
    } on http.ClientException {
      // thrown for "no internet", DNS failure, blocked request, ...
      throw const ApiException(
        'No internet connection. Check your network and try again.',
        isOffline: true,
      );
    } on FormatException {
      throw const ApiException('The server sent data in an unexpected format.');
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.');
    }
  }

  List<Product> _parse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON list');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }
}
