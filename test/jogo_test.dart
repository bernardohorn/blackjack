// Testa o fluxo inteiro com um servidor previsível e persistência em memória.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:clube_21/jogo.dart';
import 'package:clube_21/regras.dart';

import 'apoio.dart';

void main() {
  test(
    'falha ao salvar após a compra mantém a proteção na próxima abertura',
    () async {
      final memoria = MemoriaTeste();
      final servidor = ServidorTeste(['9S', 'KS', '7H', '7D', 'AS']);
      final jogo = servidor.jogo(memoria);
      await jogo.novoJogo();
      servidor.antesDaCompra = () async {
        memoria.falhar = true;
      };
      await jogo.pedirCarta();
      expect(jogo.mesa, isNull);
      expect(jogo.falhaLocal, isTrue);
      expect(jogo.erro, contains('salvar'));
      expect(jsonDecode(memoria.conteudo!)['pendente'], isTrue);
      final reaberto = Jogo(servidor.api, memoria);
      await reaberto.carregar();
      expect(reaberto.mesa, isNull);
      expect(reaberto.aviso, contains('interrompida'));
    },
  );
  test('falta de cartas no meio da rodada não mistura baralhos', () async {
    final servidor = ServidorTeste(['9S', 'KS', '7H', '7D']);
    final jogo = servidor.jogo();
    await jogo.novoJogo();
    jogo.mesa!.restantes = 0;
    await jogo.pedirCarta();
    expect(jogo.mesa, isNull);
    expect(jogo.erro, isNotNull);
    expect(servidor.chamadas.length, 2);
  });
  test('erro ao salvar preferências restaura os valores anteriores', () async {
    final memoria = MemoriaTeste()..falhar = true;
    final jogo = ServidorTeste([]).jogo(memoria);
    await jogo.configurar(Preferencias(baralhos: 1, escuro: false));
    expect(jogo.preferencias.baralhos, 6);
    expect(jogo.preferencias.escuro, isTrue);
    expect(jogo.aviso, isNotNull);
  });
  test('criação sequencial, distribuição alternada, pedir e parar', () async {
    final servidor = ServidorTeste(['9H', 'KS', '7C', '7D', 'AS']);
    final jogo = servidor.jogo();
    await jogo.novoJogo();
    expect(
      servidor.chamadas[0].toString(),
      'https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=6',
    );
    expect(
      servidor.chamadas[1].toString(),
      'https://deckofcardsapi.com/api/deck/mesa1/draw/?count=4',
    );
    expect(jogo.mesa!.jogador.map((carta) => carta.codigo), ['9H', '7C']);
    expect(jogo.mesa!.banca.map((carta) => carta.codigo), ['KS', '7D']);
    expect(jogo.mesa!.restantes, 308);
    await jogo.pedirCarta();
    expect(
      servidor.chamadas.last.toString(),
      'https://deckofcardsapi.com/api/deck/mesa1/draw/?count=1',
    );
    expect(pontuar(jogo.mesa!.jogador).pontos, 17);
    await jogo.parar();
    expect(servidor.chamadas.length, 3); // Revelar e parar em 17 não compra.
    expect(resultado(jogo.mesa!.jogador, jogo.mesa!.banca).titulo, 'Empate');
  });
  test('naturais terminam antes do turno do jogador', () async {
    for (final cartas in [
      ['AS', 'KS', 'KH', '7D'],
      ['KS', 'AS', 'QH', 'KD'],
      ['AS', 'AH', 'KS', 'KH'],
    ]) {
      final servidor = ServidorTeste(cartas);
      final jogo = servidor.jogo();
      await jogo.novoJogo();
      expect(jogo.mesa!.fase, Fase.concluida);
      await jogo.pedirCarta();
      expect(servidor.chamadas.length, 2);
    }
  });
  test(
    'estouro não compra para a banca; 21 passa o turno automaticamente',
    () async {
      final estouro = ServidorTeste(['KS', '2S', 'QH', '3S', '2D']).jogo();
      await estouro.novoJogo();
      await estouro.pedirCarta();
      expect(estouro.mesa!.fase, Fase.concluida);
      expect(estouro.mesa!.banca.length, 2);
      final vinteUm = ServidorTeste(['9S', 'KS', '7H', '7D', '5S']).jogo();
      await vinteUm.novoJogo();
      await vinteUm.pedirCarta();
      expect(vinteUm.mesa!.fase, Fase.concluida);
      expect(
        resultado(vinteUm.mesa!.jogador, vinteUm.mesa!.banca).titulo,
        'Você venceu',
      );
    },
  );
  test('banca compra uma a uma e respeita a regra congelada da mesa', () async {
    final servidor = ServidorTeste(['KS', 'AS', 'QH', '6H', '2D']);
    final jogo = servidor.jogo();
    jogo.preferencias.paraNo17Suave = false;
    await jogo.novoJogo();
    await jogo.configurar(Preferencias(paraNo17Suave: true, baralhos: 1));
    expect(jogo.mesa!.baralhos, 6);
    await jogo.parar();
    expect(jogo.mesa!.banca.length, 3);
    expect(jogo.mesa!.restantes, 307);
  });
  test('nova rodada reutiliza a mesa e renova em 25 por cento', () async {
    final servidor = ServidorTeste([
      'AS',
      'KS',
      'KH',
      '7D',
      'AS',
      'KS',
      'KH',
      '7D',
      '9S',
      'KS',
      '7H',
      '7D',
    ]);
    final jogo = servidor.jogo();
    await jogo.novoJogo();
    await jogo.novaRodada();
    expect(servidor.criacoes, 1);
    expect(jogo.mesa!.rodada, 2);
    jogo.mesa!.restantes = 78;
    await jogo.configurar(Preferencias(baralhos: 1));
    await jogo.novaRodada();
    expect(servidor.criacoes, 2);
    expect(jogo.mesa!.baralhos, 1);
    expect(jogo.mesa!.restantes, 48);
  });
  test('toques duplicados não fazem compras duplicadas', () async {
    final servidor = ServidorTeste(['9S', 'KS', '7H', '7D', 'AS']);
    final jogo = servidor.jogo();
    await jogo.novoJogo();
    final liberar = Completer<void>();
    servidor.antesDaCompra = () => liberar.future;
    final primeira = jogo.pedirCarta();
    await jogo.pedirCarta();
    await jogo.parar();
    liberar.complete();
    await primeira;
    expect(servidor.chamadas.length, 3);
    expect(jogo.mesa!.jogador.length, 3);
  });
  test('falha de compra invalida sessão e exige novo baralho', () async {
    final memoria = MemoriaTeste();
    final servidor = ServidorTeste([
      '9S',
      'KS',
      '7H',
      '7D',
      '9S',
      'KS',
      '7H',
      '7D',
    ]);
    final jogo = servidor.jogo(memoria);
    await jogo.novoJogo();
    servidor.falharCompra = true;
    await jogo.pedirCarta();
    expect(jogo.compraIncerta, isTrue);
    expect(jogo.mesa, isNull);
    expect(jsonDecode(memoria.conteudo!)['mesa'], isNull);
    await jogo.pedirCarta();
    expect(servidor.chamadas.length, 3);
    servidor.falharCompra = false;
    await jogo.novoJogo();
    expect(jogo.mesa!.identificador, 'mesa2');
  });
  test('falha na criação permite nova tentativa sem repetir compra', () async {
    final servidor = ServidorTeste(['9S', 'KS', '7H', '7D'])
      ..falharCriacao = true;
    final jogo = servidor.jogo();
    await jogo.novoJogo();
    expect(jogo.compraIncerta, isFalse);
    expect(jogo.mesa, isNull);
    expect(servidor.chamadas.length, 1);
    servidor.falharCriacao = false;
    await jogo.novoJogo();
    expect(jogo.mesa, isNotNull);
  });
  test('reabrir recupera mãos e preferências sem nenhuma chamada', () async {
    final memoria = MemoriaTeste();
    final servidor = ServidorTeste(['9S', 'KS', '7H', '7D']);
    final jogo = servidor.jogo(memoria);
    await jogo.novoJogo();
    await jogo.configurar(Preferencias(escuro: false, som: false));
    final reaberto = Jogo(servidor.api, memoria);
    await reaberto.carregar();
    expect(reaberto.mesa!.salvar(), jogo.mesa!.salvar());
    expect(reaberto.preferencias.escuro, isFalse);
    expect(servidor.chamadas.length, 2);
  });
  test('fechar durante compra nunca restaura uma mão desatualizada', () async {
    final memoria = MemoriaTeste();
    final servidor = ServidorTeste(['9S', 'KS', '7H', '7D', 'AS']);
    final jogo = servidor.jogo(memoria);
    await jogo.novoJogo();
    final liberar = Completer<void>();
    final enviada = Completer<void>();
    servidor.antesDaCompra = () {
      enviada.complete();
      return liberar.future;
    };
    final compra = jogo.pedirCarta();
    await enviada.future;
    final reaberto = Jogo(servidor.api, memoria);
    await reaberto.carregar();
    expect(reaberto.mesa, isNull);
    expect(reaberto.aviso, contains('interrompida'));
    liberar.complete();
    await compra;
  });
  test('erro de armazenamento antes da compra não envia requisição', () async {
    final memoria = MemoriaTeste();
    final servidor = ServidorTeste(['9S', 'KS', '7H', '7D']);
    final jogo = servidor.jogo(memoria);
    await jogo.novoJogo();
    memoria.falhar = true;
    await jogo.pedirCarta();
    expect(servidor.chamadas.length, 2);
    expect(jogo.mesa, isNotNull);
    expect(jogo.erro, contains('salvar'));
  });
  test(
    'sessão expirada, incompleta ou corrompida não quebra a abertura',
    () async {
      final memoria = MemoriaTeste();
      final servidor = ServidorTeste(['9S', 'KS', '7H', '7D']);
      final jogo = servidor.jogo(memoria);
      await jogo.novoJogo();
      final dados = jsonDecode(memoria.conteudo!);
      dados['mesa']['ultimaJogada'] = DateTime.now()
          .subtract(const Duration(days: 15))
          .toIso8601String();
      memoria.conteudo = jsonEncode(dados);
      await jogo.carregar();
      expect(jogo.mesa, isNull);
      expect(jogo.aviso, contains('expirou'));
      memoria.conteudo = '{inválido';
      await jogo.carregar();
      expect(jogo.mesa, isNull);
      expect(jogo.iniciando, isFalse);
    },
  );
}
