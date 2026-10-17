// dart format off
// Mantém as explicações ao lado das linhas durante a formatação automática.

// ========================================================================================
// SUMÁRIO DESTE ARQUIVO - lib/api.dart
// As faixas abaixo incluem a primeira e a última linha da declaração.
// Consulte o nome completo: funções com nomes iguais pertencem a classes diferentes.
// No editor: abra o arquivo indicado e use Ir para linha (Ctrl+G no VS Code).
// As linhas já consideram este sumário. Se editar o arquivo, atualize as referências.
// Guia com links e perguntas rápidas: docs/SUMARIO.md.
// Legenda: construtor cria um objeto; consulta (get) calcula uma informação ao acessá-la.
//
// lib/api.dart - URLs, prazo de espera e validação das respostas da API.
// Início-fim | Função, consulta, classe ou construtor | O que faz
//   57-178  | ApiBaralho [classe] | Define o componente responsável por conversar com o serviço de cartas.
//   58-58   | ApiBaralho() [construtor] | Recebe o cliente HTTP e usa dez segundos como prazo padrão.
//   67-87   | ApiBaralho._consultar() [método] | Monta a URL HTTPS, envia GET e confere a resposta comum.
//   94-106  | ApiBaralho._restantes() [método] | Valida a contagem de cartas recebida da API.
//  113-127  | ApiBaralho.criar() [método] | Cria um shoe embaralhado com a quantidade escolhida de baralhos.
//  134-177  | ApiBaralho.comprar() [método] | Compra cartas e valida ID, quantidade, contagem, valor e naipe.
//
// ENDPOINTS IMPLEMENTADOS (GET) - O APP NÃO POSSUI BACKEND PRÓPRIO
// GET https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=N
// Criar shoe (N de 1 a 6). Implementação: lib/api.dart:113-127; caminho montado na linha 114.
// GET https://deckofcardsapi.com/api/deck/{deck_id}/draw/?count=N
// Comprar cartas: N=4 na distribuição; N=1 nas jogadas. Implementação: lib/api.dart:134-177; caminho montado na linha 141.
//
// ONDE AS AÇÕES USAM ESSES ENDPOINTS
// Novo jogo: lib/jogo.dart:204-212 - Cria shoe e depois distribui.
// Renovar shoe: lib/jogo.dart:219-232 - Cria outro shoe quando atinge o corte.
// Distribuir quatro cartas: lib/jogo.dart:239-251 - draw com count=4.
// Jogador pede carta: lib/jogo.dart:271-279 - draw com count=1, via _comprar.
// Banca compra cartas: lib/jogo.dart:296-306 - draw com count=1 por compra, via _comprar.
// Compra compartilhada: lib/jogo.dart:258-264 - Chama ApiBaralho.comprar e atualiza a mesa.
// Requisição HTTP e prazo: lib/api.dart:67-87 - Uma tentativa GET, com prazo de espera configurado.
// Imagens: usa a URL recebida em images.png (alternativa image); não é endpoint fixo.
// Leitura da URL: lib/api.dart:155; carregamento: lib/telas.dart:1088.
// Menu, pontuação, revelação, pausa e retomada usam dados locais, sem endpoint de cartas.
// ========================================================================================

// --------------------------------------------------------------------------
// BIBLIOTECAS E COMUNICAÇÃO EXTERNA
// Este arquivo é o único que conhece os caminhos e campos da API de cartas.
// As importações disponibilizam conversão de dados, acesso HTTP e regras locais.
// --------------------------------------------------------------------------
import 'dart:convert'; // Disponibiliza a conversão entre texto JSON e dados do programa.

import 'package:http/http.dart' as http; // Disponibiliza consultas pela internet usando o apelido http.

import 'regras.dart'; // Permite usar cartas, mesas, preferências e regras deste projeto.

// --------------------------------------------------------------------------
// CLIENTE DE CARTAS E PRAZO DE ESPERA
// Recebe o cliente das consultas e um prazo de dez segundos por padrão.
// Receber o cliente por fora permite usar respostas simuladas durante os testes.
// --------------------------------------------------------------------------
class ApiBaralho { // Define o componente responsável por conversar com o serviço de cartas.
  ApiBaralho(this.cliente, {this.limite = const Duration(seconds: 10)}); // Recebe o cliente HTTP e usa dez segundos como prazo padrão.
  final http.Client cliente; // Guarda o cliente usado para enviar os pedidos pela internet.
  final Duration limite; // Guarda o tempo máximo de espera de cada pedido.

