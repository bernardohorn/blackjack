// Verifica navegação, acessibilidade e telas pequenas sem depender da API real.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clube_21/main.dart';
import 'package:clube_21/regras.dart';
import 'package:clube_21/telas.dart';

import 'apoio.dart';

void main() {
  testWidgets('menu, partida, pausa e retomada sem comprar novamente', (
    teste,
  ) async {
    teste.view.physicalSize = const Size(390, 844);
    teste.view.devicePixelRatio = 1;
    addTearDown(teste.view.resetPhysicalSize);
    addTearDown(teste.view.resetDevicePixelRatio);
    final servidor = ServidorTeste(['9H', 'KS', '7C', '7D']);
    final jogo = servidor.jogo();
    jogo.preferencias.som = false;
    jogo.preferencias.vibracao = false;
    await teste.pumpWidget(Clube21(jogo: jogo));
    await teste.pumpAndSettle();
    expect(
      teste
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Continuar partida'),
          )
          .onPressed,
      isNull,
    );
    await teste.tap(find.text('Novo jogo'));
    await teste.pumpAndSettle();
    expect(find.text('Sua vez'), findsOneWidget);
    expect(find.text('10 + ? pts'), findsOneWidget);
    final semantica = teste.ensureSemantics();
    expect(find.bySemanticsLabel('Carta fechada'), findsOneWidget);
    expect(find.bySemanticsLabel('7 de ouros'), findsNothing);
    semantica.dispose();
    await teste.tap(find.byTooltip('Pausar partida'));
    await teste.pumpAndSettle();
    await teste.tap(find.text('Salvar e ir ao menu'));
    await teste.pumpAndSettle();
    await teste.tap(find.text('Continuar partida'));
    await teste.pumpAndSettle();
    expect(servidor.chamadas.length, 2);
    await teste.ensureVisible(find.text('Parar'));
    await teste.tap(find.text('Parar'));
    await teste.pumpAndSettle();
    expect(find.text('A banca venceu'), findsOneWidget);
    expect(teste.takeException(), isNull);
  });

  testWidgets('configurações e regras cabem em 320 pixels e texto ampliado', (
    teste,
  ) async {
    teste.view.physicalSize = const Size(320, 740);
    teste.view.devicePixelRatio = 1;
    teste.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(teste.view.resetPhysicalSize);
    addTearDown(teste.view.resetDevicePixelRatio);
    addTearDown(teste.platformDispatcher.clearTextScaleFactorTestValue);
    final jogo = ServidorTeste([]).jogo();
    await teste.pumpWidget(Clube21(jogo: jogo));
    await teste.pumpAndSettle();
    expect(teste.takeException(), isNull);
    await teste.scrollUntilVisible(find.text('Configurações'), 200);
    await teste.pumpAndSettle();
    await teste.tap(find.text('Configurações'));
    await teste.pumpAndSettle();
    expect(teste.takeException(), isNull);
    await teste.scrollUntilVisible(find.text('Claro'), 200);
    await teste.pumpAndSettle();
    await teste.tap(find.text('Claro'));
    await teste.pumpAndSettle();
    expect(jogo.preferencias.escuro, isFalse);
    expect(teste.takeException(), isNull);
    await teste.scrollUntilVisible(find.byTooltip('Voltar ao menu'), -200);
    await teste.pumpAndSettle();
    await teste.tap(find.byTooltip('Voltar ao menu'));
    await teste.pumpAndSettle();
    await teste.scrollUntilVisible(find.text('Como jogar'), 200);
    await teste.pumpAndSettle();
    await teste.tap(find.text('Como jogar'));
    await teste.pumpAndSettle();
    expect(find.text('01  Chegue perto de 21'), findsOneWidget);
    expect(teste.takeException(), isNull);
  });

  testWidgets('imagem indisponível preserva valor e naipe locais', (
    teste,
  ) async {
    await teste.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CartaVisual(
              carta: Carta('AS', 'https://exemplo.invalid/carta.png'),
            ),
          ),
        ),
      ),
    );
    await teste.pumpAndSettle();
    expect(find.text('A\n♠\uFE0E'), findsNWidgets(2));
    expect(find.text('♠\uFE0E'), findsOneWidget);
    expect(teste.takeException(), isNull);
  });
}
