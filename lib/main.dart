// dart format off
// Mantém as explicações ao lado das linhas durante a formatação automática.

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
