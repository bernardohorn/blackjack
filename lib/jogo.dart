// dart format off
// Mantém as explicações ao lado das linhas durante a formatação automática.

// --------------------------------------------------------------------------
// BIBLIOTECAS DO CONTROLE DO JOGO
// Este arquivo liga as regras, as consultas à internet e o salvamento local.
// A interface pede ações ao controlador e recebe avisos quando algo muda.
// --------------------------------------------------------------------------
import 'dart:convert'; // Disponibiliza a conversão entre texto JSON e dados do programa.

import 'package:flutter/foundation.dart'; // Disponibiliza o mecanismo que avisa as telas sobre mudanças.
import 'package:shared_preferences/shared_preferences.dart'; // Disponibiliza o armazenamento local de preferências e partida.

import 'api.dart'; // Permite usar o cliente da API de cartas.
import 'regras.dart'; // Permite usar cartas, mesas, preferências e regras deste projeto.

// --------------------------------------------------------------------------
// CONTRATO DE ARMAZENAMENTO
// Define apenas o que é necessário para ler e salvar um texto.
// Os testes podem cumprir esse contrato em memória, sem usar o aparelho.
// --------------------------------------------------------------------------
abstract class Armazenamento { // Define as operações que qualquer forma de armazenamento precisa oferecer.
  Future<String?> ler(); // Exige uma leitura que pode devolver texto salvo ou nada, após uma espera.
  Future<void> salvar(String conteudo); // Exige uma gravação de texto que informa quando terminou.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// SALVAMENTO NO DISPOSITIVO
// Guarda preferências e mesa juntas em uma única entrada chamada clube21.
// O plugin cuida do armazenamento apropriado ao sistema ou ao navegador.
// --------------------------------------------------------------------------
class MemoriaLocal implements Armazenamento { // Implementa a leitura e a gravação usando o armazenamento do dispositivo.
  final _preferencias = SharedPreferencesAsync(); // Cria o acesso ao plugin de preferências locais.
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  Future<String?> ler() => _preferencias.getString('clube21'); // Lê o texto guardado na entrada clube21.
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  Future<void> salvar(String conteudo) => // Define a gravação do texto fornecido.
      _preferencias.setString('clube21', conteudo); // Guarda o texto na mesma entrada usada pela leitura.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// ESTADO E DEPENDÊNCIAS DO JOGO
// Reúne a mesa atual, as preferências e os indicadores de andamento ou erro.
// ChangeNotifier permite avisar as telas quando esses dados mudam.
// --------------------------------------------------------------------------
class Jogo extends ChangeNotifier { // Define o controlador capaz de avisar as telas sobre mudanças no jogo.
  Jogo( // Começa a criação do controlador e a definição de suas dependências.
    this.api, // Recebe o componente que conversa com o serviço de cartas.
    this.armazenamento, { // Recebe onde salvar e abre a lista de opções adicionais.
    this.pausaVisual = const Duration(milliseconds: 650), // Usa uma pausa de 0,65 segundo para tornar as etapas visíveis.
  }); // Conclui o bloco estado e dependências do jogo.
  final Duration pausaVisual; // Guarda a duração das pausas de apresentação.
  final ApiBaralho api; // Guarda a API que será usada nas compras e criações.
  final Armazenamento armazenamento; // Guarda o mecanismo escolhido para ler e salvar a partida.
  Preferencias preferencias = Preferencias(); // Começa com as escolhas padrão até recuperar ou alterar as preferências.
  Mesa? mesa; // Guarda a mesa atual; o ponto de interrogação permite não haver mesa.
  bool ocupado = false, iniciando = true, compraIncerta = false; // Começa livre, em carregamento inicial e sem compra incerta.
  bool renovando = false, falhaLocal = false; // Começa sem renovação em andamento nem falha de armazenamento.
  String corte = ''; // Reserva o texto que mostrará a contagem no corte do shoe.
  String? erro, aviso; // Guarda mensagens opcionais de erro e de aviso.
  String andamento = 'Preparando sua mesa…'; // Define a mensagem inicial de preparação.

