// Dados e regras do Blackjack: este arquivo não depende de telas nem de internet.
enum Fase { jogador, banca, concluida }

/// Uma carta usa o código da API; os nomes exibidos são traduzidos aqui.
class Carta {
  const Carta(this.codigo, [this.imagem = '']);
  final String codigo;
  final String imagem;

  String get valor => codigo[0] == '0' ? '10' : codigo[0];
  String get simbolo =>
      const {'S': '♠', 'H': '♥', 'D': '♦', 'C': '♣'}[codigo[1]]!;
  bool get vermelha => codigo.endsWith('H') || codigo.endsWith('D');
  int get pontos => valor == 'A' ? 11 : int.tryParse(valor) ?? 10;
  String get descricao {
    final nome =
        const {'A': 'Ás', 'J': 'Valete', 'Q': 'Dama', 'K': 'Rei'}[valor] ??
        valor;
    final naipe = const {
      'S': 'espadas',
      'H': 'copas',
      'D': 'ouros',
      'C': 'paus',
    }[codigo[1]];
    return '$nome de $naipe';
  }

  // O formato salvo é pequeno; a API é traduzida separadamente em api.dart.
  Map<String, dynamic> salvar() => {'codigo': codigo, 'imagem': imagem};
  factory Carta.ler(Map<String, dynamic> dados) {
    final codigo = dados['codigo'];
    if (codigo is! String || !RegExp(r'^[A2-90JQK][SHDC]$').hasMatch(codigo)) {
      throw const FormatException('Carta inválida.');
    }
    return Carta(codigo, dados['imagem'] as String? ?? '');
  }
}

/// Reduz o Ás de 11 para 1 somente quando necessário para evitar um estouro.
({int pontos, bool suave}) pontuar(List<Carta> cartas) {
  var total = 0;
  var ases = 0;
  for (final carta in cartas) {
    total += carta.pontos;
    if (carta.valor == 'A') ases++;
  }
  while (total > 21 && ases > 0) {
    total -= 10;
    ases--;
  }
  return (pontos: total, suave: ases > 0);
}

bool natural(List<Carta> cartas) =>
    cartas.length == 2 && pontuar(cartas).pontos == 21;

/// Soft 17 significa 17 pontos com pelo menos um Ás ainda valendo 11.
bool bancaCompra(List<Carta> cartas, bool paraNo17Suave) {
  final mao = pontuar(cartas);
  return mao.pontos < 17 || (mao.pontos == 17 && mao.suave && !paraNo17Suave);
}

/// A ordem das verificações garante que um natural vença um 21 de três cartas.
({String titulo, String detalhe}) resultado(
  List<Carta> jogador,
  List<Carta> banca,
) {
  final seusPontos = pontuar(jogador).pontos;
  final pontosBanca = pontuar(banca).pontos;
  if (seusPontos > 21) {
    return (
      titulo: 'Você passou de 21',
      detalhe: '$seusPontos pontos. A banca venceu a rodada.',
    );
  }
  if (natural(jogador) && natural(banca)) {
    return (
      titulo: 'Empate',
      detalhe: 'Dois Blackjacks naturais. Uma nova chance vem aí.',
    );
  }
  if (natural(banca)) {
    return (
      titulo: 'Blackjack da banca',
      detalhe: 'A banca fez 21 com duas cartas.',
    );
  }
  if (natural(jogador)) {
    return (
      titulo: 'Blackjack!',
      detalhe: 'Um Ás e uma carta de valor 10. Uma mão perfeita.',
    );
  }
  if (pontosBanca > 21) {
    return (titulo: 'Você venceu', detalhe: 'A banca passou de 21.');
  }
  if (seusPontos == pontosBanca) {
    return (
      titulo: 'Empate',
      detalhe: '$seusPontos a $pontosBanca. Uma nova chance vem aí.',
    );
  }
  return (
    titulo: seusPontos > pontosBanca ? 'Você venceu' : 'A banca venceu',
    detalhe: 'Você: $seusPontos · Banca: $pontosBanca',
  );
}

/// As preferências são copiadas ao criar a mesa, preservando suas regras atuais.
class Preferencias {
  Preferencias({
    this.baralhos = 6,
    this.paraNo17Suave = true,
    this.som = true,
    this.vibracao = true,
    this.escuro = true,
  });
  int baralhos;
  bool paraNo17Suave, som, vibracao, escuro;
  Map<String, dynamic> salvar() => {
    'baralhos': baralhos,
    'paraNo17Suave': paraNo17Suave,
    'som': som,
    'vibracao': vibracao,
    'escuro': escuro,
  };
  factory Preferencias.ler(Map<String, dynamic> dados) => Preferencias(
    baralhos: (dados['baralhos'] as int? ?? 6).clamp(1, 6),
    paraNo17Suave: dados['paraNo17Suave'] as bool? ?? true,
    som: dados['som'] as bool? ?? true,
    vibracao: dados['vibracao'] as bool? ?? true,
    escuro: dados['escuro'] as bool? ?? true,
  );
}

/// Tudo que precisamos para continuar uma partida, inclusive as duas mãos.
class Mesa {
  Mesa({
    required this.identificador,
    required this.restantes,
    required this.baralhos,
    required this.paraNo17Suave,
  });
  final String identificador;
  final int baralhos;
  final bool paraNo17Suave;
  int restantes, rodada = 0;
  List<Carta> jogador = [], banca = [];
  Fase fase = Fase.jogador;
  DateTime ultimaJogada = DateTime.now();
  bool get renovar => restantes <= baralhos * 52 / 4 || restantes < 4;

  Map<String, dynamic> salvar() => {
    'identificador': identificador,
    'restantes': restantes,
    'baralhos': baralhos,
    'paraNo17Suave': paraNo17Suave,
    'rodada': rodada,
    'fase': fase.name,
    'jogador': jogador.map((carta) => carta.salvar()).toList(),
    'banca': banca.map((carta) => carta.salvar()).toList(),
    'ultimaJogada': ultimaJogada.toIso8601String(),
  };

  factory Mesa.ler(Map<String, dynamic> dados) {
    final mesa = Mesa(
      identificador: dados['identificador'] as String,
      restantes: dados['restantes'] as int,
      baralhos: dados['baralhos'] as int,
      paraNo17Suave: dados['paraNo17Suave'] as bool,
    );
    mesa.rodada = dados['rodada'] as int;
    mesa.fase = Fase.values.byName(dados['fase'] as String);
    mesa.jogador = (dados['jogador'] as List)
        .map((carta) => Carta.ler(Map<String, dynamic>.from(carta)))
        .toList();
    mesa.banca = (dados['banca'] as List)
        .map((carta) => Carta.ler(Map<String, dynamic>.from(carta)))
        .toList();
    mesa.ultimaJogada = DateTime.parse(dados['ultimaJogada'] as String);
    if (mesa.identificador.isEmpty ||
        mesa.baralhos < 1 ||
        mesa.baralhos > 6 ||
        mesa.restantes < 0 ||
        mesa.restantes > mesa.baralhos * 52 ||
        mesa.rodada < 1 ||
        mesa.jogador.length < 2 ||
        mesa.banca.length < 2 ||
        mesa.fase == Fase.banca) {
      throw const FormatException('Partida salva inválida.');
    }
    return mesa;
  }
}