  // --------------------------------------------------------------------------
  // CONSULTA AO SERVIÇO DE CARTAS
  // Monta o endereço HTTPS, faz uma única tentativa e lê a resposta.
  // Rejeita erro HTTP, conteúdo inválido ou uma resposta sem identificador de baralho.
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>> _consultar( // Define uma consulta que devolverá campos da resposta após a espera.
    String caminho, // Recebe a operação que completa o caminho do endereço.
    Map<String, String> parametros, // Recebe os nomes e valores enviados na consulta.
  ) async { // Começa o corpo da função que pode aguardar outras operações.
    final resposta = await cliente // Aguarda o pedido feito pelo cliente e guarda a resposta.
        .get(Uri.https('deckofcardsapi.com', '/api/deck/$caminho/', parametros)) // Monta a URL segura e envia um pedido GET para essa operação.
        .timeout(limite); // Interrompe a espera com uma falha se ultrapassar o prazo configurado.
    if (resposta.statusCode < 200 || resposta.statusCode >= 300) { // Detecta um código HTTP fora da faixa de sucesso, de 200 a 299.
      throw const FormatException( // Interrompe a operação com uma mensagem de dados ou resposta inválidos.
        'O serviço de cartas não respondeu corretamente.', // Fornece este texto à função ou ao componente que o envolve.
      ); // Conclui a indicação de dados inválidos.
    } // Conclui a condição verificada.
    final dados = jsonDecode(resposta.body); // Converte o texto recebido em dados que o programa consegue consultar.
    if (dados is! Map<String, dynamic> || // Verifica se a resposta deixou de ser um conjunto de campos nomeados.
        dados['success'] != true || // Também considera erro quando o servidor não confirma sucesso.
        dados['deck_id'] is! String || // Também considera erro quando o identificador não é um texto.
        (dados['deck_id'] as String).isEmpty) { // Também rejeita um identificador que seja um texto vazio.
      throw const FormatException('Resposta inválida do serviço de cartas.'); // Sinaliza que a resposta não atende ao contrato esperado.
    } // Conclui a condição verificada.
    return dados; // Entrega os campos conferidos para a função que pediu a consulta.
  } // Conclui o bloco consulta ao serviço de cartas.

  // --------------------------------------------------------------------------
  // CONFERÊNCIA DAS CARTAS RESTANTES
  // Aceita uma contagem inteira enviada como número ou como texto.
  // Não inventa zero quando o campo falta e não aceita números negativos ou fracionários.
  // --------------------------------------------------------------------------
  int _restantes(Map<String, dynamic> dados) { // Define como ler e validar a quantidade de cartas restantes.
    final recebido = dados['remaining']; // Lê o campo de contagem enviado pelo servidor.
    final valor = // Prepara uma variável para guardar o valor escolhido nas próximas linhas.
        recebido is num && // Confere se o conteúdo recebido é um número.
            recebido.isFinite && // Exige um número finito, sem infinito nem valor numérico inválido.
            recebido == recebido.roundToDouble() // Confere que o número não tem parte fracionária.
        ? recebido.toInt() // Se as verificações passarem, converte o número para inteiro.
        : int.tryParse('$recebido'); // Caso contrário, tenta interpretar o conteúdo como texto de um inteiro.
    if (valor == null || valor < 0) { // Rejeita uma conversão impossível ou uma contagem negativa.
      throw const FormatException('Contagem inválida.'); // Interrompe a operação porque não há uma contagem confiável.
    } // Conclui a condição verificada.
    return valor; // Devolve o inteiro validado para quem chamou esta função.
  } // Conclui o bloco conferência das cartas restantes.

  // --------------------------------------------------------------------------
  // CRIAÇÃO DE UM NOVO BARALHO
  // Solicita a quantidade escolhida de baralhos já embaralhados.
  // Só cria a mesa local se o servidor confirmar todas as cartas esperadas.
  // --------------------------------------------------------------------------
  Future<Mesa> criar(Preferencias preferencias) async { // Define a criação de uma mesa a partir das escolhas do jogador.
    final dados = await _consultar('new/shuffle', { // Solicita ao serviço um conjunto novo e embaralhado de cartas.
      'deck_count': '${preferencias.baralhos}', // Envia quantos baralhos devem formar esse conjunto.
    }); // Conclui a consulta ao serviço de cartas.
    final restantes = _restantes(dados); // Obtém a contagem da resposta usando a validação centralizada.
    if (dados['shuffled'] != true || restantes != preferencias.baralhos * 52) { // Exige embaralhamento confirmado e 52 cartas por baralho escolhido.
      throw const FormatException('Baralho incompleto.'); // Impede iniciar uma mesa com quantidade ou embaralhamento incorretos.
    } // Conclui a condição verificada.
    return Mesa( // Começa os dados da mesa.
      identificador: dados['deck_id'], // Guarda na mesa o identificador criado pelo serviço.
      restantes: restantes, // Guarda a quantidade validada de cartas ainda disponíveis.
      baralhos: preferencias.baralhos, // Copia a quantidade de baralhos escolhida para esta mesa.
      paraNo17Suave: preferencias.paraNo17Suave, // Copia a regra de parada da banca para esta mesa.
    ); // Conclui os dados da mesa.
  } // Conclui o bloco criação de um novo baralho.

