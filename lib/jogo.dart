// Coordena as regras, a internet e o salvamento; as telas apenas pedem ações.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'regras.dart';

/// Esta pequena interface permite testar o salvamento sem usar o dispositivo.
abstract class Armazenamento {
  Future<String?> ler();
  Future<void> salvar(String conteudo);
}

/// Guarda preferências e partida juntas em uma única entrada do dispositivo.
class MemoriaLocal implements Armazenamento {
  final _preferencias = SharedPreferencesAsync();
  @override
  Future<String?> ler() => _preferencias.getString('clube21');
  @override
  Future<void> salvar(String conteudo) =>
      _preferencias.setString('clube21', conteudo);
}

class Jogo extends ChangeNotifier {
  Jogo(
    this.api,
    this.armazenamento, {
    this.pausaVisual = const Duration(milliseconds: 650),
  });
  // A pausa torna visíveis a abertura e a vez da banca. Testes podem usar zero.
  final Duration pausaVisual;
  final ApiBaralho api;
  final Armazenamento armazenamento;
  Preferencias preferencias = Preferencias();
  Mesa? mesa;
  bool ocupado = false, iniciando = true, compraIncerta = false;
  bool renovando = false, falhaLocal = false;
  String corte = '';
  String? erro, aviso;
  String andamento = 'Preparando sua mesa…';

  /// Uma marca pendente impede retomar mãos antigas após fechar durante uma compra.
  Future<void> _salvar({bool pendente = false}) => armazenamento.salvar(
    jsonEncode({
      'versao': 1,
      'preferencias': preferencias.salvar(),
      'mesa': mesa?.salvar(),
      'pendente': pendente,
    }),
  );

  // Recupera o arquivo salvo; dados incompletos não impedem abrir o aplicativo.
  Future<void> carregar() async {
    final abertura = Future<void>.delayed(pausaVisual);
    mesa = null;
    aviso = null;
    try {
      final texto = await armazenamento.ler();
      if (texto != null) {
        final dados = jsonDecode(texto) as Map<String, dynamic>;
        if (dados['versao'] != 1) throw const FormatException();
        preferencias = Preferencias.ler(dados['preferencias']);
        if (dados['pendente'] == true) {
          aviso = 'A última operação foi interrompida. Inicie uma nova mesa.';
        } else if (dados['mesa'] != null) {
          mesa = Mesa.ler(dados['mesa']);
          if (DateTime.now().difference(mesa!.ultimaJogada).inDays >= 14) {
            mesa = null;
            aviso = 'A mesa salva expirou. Comece um novo jogo.';
          }
        }
      }
    } catch (_) {
      mesa = null;
      aviso = 'Não foi possível recuperar a partida salva.';
    }
    await abertura;
    iniciando = false;
    notifyListeners();
  }

  /// Salva antes de enviar e após concluir. Falhas bloqueiam a mesa por segurança.
  Future<void> _executar(Future<void> Function() acao) async {
    if (ocupado) return;
    ocupado = true;
    erro = null;
    compraIncerta = false;
    falhaLocal = false;
    notifyListeners();
    var iniciou = false;
    var salvando = true;
    try {
      await _salvar(pendente: true);
      iniciou = true;
      salvando = false;
      await acao();
      salvando = true;
      await _salvar();
    } catch (_) {
      falhaLocal = salvando;
      if (!iniciou) {
        erro = 'Não foi possível salvar no dispositivo. Libere espaço e tente novamente.';
      } else {
        mesa = null;
        erro = salvando
            ? 'Não foi possível salvar a última jogada. A mesa foi encerrada para não recuperar cartas desatualizadas.'
            : compraIncerta
            ? 'Não sabemos se a última compra foi concluída. Reinicie a mesa com um novo baralho.'
            : 'Confira sua conexão e tente novamente. Não foi possível preparar a mesa.';
        try {
          await _salvar();
        } catch (_) {
          /* A marca pendente já protege a próxima abertura. */
        }
      }
    } finally {
      ocupado = false;
      renovando = false;
      notifyListeners();
    }
  }

  // Cria um baralho novo e só depois compra as quatro cartas iniciais.
  Future<void> novoJogo() => _executar(() async {
    aviso = null;
    renovando = false;
    andamento = 'Embaralhando a sorte…';
    mesa = null;
    notifyListeners();
    mesa = await api.criar(preferencias);
    await _distribuir();
  });

  // Continua no baralho atual, exceto quando o corte de renovação foi atingido.
  Future<void> novaRodada() async {
    if (mesa?.fase != Fase.concluida || ocupado) return;
    await _executar(() async {
      if (mesa!.renovar) {
        renovando = true;
        corte = '${mesa!.restantes} / ${mesa!.baralhos * 52} cartas';
        andamento = 'Renovando a mesa…';
        mesa = null;
        notifyListeners();
        mesa = await api.criar(preferencias);
      }
      await _distribuir();
    });
  }

  // A compra inicial alterna jogador, banca, jogador, banca.
  Future<void> _distribuir() async {
    mesa!.jogador = [];
    mesa!.banca = [];
    andamento = 'Distribuindo cartas…';
    notifyListeners();
    final cartas = await _comprar(4);
    mesa!.jogador = [cartas[0], cartas[2]];
    mesa!.banca = [cartas[1], cartas[3]];
    mesa!.rodada++;
    mesa!.fase = natural(mesa!.jogador) || natural(mesa!.banca)
        ? Fase.concluida
        : Fase.jogador;
  }

  // A incerteza começa antes do envio e só deixa de importar após salvar a operação.
  Future<List<Carta>> _comprar(int quantidade) async {
    compraIncerta = true;
    final compra = await api.comprar(mesa!, quantidade);
    mesa!.restantes = compra.restantes;
    mesa!.ultimaJogada = DateTime.now();
    return compra.cartas;
  }

  // Recebe uma carta; 21 passa a vez e estouro encerra imediatamente.
  Future<void> pedirCarta() async {
    if (mesa?.fase != Fase.jogador || ocupado || erro != null) return;
    await _executar(() async {
      mesa!.jogador.addAll(await _comprar(1));
      final pontos = pontuar(mesa!.jogador).pontos;
      if (pontos > 21) mesa!.fase = Fase.concluida;
      if (pontos == 21) await _jogarBanca();
    });
  }

  // Entrega o turno para a banca sem alterar a mão do jogador.
  Future<void> parar() async {
    if (mesa?.fase != Fase.jogador || ocupado || erro != null) return;
    await _executar(_jogarBanca);
  }

  /// Revelar a carta não consulta a API. A banca compra apenas se a regra exigir.
  Future<void> _jogarBanca() async {
    mesa!.fase = Fase.banca;
    notifyListeners();
    await Future<void>.delayed(pausaVisual);
    while (bancaCompra(mesa!.banca, mesa!.paraNo17Suave)) {
      mesa!.banca.addAll(await _comprar(1));
      notifyListeners();
      await Future<void>.delayed(pausaVisual);
    }
    mesa!.fase = Fase.concluida;
  }

  // Aplica preferências e desfaz a alteração se não for possível salvá-la.
  Future<void> configurar(Preferencias novas) async {
    if (ocupado) return;
    ocupado = true;
    final anteriores = preferencias;
    preferencias = novas;
    aviso = null;
    notifyListeners();
    try {
      await _salvar();
    } catch (_) {
      preferencias = anteriores;
      aviso = 'Não foi possível salvar as configurações.';
    }
    ocupado = false;
    notifyListeners();
  }

  void limparErro() {
    erro = null;
    notifyListeners();
  }

  @override
  void dispose() {
    api.cliente.close();
    super.dispose();
  }
}
