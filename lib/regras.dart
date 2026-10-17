// dart format off
// Mantém as explicações ao lado das linhas durante a formatação automática.

// --------------------------------------------------------------------------
// ETAPAS DE UMA RODADA
// Uma rodada pode estar na vez do jogador, na vez da banca ou encerrada.
// Estes nomes permitem ao restante do código saber quais ações estão disponíveis.
// --------------------------------------------------------------------------
enum Fase { jogador, banca, concluida } // Nomeia as três etapas possíveis de uma rodada.

// --------------------------------------------------------------------------
// DADOS E LEITURA DE UMA CARTA
// Cada carta tem um código de duas posições e, opcionalmente, uma imagem.
// Os getters são informações calculadas a partir desse código, sem acesso à internet.
// --------------------------------------------------------------------------
class Carta { // Define quais dados e cálculos pertencem a uma carta.
  const Carta(this.codigo, [this.imagem = '']); // Cria a carta com um código e uma imagem opcional, vazia por padrão.
  final String codigo; // Guarda o código da carta sem permitir trocá-lo depois da criação.
  final String imagem; // Guarda o endereço da imagem, que pode ser um texto vazio.

  String get valor => codigo[0] == '0' ? '10' : codigo[0]; // Lê o valor na primeira posição e traduz o código 0 para dez.
  String get simbolo => // Define a leitura do símbolo gráfico do naipe.
      const {'S': '♠', 'H': '♥', 'D': '♦', 'C': '♣'}[codigo[1]]!; // Busca o símbolo pelo segundo caractere de um código já validado.
  bool get vermelha => codigo.endsWith('H') || codigo.endsWith('D'); // Marca copas e ouros como cartas vermelhas.
  int get pontos => valor == 'A' ? 11 : int.tryParse(valor) ?? 10; // Conta Ás como 11, números pelo valor e figuras como 10.

  // --------------------------------------------------------------------------
  // NOME DA CARTA EM PORTUGUÊS
  // Traduz o valor e o naipe para uma frase como Ás de espadas.
  // Essa descrição também ajuda quem usa leitor de tela.
  // --------------------------------------------------------------------------
  String get descricao { // Monta o nome completo da carta para leitura em português.
    final nome = // Prepara o nome do valor da carta.
        const {'A': 'Ás', 'J': 'Valete', 'Q': 'Dama', 'K': 'Rei'}[valor] ?? // Traduz Ás e figuras; se não encontrar, usa a alternativa seguinte.
        valor; // Mantém o número como nome das cartas numéricas.
    final naipe = const { // Prepara uma tabela para descobrir o nome do naipe.
      'S': 'espadas', // Traduz o código S para espadas.
      'H': 'copas', // Traduz o código H para copas.
      'D': 'ouros', // Traduz o código D para ouros.
      'C': 'paus', // Traduz o código C para paus.
    }[codigo[1]]; // Escolhe o nome correspondente ao segundo caractere do código.
    return '$nome de $naipe'; // Junta valor e naipe numa descrição, como Ás de espadas.
  } // Conclui o bloco nome da carta em português.

