// Valida o contrato remoto e prova que timeout nunca repete a compra.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:clube_21/api.dart';
import 'package:clube_21/regras.dart';

import 'apoio.dart';

void main() {
  Mesa mesa() => Mesa(
    identificador: 'mesa1',
    restantes: 52,
    baralhos: 1,
    paraNo17Suave: true,
  );
  for (final contagem in ['51', 51, 51.0]) {
    test(
      'aceita remaining $contagem (${contagem.runtimeType}) e carta sem images',
      () async {
        final api = ApiBaralho(
          MockClient(
            (_) async => http.Response(
              jsonEncode({
                'success': true,
                'deck_id': 'mesa1',
                'remaining': contagem,
                'cards': [cartaApi('AS')],
              }),
              200,
            ),
          ),
        );
        final compra = await api.comprar(mesa(), 1);
        expect(compra.restantes, 51);
        expect(compra.cartas.single.codigo, 'AS');
      },
    );
  }
  test('recusa HTTP ruim, JSON inválido e resposta sem success', () async {
    for (final resposta in [
      http.Response('{}', 503),
      http.Response('não é JSON', 200),
      http.Response('{"deck_id":"a","remaining":52}', 200),
    ]) {
      final api = ApiBaralho(MockClient((_) async => resposta));
      await expectLater(
        api.criar(Preferencias(baralhos: 1)),
        throwsFormatException,
      );
    }
  });
  test(
    'rejeita compra parcial, outro ID, contagem ou carta inconsistente',
    () async {
      final base = {
        'success': true,
        'deck_id': 'mesa1',
        'remaining': 51,
        'cards': [cartaApi('AS')],
      };
      for (final alteracao in [
        {'cards': []},
        {'deck_id': 'outra'},
        {'remaining': 50},
        {'remaining': -1},
        {'remaining': 51.5},
        {
          'cards': [
            {...cartaApi('AS'), 'value': 'KING'},
          ],
        },
      ]) {
        final api = ApiBaralho(
          MockClient(
            (_) async =>
                http.Response(jsonEncode({...base, ...alteracao}), 200),
          ),
        );
        await expectLater(api.comprar(mesa(), 1), throwsFormatException);
      }
    },
  );
  test('timeout faz exatamente uma chamada', () async {
    var chamadas = 0;
    final resposta = Completer<http.Response>();
    final api = ApiBaralho(
      MockClient((_) {
        chamadas++;
        return resposta.future;
      }),
      limite: const Duration(milliseconds: 5),
    );
    await expectLater(api.comprar(mesa(), 1), throwsA(isA<TimeoutException>()));
    expect(chamadas, 1);
    resposta.complete(http.Response('{}', 200));
  });
}