  // --------------------------------------------------------------------------
  // PREPARAÇÃO DO SALVAMENTO
  // Converte preferências, mesa e uma marca de operação pendente em texto JSON.
  // A marca impede recuperar uma mão antiga se o app fechar durante uma compra.
  // --------------------------------------------------------------------------
  Future<void> _salvar({bool pendente = false}) => armazenamento.salvar( // Salva o estado, marcando como pendente somente quando solicitado.
    jsonEncode({ // Converte os campos seguintes em um único texto JSON.
      'versao': 1, // Identifica o formato salvo para impedir leituras incompatíveis.
      'preferencias': preferencias.salvar(), // Inclui as preferências convertidas para campos simples.
      'mesa': mesa?.salvar(), // Inclui a mesa convertida ou nada se não houver partida.
      'pendente': pendente, // Registra se há uma operação ainda sem conclusão confirmada.
    }), // Conclui a conversão dos dados em texto JSON.
  ); // Conclui o bloco preparação do salvamento.

  // --------------------------------------------------------------------------
  // RECUPERAÇÃO AO ABRIR O APLICATIVO
  // Lê os dados locais e recupera apenas uma mesa válida e ainda recente.
  // Dados ruins ou operações interrompidas geram aviso, mas o menu continua abrindo.
  // --------------------------------------------------------------------------
  Future<void> carregar() async { // Define a leitura inicial da partida e das preferências.
    final abertura = Future<void>.delayed(pausaVisual); // Inicia a pequena espera que mantém a abertura visível.
    mesa = null; // Retira a referência à mesa, deixando o controlador sem partida retomável.
    aviso = null; // Limpa qualquer aviso anterior.
    try { // Inicia uma tentativa cuja falha será tratada logo abaixo.
      final texto = await armazenamento.ler(); // Aguarda a leitura do conteúdo salvo no dispositivo.
      if (texto != null) { // Só tenta recuperar campos quando existe um texto salvo.
        final dados = jsonDecode(texto) as Map<String, dynamic>; // Converte o texto salvo para um conjunto de campos nomeados.
        if (dados['versao'] != 1) throw const FormatException(); // Rejeita um formato de salvamento desconhecido.
        preferencias = Preferencias.ler(dados['preferencias']); // Restaura as escolhas guardadas do jogador.
        if (dados['pendente'] == true) { // Detecta que o app fechou antes de confirmar a última operação.
          aviso = 'A última operação foi interrompida. Inicie uma nova mesa.'; // Explica por que a partida interrompida não será recuperada.
        } else if (dados['mesa'] != null) { // Sem operação pendente, tenta recuperar a mesa que estiver salva.
          mesa = Mesa.ler(dados['mesa']); // Reconstrói a mesa e confere a validade de seus campos.
          if (DateTime.now().difference(mesa!.ultimaJogada).inDays >= 14) { // Verifica se passaram pelo menos quatorze dias sem comprar cartas.
            mesa = null; // Retira a referência à mesa, deixando o controlador sem partida retomável.
            aviso = 'A mesa salva expirou. Comece um novo jogo.'; // Informa que a mesa antiga não será retomada por expiração.
          } // Conclui a condição verificada.
        } // Conclui a condição verificada.
      } // Conclui a condição verificada.
    } catch (_) { // Trata a falha sem precisar guardar seus detalhes técnicos.
      mesa = null; // Retira a referência à mesa, deixando o controlador sem partida retomável.
      aviso = 'Não foi possível recuperar a partida salva.'; // Mostra um aviso quando a leitura ou validação local falha.
    } // Conclui o tratamento da falha.
    await abertura; // Aguarda o restante da breve apresentação inicial.
    iniciando = false; // Indica que a abertura terminou e o menu pode aparecer.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
  } // Conclui o bloco recuperação ao abrir o aplicativo.