  // --------------------------------------------------------------------------
  // GUARDAR E RECUPERAR UMA CARTA
  // Transforma a carta em campos simples para salvar e faz o caminho de volta.
  // Na leitura, rejeita códigos que não representam uma carta válida.
  // --------------------------------------------------------------------------
  Map<String, dynamic> salvar() => {'codigo': codigo, 'imagem': imagem}; // Converte a carta em dois campos simples para poder salvá-la.
  factory Carta.ler(Map<String, dynamic> dados) { // Reconstrói uma carta a partir dos campos recebidos.
    final codigo = dados['codigo']; // Lê o código que será conferido antes da criação da carta.
    if (codigo is! String || !RegExp(r'^[A2-90JQK][SHDC]$').hasMatch(codigo)) { // Exige duas posições: um valor permitido e um dos quatro naipes.
      throw const FormatException('Carta inválida.'); // Interrompe a leitura quando o código não representa uma carta válida.
    } // Conclui a condição verificada.
    return Carta(codigo, dados['imagem'] as String? ?? ''); // Cria a carta validada, usando imagem vazia se ela estiver ausente.
  } // Conclui os dados da carta.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// CONTAGEM DE PONTOS E AJUSTE DOS ASES
// Soma os valores da mão e começa contando cada Ás como 11.
// Se passar de 21, reduz ases para 1 até evitar o estouro ou acabar os ases.
// --------------------------------------------------------------------------
({int pontos, bool suave}) pontuar(List<Carta> cartas) { // Define o cálculo que devolve pontos e informa se há um Ás valendo 11.
  var total = 0; // Inicia a soma de pontos em zero.
  var ases = 0; // Inicia em zero a contagem de ases ainda tratados como 11.
  for (final carta in cartas) { // Examina uma carta de cada vez até percorrer a mão inteira.
    total += carta.pontos; // Acrescenta à soma os pontos desta carta.
    if (carta.valor == 'A') ases++; // Conta mais um Ás quando a carta examinada é um Ás.
  } // Conclui a repetição dos itens.
  while (total > 21 && ases > 0) { // Repete o ajuste enquanto houver estouro e um Ás ainda valendo 11.
    total -= 10; // Reduz a soma em dez, fazendo um Ás passar de 11 para 1.
    ases--; // Retira esse Ás da contagem dos que ainda valem 11.
  } // Conclui a repetição enquanto a condição valer.
  return (pontos: total, suave: ases > 0); // Devolve a soma e informa se sobrou algum Ás valendo 11.
} // Conclui o bloco contagem de pontos e ajuste dos ases.

// --------------------------------------------------------------------------
// BLACKJACK NATURAL
// Um natural exige exatamente duas cartas cuja soma seja 21.
// Chegar a 21 com mais cartas é uma mão válida, mas não é um natural.
// --------------------------------------------------------------------------
bool natural(List<Carta> cartas) => // Define a verificação de Blackjack natural.
    cartas.length == 2 && pontuar(cartas).pontos == 21; // Só confirma natural quando existem duas cartas e exatamente 21 pontos.

// --------------------------------------------------------------------------
// DECISÃO AUTOMÁTICA DA BANCA
// A banca compra abaixo de 17 pontos.
// Com 17 e um Ás valendo 11, a configuração da mesa decide se ela compra.
// --------------------------------------------------------------------------
bool bancaCompra(List<Carta> cartas, bool paraNo17Suave) { // Define se a regra exige mais uma carta para a banca.
  final mao = pontuar(cartas); // Calcula pontos e presença de Ás valendo 11 nessa mão.
  return mao.pontos < 17 || (mao.pontos == 17 && mao.suave && !paraNo17Suave); // Compra abaixo de 17 ou no 17 suave quando a mesa usa essa opção.
} // Conclui o bloco decisão automática da banca.

// --------------------------------------------------------------------------
// RESULTADO DA RODADA
// Compara as mãos em uma ordem que respeita estouros, naturais e empates.
// Devolve um título e uma explicação para a tela, sem consultar a internet.
// --------------------------------------------------------------------------
({String titulo, String detalhe}) resultado( // Define o cálculo que devolve o título e a explicação do resultado.
  List<Carta> jogador, // Recebe as cartas do jogador para comparar.
  List<Carta> banca, // Recebe as cartas da banca para comparar.
) { // Termina a declaração ou condição e começa as instruções deste bloco.
  final seusPontos = pontuar(jogador).pontos; // Calcula o total final de pontos do jogador.
  final pontosBanca = pontuar(banca).pontos; // Calcula o total final de pontos da banca.
  if (seusPontos > 21) { // Verifica primeiro se o jogador estourou, o que encerra sua chance.
    return ( // Começa o conjunto de informações devolvido pela função.
      titulo: 'Você passou de 21', // Define a frase principal desta mensagem.
      detalhe: '$seusPontos pontos. A banca venceu a rodada.', // Define a explicação que acompanha esta mensagem.
    ); // Conclui os valores devolvidos pela função.
  } // Conclui a condição verificada.
  if (natural(jogador) && natural(banca)) { // Verifica se os dois lados receberam Blackjack natural.
    return ( // Começa o conjunto de informações devolvido pela função.
      titulo: 'Empate', // Define a frase principal desta mensagem.
      detalhe: 'Dois Blackjacks naturais. Uma nova chance vem aí.', // Define a explicação que acompanha esta mensagem.
    ); // Conclui os valores devolvidos pela função.
  } // Conclui a condição verificada.
  if (natural(banca)) { // Verifica se a banca tem natural depois de descartar o empate de naturais.
    return ( // Começa o conjunto de informações devolvido pela função.
      titulo: 'Blackjack da banca', // Define a frase principal desta mensagem.
      detalhe: 'A banca fez 21 com duas cartas.', // Define a explicação que acompanha esta mensagem.
    ); // Conclui os valores devolvidos pela função.
  } // Conclui a condição verificada.
  if (natural(jogador)) { // Verifica se o jogador tem natural depois de descartar um natural da banca.
    return ( // Começa o conjunto de informações devolvido pela função.
      titulo: 'Blackjack!', // Define a frase principal desta mensagem.
      detalhe: 'Um Ás e uma carta de valor 10. Uma mão perfeita.', // Define a explicação que acompanha esta mensagem.
    ); // Conclui os valores devolvidos pela função.
  } // Conclui a condição verificada.
  if (pontosBanca > 21) { // Verifica se a banca estourou enquanto o jogador permaneceu válido.
    return (titulo: 'Você venceu', detalhe: 'A banca passou de 21.'); // Declara a vitória do jogador causada pelo estouro da banca.
  } // Conclui a condição verificada.
  if (seusPontos == pontosBanca) { // Verifica se as duas mãos válidas terminaram com o mesmo total.
    return ( // Começa o conjunto de informações devolvido pela função.
      titulo: 'Empate', // Define a frase principal desta mensagem.
      detalhe: '$seusPontos a $pontosBanca. Uma nova chance vem aí.', // Define a explicação que acompanha esta mensagem.
    ); // Conclui os valores devolvidos pela função.
  } // Conclui a condição verificada.
  return ( // Começa o conjunto de informações devolvido pela função.
    titulo: seusPontos > pontosBanca ? 'Você venceu' : 'A banca venceu', // Define a frase principal desta mensagem.
    detalhe: 'Você: $seusPontos · Banca: $pontosBanca', // Define a explicação que acompanha esta mensagem.
  ); // Conclui os valores devolvidos pela função.
} // Conclui o bloco resultado da rodada.

// --------------------------------------------------------------------------
// PREFERÊNCIAS DO JOGADOR
// Guarda quantidade de baralhos, regra da banca, som, vibração e tema.
// Também converte essas escolhas para salvar e recuperar no dispositivo.
// --------------------------------------------------------------------------
class Preferencias { // Agrupa as escolhas do jogador que podem ser salvas.
  Preferencias({ // Começa a criação das preferências com valores padrão.
    this.baralhos = 6, // Usa seis baralhos quando nenhuma quantidade é informada.
    this.paraNo17Suave = true, // Faz a banca parar no 17 suave por padrão.
    this.som = true, // Deixa o som habilitado por padrão.
    this.vibracao = true, // Deixa a vibração habilitada por padrão.
    this.escuro = true, // Seleciona o tema escuro por padrão.
  }); // Conclui as preferências do jogo.
  int baralhos; // Guarda a quantidade de baralhos escolhida.
  bool paraNo17Suave, som, vibracao, escuro; // Guarda as quatro escolhas que podem estar ligadas ou desligadas.

