// dart format off
// Mantém as explicações ao lado das linhas durante a formatação automática.

// ========================================================================================
// SUMÁRIO GERAL DO APLICATIVO - GUIA PARA APRESENTAÇÃO
// As faixas abaixo incluem a primeira e a última linha da declaração.
// Consulte o nome completo: funções com nomes iguais pertencem a classes diferentes.
// No editor: abra o arquivo indicado e use Ir para linha (Ctrl+G no VS Code).
// As linhas já consideram este sumário. Se editar o arquivo, atualize as referências.
// Guia com links e perguntas rápidas: docs/SUMARIO.md.
// Legenda: construtor cria um objeto; consulta (get) calcula uma informação ao acessá-la.
//
// MAPA DAS PASTAS E ARQUIVOS
// lib/main.dart - Entrada do app, idioma, tema e ligação dos componentes.
// lib/regras.dart - Cartas, pontos, naturais, resultados e dados salvos.
// lib/api.dart - URLs, prazo de espera e validação das respostas da API.
// lib/jogo.dart - Turnos, compras, renovação, salvamento e recuperação.
// lib/telas.dart - Menu, mesa, configurações, botões, cartas e textura.
// test/ - Testes automatizados; docs/ - Guias, imagens e referências.
//
// lib/main.dart - Entrada do app, idioma, tema e ligação dos componentes.
// Início-fim | Função, consulta, classe ou construtor | O que faz
//  171-174  | main() [função] | Define a primeira função executada ao abrir o aplicativo.
//  181-186  | Clube21 [classe] | Define o componente principal, cujo estado acompanha o ciclo do app.
//  182-182  | Clube21() [construtor] | Recebe o controlador obrigatório e a identificação opcional do componente.
//  185-185  | Clube21.createState() [método] | Cria o objeto que cuidará da abertura, do tema e da limpeza.
//  193-269  | _Clube21State [classe] | Define o estado associado ao componente principal.
//  195-198  | _Clube21State.initState() [método] | Define a preparação executada uma vez quando o estado é criado.
//  206-209  | _Clube21State.dispose() [método] | Define a limpeza feita quando este objeto deixa de ser usado.
//  217-268  | _Clube21State.build() [método] | Define a interface principal que acompanha mudanças no controlador.
//
// lib/regras.dart - Cartas, pontos, naturais, resultados e dados salvos.
// Início-fim | Função, consulta, classe ou construtor | O que faz
//   45-45   | Fase [opções] | Nomeia as três etapas possíveis de uma rodada.
//   52-94   | Carta [classe] | Define quais dados e cálculos pertencem a uma carta.
//   53-53   | Carta() [construtor] | Cria a carta com um código e uma imagem opcional, vazia por padrão.
//   57-57   | Carta.valor [consulta] | Lê o valor na primeira posição e traduz o código 0 para dez.
//   58-59   | Carta.simbolo [consulta] | Define a leitura do símbolo gráfico do naipe.
//   60-60   | Carta.vermelha [consulta] | Marca copas e ouros como cartas vermelhas.
//   61-61   | Carta.pontos [consulta] | Conta Ás como 11, números pelo valor e figuras como 10.
//   68-79   | Carta.descricao [consulta] | Monta o nome completo da carta para leitura em português.
//   86-86   | Carta.salvar() [método] | Converte a carta em dois campos simples para poder salvá-la.
//   87-93   | Carta.ler() [construtor] | Reconstrói uma carta a partir dos campos recebidos.
//  101-113  | pontuar() [função] | Soma a mão e reduz ases de 11 para 1 quando necessário.
//  120-121  | natural() [função] | Reconhece Blackjack natural: duas cartas somando 21.
//  128-131  | bancaCompra() [função] | Decide quando a banca compra, incluindo a regra do 17 suave.
//  138-181  | resultado() [função] | Decide vitória, derrota, empate, natural e estouro.
//  188-218  | Preferencias [classe] | Agrupa as escolhas do jogador que podem ser salvas.
//  189-195  | Preferencias() [construtor] | Começa a criação das preferências com valores padrão.
//  204-210  | Preferencias.salvar() [método] | Devolve um mapa de campos simples para o salvamento deste objeto.
//  211-217  | Preferencias.ler() [construtor] | Recupera as preferências a partir dos campos guardados.
//  225-292  | Mesa [classe] | Define os dados necessários para jogar e retomar uma mesa.
//  226-231  | Mesa() [construtor] | Começa a criação de uma mesa com informações obrigatórias.
//  239-239  | Mesa.renovar [consulta] | Pede renovação com 25% ou menos do total, ou menos de quatro cartas.
//  246-256  | Mesa.salvar() [método] | Devolve um mapa de campos simples para o salvamento deste objeto.
//  263-291  | Mesa.ler() [construtor] | Define a reconstrução e a validação de uma mesa salva.
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
// lib/jogo.dart - Turnos, compras, renovação, salvamento e recuperação.
// Início-fim | Função, consulta, classe ou construtor | O que faz
//   65-68   | Armazenamento [classe] | Define as operações que qualquer forma de armazenamento precisa oferecer.
//   66-66   | Armazenamento.ler() [método] | Exige uma leitura que pode devolver texto salvo ou nada, após uma espera.
//   67-67   | Armazenamento.salvar() [método] | Exige uma gravação de texto que informa quando terminou.
//   75-82   | MemoriaLocal [classe] | Implementa a leitura e a gravação usando o armazenamento do dispositivo.
//   78-78   | MemoriaLocal.ler() [método] | Lê o texto guardado na entrada clube21.
//   80-81   | MemoriaLocal.salvar() [método] | Define a gravação do texto fornecido.
//   89-350  | Jogo [classe] | Define o controlador capaz de avisar as telas sobre mudanças no jogo.
//   90-94   | Jogo() [construtor] | Começa a criação do controlador e a definição de suas dependências.
//  111-118  | Jogo._salvar() [método] | Guarda preferências, mesa e marca de operação pendente.
//  125-152  | Jogo.carregar() [método] | Recupera a partida; rejeita pendência, dados inválidos e expiração.
//  159-197  | Jogo._executar() [método] | Bloqueia ações simultâneas, salva antes/depois e trata falhas.
//  204-212  | Jogo.novoJogo() [método] | Cria outro shoe e distribui as quatro primeiras cartas.
//  219-232  | Jogo.novaRodada() [método] | Continua no shoe ou renova após o corte de 25%.
//  239-251  | Jogo._distribuir() [método] | Compra quatro cartas, alterna as mãos e verifica naturais.
//  258-264  | Jogo._comprar() [método] | Centraliza a compra e atualiza contagem e horário.
//  271-279  | Jogo.pedirCarta() [método] | Compra uma carta; verifica estouro ou passagem automática ao atingir 21.
//  286-289  | Jogo.parar() [método] | Entrega a vez à banca sem mudar a mão do jogador.
//  296-306  | Jogo._jogarBanca() [método] | Revela a mão, compra conforme a regra e encerra a rodada.
//  313-328  | Jogo.configurar() [método] | Define a tentativa de aplicar e salvar novas preferências.
//  335-338  | Jogo.limparErro() [método] | Define a ação que retira a mensagem de erro atual.
//  346-349  | Jogo.dispose() [método] | Define a limpeza feita quando este objeto deixa de ser usado.
//
// lib/telas.dart - Menu, mesa, configurações, botões, cartas e textura.
// Início-fim | Função, consulta, classe ou construtor | O que faz
//   79-79   | Pagina [opções] | Dá um nome a cada página disponível na navegação.
//   86-91   | Telas [classe] | Define a interface que acompanha qual página está aberta.
//   87-87   | Telas() [construtor] | Recebe o controlador e a identificação opcional deste componente.
//   90-90   | Telas.createState() [método] | Cria o estado que guarda a navegação e os efeitos sonoros.
//   98-1018 | _TelasState [classe] | Define os dados e comportamentos locais das páginas.
//  101-101  | _TelasState.jogo [consulta] | Oferece um atalho para o controlador recebido pelo componente.
//  102-102  | _TelasState.dourado [consulta] | Obtém a cor de destaque adequada ao tema atual.
//  103-103  | _TelasState.escuro [consulta] | Consulta se a apresentação deve usar o tema escuro.
//  111-114  | _TelasState.dispose() [método] | Define a limpeza feita quando este objeto deixa de ser usado.
//  121-136  | _TelasState._retorno() [método] | Define os efeitos opcionais produzidos após um toque.
//  143-143  | _TelasState._abrir() [método] | Troca a página escolhida e pede ao Flutter para atualizar a interface.
//  150-191  | _TelasState._confirmar() [método] | Define uma pergunta que devolverá a escolha de confirmar ou não.
//  198-212  | _TelasState._novoJogo() [método] | Define o que a interface faz quando a pessoa pede um novo jogo.
//  219-233  | _TelasState._voltar() [método] | Define o retorno ao menu e a confirmação de pausa.
//  241-293  | _TelasState.build() [método] | Monta a página e controla o comportamento de voltar do sistema.
//  300-335  | _TelasState._cabecalho() [método] | Define o cabeçalho como elementos dispostos lado a lado.
//  342-353  | _TelasState._titulo() [método] | Define um título com texto obrigatório, tamanho padrão e cor opcional.
//  360-368  | _TelasState._legenda() [método] | Define um texto explicativo com aparência padronizada.
//  375-388  | _TelasState._selo() [método] | Define uma pequena caixa arredondada para uma informação curta.
//  395-406  | _TelasState._painel() [método] | Define uma caixa de conteúdo com destaque opcional de derrota.
//  413-460  | _TelasState._botao() [método] | Define a construção de um botão reutilizável.
//  467-496  | _TelasState._marca() [método] | Define o espaço e as cartas decorativas da marca.
//  503-516  | _TelasState._abertura() [método] | Define os elementos mostrados durante a abertura do aplicativo.
//  523-569  | _TelasState._menu() [método] | Define os elementos e ações do menu principal.
//  576-611  | _TelasState._carregando() [método] | Define o conteúdo mostrado enquanto a mesa é preparada.
//  618-648  | _TelasState._erro() [método] | Define as mensagens e ações da página de falha.
//  655-787  | _TelasState._mesa() [método] | Monta as mãos, mensagens, resultado e botões Pedir/Parar/Nova rodada.
//  794-837  | _TelasState._mao() [método] | Define a exibição de uma mão, permitindo ocultar a segunda carta.
//  844-881  | _TelasState._regras() [método] | Define os elementos da página que ensina a jogar.
//  888-892  | _TelasState._configurar() [método] | Recebe uma função que modifica uma preferência na cópia criada aqui.
//  899-914  | _TelasState._opcao() [método] | Define uma preferência apresentada como interruptor de ligar ou desligar.
//  921-1017 | _TelasState._configuracoes() [método] | Define os controles e textos da página de preferências.
// 1025-1144 | CartaVisual [classe] | Define uma carta visual que depende apenas dos dados recebidos.
// 1026-1031 | CartaVisual() [construtor] | Começa a criação do componente visual da carta.
// 1042-1098 | CartaVisual.build() [método] | Escolhe frente/verso, acessibilidade e carregamento da imagem.
// 1105-1143 | CartaVisual._frente() [método] | Define uma frente de carta desenhada com textos e símbolos locais.
// 1151-1201 | _Trama [classe] | Define um desenho personalizado para a textura de mesa e cartas.
// 1152-1152 | _Trama() [construtor] | Recebe a cor e usa malha reta por padrão, com opção de diagonais.
// 1162-1191 | _Trama.paint() [método] | Recebe a área de desenho e suas dimensões para pintar a textura.
// 1199-1200 | _Trama.shouldRepaint() [método] | Define quando é necessário substituir a textura já desenhada.
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
// BIBLIOTECAS E PONTO DE ENTRADA
// As importações dão acesso à interface, ao português e ao cliente de internet.
// Os arquivos locais fornecem a API, o controlador e as telas do aplicativo.
// --------------------------------------------------------------------------
import 'package:flutter/material.dart'; // Disponibiliza os componentes visuais e temas do Flutter.
import 'package:flutter_localizations/flutter_localizations.dart'; // Disponibiliza a tradução dos controles padrão para português.
import 'package:http/http.dart' as http; // Disponibiliza consultas pela internet usando o apelido http.

