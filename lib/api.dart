// Somente este arquivo conhece os endereços e os nomes de campos da API.
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'regras.dart';

class ApiBaralho {
  ApiBaralho(this.cliente, {this.limite = const Duration(seconds: 10)});
  final http.Client cliente;
  final Duration limite;

  /// Uma única tentativa: repetir uma compra pode consumir cartas extras.
  Future<Map<String, dynamic>> _consultar(
    String caminho,
    Map<String, String> parametros,
  ) async {
    final resposta = await cliente
        .get(Uri.https('deckofcardsapi.com', '/api/deck/$caminho/', parametros))
        .timeout(limite);
    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw const FormatException(
        'O serviço de cartas não respondeu corretamente.',
      );
    }
    final dados = jsonDecode(resposta.body);
    if (dados is! Map<String, dynamic> ||
        dados['success'] != true ||
        dados['deck_id'] is! String ||
        (dados['deck_id'] as String).isEmpty) {
      throw const FormatException('Resposta inválida do serviço de cartas.');
    }
    return dados;
  }

  // Aceita a contagem como número ou texto, mas nunca inventa um valor ausente.
  int _restantes(Map<String, dynamic> dados) {
    final recebido = dados['remaining'];
    final valor =
        recebido is num &&
            recebido.isFinite &&
            recebido == recebido.roundToDouble()
        ? recebido.toInt()
        : int.tryParse('$recebido');
    if (valor == null || valor < 0) {
      throw const FormatException('Contagem inválida.');
    }
    return valor;
  }

  Future<Mesa> criar(Preferencias preferencias) async {
    final dados = await _consultar('new/shuffle', {
      'deck_count': '${preferencias.baralhos}',
    });
    final restantes = _restantes(dados);
    if (dados['shuffled'] != true || restantes != preferencias.baralhos * 52) {
      throw const FormatException('Baralho incompleto.');
    }
    return Mesa(
      identificador: dados['deck_id'],
      restantes: restantes,
      baralhos: preferencias.baralhos,
      paraNo17Suave: preferencias.paraNo17Suave,
    );
  }

  /// Confere toda a resposta antes de permitir qualquer alteração na mão.
  Future<({List<Carta> cartas, int restantes})> comprar(
    Mesa mesa,
    int quantidade,
  ) async {
    if (mesa.restantes < quantidade) {
      throw const FormatException('Faltam cartas nesta mesa.');
    }
    final dados = await _consultar('${mesa.identificador}/draw', {
      'count': '$quantidade',
    });
    final lista = dados['cards'];
    final restantes = _restantes(dados);
    if (dados['deck_id'] != mesa.identificador ||
        lista is! List ||
        lista.length != quantidade ||
        restantes != mesa.restantes - quantidade) {
      throw const FormatException('A compra não pôde ser confirmada.');
    }
    final cartas = lista.map((item) {
      final carta = Carta.ler({
        'codigo': item['code'],
        'imagem': item['images']?['png'] ?? item['image'] ?? '',
      });
      final valor =
          const {
            'A': 'ACE',
            'J': 'JACK',
            'Q': 'QUEEN',
            'K': 'KING',
          }[carta.valor] ??
          carta.valor;
      final naipe = const {
        'S': 'SPADES',
        'H': 'HEARTS',
        'D': 'DIAMONDS',
        'C': 'CLUBS',
      }[carta.codigo[1]];
      if (item['value'] != valor || item['suit'] != naipe) {
        throw const FormatException('Carta inconsistente.');
      }
      return carta;
    }).toList();
    return (cartas: cartas, restantes: restantes);
  }
}