  // --------------------------------------------------------------------------
  // PREPARAR OS DADOS PARA SALVAMENTO
  // Converte os campos deste objeto em um mapa: nomes associados a valores.
  // Cartas e datas também precisam ser convertidas para caber no texto salvo.
  // --------------------------------------------------------------------------
  Map<String, dynamic> salvar() => { // Devolve um mapa de campos simples para o salvamento deste objeto.
    'baralhos': baralhos, // Salva a quantidade de baralhos.
    'paraNo17Suave': paraNo17Suave, // Salva a regra de parada da banca no 17 suave.
    'som': som, // Salva a escolha de reproduzir som.
    'vibracao': vibracao, // Salva a escolha de usar vibração.
    'escuro': escuro, // Salva a escolha do tema escuro ou claro.
  }; // Conclui o bloco preparar os dados para salvamento.
  factory Preferencias.ler(Map<String, dynamic> dados) => Preferencias( // Recupera as preferências a partir dos campos guardados.
    baralhos: (dados['baralhos'] as int? ?? 6).clamp(1, 6), // Recupera a quantidade, usa seis na ausência e limita entre um e seis.
    paraNo17Suave: dados['paraNo17Suave'] as bool? ?? true, // Recupera a regra da banca ou mantém a parada no 17 suave como padrão.
    som: dados['som'] as bool? ?? true, // Recupera o som ou o deixa ligado quando o campo está ausente.
    vibracao: dados['vibracao'] as bool? ?? true, // Recupera a vibração ou a deixa ligada quando o campo está ausente.
    escuro: dados['escuro'] as bool? ?? true, // Recupera o tema ou escolhe escuro quando o campo está ausente.
  ); // Conclui as preferências do jogo.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// DADOS DA MESA EM ANDAMENTO
// Reúne as mãos, as regras desta mesa, as cartas restantes e a fase atual.
// As regras copiadas na criação permanecem fixas até uma nova mesa.
// --------------------------------------------------------------------------
class Mesa { // Define os dados necessários para jogar e retomar uma mesa.
  Mesa({ // Começa a criação de uma mesa com informações obrigatórias.
    required this.identificador, // Exige o identificador do baralho fornecido pela API.
    required this.restantes, // Exige a quantidade de cartas ainda disponíveis.
    required this.baralhos, // Exige a quantidade de baralhos usada nesta mesa.
    required this.paraNo17Suave, // Exige a regra de parada escolhida para esta mesa.
  }); // Conclui os dados da mesa.
  final String identificador; // Mantém fixo o identificador remoto desta mesa.
  final int baralhos; // Mantém fixa a quantidade de baralhos desta mesa.
  final bool paraNo17Suave; // Mantém fixa a regra da banca até criar outra mesa.
  int restantes, rodada = 0; // Guarda cartas restantes e inicia o contador de rodadas em zero.
  List<Carta> jogador = [], banca = []; // Cria as duas mãos inicialmente sem cartas.
  Fase fase = Fase.jogador; // Define a vez do jogador como fase inicial.
  DateTime ultimaJogada = DateTime.now(); // Registra o horário inicial, depois atualizado a cada compra válida.
  bool get renovar => restantes <= baralhos * 52 / 4 || restantes < 4; // Pede renovação com 25% ou menos do total, ou menos de quatro cartas.

