// Uma tela por etapa do jogo; regras e chamadas HTTP permanecem em Jogo.
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'jogo.dart';
import 'regras.dart';

enum Pagina { menu, mesa, regras, configuracoes }

class Telas extends StatefulWidget {
  const Telas({super.key, required this.jogo});
  final Jogo jogo;
  @override
  State<Telas> createState() => _TelasState();
}

class _TelasState extends State<Telas> {
  Pagina pagina = Pagina.menu;
  AudioPlayer? audio;
  Jogo get jogo => widget.jogo;
  Color get dourado => Theme.of(context).colorScheme.primary;
  bool get escuro => jogo.preferencias.escuro;

  @override
  void dispose() {
    audio?.dispose();
    super.dispose();
  }

  // Estes efeitos são opcionais: uma falha de áudio não interrompe o jogo.
  Future<void> _retorno() async {
    if (jogo.preferencias.vibracao) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {
        /* Sem vibração. */
      }
    }
    if (jogo.preferencias.som) {
      try {
        await (audio ??= AudioPlayer()).play(AssetSource('sons/carta.wav'));
      } catch (_) {
        /* Áudio indisponível neste dispositivo. */
      }
    }
  }

  void _abrir(Pagina destino) => setState(() => pagina = destino);

  // O mesmo modal protege a pausa e a substituição de uma partida existente.
  Future<bool> _confirmar(
    String titulo,
    String texto,
    String confirmar,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (contexto) => Dialog(
          backgroundColor: escuro
              ? const Color(0xFF194B3D)
              : const Color(0xFFF7F1E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: dourado.withValues(alpha: .5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _titulo(titulo, tamanho: 26),
                const SizedBox(height: 14),
                _legenda(texto),
                const SizedBox(height: 24),
                _botao(
                  'Continuar jogando',
                  () => Navigator.pop(contexto, false),
                ),
                const SizedBox(height: 12),
                _botao(
                  confirmar,
                  () => Navigator.pop(contexto, true),
                  destaque: false,
                ),
                const SizedBox(height: 18),
                _legenda('Novo jogo substitui a mesa após confirmar.'),
              ],
            ),
          ),
        ),
      ) ??
      false;

  Future<void> _novoJogo() async {
    if (jogo.ocupado) return;
    if (jogo.mesa != null &&
        !await _confirmar(
          'Começar de novo?',
          'A mesa atual será substituída por uma nova partida.',
          'Novo jogo',
        )) {
      return;
    }
    if (!mounted) return;
    _abrir(Pagina.mesa);
    unawaited(_retorno());
    await jogo.novoJogo();
  }

  Future<void> _voltar() async {
    if (jogo.ocupado) return;
    if (pagina == Pagina.mesa && jogo.mesa != null && jogo.erro == null) {
      if (!await _confirmar(
        'Pausar a mesa?',
        'Sua partida fica salva neste dispositivo.\nVocê pode voltar quando quiser.',
        'Salvar e ir ao menu',
      )) {
        return;
      }
    }
    if (!mounted) return;
    jogo.limparErro();
    _abrir(Pagina.menu);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: pagina == Pagina.menu && !jogo.ocupado,
    onPopInvokedWithResult: (saiu, _) {
      if (!saiu) _voltar();
    },
    child: Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -.16),
            radius: 1,
            colors: escuro
                ? const [Color(0xFF155640), Color(0xFF062A22)]
                : const [Color(0xFFFFFDF5), Color(0xFFE5EADB)],
          ),
        ),
        child: CustomPaint(
          painter: _Trama(
            cor: escuro ? const Color(0x0991B89C) : const Color(0x08103F33),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ListView(
                  key: ValueKey(pagina),
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (!jogo.iniciando) _cabecalho(),
                    SizedBox(height: pagina == Pagina.mesa ? 8 : 20),
                    if (jogo.iniciando)
                      ..._abertura()
                    else if (pagina == Pagina.mesa && jogo.erro != null)
                      ..._erro()
                    else if (pagina == Pagina.mesa &&
                        (jogo.mesa == null || jogo.mesa!.jogador.isEmpty))
                      ..._carregando()
                    else
                      ...switch (pagina) {
                        Pagina.menu => _menu(),
                        Pagina.mesa => _mesa(),
                        Pagina.regras => _regras(),
                        Pagina.configuracoes => _configuracoes(),
                      },
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  // Marca, navegação e pausa seguem a posição do wireframe; o SO cuida das barras do aparelho.
  Widget _cabecalho() => Row(
    children: [
      if (pagina == Pagina.regras || pagina == Pagina.configuracoes)
        IconButton(
          tooltip: 'Voltar ao menu',
          onPressed: jogo.ocupado ? null : _voltar,
          icon: const Icon(Icons.chevron_left),
        ),
      Expanded(
        child: Text(
          switch (pagina) {
            Pagina.regras => 'Como jogar',
            Pagina.configuracoes => 'Configurações',
            _ => '♠\uFE0E CLUBE 21',
          },
          style: TextStyle(
            fontFamily: 'Gelasio',
            fontFamilyFallback: const ['Naipes'],
            fontSize: pagina == Pagina.menu || pagina == Pagina.mesa ? 21 : 24,
            fontWeight: FontWeight.w700,
            color: pagina == Pagina.menu || pagina == Pagina.mesa
                ? dourado
                : null,
          ),
        ),
      ),
      if (pagina == Pagina.menu)
        _selo('${jogo.preferencias.baralhos} baralhos'),
      if (pagina == Pagina.mesa)
        IconButton.filledTonal(
          tooltip: 'Pausar partida',
          onPressed: jogo.ocupado ? null : _voltar,
          icon: const Icon(Icons.pause_rounded),
        ),
    ],
  );

  // Componentes compartilhados mantêm cores, espaçamentos e controles consistentes.
  Widget _titulo(String texto, {double tamanho = 30, Color? cor}) => Text(
    texto,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: 'Gelasio',
      fontFamilyFallback: const ['Naipes'],
      fontSize: tamanho,
      height: 1.15,
      fontWeight: FontWeight.w600,
      color: cor,
    ),
  );
  Widget _legenda(String texto) => Text(
    texto,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 12,
      height: 1.5,
      color: escuro ? const Color(0xFFB6CDC2) : const Color(0xFF40564B),
    ),
  );
  Widget _selo(String texto) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: escuro ? const Color(0xFF214F42) : const Color(0xFFDCE4D5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 12,
        color: escuro ? const Color(0xFFF7F1E4) : const Color(0xFF173B30),
      ),
    ),
  );
  Widget _painel(Widget conteudo, {bool derrota = false}) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: derrota
          ? (escuro ? const Color(0xFF4D3531) : const Color(0xFFF3D7D1))
          : (escuro ? const Color(0xFF19463B) : const Color(0xFFE9EBDD)),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: dourado.withValues(alpha: .35)),
    ),
    child: Material(type: MaterialType.transparency, child: conteudo),
  );
  Widget _botao(
    String texto,
    VoidCallback? acao, {
    bool destaque = true,
    String? apoio,
  }) {
    final conteudo = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (apoio != null)
            Text(
              apoio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
    if (!destaque) return OutlinedButton(onPressed: acao, child: conteudo);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: acao == null
            ? null
            : const LinearGradient(
                colors: [Color(0xFFF1D991), Color(0xFFD7B25F)],
              ),
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: acao,
        child: conteudo,
      ),
    );
  }

  // As cartas decorativas são locais; abrir o menu não consome o baralho remoto.
  Widget _marca() => SizedBox(
    height: 215,
    child: Center(
      child: SizedBox(
        width: 190,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 28,
              top: 18,
              child: Transform.rotate(
                angle: -.21,
                child: const CartaVisual(carta: Carta('AS'), largura: 100),
              ),
            ),
            Positioned(
              right: 22,
              top: 10,
              child: Transform.rotate(
                angle: .16,
                child: const CartaVisual(carta: Carta('AD'), largura: 100),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  List<Widget> _abertura() => [
    const SizedBox(height: 74),
    _legenda('UM CLÁSSICO NA SUA MÃO'),
    _marca(),
    _titulo('Blackjack', tamanho: 44),
    const SizedBox(height: 10),
    _legenda('C L U B E  2 1'),
    const SizedBox(height: 34),
    _legenda('A estratégia encontra a sorte.\nChegue perto de 21.'),
    const SizedBox(height: 64),
    const LinearProgressIndicator(),
    const SizedBox(height: 10),
    _legenda('Preparando sua mesa…'),
  ];

  List<Widget> _menu() => [
    const SizedBox(height: 20),
    _marca(),
    _titulo('Sua próxima\nboa jogada.', tamanho: 36),
    const SizedBox(height: 14),
    _legenda('Um clássico. Um novo jeito de jogar.'),
    const SizedBox(height: 40),
    _botao('Novo jogo', jogo.ocupado ? null : _novoJogo),
    const SizedBox(height: 14),
    _botao(
      'Continuar partida',
      jogo.mesa == null || jogo.ocupado ? null : () => _abrir(Pagina.mesa),
      destaque: false,
    ),
    const SizedBox(height: 14),
    _legenda(
      jogo.mesa == null
          ? 'Sua partida aparecerá aqui quando começar.'
          : 'Mesa 01 · ${jogo.mesa!.restantes} cartas restantes',
    ),
    if (jogo.aviso != null) _painel(Text(jogo.aviso!)),
    const Padding(
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 64),
      child: Divider(),
    ),
    Row(
      children: [
        Expanded(
          child: _botao(
            'Como jogar',
            () => _abrir(Pagina.regras),
            destaque: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _botao(
            'Configurações',
            () => _abrir(Pagina.configuracoes),
            destaque: false,
          ),
        ),
      ],
    ),
    const SizedBox(height: 24),
    _legenda('Flutter + Deck of Cards API'),
  ];

  // Distribuir e renovar têm mensagens próprias, mas usam a mesma sequência de API.
  List<Widget> _carregando() => [
    _titulo(
      jogo.renovando ? 'Renovando a mesa' : 'Preparando a mesa',
      tamanho: 25,
    ),
    const SizedBox(height: 14),
    _legenda(
      jogo.renovando
          ? 'Um baralho novo, a mesma experiência.'
          : 'Uma nova rodada está chegando.',
    ),
    const SizedBox(height: 45),
    _marca(),
    _titulo(
      jogo.renovando ? 'Hora de renovar o shoe' : 'Embaralhando a sorte…',
      tamanho: 26,
    ),
    const SizedBox(height: 20),
    _legenda(
      jogo.renovando
          ? 'O corte foi atingido entre rodadas.\nVamos criar outro shoe antes de distribuir.'
          : 'Criando seu shoe e distribuindo cartas.\nAs ações ficam disponíveis em instantes.',
    ),
    if (jogo.renovando)
      Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Center(child: _selo(jogo.corte)),
      ),
    const SizedBox(height: 45),
    const LinearProgressIndicator(),
    const SizedBox(height: 16),
    _botao(
      jogo.renovando ? 'Preparando nova rodada…' : 'Distribuindo cartas…',
      null,
    ),
  ];

  List<Widget> _erro() => [
    const SizedBox(height: 100),
    Icon(Icons.error_outline, size: 64, color: dourado),
    const SizedBox(height: 28),
    _titulo(
      jogo.falhaLocal
          ? 'Não foi possível salvar'
          : jogo.compraIncerta
          ? 'Rodada interrompida'
          : 'Não foi possível conectar',
      tamanho: 28,
    ),
    const SizedBox(height: 20),
    _legenda(jogo.erro!),
    const SizedBox(height: 24),
    if (!jogo.falhaLocal)
      _painel(
        _legenda(
          jogo.compraIncerta
              ? 'Para manter a rodada correta, reinicie a mesa com um novo baralho.\nA rodada atual será encerrada.'
              : 'Seu jogo não começou.\nTentar novamente cria uma nova mesa.\nNenhuma compra será repetida.',
        ),
      ),
    const SizedBox(height: 48),
    _botao(
      jogo.compraIncerta ? 'Reiniciar mesa' : 'Tentar novamente',
      _novoJogo,
    ),
    const SizedBox(height: 12),
    _botao('Voltar ao menu', _voltar, destaque: false),
  ];

  List<Widget> _mesa() {
    final mesa = jogo.mesa!;
    final terminada = mesa.fase == Fase.concluida;
    final suaVez = mesa.fase == Fase.jogador && !jogo.ocupado;
    final ases = mesa.jogador.where((carta) => carta.valor == 'A').length;
    final mao = pontuar(mesa.jogador);
    final ajustado = ases > (mao.suave ? 1 : 0);
    final mensagem = terminada
        ? resultado(mesa.jogador, mesa.banca)
        : mesa.fase == Fase.banca
        ? (
            titulo: 'Vez da banca',
            detalhe: bancaCompra(mesa.banca, mesa.paraNo17Suave)
                ? 'A banca pede mais uma carta.'
                : '${pontuar(mesa.banca).pontos} pontos. A banca para.',
          )
        : ajustado && !jogo.ocupado
        ? (
            titulo: 'Boa decisão.',
            detalhe: 'Ás ajustado: você continua no jogo.',
          )
        : (
            titulo: jogo.ocupado ? 'Pedindo carta…' : 'Sua vez',
            detalhe: 'Pedir mais uma carta ou parar?',
          );
    final derrota =
        terminada &&
        (mao.pontos > 21 ||
            natural(mesa.banca) && !natural(mesa.jogador) ||
            pontuar(mesa.banca).pontos <= 21 &&
                pontuar(mesa.banca).pontos > mao.pontos);
    return [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MESA 01',
                  style: TextStyle(letterSpacing: 2, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '${mesa.restantes} cartas no shoe',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _selo('${mesa.baralhos} baralhos'),
        ],
      ),
      const SizedBox(height: 12),
      _mao('BANCA', mesa.banca, ocultar: mesa.fase == Fase.jogador),
      const SizedBox(height: 12),
      _legenda('B L A C K J A C K  ·  C L U B E  2 1'),
      const SizedBox(height: 12),
      Semantics(
        liveRegion: true,
        child: _painel(
          Column(
            children: [
              _titulo(
                mensagem.titulo,
                tamanho: 26,
                cor: derrota
                    ? (escuro
                          ? const Color(0xFFF1B6A5)
                          : const Color(0xFF802D27))
                    : dourado,
              ),
              const SizedBox(height: 8),
              _legenda(mensagem.detalhe),
            ],
          ),
          derrota: derrota,
        ),
      ),
      const SizedBox(height: 8),
      _mao('SUA MÃO', mesa.jogador),
      const SizedBox(height: 10),
      _legenda(
        ajustado
            ? (ases == 1
                  ? 'Ás vale 1 nesta mão'
                  : 'Um ou mais ases valem 1 nesta mão')
            : 'Sem apostas · jogue para aprender',
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _botao(
              'Pedir carta',
              suaVez
                  ? () {
                      unawaited(_retorno());
                      jogo.pedirCarta();
                    }
                  : null,
              apoio: 'HIT · +1 carta',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _botao(
              'Parar',
              suaVez
                  ? () {
                      unawaited(_retorno());
                      jogo.parar();
                    }
                  : null,
              destaque: false,
              apoio: 'STAND · vez da banca',
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (jogo.ocupado) const LinearProgressIndicator(),
      _botao(
        terminada ? 'Nova rodada' : 'Rodada em andamento',
        terminada && !jogo.ocupado
            ? () {
                unawaited(_retorno());
                jogo.novaRodada();
              }
            : null,
      ),
    ];
  }

  // As cartas se sobrepõem como no wireframe; mãos longas têm rolagem horizontal.
  Widget _mao(String nome, List<Carta> cartas, {bool ocultar = false}) =>
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _selo(
                ocultar
                    ? '${cartas.first.pontos} + ? pts'
                    : '${pontuar(cartas).pontos} pts',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 90 + (cartas.length - 1) * 67,
              height: 134,
              child: Stack(
                children: [
                  for (var i = 0; i < cartas.length; i++)
                    Positioned(
                      left: i * 67,
                      top: 0,
                      child: CartaVisual(
                        carta: cartas[i],
                        oculta: ocultar && i == 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );

  List<Widget> _regras() => [
    _legenda('Poucas regras. Muitas boas decisões.'),
    const SizedBox(height: 20),
    for (final regra in const [
      (
        '01  Chegue perto de 21',
        'Vença a banca com mais pontos, sem ultrapassar 21. Empate não é derrota.',
      ),
      (
        '02  Conheça as cartas',
        '2 a 10 valem o número da carta. J, Q e K valem 10. O Ás vale 1 ou 11.\nÁs + 9 + Ás = 21: um Ás vale 11; o outro vale 1.',
      ),
      (
        '03  Escolha sua ação',
        'Pedir carta (Hit): recebe mais uma carta. Parar (Stand): encerra sua vez. Ao chegar a 21, a banca joga automaticamente.',
      ),
      (
        '04  A vez da banca',
        'Compra abaixo de 17; para a partir de 17. Soft 17 segue a configuração da mesa.\nÁs + carta de valor 10 em duas cartas é Blackjack. Dois Blackjacks naturais empatam. 21 em três ou mais cartas não é natural.',
      ),
    ])
      _painel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              regra.$1,
              style: TextStyle(color: dourado, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(regra.$2, style: const TextStyle(fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    _legenda(
      'Modo de estudo · sem apostas\nSem divisão de mãos, dobra ou seguro.',
    ),
  ];

  // Alteramos uma cópia: se o salvamento falhar, Jogo pode recuperar a anterior.
  void _configurar(void Function(Preferencias) alterar) {
    final novas = Preferencias.ler(jogo.preferencias.salvar());
    alterar(novas);
    jogo.configurar(novas);
  }

  Widget _opcao(
    String nome,
    bool valor,
    void Function(bool) alterar, {
    String? detalhe,
  }) => _painel(
    SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: detalhe == null
          ? null
          : Text(detalhe, style: const TextStyle(fontSize: 12, height: 1.5)),
      value: valor,
      onChanged: jogo.ocupado ? null : alterar,
    ),
  );

  List<Widget> _configuracoes() {
    final preferencias = jogo.preferencias;
    return [
      _legenda('Deixe o jogo com a sua cara.'),
      const SizedBox(height: 28),
      Text(
        'REGRAS DA PRÓXIMA MESA',
        style: TextStyle(color: dourado, fontSize: 12, letterSpacing: 1.4),
      ),
      const SizedBox(height: 16),
      _painel(
        Row(
          children: [
            const Expanded(
              child: Text(
                'Baralhos\nPadrão clássico: 6',
                style: TextStyle(height: 1.7),
              ),
            ),
            IconButton(
              tooltip: 'Diminuir baralhos',
              onPressed: preferencias.baralhos > 1 && !jogo.ocupado
                  ? () => _configurar((nova) => nova.baralhos--)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Text(
              '${preferencias.baralhos}',
              style: TextStyle(fontSize: 22, color: dourado),
            ),
            IconButton(
              tooltip: 'Aumentar baralhos',
              onPressed: preferencias.baralhos < 6 && !jogo.ocupado
                  ? () => _configurar((nova) => nova.baralhos++)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
      _opcao(
        'Banca para no soft 17',
        preferencias.paraNo17Suave,
        (valor) => _configurar((nova) => nova.paraNo17Suave = valor),
        detalhe:
            'Ás + 6 = 17, com Ás valendo 11.\n${preferencias.paraNo17Suave ? 'Ligado: a banca para nessa mão.' : 'Desligado: a banca compra nessa mão.'}',
      ),
      const SizedBox(height: 20),
      Text(
        'PREFERÊNCIAS',
        style: TextStyle(color: dourado, fontSize: 12, letterSpacing: 1.4),
      ),
      const SizedBox(height: 16),
      _opcao(
        'Som',
        preferencias.som,
        (valor) => _configurar((nova) => nova.som = valor),
      ),
      _opcao(
        'Vibração',
        preferencias.vibracao,
        (valor) => _configurar((nova) => nova.vibracao = valor),
      ),
      _painel(
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 14,
          runSpacing: 12,
          children: [
            const Text('Tema'),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: true, label: Text('Escuro')),
                ButtonSegment(value: false, label: Text('Claro')),
              ],
              selected: {preferencias.escuro},
              onSelectionChanged: jogo.ocupado
                  ? null
                  : (valor) =>
                        _configurar((nova) => nova.escuro = valor.single),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _legenda('As regras atuais da mesa são preservadas.'),
      if (jogo.aviso != null) _painel(Text(jogo.aviso!)),
      const SizedBox(height: 24),
      _botao(
        'Restaurar padrões',
        jogo.ocupado ? null : () => jogo.configurar(Preferencias()),
        destaque: false,
      ),
    ];
  }
}

/// A imagem da API tem uma frente local como alternativa. A carta fechada nunca carrega sua imagem.
class CartaVisual extends StatelessWidget {
  const CartaVisual({
    super.key,
    required this.carta,
    this.oculta = false,
    this.largura = 90,
  });
  final Carta carta;
  final bool oculta;
  final double largura;

  @override
  Widget build(BuildContext context) => Semantics(
    label: oculta ? 'Carta fechada' : carta.descricao,
    image: true,
    child: ExcludeSemantics(
      child: MediaQuery.withNoTextScaling(
        child: Container(
          width: largura,
          height: largura * 1.46,
          decoration: BoxDecoration(
            color: oculta ? const Color(0xFF103F33) : const Color(0xFFF7F1E4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDFD8C9)),
            boxShadow: const [
              BoxShadow(color: Color(0x80031F19), offset: Offset(0, 3)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: oculta
              ? Padding(
                  padding: const EdgeInsets.all(6),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD7B25F)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomPaint(
                      painter: const _Trama(
                        cor: Color(0x55BFA362),
                        diagonal: true,
                      ),
                      child: const Center(
                        child: Text(
                          '♠\uFE0E',
                          style: TextStyle(
                            fontFamily: 'Gelasio',
                            fontFamilyFallback: ['Naipes'],
                            fontSize: 40,
                            color: Color(0xFFE8C778),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : carta.imagem.isEmpty
              ? _frente()
              : Image.network(
                  carta.imagem,
                  fit: BoxFit.fill,
                  loadingBuilder: (_, imagem, progresso) =>
                      progresso == null ? imagem : _frente(),
                  errorBuilder: (_, erro, pilha) => _frente(),
                ),
        ),
      ),
    ),
  );

  Widget _frente() => DefaultTextStyle(
    style: TextStyle(
      fontFamily: 'Gelasio',
      fontFamilyFallback: const ['Naipes'],
      color: carta.vermelha ? const Color(0xFFAB3A40) : const Color(0xFF233B32),
      fontSize: largura / 4.5,
      fontWeight: FontWeight.w700,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${carta.valor}\n${carta.simbolo}\uFE0E',
              style: const TextStyle(height: 1.05),
            ),
          ),
          Center(
            child: Text(
              '${carta.simbolo}\uFE0E',
              style: TextStyle(fontSize: largura / 2),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: RotatedBox(
              quarterTurns: 2,
              child: Text(
                '${carta.valor}\n${carta.simbolo}\uFE0E',
                style: const TextStyle(height: 1.05),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Uma malha leve imita o feltro; linhas diagonais formam o desenho do verso.
class _Trama extends CustomPainter {
  const _Trama({required this.cor, this.diagonal = false});
  final Color cor;
  final bool diagonal;
  @override
  void paint(Canvas tela, Size tamanho) {
    final pincel = Paint()
      ..color = cor
      ..strokeWidth = .6;
    if (diagonal) {
      for (
        double x = -tamanho.height;
        x < tamanho.width + tamanho.height;
        x += 12
      ) {
        tela.drawLine(
          Offset(x, 0),
          Offset(x + tamanho.height, tamanho.height),
          pincel,
        );
        tela.drawLine(
          Offset(x, 0),
          Offset(x - tamanho.height, tamanho.height),
          pincel,
        );
      }
    } else {
      for (double x = 0; x < tamanho.width; x += 5) {
        tela.drawLine(Offset(x, 0), Offset(x, tamanho.height), pincel);
      }
      for (double y = 0; y < tamanho.height; y += 5) {
        tela.drawLine(Offset(0, y), Offset(tamanho.width, y), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(_Trama anterior) =>
      anterior.cor != cor || anterior.diagonal != diagonal;
}
