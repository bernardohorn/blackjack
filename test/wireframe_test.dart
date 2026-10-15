// Exercita os 19 estados do wireframe e, opcionalmente, exporta imagens reais do Flutter.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clube_21/jogo.dart';
import 'package:clube_21/main.dart';
import 'package:clube_21/regras.dart';

import 'apoio.dart';

// Só os dados são simulados; a interface usada é a mesma do aplicativo.
class JogoCenario extends Jogo {
  JogoCenario() : super(ServidorTeste([]).api, MemoriaTeste()) {
    iniciando = false;
    preferencias.som = false;
    preferencias.vibracao = false;
  }
  @override
  Future<void> carregar() async {}
  void atualizar() => notifyListeners();
}

Mesa mesaCenario(List<String> jogador, List<String> banca, Fase fase) =>
    Mesa(
        identificador: 'cenario',
        restantes: 312 - jogador.length - banca.length,
        baralhos: 6,
        paraNo17Suave: true,
      )
      ..jogador = jogador.map(Carta.new).toList()
      ..banca = banca.map(Carta.new).toList()
      ..rodada = 1
      ..fase = fase;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const exportar = bool.fromEnvironment('EXPORTAR_TELAS');
  // Os testes comuns dispensam fontes. A galeria usa as fontes locais do SDK e do app.
  setUpAll(() async {
    if (!exportar) return;
    final gelasio = FontLoader('Gelasio')
      ..addFont(rootBundle.load('assets/fontes/Gelasio.ttf'));
    final naipes = FontLoader('Naipes')
      ..addFont(rootBundle.load('assets/fontes/Naipes.ttf'));
    final icones = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    final sdk = Platform.environment['FLUTTER_ROOT'];
    if (sdk == null) {
      throw StateError('Defina FLUTTER_ROOT para exportar a galeria.');
    }
    final roboto = FontLoader('Roboto');
    for (final peso in ['regular', 'medium', 'bold']) {
      final bytes = await File(
        '$sdk/bin/cache/artifacts/material_fonts/roboto-$peso.ttf',
      ).readAsBytes();
      roboto.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await Future.wait([
      gelasio.load(),
      naipes.load(),
      icones.load(),
      roboto.load(),
    ]);
  });

  const telas = {
    '01-abertura': 'Preparando sua mesa…',
    '02-menu': 'Novo jogo',
    '03-menu-ativo': 'Mesa 01 · 308 cartas restantes',
    '04-configuracoes': 'Baralhos\nPadrão clássico: 6',
    '05-regras': '01  Chegue perto de 21',
    '06-distribuindo': 'Distribuindo cartas…',
    '07-sua-vez': 'Sua vez',
    '08-as-flexivel': 'Boa decisão.',
    '09-banca': 'Vez da banca',
    '10-blackjack': 'Blackjack!',
    '11-vitoria': 'Você venceu',
    '12-empate': 'Empate',
    '13-derrota': 'A banca venceu',
    '14-estouro': 'Você passou de 21',
    '15-erro-conexao': 'Não foi possível conectar',
    '16-compra-incerta': 'Rodada interrompida',
    '17-renovar-shoe': 'Hora de renovar o shoe',
    '18-sair': 'Pausar a mesa?',
    '19-blackjack-banca': 'Blackjack da banca',
  };
  for (final tela in telas.entries) {
    testWidgets('wireframe ${tela.key}', (teste) async {
      teste.view.physicalSize = const Size(390, 844);
      teste.view.devicePixelRatio = 1;
      addTearDown(teste.view.resetPhysicalSize);
      addTearDown(teste.view.resetDevicePixelRatio);
      final numero = int.parse(tela.key.substring(0, 2));
      final jogo = JogoCenario();
      if (numero == 1) jogo.iniciando = true;
      if (numero == 3 || numero >= 6) {
        jogo.mesa = mesaCenario(['9H', '7C'], ['KS', '7D'], Fase.jogador);
      }
      final captura = GlobalKey();
      await teste.pumpWidget(
        RepaintBoundary(
          key: captura,
          child: Clube21(jogo: jogo),
        ),
      );
      await teste.pump(const Duration(milliseconds: 100));
      if (numero == 4 || numero == 5) {
        final destino = find.text(numero == 4 ? 'Configurações' : 'Como jogar');
        await teste.ensureVisible(destino);
        await teste.pumpAndSettle();
        await teste.tap(destino);
        await teste.pumpAndSettle();
      }
      if (numero >= 6) {
        await teste.tap(find.text('Continuar partida'));
        await teste.pumpAndSettle();
        switch (numero) {
          case 6:
            jogo.mesa = null;
            jogo.ocupado = true;
          case 8:
            jogo.mesa = mesaCenario(
              ['9H', '7C', 'AS'],
              ['KS', '7D'],
              Fase.jogador,
            );
          case 9:
            jogo.mesa!.fase = Fase.banca;
            jogo.ocupado = true;
          case 10:
            jogo.mesa = mesaCenario(['AS', 'KH'], ['0S', '7D'], Fase.concluida);
          case 11:
            jogo.mesa = mesaCenario(
              ['9H', '7C', 'AS'],
              ['KS', '6D', '6C'],
              Fase.concluida,
            );
          case 12:
            jogo.mesa = mesaCenario(
              ['9H', '7C', 'AS'],
              ['KS', '7D'],
              Fase.concluida,
            );
          case 13:
            jogo.mesa!.fase = Fase.concluida;
          case 14:
            jogo.mesa = mesaCenario(
              ['9H', '7C', 'AS', '8H'],
              ['KS', '7D'],
              Fase.concluida,
            );
          case 15:
            jogo.mesa = null;
            jogo.erro = 'Confira sua conexão e tente novamente. Não foi possível preparar a mesa.';
          case 16:
            jogo.mesa = null;
            jogo.compraIncerta = true;
            jogo.erro = 'Não sabemos se a última compra foi concluída. Reinicie a mesa com um novo baralho.';
          case 17:
            jogo.mesa = null;
            jogo.renovando = true;
            jogo.ocupado = true;
            jogo.corte = '78 / 312 cartas';
          case 18:
            await teste.tap(find.byTooltip('Pausar partida'));
            await teste.pumpAndSettle();
          case 19:
            jogo.mesa = mesaCenario(['KS', 'QH'], ['AS', 'KH'], Fase.concluida);
        }
        jogo.atualizar();
        await teste.pump(const Duration(milliseconds: 100));
      }
      expect(find.text(tela.value), findsOneWidget);
      expect(teste.takeException(), isNull);
      if (numero == 8) expect(find.text('Ás vale 1 nesta mão'), findsOneWidget);
      if (numero == 16) {
        await teste.ensureVisible(find.text('Voltar ao menu'));
        await teste.pump();
      }
      if (exportar) {
        // Captura sem relógio/barras fictícias do sistema e sem chamar a API pública.
        final quadro =
            captura.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await teste.runAsync(() async {
          final imagem = await quadro.toImage(pixelRatio: 2);
          final dados = await imagem.toByteData(format: ui.ImageByteFormat.png);
          await File('docs/imagens/${tela.key}.png')
              .writeAsBytes(dados!.buffer.asUint8List());
          imagem.dispose();
        });
      }
      // A recuperação da falha de compra nunca oferece uma sessão inválida.
      if (numero == 16) {
        await teste.tap(find.text('Voltar ao menu'));
        await teste.pumpAndSettle();
        expect(
          teste
              .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Continuar partida'),
              )
              .onPressed,
          isNull,
        );
      }
    });
  }
}