  // --------------------------------------------------------------------------
  // EXECUÇÃO PROTEGIDA DE UMA JOGADA
  // Bloqueia ações simultâneas e salva antes e depois de realizar a operação.
  // Em caso de falha, informa o problema e evita retomar uma mesa desatualizada.
  // --------------------------------------------------------------------------
  Future<void> _executar(Future<void> Function() acao) async { // Recebe uma ação que pode demorar e a executa com proteção de salvamento.
    if (ocupado) return; // Ignora a solicitação se outra operação já estiver em andamento.
    ocupado = true; // Bloqueia novas ações enquanto esta operação é executada.
    erro = null; // Remove a mensagem de erro anterior.
    compraIncerta = false; // Começa esta operação sem indicar uma compra enviada à API.
    falhaLocal = false; // Limpa o indicador de problema no armazenamento local.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
    var iniciou = false; // Registra que a ação ainda não passou da gravação inicial.
    var salvando = true; // Indica que a próxima etapa é uma gravação no dispositivo.
    try { // Inicia uma tentativa cuja falha será tratada logo abaixo.
      await _salvar(pendente: true); // Grava a marca de pendência antes de alterar o baralho remoto.
      iniciou = true; // Confirma que a gravação inicial funcionou e a ação pode começar.
      salvando = false; // Indica que a execução saiu da etapa de armazenamento.
      await acao(); // Aguarda a ação recebida, incluindo suas compras ou mudanças de fase.
      salvando = true; // Marca que a etapa seguinte volta a ser a gravação local.
      await _salvar(); // Aguarda o salvamento do estado atual sem a marca de pendência.
    } catch (_) { // Trata a falha sem precisar guardar seus detalhes técnicos.
      falhaLocal = salvando; // Identifica se a falha ocorreu durante uma gravação local.
      if (!iniciou) { // Distingue a falha anterior ao envio de qualquer ação remota.
        erro = 'Não foi possível salvar no dispositivo. Libere espaço e tente novamente.'; // Informa que não foi possível iniciar por um problema de salvamento.
      } else { // Executa a alternativa quando a condição anterior não é atendida.
        mesa = null; // Retira a referência à mesa, deixando o controlador sem partida retomável.
        erro = salvando // Escolhe a mensagem de erro conforme a etapa em que ocorreu a falha.
            ? 'Não foi possível salvar a última jogada. A mesa foi encerrada para não recuperar cartas desatualizadas.' // Explica o encerramento causado pela falha ao guardar a jogada concluída.
            : compraIncerta // Se não foi na gravação, verifica se uma compra já havia sido iniciada.
            ? 'Não sabemos se a última compra foi concluída. Reinicie a mesa com um novo baralho.' // Explica que repetir a compra seria inseguro porque ela pode ter ocorrido.
            : 'Confira sua conexão e tente novamente. Não foi possível preparar a mesa.'; // Usa a mensagem de falha na preparação quando nenhuma compra foi enviada.
        try { // Inicia uma tentativa cuja falha será tratada logo abaixo.
          await _salvar(); // Aguarda o salvamento do estado atual sem a marca de pendência.
        } catch (_) { // Trata a falha sem precisar guardar seus detalhes técnicos.
          /* A marca pendente já protege a próxima abertura. */
        } // Conclui o tratamento da falha.
      } // Conclui a condição verificada.
    } finally { // Inicia a finalização que acontece tanto no sucesso quanto na falha.
      ocupado = false; // Libera o controlador para receber outra ação.
      renovando = false; // Desliga o indicador de renovação do shoe.
      notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
    } // Conclui a finalização executada mesmo após uma falha.
  } // Conclui a ação protegida por salvamento.

  // --------------------------------------------------------------------------
  // INÍCIO DE UMA NOVA PARTIDA
  // Limpa a referência da mesa anterior e solicita um novo shoe à API.
  // Depois distribui as quatro primeiras cartas dentro da mesma operação protegida.
  // --------------------------------------------------------------------------
  Future<void> novoJogo() => _executar(() async { // Inicia uma nova partida dentro da operação protegida.
    aviso = null; // Limpa qualquer aviso anterior.
    renovando = false; // Desliga o indicador de renovação do shoe.
    andamento = 'Embaralhando a sorte…'; // Atualiza a mensagem para a etapa de criação do baralho.
    mesa = null; // Retira a referência à mesa, deixando o controlador sem partida retomável.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
    mesa = await api.criar(preferencias); // Aguarda um shoe novo e cria a mesa com as preferências atuais.
    await _distribuir(); // Aguarda a distribuição das quatro cartas iniciais.
  }); // Conclui a ação protegida por salvamento.

  // --------------------------------------------------------------------------
  // PRÓXIMA RODADA E RENOVAÇÃO DO SHOE
  // Uma nova rodada só começa depois de concluir a atual.
  // No corte de 25% ou com menos de quatro cartas, cria outro shoe antes de distribuir.
  // --------------------------------------------------------------------------
  Future<void> novaRodada() async { // Define a ação de começar outra rodada após o resultado.
    if (mesa?.fase != Fase.concluida || ocupado) return; // Só continua se a rodada terminou e nenhuma operação está em andamento.
    await _executar(() async { // Aguarda uma operação protegida que executará o bloco seguinte.
      if (mesa!.renovar) { // Verifica se a mesa atingiu o limite para trocar o shoe.
        renovando = true; // Ativa a apresentação específica de renovação.
        corte = '${mesa!.restantes} / ${mesa!.baralhos * 52} cartas'; // Guarda a contagem antiga e o total original para explicar o corte.
        andamento = 'Renovando a mesa…'; // Atualiza a mensagem para a troca do conjunto de baralhos.
        mesa = null; // Retira a referência à mesa, deixando o controlador sem partida retomável.
        notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
        mesa = await api.criar(preferencias); // Aguarda um shoe novo e cria a mesa com as preferências atuais.
      } // Conclui a condição verificada.
      await _distribuir(); // Aguarda a distribuição das quatro cartas iniciais.
    }); // Conclui a ação protegida por salvamento.
  } // Conclui o bloco próxima rodada e renovação do shoe.