import 'api.dart'; // Permite usar o cliente da API de cartas.
import 'jogo.dart'; // Permite consultar o estado do jogo e executar suas ações.
import 'telas.dart'; // Permite mostrar as páginas do aplicativo.

// --------------------------------------------------------------------------
// INICIALIZAÇÃO DO APLICATIVO
// Prepara o Flutter e conecta cliente HTTP, API e armazenamento ao controlador.
// Em seguida, entrega o aplicativo ao Flutter para aparecer na tela.
// --------------------------------------------------------------------------
void main() { // Define a primeira função executada ao abrir o aplicativo.
  WidgetsFlutterBinding.ensureInitialized(); // Prepara a ligação do Flutter com os recursos do sistema.
  runApp(Clube21(jogo: Jogo(ApiBaralho(http.Client()), MemoriaLocal()))); // Conecta os componentes e inicia a interface com seu controlador.
} // Conclui o bloco inicialização do aplicativo.

// --------------------------------------------------------------------------
// COMPONENTE PRINCIPAL
// Recebe o controlador do jogo e cria seu estado visual.
// Um componente com estado acompanha abertura, alterações e encerramento.
// --------------------------------------------------------------------------
class Clube21 extends StatefulWidget { // Define o componente principal, cujo estado acompanha o ciclo do app.
  const Clube21({super.key, required this.jogo}); // Recebe o controlador obrigatório e a identificação opcional do componente.
  final Jogo jogo; // Guarda o controlador compartilhado com a interface.
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  State<Clube21> createState() => _Clube21State(); // Cria o objeto que cuidará da abertura, do tema e da limpeza.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// CARREGAMENTO AO ABRIR
// Assim que o componente é criado, solicita a leitura das preferências e da mesa.
// O carregamento ocorre sem bloquear a construção inicial da interface.
// --------------------------------------------------------------------------
class _Clube21State extends State<Clube21> { // Define o estado associado ao componente principal.
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  void initState() { // Define a preparação executada uma vez quando o estado é criado.
    super.initState(); // Executa primeiro a preparação básica prevista pelo Flutter.
    widget.jogo.carregar(); // Solicita a recuperação local da mesa e das preferências.
  } // Conclui o bloco carregamento ao abrir.

