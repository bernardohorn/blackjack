// Baralho e armazenamento previsíveis para testar sem internet nem dispositivo.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:clube_21/api.dart';
import 'package:clube_21/jogo.dart';
import 'package:clube_21/regras.dart';

class MemoriaTeste implements Armazenamento {
  String? conteudo;
  bool falhar = false;
  @override
  Future<String?> ler() async => conteudo;
  @override
  Future<void> salvar(String valor) async {
    if (falhar) throw Exception('Sem espaço.');
    conteudo = valor;
  }
}

Map<String, dynamic> cartaApi(String codigo) {
  final carta = Carta(codigo);
  return {
    'code': codigo,
    'image': '',
    'value':
        const {
          'A': 'ACE',
          'K': 'KING',
          'Q': 'QUEEN',
          'J': 'JACK',
        }[carta.valor] ??
        carta.valor,
    'suit': const {
      'S': 'SPADES',
      'H': 'HEARTS',
      'D': 'DIAMONDS',
      'C': 'CLUBS',
    }[codigo[1]],
  };
}

class ServidorTeste {
  ServidorTeste(this.cartas);
  final List<String> cartas;
  final List<Uri> chamadas = [];
  int restantes = 312, criacoes = 0;
  bool falharCompra = false, falharCriacao = false;
  Future<void> Function()? antesDaCompra;

  late final api = ApiBaralho(
    MockClient((requisicao) async {
      chamadas.add(requisicao.url);
      if (requisicao.url.path.contains('new/shuffle')) {
        if (falharCriacao) throw Exception('Sem rede.');
        criacoes++;
        restantes =
            int.parse(requisicao.url.queryParameters['deck_count']!) * 52;
        return http.Response(
          jsonEncode({
            'success': true,
            'deck_id': 'mesa$criacoes',
            'remaining': restantes,
            'shuffled': true,
          }),
          200,
        );
      }
      await antesDaCompra?.call();
      if (falharCompra) throw Exception('Conexão interrompida.');
      final quantidade = int.parse(requisicao.url.queryParameters['count']!);
      final compradas = cartas.take(quantidade).map(cartaApi).toList();
      cartas.removeRange(0, quantidade);
      restantes -= quantidade;
      return http.Response(
        jsonEncode({
          'success': true,
          'deck_id': 'mesa$criacoes',
          'remaining': restantes,
          'cards': compradas,
        }),
        200,
      );
    }),
  );

  Jogo jogo([MemoriaTeste? memoria]) =>
      Jogo(api, memoria ?? MemoriaTeste(), pausaVisual: Duration.zero);
}