  // --------------------------------------------------------------------------
  // DISTRIBUIÇÃO INICIAL DAS CARTAS
  // Compra quatro cartas e alterna jogador, banca, jogador e banca.
  // Verifica naturais logo nessa distribuição para evitar compras desnecessárias.
  // --------------------------------------------------------------------------
  Future<void> _distribuir() async { // Define a distribuição inicial de uma rodada.
    mesa!.jogador = []; // Esvazia a mão local do jogador para receber a nova distribuição.
    mesa!.banca = []; // Esvazia a mão local da banca para receber a nova distribuição.
    andamento = 'Distribuindo cartas…'; // Indica que as mãos estão sendo preparadas.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
    final cartas = await _comprar(4); // Compra quatro cartas juntas e aguarda a resposta validada.
    mesa!.jogador = [cartas[0], cartas[2]]; // Entrega ao jogador a primeira e a terceira cartas recebidas.
    mesa!.banca = [cartas[1], cartas[3]]; // Entrega à banca a segunda e a quarta cartas recebidas.
    mesa!.rodada++; // Soma uma unidade ao número da rodada.
    mesa!.fase = natural(mesa!.jogador) || natural(mesa!.banca) // Verifica se algum dos lados recebeu um natural nas duas cartas iniciais.
        ? Fase.concluida // Se houver natural, encerra a rodada imediatamente.
        : Fase.jogador; // Caso contrário, permite que o jogador escolha sua ação.
  } // Conclui o bloco distribuição inicial das cartas.

  // --------------------------------------------------------------------------
  // COMPRA E ATUALIZAÇÃO DA CONTAGEM
  // Marca a possibilidade de compra incerta antes de enviar o pedido.
  // Após a resposta válida, atualiza a contagem e o horário da última compra.
  // --------------------------------------------------------------------------
  Future<List<Carta>> _comprar(int quantidade) async { // Define uma compra e a atualização dos dados da mesa.
    compraIncerta = true; // Marca a possibilidade de o servidor consumir cartas antes da confirmação local.
    final compra = await api.comprar(mesa!, quantidade); // Aguarda a compra e as validações feitas pelo cliente da API.
    mesa!.restantes = compra.restantes; // Atualiza a contagem usando o número confirmado pelo serviço.
    mesa!.ultimaJogada = DateTime.now(); // Registra o horário desta compra confirmada.
    return compra.cartas; // Entrega as cartas para quem vai distribuí-las ou acrescentá-las à mão.
  } // Conclui o bloco compra e atualização da contagem.

  // --------------------------------------------------------------------------
  // JOGADOR PEDE UMA CARTA
  // Compra uma carta somente na vez do jogador e sem outra ação em andamento.
  // Estourar encerra a rodada; chegar a 21 entrega automaticamente a vez à banca.
  // --------------------------------------------------------------------------
  Future<void> pedirCarta() async { // Define o comando para o jogador receber mais uma carta.
    if (mesa?.fase != Fase.jogador || ocupado || erro != null) return; // Impede jogar fora do turno, durante outra ação ou enquanto há erro.
    await _executar(() async { // Aguarda uma operação protegida que executará o bloco seguinte.
      mesa!.jogador.addAll(await _comprar(1)); // Compra uma carta e a acrescenta à mão do jogador.
      final pontos = pontuar(mesa!.jogador).pontos; // Calcula o total da mão depois da nova carta.
      if (pontos > 21) mesa!.fase = Fase.concluida; // Encerra imediatamente a rodada se o jogador estourou.
      if (pontos == 21) await _jogarBanca(); // Passa automaticamente à banca se o jogador chegou a 21.
    }); // Conclui a ação protegida por salvamento.
  } // Conclui o bloco jogador pede uma carta.

