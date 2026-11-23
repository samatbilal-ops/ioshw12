import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
// NOTE: "sole_app" must match the `name:` in your pubspec.yaml
import 'package:sole_app/explorer/services/product_api.dart';

ProductApi _api(
  Future<http.Response> Function(http.Request) handler, {
  Duration timeout = const Duration(seconds: 1),
}) =>
    ProductApi(client: MockClient(handler), timeout: timeout);

void main() {
  test('200 OK -> list of products', () async {
    final api = _api((_) async => http.Response(
          '[{"id":1,"title":"A","price":5,"rating":{"rate":4,"count":2}},'
          '{"id":2,"title":"B","price":6.5}]',
          200,
        ));
    final list = await api.fetchProducts();
    expect(list.length, 2);
    expect(list.first.price, 5.0);
  });

  test('404 -> ApiException with statusCode 404', () async {
    final api = _api((_) async => http.Response('', 404));
    await expectLater(
      api.fetchProducts(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 404)),
    );
  });

  test('500 -> server error message', () async {
    final api = _api((_) async => http.Response('', 500));
    await expectLater(
      api.fetchProducts(),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'code', 500)
          .having((e) => e.message, 'message', contains('Server'))),
    );
  });

  test('no internet (ClientException) -> offline error', () async {
    final api = _api((_) async => throw http.ClientException('no network'));
    await expectLater(
      api.fetchProducts(),
      throwsA(isA<ApiException>().having((e) => e.isOffline, 'offline', true)),
    );
  });

  test('timeout -> offline error', () async {
    final api = _api(
      (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return http.Response('[]', 200);
      },
      timeout: const Duration(milliseconds: 50),
    );
    await expectLater(
      api.fetchProducts(),
      throwsA(isA<ApiException>().having((e) => e.isOffline, 'offline', true)),
    );
  });

  test('broken JSON -> ApiException (no crash)', () async {
    final api = _api((_) async => http.Response('not json', 200));
    await expectLater(api.fetchProducts(), throwsA(isA<ApiException>()));
  });

  test('JSON object instead of list -> ApiException', () async {
    final api = _api((_) async => http.Response('{"a":1}', 200));
    await expectLater(api.fetchProducts(), throwsA(isA<ApiException>()));
  });
}