  // --------------------------------------------------------------------------
  // PREPARAR OS DADOS PARA SALVAMENTO
  // Converte os campos deste objeto em um mapa: nomes associados a valores.
  // Cartas e datas também precisam ser convertidas para caber no texto salvo.
  // --------------------------------------------------------------------------
  Map<String, dynamic> salvar() => { // Devolve um mapa de campos simples para o salvamento deste objeto.
    'identificador': identificador, // Salva a referência ao mesmo baralho remoto.
    'restantes': restantes, // Salva a quantidade disponível para próximas compras.
    'baralhos': baralhos, // Salva a quantidade de baralhos.
    'paraNo17Suave': paraNo17Suave, // Salva a regra de parada da banca no 17 suave.
    'rodada': rodada, // Salva o número da rodada atual.
    'fase': fase.name, // Salva o nome da etapa atual em forma de texto.
    'jogador': jogador.map((carta) => carta.salvar()).toList(), // Converte e salva cada carta da mão do jogador.
    'banca': banca.map((carta) => carta.salvar()).toList(), // Converte e salva cada carta da mão da banca.
    'ultimaJogada': ultimaJogada.toIso8601String(), // Salva o horário da última compra num formato de texto padronizado.
  }; // Conclui o bloco preparar os dados para salvamento.