  // --------------------------------------------------------------------------
  // JOGADOR ENCERRA SUA VEZ
  // Mantém as cartas do jogador e entrega o turno à banca.
  // Usa a mesma proteção de salvamento das outras ações.
  // --------------------------------------------------------------------------
  Future<void> parar() async { // Define a ação de encerrar voluntariamente a vez do jogador.
    if (mesa?.fase != Fase.jogador || ocupado || erro != null) return; // Impede jogar fora do turno, durante outra ação ou enquanto há erro.
    await _executar(_jogarBanca); // Executa o turno da banca com proteção de salvamento.
  } // Conclui o bloco jogador encerra sua vez.

  // --------------------------------------------------------------------------
  // TURNO AUTOMÁTICO DA BANCA
  // Revela a carta já recebida e compra uma por vez enquanto a regra exigir.
  // Uma breve pausa torna cada etapa visível; ao final, encerra a rodada.
  // --------------------------------------------------------------------------
  Future<void> _jogarBanca() async { // Define como a banca joga automaticamente até poder parar.
    mesa!.fase = Fase.banca; // Muda a fase para revelar a mão da banca e bloquear o jogador.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
    await Future<void>.delayed(pausaVisual); // Faz uma pequena pausa para a pessoa perceber esta etapa na tela.
    while (bancaCompra(mesa!.banca, mesa!.paraNo17Suave)) { // Repete a compra enquanto a regra desta mesa exigir outra carta.
      mesa!.banca.addAll(await _comprar(1)); // Compra uma carta e a acrescenta à mão da banca.
      notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
      await Future<void>.delayed(pausaVisual); // Faz uma pequena pausa para a pessoa perceber esta etapa na tela.
    } // Conclui a repetição enquanto a condição valer.
    mesa!.fase = Fase.concluida; // Marca o fim da rodada para a interface mostrar o resultado.
  } // Conclui o bloco turno automático da banca.

  // --------------------------------------------------------------------------
  // ALTERAÇÃO DAS PREFERÊNCIAS
  // Tenta salvar as novas escolhas e atualiza a interface.
  // Se não conseguir gravar, restaura as preferências anteriores e mostra um aviso.
  // --------------------------------------------------------------------------
  Future<void> configurar(Preferencias novas) async { // Define a tentativa de aplicar e salvar novas preferências.
    if (ocupado) return; // Ignora a solicitação se outra operação já estiver em andamento.
    ocupado = true; // Bloqueia novas ações enquanto esta operação é executada.
    final anteriores = preferencias; // Guarda as escolhas antigas para restaurá-las se a gravação falhar.
    preferencias = novas; // Aplica temporariamente as escolhas recebidas.
    aviso = null; // Limpa qualquer aviso anterior.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
    try { // Inicia uma tentativa cuja falha será tratada logo abaixo.
      await _salvar(); // Aguarda o salvamento do estado atual sem a marca de pendência.
    } catch (_) { // Trata a falha sem precisar guardar seus detalhes técnicos.
      preferencias = anteriores; // Desfaz a alteração que não pôde ser salva.
      aviso = 'Não foi possível salvar as configurações.'; // Informa que as preferências antigas foram mantidas.
    } // Conclui o tratamento da falha.
    ocupado = false; // Libera o controlador para receber outra ação.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
  } // Conclui o bloco alteração das preferências.

  // --------------------------------------------------------------------------
  // LIMPEZA DA MENSAGEM DE ERRO
  // Retira a mensagem de erro atual e avisa a interface.
  // Isso não recria uma mesa nem repete uma compra.
  // --------------------------------------------------------------------------
  void limparErro() { // Define a ação que retira a mensagem de erro atual.
    erro = null; // Remove a mensagem de erro anterior.
    notifyListeners(); // Avisa os componentes interessados para atualizarem a apresentação.
  } // Conclui o bloco limpeza da mensagem de erro.

  // --------------------------------------------------------------------------
  // LIBERAÇÃO DA CONEXÃO
  // Fecha o cliente HTTP quando o controlador deixa de ser usado.
  // Depois conclui a limpeza prevista pelo Flutter.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  void dispose() { // Define a limpeza feita quando este objeto deixa de ser usado.
    api.cliente.close(); // Fecha o cliente HTTP e libera suas conexões.
    super.dispose(); // Conclui também a limpeza prevista pela classe-base do Flutter.
  } // Conclui o bloco liberação da conexão.
} // Conclui a definição desta classe.