  // --------------------------------------------------------------------------
  // COMPRA E VALIDAÇÃO DAS CARTAS
  // Pede a quantidade necessária e confere identidade, contagem e cada carta.
  // Devolve tudo junto apenas após a conferência; repetir uma compra pode consumir outras cartas.
  // --------------------------------------------------------------------------
  Future<({List<Carta> cartas, int restantes})> comprar( // Define uma compra que devolverá cartas e contagem restante juntas.
    Mesa mesa, // Recebe a mesa de onde as cartas serão retiradas.
    int quantidade, // Recebe quantas cartas devem ser compradas nesta chamada.
  ) async { // Começa o corpo da função que pode aguardar outras operações.
    if (mesa.restantes < quantidade) { // Impede pedir mais cartas do que a mesa ainda tem.
      throw const FormatException('Faltam cartas nesta mesa.'); // Sinaliza que o shoe não tem cartas suficientes para o pedido.
    } // Conclui a condição verificada.
    final dados = await _consultar('${mesa.identificador}/draw', { // Pede cartas ao baralho identificado na mesa atual.
      'count': '$quantidade', // Envia a quantidade desejada no parâmetro esperado pela API.
    }); // Conclui a consulta ao serviço de cartas.
    final lista = dados['cards']; // Separa a lista de cartas recebidas na resposta.
    final restantes = _restantes(dados); // Obtém a contagem da resposta usando a validação centralizada.
    if (dados['deck_id'] != mesa.identificador || // Rejeita uma resposta que pertença a outro baralho.
        lista is! List || // Também rejeita quando cards não contém uma lista.
        lista.length != quantidade || // Também rejeita uma quantidade de cartas diferente da solicitada.
        restantes != mesa.restantes - quantidade) { // Exige que a contagem tenha diminuído exatamente pelo total comprado.
      throw const FormatException('A compra não pôde ser confirmada.'); // Sinaliza uma compra cuja resposta não pode ser aplicada com segurança.
    } // Conclui a condição verificada.
    final cartas = lista.map((item) { // Percorre os itens recebidos para transformar cada um em uma Carta.
      final carta = Carta.ler({ // Cria e valida uma carta usando os nomes locais dos campos.
        'codigo': item['code'], // Copia o código remoto para o campo local da carta.
        'imagem': item['images']?['png'] ?? item['image'] ?? '', // Prefere a imagem PNG, aceita a alternativa e usa vazio se não houver URL.
      }); // Conclui os dados da carta.
      final valor = // Prepara uma variável para guardar o valor escolhido nas próximas linhas.
          const { // Começa uma tabela fixa de correspondências entre valores.
            'A': 'ACE', // Relaciona o Ás ao nome que a API deve informar.
            'J': 'JACK', // Relaciona o Valete ao nome que a API deve informar.
            'Q': 'QUEEN', // Relaciona a Dama ao nome que a API deve informar.
            'K': 'KING', // Relaciona o Rei ao nome que a API deve informar.
          }[carta.valor] ?? // Procura o valor nessa tabela; se não existir, usa a próxima alternativa.
          carta.valor; // Mantém o próprio número para as cartas numéricas.
      final naipe = const { // Prepara uma tabela para descobrir o nome do naipe.
        'S': 'SPADES', // Relaciona S ao nome de espadas usado pela API.
        'H': 'HEARTS', // Relaciona H ao nome de copas usado pela API.
        'D': 'DIAMONDS', // Relaciona D ao nome de ouros usado pela API.
        'C': 'CLUBS', // Relaciona C ao nome de paus usado pela API.
      }[carta.codigo[1]]; // Consulta o naipe usando a segunda posição do código da carta.
      if (item['value'] != valor || item['suit'] != naipe) { // Confere que valor e naipe recebidos combinam com o código da carta.
        throw const FormatException('Carta inconsistente.'); // Rejeita uma carta cujos campos se contradizem.
      } // Conclui a condição verificada.
      return carta; // Entrega a carta conferida para compor a lista da compra.
    }).toList(); // Termina a transformação e reúne os resultados em uma lista.
    return (cartas: cartas, restantes: restantes); // Devolve as cartas e a contagem como um único resultado confirmado.
  } // Conclui o bloco compra e validação das cartas.
} // Conclui a definição desta classe.