  // --------------------------------------------------------------------------
  // RECUPERAR E CONFERIR A MESA SALVA
  // Reconstrói a mesa usando os campos recuperados do dispositivo.
  // Rejeita dados incompletos ou uma vez da banca interrompida, evitando uma retomada incorreta.
  // --------------------------------------------------------------------------
  factory Mesa.ler(Map<String, dynamic> dados) { // Define a reconstrução e a validação de uma mesa salva.
    final mesa = Mesa( // Cria a mesa que receberá os campos recuperados.
      identificador: dados['identificador'] as String, // Recupera o identificador exigindo um texto.
      restantes: dados['restantes'] as int, // Recupera a contagem exigindo um número inteiro.
      baralhos: dados['baralhos'] as int, // Recupera a quantidade de baralhos como inteiro.
      paraNo17Suave: dados['paraNo17Suave'] as bool, // Recupera a regra de parada como verdadeiro ou falso.
    ); // Conclui os dados da mesa.
    mesa.rodada = dados['rodada'] as int; // Restaura o contador de rodadas.
    mesa.fase = Fase.values.byName(dados['fase'] as String); // Converte o nome salvo para uma das fases permitidas.
    mesa.jogador = (dados['jogador'] as List) // Inicia a recuperação da lista de cartas do jogador.
        .map((carta) => Carta.ler(Map<String, dynamic>.from(carta))) // Reconstrói e valida cada carta a partir dos campos salvos.
        .toList(); // Reúne os resultados convertidos em uma lista utilizável.
    mesa.banca = (dados['banca'] as List) // Inicia a recuperação da lista de cartas da banca.
        .map((carta) => Carta.ler(Map<String, dynamic>.from(carta))) // Reconstrói e valida cada carta a partir dos campos salvos.
        .toList(); // Reúne os resultados convertidos em uma lista utilizável.
    mesa.ultimaJogada = DateTime.parse(dados['ultimaJogada'] as String); // Converte a data em texto para um horário que pode ser comparado.
    if (mesa.identificador.isEmpty || // Começa a rejeição dos dados se o identificador estiver vazio.
        mesa.baralhos < 1 || // Também rejeita menos de um baralho.
        mesa.baralhos > 6 || // Também rejeita mais de seis baralhos.
        mesa.restantes < 0 || // Também rejeita uma quantidade negativa de cartas restantes.
        mesa.restantes > mesa.baralhos * 52 || // Também rejeita mais cartas restantes que o total original.
        mesa.rodada < 1 || // Também rejeita uma mesa salva sem rodada iniciada.
        mesa.jogador.length < 2 || // Também rejeita uma mão do jogador sem as duas cartas iniciais.
        mesa.banca.length < 2 || // Também rejeita uma mão da banca sem as duas cartas iniciais.
        mesa.fase == Fase.banca) { // Também rejeita uma vez da banca interrompida no meio da execução.
      throw const FormatException('Partida salva inválida.'); // Impede restaurar uma mesa que não passou nas verificações.
    } // Conclui a condição verificada.
    return mesa; // Entrega a mesa restaurada e validada.
  } // Conclui os dados da mesa.
} // Conclui a definição desta classe.