  // --------------------------------------------------------------------------
  // ENCERRAMENTO DO APLICATIVO
  // Libera os recursos do controlador quando este componente é removido.
  // Também conclui a limpeza herdada do Flutter.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  void dispose() { // Define a limpeza feita quando este objeto deixa de ser usado.
    widget.jogo.dispose(); // Pede ao controlador para liberar seus recursos.
    super.dispose(); // Conclui também a limpeza prevista pela classe-base do Flutter.
  } // Conclui o bloco encerramento do aplicativo.

  // --------------------------------------------------------------------------
  // IDIOMA, TEMA E TELA INICIAL
  // Reconstrói a apresentação quando o controlador informa uma mudança.
  // Aplica português do Brasil, tema claro ou escuro e padrões de texto e botões.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  Widget build(BuildContext context) => AnimatedBuilder( // Define a interface principal que acompanha mudanças no controlador.
    animation: widget.jogo, // Escolhe o controlador como fonte dos avisos de atualização.
    builder: (context, _) { // Define como reconstruir a interface quando houver uma atualização.
      final escuro = widget.jogo.preferencias.escuro; // Consulta se o jogador escolheu o tema escuro.
      final cores = ColorScheme.fromSeed( // Gera uma paleta de cores consistente a partir de uma cor-base.
        seedColor: const Color(0xFFD8B65D), // Usa dourado como ponto de partida da paleta.
        brightness: escuro ? Brightness.dark : Brightness.light, // Escolhe a luminosidade do tema conforme a preferência.
        primary: escuro ? const Color(0xFFE8C778) : const Color(0xFF765819), // Ajusta a cor principal para ter contraste no tema escolhido.
        surface: escuro ? const Color(0xFF103F33) : const Color(0xFFF6F3E8), // Escolhe o verde escuro ou o fundo claro das superfícies.
      ); // Conclui a paleta de cores.
      return MaterialApp( // Começa o aplicativo Flutter.
        title: 'Clube 21', // Define o nome do aplicativo usado pelo sistema.
        debugShowCheckedModeBanner: false, // Esconde a faixa visual de depuração na interface.
        locale: const Locale('pt', 'BR'), // Define português do Brasil como idioma ativo.
        supportedLocales: const [Locale('pt', 'BR')], // Informa que esta versão oferece português do Brasil.
        localizationsDelegates: GlobalMaterialLocalizations.delegates, // Traduz os controles padrão do Flutter para o idioma selecionado.
        theme: ThemeData( // Começa a configuração visual compartilhada pelo aplicativo.
          useMaterial3: true, // Usa os componentes da terceira versão do padrão visual Material.
          fontFamily: 'Roboto', // Escolhe a fonte usada para desenhar as letras.
          fontFamilyFallback: const ['Naipes'], // Usa a fonte de naipes quando a fonte principal não tiver o símbolo.
          colorScheme: cores, // Aplica a paleta calculada anteriormente.
          scaffoldBackgroundColor: cores.surface, // Usa a cor de superfície como fundo padrão das páginas.
          filledButtonTheme: FilledButtonThemeData( // Define o padrão dos botões preenchidos em todo o aplicativo.
            style: FilledButton.styleFrom( // Começa as opções visuais dos botões preenchidos.
              backgroundColor: const Color(0xFFE8C778), // Define o fundo dourado do botão.
              foregroundColor: const Color(0xFF123C30), // Define o verde escuro do texto e dos ícones do botão.
              minimumSize: const Size(double.infinity, 54), // Pede toda a largura disponível e pelo menos 54 unidades de altura.
              textStyle: const TextStyle( // Começa a definição da aparência das letras dos botões.
                fontFamily: 'Roboto', // Escolhe a fonte usada para desenhar as letras.
                fontWeight: FontWeight.w700, // Define a espessura das letras, como normal ou negrito.
                fontSize: 16, // Define o tamanho das letras deste texto.
              ), // Conclui o estilo das letras.
              shape: RoundedRectangleBorder( // Escolhe um retângulo com cantos arredondados.
                borderRadius: BorderRadius.circular(17), // Arredonda os cantos com o raio indicado.
              ), // Conclui o formato com cantos arredondados.
            ), // Conclui o botão preenchido.
          ), // Conclui o padrão dos botões preenchidos.
          outlinedButtonTheme: OutlinedButtonThemeData( // Define o padrão dos botões desenhados com contorno.
            style: OutlinedButton.styleFrom( // Começa as opções visuais dos botões com contorno.
              minimumSize: const Size(double.infinity, 52), // Pede toda a largura disponível e pelo menos 52 unidades de altura.
              foregroundColor: cores.onSurface, // Usa uma cor de texto adequada ao contraste com o fundo.
              side: BorderSide(color: cores.primary.withValues(alpha: .55)), // Desenha a borda com a cor principal e transparência parcial.
              shape: RoundedRectangleBorder( // Escolhe um retângulo com cantos arredondados.
                borderRadius: BorderRadius.circular(17), // Arredonda os cantos com o raio indicado.
              ), // Conclui o formato com cantos arredondados.
            ), // Conclui o botão com contorno.
          ), // Conclui o padrão dos botões com contorno.
        ), // Conclui o tema do aplicativo.
        home: Telas(jogo: widget.jogo), // Mostra as páginas do jogo usando o mesmo controlador.
      ); // Conclui o aplicativo Flutter.
    }, // Conclui a construção visual deste componente.
  ); // Conclui a atualização da tela quando o jogo muda.
} // Conclui a definição desta classe.
