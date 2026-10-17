// dart format off
// Mantém as explicações ao lado das linhas durante a formatação automática.

// ========================================================================================
// SUMÁRIO DESTE ARQUIVO - lib/telas.dart
// As faixas abaixo incluem a primeira e a última linha da declaração.
// Consulte o nome completo: funções com nomes iguais pertencem a classes diferentes.
// No editor: abra o arquivo indicado e use Ir para linha (Ctrl+G no VS Code).
// As linhas já consideram este sumário. Se editar o arquivo, atualize as referências.
// Guia com links e perguntas rápidas: docs/SUMARIO.md.
// Legenda: construtor cria um objeto; consulta (get) calcula uma informação ao acessá-la.
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
// Imagem remota da carta: lib/telas.dart:1088; a URL vem de images.png ou image.
// Os botões encaminham jogadas a Jogo; as URLs de cartas ficam em lib/api.dart.
// ========================================================================================

// --------------------------------------------------------------------------
// BIBLIOTECAS E PÁGINAS
// Reúne os recursos de interface, som, vibração e tarefas que podem demorar.
// As regras e o acesso às cartas continuam sob responsabilidade do controlador.
// --------------------------------------------------------------------------
import 'dart:async'; // Disponibiliza utilidades para tarefas que terminam mais tarde.

import 'package:audioplayers/audioplayers.dart'; // Disponibiliza o tocador do som de carta.
import 'package:flutter/material.dart'; // Disponibiliza os componentes visuais e temas do Flutter.
import 'package:flutter/services.dart'; // Disponibiliza recursos do dispositivo, como a vibração.

import 'jogo.dart'; // Permite consultar o estado do jogo e executar suas ações.
import 'regras.dart'; // Permite usar cartas, mesas, preferências e regras deste projeto.

// --------------------------------------------------------------------------
// PÁGINAS DISPONÍVEIS
// Define os quatro destinos de navegação dentro do aplicativo.
// Os estados de resultado e erro aparecem dentro dessas páginas, conforme o jogo.
// --------------------------------------------------------------------------
enum Pagina { menu, mesa, regras, configuracoes } // Dá um nome a cada página disponível na navegação.

// --------------------------------------------------------------------------
// COMPONENTE DAS TELAS
// Recebe o controlador que será consultado pelos botões e textos.
// Seu estado guarda a página aberta e o recurso de áudio.
// --------------------------------------------------------------------------
class Telas extends StatefulWidget { // Define a interface que acompanha qual página está aberta.
  const Telas({super.key, required this.jogo}); // Recebe o controlador e a identificação opcional deste componente.
  final Jogo jogo; // Guarda o controlador compartilhado com a interface.
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  State<Telas> createState() => _TelasState(); // Cria o estado que guarda a navegação e os efeitos sonoros.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// ESTADO LOCAL DA INTERFACE
// Começa no menu e oferece atalhos para jogo, tema e cor de destaque.
// Esses dados organizam a apresentação, sem calcular o resultado das rodadas.
// --------------------------------------------------------------------------
class _TelasState extends State<Telas> { // Define os dados e comportamentos locais das páginas.
  Pagina pagina = Pagina.menu; // Escolhe o menu como primeira página.
  AudioPlayer? audio; // Reserva um tocador de áudio, criado somente se for necessário.
  Jogo get jogo => widget.jogo; // Oferece um atalho para o controlador recebido pelo componente.
  Color get dourado => Theme.of(context).colorScheme.primary; // Obtém a cor de destaque adequada ao tema atual.
  bool get escuro => jogo.preferencias.escuro; // Consulta se a apresentação deve usar o tema escuro.

  // --------------------------------------------------------------------------
  // ENCERRAMENTO DO ÁUDIO
  // Libera o tocador de som quando a interface deixa de ser usada.
  // A chamada ao Flutter termina a limpeza do componente.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  void dispose() { // Define a limpeza feita quando este objeto deixa de ser usado.
    audio?.dispose(); // Libera o tocador de áudio se ele chegou a ser criado.
    super.dispose(); // Conclui também a limpeza prevista pela classe-base do Flutter.
  } // Conclui o bloco encerramento do áudio.

  // --------------------------------------------------------------------------
  // SOM E VIBRAÇÃO DE UM TOQUE
  // Executa os efeitos habilitados nas preferências do jogador.
  // A indisponibilidade de um efeito é ignorada para não impedir o jogo.
  // --------------------------------------------------------------------------
  Future<void> _retorno() async { // Define os efeitos opcionais produzidos após um toque.
    if (jogo.preferencias.vibracao) { // Só tenta vibrar quando essa preferência está ligada.
      try { // Inicia uma tentativa cuja falha será tratada logo abaixo.
        await HapticFeedback.lightImpact(); // Solicita uma vibração leve ao dispositivo e aguarda sua conclusão.
      } catch (_) { // Trata a falha sem precisar guardar seus detalhes técnicos.
        /* Sem vibração. */
      } // Conclui o tratamento da falha.
    } // Conclui a condição verificada.
    if (jogo.preferencias.som) { // Só tenta reproduzir áudio quando essa preferência está ligada.
      try { // Inicia uma tentativa cuja falha será tratada logo abaixo.
        await (audio ??= AudioPlayer()).play(AssetSource('sons/carta.wav')); // Cria o tocador se necessário e reproduz o som local da carta.
      } catch (_) { // Trata a falha sem precisar guardar seus detalhes técnicos.
        /* Áudio indisponível neste dispositivo. */
      } // Conclui o tratamento da falha.
    } // Conclui a condição verificada.
  } // Conclui o bloco som e vibração de um toque.

  // --------------------------------------------------------------------------
  // TROCA DE PÁGINA
  // Guarda qual página deve aparecer e solicita uma atualização visual.
  // Essa navegação local não consulta o servidor de cartas.
  // --------------------------------------------------------------------------
  void _abrir(Pagina destino) => setState(() => pagina = destino); // Troca a página escolhida e pede ao Flutter para atualizar a interface.

  // --------------------------------------------------------------------------
  // JANELA DE CONFIRMAÇÃO
  // Mostra uma pergunta antes de pausar ou substituir a partida existente.
  // Devolve verdadeiro somente quando a pessoa escolhe o botão de confirmação.
  // --------------------------------------------------------------------------
  Future<bool> _confirmar( // Define uma pergunta que devolverá a escolha de confirmar ou não.
    String titulo, // Recebe a frase principal da janela de confirmação.
    String texto, // Recebe o texto que será apresentado por este componente.
    String confirmar, // Recebe o rótulo do botão que confirma a ação.
  ) async => // Encerra os parâmetros e inicia a expressão que aguardará a resposta.
      await showDialog<bool>( // Abre uma janela e espera uma resposta verdadeira, falsa ou ausente.
        context: context, // Informa onde esta janela deve aparecer na interface.
        builder: (contexto) => Dialog( // Define o conteúdo visual da janela de confirmação.
          backgroundColor: escuro // Escolhe a cor do fundo conforme o tema atual.
              ? const Color(0xFF194B3D) // Usa fundo verde no tema escuro.
              : const Color(0xFFF7F1E4), // Usa fundo claro na outra opção de tema.
          shape: RoundedRectangleBorder( // Escolhe um retângulo com cantos arredondados.
            borderRadius: BorderRadius.circular(24), // Arredonda os cantos com o raio indicado.
            side: BorderSide(color: dourado.withValues(alpha: .5)), // Desenha uma borda dourada com metade da opacidade.
          ), // Conclui o formato com cantos arredondados.
          child: Padding( // Começa o espaçamento interno.
            padding: const EdgeInsets.all(24), // Aplica a mesma distância interna nos quatro lados.
            child: Column( // Começa a organização dos elementos em coluna.
              mainAxisSize: MainAxisSize.min, // Faz a coluna ocupar apenas a altura necessária ao conteúdo.
              children: [ // Começa a lista de elementos que aparecem neste grupo.
                _titulo(titulo, tamanho: 26), // Mostra o título recebido com tamanho 26.
                const SizedBox(height: 14), // Reserva 14 unidades de espaço na vertical.
                _legenda(texto), // Mostra a explicação recebida abaixo do título.
                const SizedBox(height: 24), // Reserva 24 unidades de espaço na vertical.
                _botao( // Começa o botão reutilizável.
                  'Continuar jogando', // Fornece este texto à função ou ao componente que o envolve.
                  () => Navigator.pop(contexto, false), // Fecha a janela e informa que a ação não foi confirmada.
                ), // Conclui o botão reutilizável.
                const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
                _botao( // Começa o botão reutilizável.
                  confirmar, // Usa o rótulo recebido para o botão de confirmação.
                  () => Navigator.pop(contexto, true), // Fecha a janela e informa que a ação foi confirmada.
                  destaque: false, // Escolhe o botão com contorno em vez do botão preenchido.
                ), // Conclui o botão reutilizável.
                const SizedBox(height: 18), // Reserva 18 unidades de espaço na vertical.
                _legenda('Novo jogo substitui a mesa após confirmar.'), // Mostra esta orientação com o estilo dos textos explicativos.
              ], // Conclui a lista de elementos da tela.
            ), // Conclui a organização dos elementos em coluna.
          ), // Conclui o espaçamento interno.
        ), // Conclui a construção visual deste componente.
      ) ?? // Conclui a exibição da janela de confirmação.
      false; // Trata o fechamento sem escolha como uma ação não confirmada.

  // --------------------------------------------------------------------------
  // BOTÃO DE NOVO JOGO
  // Confirma a substituição quando já existe uma mesa e abre a página da partida.
  // Aciona os efeitos opcionais e pede ao controlador para criar o jogo.
  // --------------------------------------------------------------------------
  Future<void> _novoJogo() async { // Define o que a interface faz quando a pessoa pede um novo jogo.
    if (jogo.ocupado) return; // Ignora o toque enquanto o controlador já executa outra operação.
    if (jogo.mesa != null && // Verifica primeiro se existe uma mesa que seria substituída.
        !await _confirmar( // Aguarda a confirmação e verifica se ela foi recusada.
          'Começar de novo?', // Fornece este texto à função ou ao componente que o envolve.
          'A mesa atual será substituída por uma nova partida.', // Fornece este texto à função ou ao componente que o envolve.
          'Novo jogo', // Fornece este texto à função ou ao componente que o envolve.
        )) { // Conclui a condição verificada.
      return; // Encerra esta ação sem executar as próximas linhas.
    } // Conclui a condição verificada.
    if (!mounted) return; // Para se a tela foi removida enquanto aguardava uma resposta.
    _abrir(Pagina.mesa); // Abre a página em que a partida será mostrada.
    unawaited(_retorno()); // Inicia som e vibração sem fazer a jogada esperar pelos efeitos.
    await jogo.novoJogo(); // Aguarda o controlador criar a mesa e distribuir as cartas.
  } // Conclui o bloco botão de novo jogo.

  // --------------------------------------------------------------------------
  // VOLTAR E PAUSAR
  // Ao sair de uma mesa válida, pergunta se a pessoa quer voltar ao menu.
  // A partida já salva pode ser retomada sem comprar cartas novas.
  // --------------------------------------------------------------------------
  Future<void> _voltar() async { // Define o retorno ao menu e a confirmação de pausa.
    if (jogo.ocupado) return; // Ignora o toque enquanto o controlador já executa outra operação.
    if (pagina == Pagina.mesa && jogo.mesa != null && jogo.erro == null) { // Só pergunta sobre pausa quando há uma mesa válida sendo mostrada.
      if (!await _confirmar( // Aguarda a pergunta e entra neste bloco se a ação não for confirmada.
        'Pausar a mesa?', // Fornece este texto à função ou ao componente que o envolve.
        'Sua partida fica salva neste dispositivo.\nVocê pode voltar quando quiser.', // Fornece este texto à função ou ao componente que o envolve.
        'Salvar e ir ao menu', // Fornece este texto à função ou ao componente que o envolve.
      )) { // Conclui a condição verificada.
        return; // Encerra esta ação sem executar as próximas linhas.
      } // Conclui a condição verificada.
    } // Conclui a condição verificada.
    if (!mounted) return; // Para se a tela foi removida enquanto aguardava uma resposta.
    jogo.limparErro(); // Retira a mensagem de erro antes de exibir o menu.
    _abrir(Pagina.menu); // Troca a página atual pelo menu principal.
  } // Conclui o bloco voltar e pausar.

  // --------------------------------------------------------------------------
  // ESTRUTURA E ESCOLHA DA TELA
  // Desenha fundo, textura, área segura e conteúdo com rolagem.
  // Escolhe abertura, erro, carregamento ou página normal conforme o estado atual.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  Widget build(BuildContext context) => PopScope( // Monta a página e controla o comportamento de voltar do sistema.
    canPop: pagina == Pagina.menu && !jogo.ocupado, // Permite sair diretamente apenas no menu e sem operação em andamento.
    onPopInvokedWithResult: (saiu, _) { // Recebe a informação sobre a tentativa de voltar pelo sistema.
      if (!saiu) _voltar(); // Quando o sistema não saiu, usa o retorno ou a pausa do aplicativo.
    }, // Conclui o bloco estrutura e escolha da tela.
    child: Scaffold( // Começa a estrutura da página.
      body: DecoratedBox( // Começa o corpo da página com um fundo decorado.
        decoration: BoxDecoration( // Começa a definição de fundo, bordas e outros detalhes da caixa.
          gradient: RadialGradient( // Cria uma mudança de cores que parte de uma região central.
            center: const Alignment(0, -.16), // Posiciona o centro do degradê um pouco acima do meio da tela.
            radius: 1, // Define a extensão do degradê em relação ao espaço disponível.
            colors: escuro // Escolhe o conjunto de cores de acordo com o tema.
                ? const [Color(0xFF155640), Color(0xFF062A22)] // Usa dois tons de verde para o fundo escuro.
                : const [Color(0xFFFFFDF5), Color(0xFFE5EADB)], // Usa dois tons claros para o outro tema.
          ), // Conclui o degradê circular do fundo.
        ), // Conclui a aparência da caixa.
        child: CustomPaint( // Começa o desenho feito pelo aplicativo.
          painter: _Trama( // Escolhe o desenho de textura feito pelo próprio aplicativo.
            cor: escuro ? const Color(0x0991B89C) : const Color(0x08103F33), // Ajusta a cor e a transparência da textura ao tema.
          ), // Conclui o desenho da textura.
          child: SafeArea( // Começa a área que evita as barras do aparelho.
            child: Center( // Começa a centralização do conteúdo.
              child: ConstrainedBox( // Começa o limite de tamanho do conteúdo.
                constraints: const BoxConstraints(maxWidth: 440), // Limita o conteúdo a 440 unidades de largura em telas maiores.
                child: ListView( // Começa a lista que permite rolar a tela.
                  key: ValueKey(pagina), // Identifica a lista pela página para atualizar corretamente sua navegação.
                  padding: const EdgeInsets.all(24), // Aplica a mesma distância interna nos quatro lados.
                  children: [ // Começa a lista de elementos que aparecem neste grupo.
                    if (!jogo.iniciando) _cabecalho(), // Mostra o cabeçalho somente depois da abertura inicial.
                    SizedBox(height: pagina == Pagina.mesa ? 8 : 20), // Usa espaço menor na mesa e maior nas outras páginas.
                    if (jogo.iniciando) // Verifica se o aplicativo ainda está recuperando os dados iniciais.
                      ..._abertura() // Acrescenta os elementos da tela de abertura à lista exibida.
                    else if (pagina == Pagina.mesa && jogo.erro != null) // Caso contrário, verifica se a página da mesa precisa mostrar um erro.
                      ..._erro() // Acrescenta os elementos da tela de recuperação após falha.
                    else if (pagina == Pagina.mesa && // Sem erro, verifica se estamos na página da mesa e ainda falta prepará-la.
                        (jogo.mesa == null || jogo.mesa!.jogador.isEmpty)) // Considera preparação pendente se não há mesa ou a mão ainda está vazia.
                      ..._carregando() // Acrescenta os elementos de preparação ou renovação da mesa.
                    else // Escolhe a alternativa quando as condições anteriores não são atendidas.
                      ...switch (pagina) { // Acrescenta a lista de elementos correspondente à página escolhida.
                        Pagina.menu => _menu(), // Escolhe os elementos do menu principal.
                        Pagina.mesa => _mesa(), // Escolhe os elementos da partida em andamento ou concluída.
                        Pagina.regras => _regras(), // Escolhe os elementos que explicam como jogar.
                        Pagina.configuracoes => _configuracoes(), // Escolhe os controles de preferências do aplicativo.
                      }, // Conclui a escolha correspondente à página.
                  ], // Conclui a lista de elementos da tela.
                ), // Conclui a lista que permite rolar a tela.
              ), // Conclui o limite de tamanho do conteúdo.
            ), // Conclui a centralização do conteúdo.
          ), // Conclui a área que evita as barras do aparelho.
        ), // Conclui o desenho feito pelo aplicativo.
      ), // Conclui a decoração ao redor do conteúdo.
    ), // Conclui a estrutura da página.
  ); // Conclui o tratamento do botão de voltar.

  // --------------------------------------------------------------------------
  // CABEÇALHO E NAVEGAÇÃO
  // Mostra a marca ou o nome da página, com voltar, pausa ou quantidade de baralhos.
  // Os controles ficam indisponíveis enquanto uma operação está em andamento.
  // --------------------------------------------------------------------------
  Widget _cabecalho() => Row( // Define o cabeçalho como elementos dispostos lado a lado.
    children: [ // Começa a lista de elementos que aparecem neste grupo.
      if (pagina == Pagina.regras || pagina == Pagina.configuracoes) // Exibe voltar apenas nas páginas de regras e configurações.
        IconButton( // Começa o botão com ícone.
          tooltip: 'Voltar ao menu', // Fornece uma descrição curta para o botão e para acessibilidade.
          onPressed: jogo.ocupado ? null : _voltar, // Liga o botão ao retorno, desabilitando-o durante uma operação.
          icon: const Icon(Icons.chevron_left), // Escolhe o símbolo desenhado dentro do botão.
        ), // Conclui o botão com ícone.
      Expanded( // Começa a ocupação do espaço disponível.
        child: Text( // Começa o texto exibido na tela.
          switch (pagina) { // Escolhe o texto do cabeçalho de acordo com a página.
            Pagina.regras => 'Como jogar', // Usa Como jogar como título da página de regras.
            Pagina.configuracoes => 'Configurações', // Usa Configurações como título da página de preferências.
            _ => '♠\uFE0E CLUBE 21', // Nas demais páginas, mostra a marca com o naipe em forma de texto.
          }, // Conclui a escolha correspondente à página.
          style: TextStyle( // Começa a configuração da aparência deste texto.
            fontFamily: 'Gelasio', // Escolhe a fonte usada para desenhar as letras.
            fontFamilyFallback: const ['Naipes'], // Usa a fonte de naipes quando a fonte principal não tiver o símbolo.
            fontSize: pagina == Pagina.menu || pagina == Pagina.mesa ? 21 : 24, // Define o tamanho das letras deste texto.
            fontWeight: FontWeight.w700, // Define a espessura das letras, como normal ou negrito.
            color: pagina == Pagina.menu || pagina == Pagina.mesa // Verifica se o título deve usar a cor de destaque da marca.
                ? dourado // Usa a cor dourada de destaque quando a condição é atendida.
                : null, // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
          ), // Conclui o estilo das letras.
        ), // Conclui o texto exibido na tela.
      ), // Conclui a ocupação do espaço disponível.
      if (pagina == Pagina.menu) // Mostra o próximo elemento somente no menu.
        _selo('${jogo.preferencias.baralhos} baralhos'), // Exibe a quantidade de baralhos escolhida nas preferências.
      if (pagina == Pagina.mesa) // Mostra o próximo elemento somente na página da mesa.
        IconButton.filledTonal( // Cria um botão de ícone com fundo suave para pausar a partida.
          tooltip: 'Pausar partida', // Fornece uma descrição curta para o botão e para acessibilidade.
          onPressed: jogo.ocupado ? null : _voltar, // Liga o botão ao retorno, desabilitando-o durante uma operação.
          icon: const Icon(Icons.pause_rounded), // Escolhe o símbolo desenhado dentro do botão.
        ), // Conclui o botão com ícone.
    ], // Conclui a lista de elementos da tela.
  ); // Conclui a organização dos elementos em linha.

  // --------------------------------------------------------------------------
  // APARÊNCIA DOS TÍTULOS
  // Aplica a mesma fonte, alinhamento e peso aos títulos.
  // Cada chamada pode escolher tamanho e cor sem repetir toda a configuração.
  // --------------------------------------------------------------------------
  Widget _titulo(String texto, {double tamanho = 30, Color? cor}) => Text( // Define um título com texto obrigatório, tamanho padrão e cor opcional.
    texto, // Usa o texto recebido como conteúdo visível.
    textAlign: TextAlign.center, // Centraliza o texto dentro do espaço que ele ocupa.
    style: TextStyle( // Começa a configuração da aparência deste texto.
      fontFamily: 'Gelasio', // Escolhe a fonte usada para desenhar as letras.
      fontFamilyFallback: const ['Naipes'], // Usa a fonte de naipes quando a fonte principal não tiver o símbolo.
      fontSize: tamanho, // Define o tamanho das letras deste texto.
      height: 1.15, // Ajusta a altura das linhas do título em relação ao tamanho das letras.
      fontWeight: FontWeight.w600, // Define a espessura das letras, como normal ou negrito.
      color: cor, // Aplica a cor recebida ou deixa o tema fornecer a cor padrão.
    ), // Conclui o estilo das letras.
  ); // Conclui o texto exibido na tela.

  // --------------------------------------------------------------------------
  // APARÊNCIA DAS EXPLICAÇÕES
  // Mostra os textos auxiliares centralizados e com espaçamento legível.
  // A cor acompanha o tema claro ou escuro.
  // --------------------------------------------------------------------------
  Widget _legenda(String texto) => Text( // Define um texto explicativo com aparência padronizada.
    texto, // Usa o texto recebido como conteúdo visível.
    textAlign: TextAlign.center, // Centraliza o texto dentro do espaço que ele ocupa.
    style: TextStyle( // Começa a configuração da aparência deste texto.
      fontSize: 12, // Define o tamanho das letras deste texto.
      height: 1.5, // Usa altura de linha de uma vez e meia o tamanho das letras.
      color: escuro ? const Color(0xFFB6CDC2) : const Color(0xFF40564B), // Escolhe uma cor legível para a explicação em cada tema.
    ), // Conclui o estilo das letras.
  ); // Conclui o texto exibido na tela.

  // --------------------------------------------------------------------------
  // INDICADORES PEQUENOS
  // Desenha uma caixa arredondada para informações curtas, como pontos e baralhos.
  // As cores são ajustadas ao tema escolhido.
  // --------------------------------------------------------------------------
  Widget _selo(String texto) => Container( // Define uma pequena caixa arredondada para uma informação curta.
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Define as distâncias internas horizontais e/ou verticais.
    decoration: BoxDecoration( // Começa a definição de fundo, bordas e outros detalhes da caixa.
      color: escuro ? const Color(0xFF214F42) : const Color(0xFFDCE4D5), // Escolhe o fundo do indicador conforme o tema.
      borderRadius: BorderRadius.circular(20), // Arredonda os cantos com o raio indicado.
    ), // Conclui a aparência da caixa.
    child: Text( // Começa o texto exibido na tela.
      texto, // Usa o texto recebido como conteúdo visível.
      style: TextStyle( // Começa a configuração da aparência deste texto.
        fontSize: 12, // Define o tamanho das letras deste texto.
        color: escuro ? const Color(0xFFF7F1E4) : const Color(0xFF173B30), // Escolhe a cor do texto do indicador para manter contraste.
      ), // Conclui o estilo das letras.
    ), // Conclui o texto exibido na tela.
  ); // Conclui a caixa de conteúdo.

  // --------------------------------------------------------------------------
  // PAINEL DE INFORMAÇÕES
  // Envolve um conteúdo com espaço, fundo, borda e cantos arredondados.
  // O estado de derrota usa uma cor diferente para destacar o resultado.
  // --------------------------------------------------------------------------
  Widget _painel(Widget conteudo, {bool derrota = false}) => Container( // Define uma caixa de conteúdo com destaque opcional de derrota.
    margin: const EdgeInsets.only(bottom: 12), // Deixa espaço abaixo do painel para separá-lo do próximo elemento.
    padding: const EdgeInsets.all(16), // Aplica a mesma distância interna nos quatro lados.
    decoration: BoxDecoration( // Começa a definição de fundo, bordas e outros detalhes da caixa.
      color: derrota // Decide a cor do painel conforme o resultado da partida.
          ? (escuro ? const Color(0xFF4D3531) : const Color(0xFFF3D7D1)) // Usa tons avermelhados de derrota ajustados ao tema.
          : (escuro ? const Color(0xFF19463B) : const Color(0xFFE9EBDD)), // Usa o fundo normal do painel quando não é uma derrota.
      borderRadius: BorderRadius.circular(18), // Arredonda os cantos com o raio indicado.
      border: Border.all(color: dourado.withValues(alpha: .35)), // Desenha uma borda dourada discreta em todos os lados.
    ), // Conclui a aparência da caixa.
    child: Material(type: MaterialType.transparency, child: conteudo), // Permite efeitos dos controles sobre o conteúdo sem cobrir o fundo.
  ); // Conclui a caixa de conteúdo.

  // --------------------------------------------------------------------------
  // BOTÕES REUTILIZÁVEIS
  // Monta um botão com texto principal e, opcionalmente, uma explicação menor.
  // Pode ser preenchido ou ter apenas contorno; sem ação, fica desabilitado.
  // --------------------------------------------------------------------------
  Widget _botao( // Define a construção de um botão reutilizável.
    String texto, // Recebe o texto que será apresentado por este componente.
    VoidCallback? acao, { // Recebe a ação do toque; sem ação, o botão fica desabilitado.
    bool destaque = true, // Usa um botão preenchido por padrão, podendo escolher contorno.
    String? apoio, // Recebe uma explicação menor opcional abaixo do texto principal.
  }) { // Termina os parâmetros opcionais e começa as instruções da função.
    final conteudo = Padding( // Monta o conteúdo do botão com espaço interno.
      padding: const EdgeInsets.symmetric(vertical: 10), // Define as distâncias internas horizontais e/ou verticais.
      child: Column( // Começa a organização dos elementos em coluna.
        mainAxisSize: MainAxisSize.min, // Faz a coluna ocupar apenas a altura necessária ao conteúdo.
        children: [ // Começa a lista de elementos que aparecem neste grupo.
          Text( // Começa o texto exibido na tela.
            texto, // Usa o texto recebido como conteúdo visível.
            textAlign: TextAlign.center, // Centraliza o texto dentro do espaço que ele ocupa.
            style: const TextStyle(fontWeight: FontWeight.w700), // Deixa o texto em negrito para destacar a ação.
          ), // Conclui o texto exibido na tela.
          if (apoio != null) // Só mostra a segunda linha quando existe um texto de apoio.
            Text( // Começa o texto exibido na tela.
              apoio, // Usa a explicação menor recebida para este botão.
              textAlign: TextAlign.center, // Centraliza o texto dentro do espaço que ele ocupa.
              style: const TextStyle( // Começa uma configuração fixa para a aparência deste texto.
                fontSize: 11, // Define o tamanho das letras deste texto.
                fontWeight: FontWeight.normal, // Define a espessura das letras, como normal ou negrito.
              ), // Conclui o estilo das letras.
            ), // Conclui o texto exibido na tela.
        ], // Conclui a lista de elementos da tela.
      ), // Conclui a organização dos elementos em coluna.
    ); // Conclui o espaçamento interno.
    if (!destaque) return OutlinedButton(onPressed: acao, child: conteudo); // Quando não há destaque, entrega um botão com contorno e a mesma ação.
    return DecoratedBox( // Começa a decoração ao redor do conteúdo.
      decoration: BoxDecoration( // Começa a definição de fundo, bordas e outros detalhes da caixa.
        borderRadius: BorderRadius.circular(17), // Arredonda os cantos com o raio indicado.
        gradient: acao == null // Verifica se o botão está desabilitado antes de escolher o degradê.
            ? null // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
            : const LinearGradient( // Quando o botão está ativo, começa a transição linear entre suas cores.
                colors: [Color(0xFFF1D991), Color(0xFFD7B25F)], // Define os dois tons dourados que formam o fundo do botão.
              ), // Conclui a transição entre as cores.
      ), // Conclui a aparência da caixa.
      child: FilledButton( // Começa o botão preenchido.
        style: FilledButton.styleFrom( // Começa as opções visuais dos botões preenchidos.
          backgroundColor: Colors.transparent, // Deixa aparecer a decoração desenhada atrás do botão.
          shadowColor: Colors.transparent, // Evita acrescentar uma sombra própria ao botão.
        ), // Conclui o botão preenchido.
        onPressed: acao, // Executa a função recebida quando o botão for tocado.
        child: conteudo, // Coloca dentro do componente o conteúdo preparado anteriormente.
      ), // Conclui o botão preenchido.
    ); // Conclui a decoração ao redor do conteúdo.
  } // Conclui o bloco botões reutilizáveis.

  // --------------------------------------------------------------------------
  // CARTAS DECORATIVAS DA MARCA
  // Posiciona dois ases locais, inclinados e sobrepostos.
  // Essa decoração não compra cartas nem depende de internet.
  // --------------------------------------------------------------------------
  Widget _marca() => SizedBox( // Define o espaço e as cartas decorativas da marca.
    height: 215, // Reserva 215 unidades de altura para a área da marca.
    child: Center( // Começa a centralização do conteúdo.
      child: SizedBox( // Começa o espaço reservado na tela.
        width: 190, // Reserva 190 unidades de largura para as duas cartas decorativas.
        height: 180, // Reserva 180 unidades de altura para as cartas sobrepostas.
        child: Stack( // Começa a sobreposição dos elementos.
          alignment: Alignment.center, // Centraliza os elementos dentro da área disponível.
          children: [ // Começa a lista de elementos que aparecem neste grupo.
            Positioned( // Começa a posição do elemento sobreposto.
              left: 28, // Afasta a carta 28 unidades da borda esquerda.
              top: 18, // Afasta a carta 18 unidades do topo.
              child: Transform.rotate( // Começa a inclinação visual da carta decorativa.
                angle: -.21, // Inclina a primeira carta levemente no sentido anti-horário, em radianos.
                child: const CartaVisual(carta: Carta('AS'), largura: 100), // Desenha um Ás de espadas local com largura 100.
              ), // Conclui a transformação visual.
            ), // Conclui a posição do elemento sobreposto.
            Positioned( // Começa a posição do elemento sobreposto.
              right: 22, // Afasta a segunda carta 22 unidades da borda direita.
              top: 10, // Afasta a segunda carta dez unidades do topo.
              child: Transform.rotate( // Começa a inclinação visual da carta decorativa.
                angle: .16, // Inclina a segunda carta levemente no sentido horário, em radianos.
                child: const CartaVisual(carta: Carta('AD'), largura: 100), // Desenha um Ás de ouros local com largura 100.
              ), // Conclui a transformação visual.
            ), // Conclui a posição do elemento sobreposto.
          ], // Conclui a lista de elementos da tela.
        ), // Conclui a sobreposição dos elementos.
      ), // Conclui o espaço reservado na tela.
    ), // Conclui a centralização do conteúdo.
  ); // Conclui o espaço reservado na tela.

  // --------------------------------------------------------------------------
  // TELA DE ABERTURA
  // Mostra a identidade do jogo enquanto os dados locais são carregados.
  // A barra de progresso indica preparação, sem simular uma porcentagem.
  // --------------------------------------------------------------------------
  List<Widget> _abertura() => [ // Define os elementos mostrados durante a abertura do aplicativo.
    const SizedBox(height: 74), // Reserva 74 unidades de espaço na vertical.
    _legenda('UM CLÁSSICO NA SUA MÃO'), // Mostra esta orientação com o estilo dos textos explicativos.
    _marca(), // Acrescenta as duas cartas decorativas desenhadas localmente.
    _titulo('Blackjack', tamanho: 44), // Mostra este título com o tamanho indicado.
    const SizedBox(height: 10), // Reserva 10 unidades de espaço na vertical.
    _legenda('C L U B E  2 1'), // Mostra esta orientação com o estilo dos textos explicativos.
    const SizedBox(height: 34), // Reserva 34 unidades de espaço na vertical.
    _legenda('A estratégia encontra a sorte.\nChegue perto de 21.'), // Mostra esta orientação com o estilo dos textos explicativos.
    const SizedBox(height: 64), // Reserva 64 unidades de espaço na vertical.
    const LinearProgressIndicator(), // Mostra uma barra animada de espera, sem uma porcentagem específica.
    const SizedBox(height: 10), // Reserva 10 unidades de espaço na vertical.
    _legenda('Preparando sua mesa…'), // Mostra esta orientação com o estilo dos textos explicativos.
  ]; // Conclui a lista de elementos desta página.

  // --------------------------------------------------------------------------
  // MENU PRINCIPAL
  // Oferece novo jogo, retomada, regras e configurações.
  // A retomada só fica disponível quando existe uma mesa recuperável.
  // --------------------------------------------------------------------------
  List<Widget> _menu() => [ // Define os elementos e ações do menu principal.
    const SizedBox(height: 20), // Reserva 20 unidades de espaço na vertical.
    _marca(), // Acrescenta as duas cartas decorativas desenhadas localmente.
    _titulo('Sua próxima\nboa jogada.', tamanho: 36), // Mostra este título com o tamanho indicado.
    const SizedBox(height: 14), // Reserva 14 unidades de espaço na vertical.
    _legenda('Um clássico. Um novo jeito de jogar.'), // Mostra esta orientação com o estilo dos textos explicativos.
    const SizedBox(height: 40), // Reserva 40 unidades de espaço na vertical.
    _botao('Novo jogo', jogo.ocupado ? null : _novoJogo), // Oferece iniciar outra partida quando o controlador estiver livre.
    const SizedBox(height: 14), // Reserva 14 unidades de espaço na vertical.
    _botao( // Começa o botão reutilizável.
      'Continuar partida', // Fornece este texto à função ou ao componente que o envolve.
      jogo.mesa == null || jogo.ocupado ? null : () => _abrir(Pagina.mesa), // Só habilita continuar quando existe uma mesa e nenhuma operação pendente.
      destaque: false, // Escolhe o botão com contorno em vez do botão preenchido.
    ), // Conclui o botão reutilizável.
    const SizedBox(height: 14), // Reserva 14 unidades de espaço na vertical.
    _legenda( // Começa o texto explicativo.
      jogo.mesa == null // Verifica se ainda não existe uma mesa para continuar.
          ? 'Sua partida aparecerá aqui quando começar.' // Orienta a iniciar uma partida quando não há mesa salva.
          : 'Mesa 01 · ${jogo.mesa!.restantes} cartas restantes', // Caso exista mesa, mostra sua contagem atual de cartas.
    ), // Conclui o texto explicativo.
    if (jogo.aviso != null) _painel(Text(jogo.aviso!)), // Acrescenta um painel de aviso somente quando há uma mensagem.
    const Padding( // Começa o espaçamento interno.
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 64), // Define as distâncias internas horizontais e/ou verticais.
      child: Divider(), // Desenha uma linha visual para separar grupos de ações.
    ), // Conclui o espaçamento interno.
    Row( // Começa a organização dos elementos em linha.
      children: [ // Começa a lista de elementos que aparecem neste grupo.
        Expanded( // Começa a ocupação do espaço disponível.
          child: _botao( // Começa o botão reutilizável.
            'Como jogar', // Fornece este texto à função ou ao componente que o envolve.
            () => _abrir(Pagina.regras), // Liga este toque à página que explica como jogar.
            destaque: false, // Escolhe o botão com contorno em vez do botão preenchido.
          ), // Conclui o botão reutilizável.
        ), // Conclui a ocupação do espaço disponível.
        const SizedBox(width: 12), // Reserva 12 unidades de espaço na horizontal.
        Expanded( // Começa a ocupação do espaço disponível.
          child: _botao( // Começa o botão reutilizável.
            'Configurações', // Fornece este texto à função ou ao componente que o envolve.
            () => _abrir(Pagina.configuracoes), // Liga este toque à página de preferências.
            destaque: false, // Escolhe o botão com contorno em vez do botão preenchido.
          ), // Conclui o botão reutilizável.
        ), // Conclui a ocupação do espaço disponível.
      ], // Conclui a lista de elementos da tela.
    ), // Conclui a organização dos elementos em linha.
    const SizedBox(height: 24), // Reserva 24 unidades de espaço na vertical.
    _legenda('Flutter + Deck of Cards API'), // Mostra esta orientação com o estilo dos textos explicativos.
  ]; // Conclui a lista de elementos desta página.

  // --------------------------------------------------------------------------
  // PREPARAÇÃO OU RENOVAÇÃO DA MESA
  // Mostra mensagens diferentes para uma criação normal e para o corte do shoe.
  // Os botões ficam bloqueados enquanto as cartas são preparadas.
  // --------------------------------------------------------------------------
  List<Widget> _carregando() => [ // Define o conteúdo mostrado enquanto a mesa é preparada.
    _titulo( // Começa o título destacado.
      jogo.renovando ? 'Renovando a mesa' : 'Preparando a mesa', // Distingue no título a troca do shoe da criação normal.
      tamanho: 25, // Escolhe tamanho 25 para este título.
    ), // Conclui o título destacado.
    const SizedBox(height: 14), // Reserva 14 unidades de espaço na vertical.
    _legenda( // Começa o texto explicativo.
      jogo.renovando // Verifica se o carregamento corresponde à renovação do shoe.
          ? 'Um baralho novo, a mesma experiência.' // Mostra a explicação curta da renovação.
          : 'Uma nova rodada está chegando.', // Mostra a explicação curta da preparação normal.
    ), // Conclui o texto explicativo.
    const SizedBox(height: 45), // Reserva 45 unidades de espaço na vertical.
    _marca(), // Acrescenta as duas cartas decorativas desenhadas localmente.
    _titulo( // Começa o título destacado.
      jogo.renovando ? 'Hora de renovar o shoe' : 'Embaralhando a sorte…', // Escolhe a mensagem central conforme o motivo da preparação.
      tamanho: 26, // Escolhe tamanho 26 para este título.
    ), // Conclui o título destacado.
    const SizedBox(height: 20), // Reserva 20 unidades de espaço na vertical.
    _legenda( // Começa o texto explicativo.
      jogo.renovando // Verifica se o carregamento corresponde à renovação do shoe.
          ? 'O corte foi atingido entre rodadas.\nVamos criar outro shoe antes de distribuir.' // Explica que o conjunto de cartas será trocado antes da rodada seguinte.
          : 'Criando seu shoe e distribuindo cartas.\nAs ações ficam disponíveis em instantes.', // Explica a preparação inicial e a espera pelos controles.
    ), // Conclui o texto explicativo.
    if (jogo.renovando) // Exibe o próximo elemento apenas durante a renovação.
      Padding( // Começa o espaçamento interno.
        padding: const EdgeInsets.only(top: 18), // Acrescenta espaço interno somente nos lados indicados.
        child: Center(child: _selo(jogo.corte)), // Centraliza a contagem que motivou o corte do shoe.
      ), // Conclui o espaçamento interno.
    const SizedBox(height: 45), // Reserva 45 unidades de espaço na vertical.
    const LinearProgressIndicator(), // Mostra uma barra animada de espera, sem uma porcentagem específica.
    const SizedBox(height: 16), // Reserva 16 unidades de espaço na vertical.
    _botao( // Começa o botão reutilizável.
      jogo.renovando ? 'Preparando nova rodada…' : 'Distribuindo cartas…', // Escolhe o texto do botão bloqueado conforme a etapa.
      null, // Não fornece uma ação, mantendo este botão desabilitado.
    ), // Conclui o botão reutilizável.
  ]; // Conclui a lista de elementos desta página.

  // --------------------------------------------------------------------------
  // TELA DE FALHA E RECUPERAÇÃO
  // Distingue problema de salvamento, falha na criação e compra incerta.
  // Oferece iniciar outra mesa ou voltar ao menu, sem repetir a compra antiga.
  // --------------------------------------------------------------------------
  List<Widget> _erro() => [ // Define as mensagens e ações da página de falha.
    const SizedBox(height: 100), // Reserva 100 unidades de espaço na vertical.
    Icon(Icons.error_outline, size: 64, color: dourado), // Mostra um símbolo de atenção na cor de destaque.
    const SizedBox(height: 28), // Reserva 28 unidades de espaço na vertical.
    _titulo( // Começa o título destacado.
      jogo.falhaLocal // Verifica se o problema aconteceu ao salvar no dispositivo.
          ? 'Não foi possível salvar' // Escolhe o título específico para falha de armazenamento.
          : jogo.compraIncerta // Se não foi armazenamento, verifica se uma compra ficou sem confirmação.
          ? 'Rodada interrompida' // Escolhe o título para uma compra que pode ter acontecido no servidor.
          : 'Não foi possível conectar', // Usa o título de conexão para a falha na criação da mesa.
      tamanho: 28, // Escolhe tamanho 28 para o título de falha.
    ), // Conclui o título destacado.
    const SizedBox(height: 20), // Reserva 20 unidades de espaço na vertical.
    _legenda(jogo.erro!), // Mostra os detalhes do erro informado pelo controlador.
    const SizedBox(height: 24), // Reserva 24 unidades de espaço na vertical.
    if (!jogo.falhaLocal) // Mostra orientações de rede somente quando a falha não é local.
      _painel( // Começa o painel de conteúdo.
        _legenda( // Começa o texto explicativo.
          jogo.compraIncerta // Verifica se a última compra exige reiniciar a mesa.
              ? 'Para manter a rodada correta, reinicie a mesa com um novo baralho.\nA rodada atual será encerrada.' // Explica por que a compra incerta obriga a substituir a mesa.
              : 'Seu jogo não começou.\nTentar novamente cria uma nova mesa.\nNenhuma compra será repetida.', // Explica que uma nova tentativa fará uma criação, sem repetir compras.
        ), // Conclui o texto explicativo.
      ), // Conclui o painel de conteúdo.
    const SizedBox(height: 48), // Reserva 48 unidades de espaço na vertical.
    _botao( // Começa o botão reutilizável.
      jogo.compraIncerta ? 'Reiniciar mesa' : 'Tentar novamente', // Escolhe o rótulo de recuperação apropriado ao tipo de falha.
      _novoJogo, // Usa a criação de uma nova mesa como ação de recuperação.
    ), // Conclui o botão reutilizável.
    const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
    _botao('Voltar ao menu', _voltar, destaque: false), // Oferece retornar ao menu por um botão com contorno.
  ]; // Conclui a lista de elementos desta página.

  // --------------------------------------------------------------------------
  // MESA, TURNO E RESULTADO
  // Reúne as mãos, os pontos, as mensagens de andamento e os botões de jogada.
  // Os cálculos vêm das regras; os botões chamam o controlador para realizar ações.
  // --------------------------------------------------------------------------
  List<Widget> _mesa() { // Define os elementos da mesa com base na rodada atual.
    final mesa = jogo.mesa!; // Usa a mesa existente; esta tela só é escolhida quando ela está pronta.
    final terminada = mesa.fase == Fase.concluida; // Guarda se a rodada já chegou ao resultado.
    final suaVez = mesa.fase == Fase.jogador && !jogo.ocupado; // Confere se o jogador pode agir agora, sem operação em andamento.
    final ases = mesa.jogador.where((carta) => carta.valor == 'A').length; // Conta quantos ases existem na mão do jogador.
    final mao = pontuar(mesa.jogador); // Calcula os pontos e informa se algum Ás ainda vale 11.
    final ajustado = ases > (mao.suave ? 1 : 0); // Identifica se algum Ás precisou valer 1 para reduzir a soma.
    final mensagem = terminada // Começa a escolha da mensagem, verificando primeiro se a rodada acabou.
        ? resultado(mesa.jogador, mesa.banca) // Se acabou, usa o resultado calculado pelas regras do jogo.
        : mesa.fase == Fase.banca // Caso contrário, verifica se a banca está jogando.
        ? ( // Agrupa o título e o detalhe desta mensagem.
            titulo: 'Vez da banca', // Define a frase principal desta mensagem.
            detalhe: bancaCompra(mesa.banca, mesa.paraNo17Suave) // Escolhe a explicação conforme a banca precise ou não de outra carta.
                ? 'A banca pede mais uma carta.' // Informa que a regra exige continuar comprando para a banca.
                : '${pontuar(mesa.banca).pontos} pontos. A banca para.', // Informa os pontos da banca quando ela já pode parar.
          ) // Conclui o bloco mesa, turno e resultado.
        : ajustado && !jogo.ocupado // Fora da vez da banca, verifica se cabe explicar o ajuste do Ás.
        ? ( // Agrupa o título e o detalhe desta mensagem.
            titulo: 'Boa decisão.', // Define a frase principal desta mensagem.
            detalhe: 'Ás ajustado: você continua no jogo.', // Define a explicação que acompanha esta mensagem.
          ) // Conclui o bloco mesa, turno e resultado.
        : ( // Agrupa o título e o detalhe desta mensagem.
            titulo: jogo.ocupado ? 'Pedindo carta…' : 'Sua vez', // Define a frase principal desta mensagem.
            detalhe: 'Pedir mais uma carta ou parar?', // Define a explicação que acompanha esta mensagem.
          ); // Conclui o bloco mesa, turno e resultado.
    final derrota = // Prepara a identificação dos casos em que o jogador perdeu.
        terminada && // Só permite classificar derrota depois de encerrar a rodada.
        (mao.pontos > 21 || // Considera derrota quando o jogador passou de 21.
            natural(mesa.banca) && !natural(mesa.jogador) || // Também considera derrota quando só a banca tem natural.
            pontuar(mesa.banca).pontos <= 21 && // Para comparar pontos, exige que a banca não tenha estourado.
                pontuar(mesa.banca).pontos > mao.pontos); // Com a banca válida, considera derrota se ela tiver mais pontos.
    return [ // Devolve os elementos que formarão esta página.
      Row( // Começa a organização dos elementos em linha.
        children: [ // Começa a lista de elementos que aparecem neste grupo.
          Expanded( // Começa a ocupação do espaço disponível.
            child: Column( // Começa a organização dos elementos em coluna.
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha os itens da coluna pela borda inicial, à esquerda neste idioma.
              children: [ // Começa a lista de elementos que aparecem neste grupo.
                const Text( // Começa o texto exibido na tela.
                  'MESA 01', // Fornece este texto à função ou ao componente que o envolve.
                  style: TextStyle(letterSpacing: 2, fontSize: 12), // Usa letras pequenas com espaço maior entre elas.
                ), // Conclui o texto exibido na tela.
                const SizedBox(height: 8), // Reserva 8 unidades de espaço na vertical.
                Text( // Começa o texto exibido na tela.
                  '${mesa.restantes} cartas no shoe', // Fornece este texto à função ou ao componente que o envolve.
                  style: const TextStyle(fontWeight: FontWeight.w600), // Destaca o texto com uma espessura intermediária de negrito.
                ), // Conclui o texto exibido na tela.
              ], // Conclui a lista de elementos da tela.
            ), // Conclui a organização dos elementos em coluna.
          ), // Conclui a ocupação do espaço disponível.
          _selo('${mesa.baralhos} baralhos'), // Mostra a quantidade fixa de baralhos desta mesa.
        ], // Conclui a lista de elementos da tela.
      ), // Conclui a organização dos elementos em linha.
      const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
      _mao('BANCA', mesa.banca, ocultar: mesa.fase == Fase.jogador), // Exibe a mão da banca, escondendo a segunda carta durante a vez do jogador.
      const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
      _legenda('B L A C K J A C K  ·  C L U B E  2 1'), // Mostra esta orientação com o estilo dos textos explicativos.
      const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
      Semantics( // Começa a descrição para leitores de tela.
        liveRegion: true, // Permite ao leitor de tela anunciar mudanças nesta mensagem.
        child: _painel( // Começa o painel de conteúdo.
          Column( // Começa a organização dos elementos em coluna.
            children: [ // Começa a lista de elementos que aparecem neste grupo.
              _titulo( // Começa o título destacado.
                mensagem.titulo, // Usa o título de turno ou resultado escolhido anteriormente.
                tamanho: 26, // Escolhe tamanho 26 para este título.
                cor: derrota // Escolhe a cor do título conforme o jogador tenha perdido.
                    ? (escuro // Em caso de derrota, verifica qual tema está ativo.
                          ? const Color(0xFFF1B6A5) // Usa um tom claro de vermelho para contraste no fundo escuro.
                          : const Color(0xFF802D27)) // Usa um tom escuro de vermelho para contraste no fundo claro.
                    : dourado, // Nos outros casos, mantém a cor dourada de destaque.
              ), // Conclui o título destacado.
              const SizedBox(height: 8), // Reserva 8 unidades de espaço na vertical.
              _legenda(mensagem.detalhe), // Mostra a explicação do turno ou do resultado atual.
            ], // Conclui a lista de elementos da tela.
          ), // Conclui a organização dos elementos em coluna.
          derrota: derrota, // Informa ao painel se ele deve adotar as cores de derrota.
        ), // Conclui o painel de conteúdo.
      ), // Conclui a descrição para leitores de tela.
      const SizedBox(height: 8), // Reserva 8 unidades de espaço na vertical.
      _mao('SUA MÃO', mesa.jogador), // Mostra todas as cartas e a pontuação do jogador.
      const SizedBox(height: 10), // Reserva 10 unidades de espaço na vertical.
      _legenda( // Começa o texto explicativo.
        ajustado // Verifica se há algum Ás valendo 1 nesta mão.
            ? (ases == 1 // Havendo ajuste, distingue um único Ás de vários ases.
                  ? 'Ás vale 1 nesta mão' // Explica o ajuste quando existe somente um Ás.
                  : 'Um ou mais ases valem 1 nesta mão') // Explica o ajuste quando existem vários ases.
            : 'Sem apostas · jogue para aprender', // Sem ajuste de Ás, mostra a orientação educativa do jogo.
      ), // Conclui o texto explicativo.
      const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
      Row( // Começa a organização dos elementos em linha.
        children: [ // Começa a lista de elementos que aparecem neste grupo.
          Expanded( // Começa a ocupação do espaço disponível.
            child: _botao( // Começa o botão reutilizável.
              'Pedir carta', // Fornece este texto à função ou ao componente que o envolve.
              suaVez // Só oferece uma ação quando é a vez do jogador e o jogo está livre.
                  ? () { // Define o que acontecerá quando a ação estiver habilitada e for acionada.
                      unawaited(_retorno()); // Inicia som e vibração sem fazer a jogada esperar pelos efeitos.
                      jogo.pedirCarta(); // Solicita ao controlador a compra de uma carta para o jogador.
                    } // Conclui a ação executada pelo botão.
                  : null, // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
              apoio: 'HIT · +1 carta', // Acrescenta o termo do jogo e explica que a ação compra uma carta.
            ), // Conclui o botão reutilizável.
          ), // Conclui a ocupação do espaço disponível.
          const SizedBox(width: 12), // Reserva 12 unidades de espaço na horizontal.
          Expanded( // Começa a ocupação do espaço disponível.
            child: _botao( // Começa o botão reutilizável.
              'Parar', // Fornece este texto à função ou ao componente que o envolve.
              suaVez // Só oferece uma ação quando é a vez do jogador e o jogo está livre.
                  ? () { // Define o que acontecerá quando a ação estiver habilitada e for acionada.
                      unawaited(_retorno()); // Inicia som e vibração sem fazer a jogada esperar pelos efeitos.
                      jogo.parar(); // Solicita ao controlador que encerre a vez do jogador.
                    } // Conclui a ação executada pelo botão.
                  : null, // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
              destaque: false, // Escolhe o botão com contorno em vez do botão preenchido.
              apoio: 'STAND · vez da banca', // Acrescenta o termo do jogo e explica a passagem de turno.
            ), // Conclui o botão reutilizável.
          ), // Conclui a ocupação do espaço disponível.
        ], // Conclui a lista de elementos da tela.
      ), // Conclui a organização dos elementos em linha.
      const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
      if (jogo.ocupado) const LinearProgressIndicator(), // Mostra uma barra de espera enquanto a operação está em andamento.
      _botao( // Começa o botão reutilizável.
        terminada ? 'Nova rodada' : 'Rodada em andamento', // Ajusta o texto do botão conforme a rodada tenha terminado.
        terminada && !jogo.ocupado // Só habilita começar outra rodada depois do resultado e sem tarefa pendente.
            ? () { // Define o que acontecerá quando a ação estiver habilitada e for acionada.
                unawaited(_retorno()); // Inicia som e vibração sem fazer a jogada esperar pelos efeitos.
                jogo.novaRodada(); // Solicita ao controlador a distribuição da próxima rodada.
              } // Conclui a ação executada pelo botão.
            : null, // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
      ), // Conclui o botão reutilizável.
    ]; // Conclui a lista de elementos desta página.
  } // Conclui o bloco mesa, turno e resultado.

  // --------------------------------------------------------------------------
  // CARTAS E PONTOS DE UMA MÃO
  // Mostra cartas sobrepostas, com rolagem horizontal se a mão ficar grande.
  // Quando solicitado, esconde apenas a segunda carta e sua pontuação.
  // --------------------------------------------------------------------------
  Widget _mao(String nome, List<Carta> cartas, {bool ocultar = false}) => // Define a exibição de uma mão, permitindo ocultar a segunda carta.
      Column( // Começa a organização dos elementos em coluna.
        children: [ // Começa a lista de elementos que aparecem neste grupo.
          Row( // Começa a organização dos elementos em linha.
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui os itens da linha entre as bordas esquerda e direita.
            children: [ // Começa a lista de elementos que aparecem neste grupo.
              Text( // Começa o texto exibido na tela.
                nome, // Exibe o nome recebido para esta mão ou controle.
                style: const TextStyle( // Começa uma configuração fixa para a aparência deste texto.
                  fontSize: 12, // Define o tamanho das letras deste texto.
                  letterSpacing: 2, // Acrescenta espaço entre as letras do rótulo.
                  fontWeight: FontWeight.bold, // Define a espessura das letras, como normal ou negrito.
                ), // Conclui o estilo das letras.
              ), // Conclui o texto exibido na tela.
              _selo( // Começa o pequeno indicador de informação.
                ocultar // Verifica se a pontuação da segunda carta deve permanecer escondida.
                    ? '${cartas.first.pontos} + ? pts' // Mostra somente os pontos da primeira carta e um sinal de interrogação.
                    : '${pontuar(cartas).pontos} pts', // Quando a mão está aberta, mostra a soma completa de seus pontos.
              ), // Conclui o pequeno indicador de informação.
            ], // Conclui a lista de elementos da tela.
          ), // Conclui a organização dos elementos em linha.
          const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
          SingleChildScrollView( // Começa a área de rolagem da mão.
            scrollDirection: Axis.horizontal, // Permite deslizar as cartas para os lados quando não couberem na tela.
            child: SizedBox( // Começa o espaço reservado na tela.
              width: 90 + (cartas.length - 1) * 67, // Reserva a largura da primeira carta mais o avanço das demais sobrepostas.
              height: 134, // Reserva a altura da área que contém as cartas.
              child: Stack( // Começa a sobreposição dos elementos.
                children: [ // Começa a lista de elementos que aparecem neste grupo.
                  for (var i = 0; i < cartas.length; i++) // Percorre as cartas pelas posições da lista, começando em zero.
                    Positioned( // Começa a posição do elemento sobreposto.
                      left: i * 67, // Desloca cada carta 67 unidades para a direita em relação à anterior.
                      top: 0, // Alinha esta carta ao topo da área da mão.
                      child: CartaVisual( // Começa a representação visual da carta.
                        carta: cartas[i], // Entrega ao desenho a carta da posição atual da lista.
                        oculta: ocultar && i == 1, // Esconde apenas a segunda carta quando o sigilo da mão está ativo.
                      ), // Conclui a representação visual da carta.
                    ), // Conclui a posição do elemento sobreposto.
                ], // Conclui a lista de elementos da tela.
              ), // Conclui a sobreposição dos elementos.
            ), // Conclui o espaço reservado na tela.
          ), // Conclui a área de rolagem da mão.
        ], // Conclui a lista de elementos da tela.
      ); // Conclui a organização dos elementos em coluna.

  // --------------------------------------------------------------------------
  // EXPLICAÇÃO DE COMO JOGAR
  // Apresenta objetivo, valores das cartas, ações e comportamento da banca.
  // Os textos são locais e não exigem nenhuma consulta à API.
  // --------------------------------------------------------------------------
  List<Widget> _regras() => [ // Define os elementos da página que ensina a jogar.
    _legenda('Poucas regras. Muitas boas decisões.'), // Mostra esta orientação com o estilo dos textos explicativos.
    const SizedBox(height: 20), // Reserva 20 unidades de espaço na vertical.
    for (final regra in const [ // Percorre uma lista fixa de pares com título e explicação de cada regra.
      ( // Agrupa o título e a explicação desta regra.
        '01  Chegue perto de 21', // Fornece este texto à função ou ao componente que o envolve.
        'Vença a banca com mais pontos, sem ultrapassar 21. Empate não é derrota.', // Fornece este texto à função ou ao componente que o envolve.
      ), // Conclui o bloco explicação de como jogar.
      ( // Agrupa o título e a explicação desta regra.
        '02  Conheça as cartas', // Fornece este texto à função ou ao componente que o envolve.
        '2 a 10 valem o número da carta. J, Q e K valem 10. O Ás vale 1 ou 11.\nÁs + 9 + Ás = 21: um Ás vale 11; o outro vale 1.', // Fornece este texto à função ou ao componente que o envolve.
      ), // Conclui o bloco explicação de como jogar.
      ( // Agrupa o título e a explicação desta regra.
        '03  Escolha sua ação', // Fornece este texto à função ou ao componente que o envolve.
        'Pedir carta (Hit): recebe mais uma carta. Parar (Stand): encerra sua vez. Ao chegar a 21, a banca joga automaticamente.', // Fornece este texto à função ou ao componente que o envolve.
      ), // Conclui o bloco explicação de como jogar.
      ( // Agrupa o título e a explicação desta regra.
        '04  A vez da banca', // Fornece este texto à função ou ao componente que o envolve.
        'Compra abaixo de 17; para a partir de 17. Soft 17 segue a configuração da mesa.\nÁs + carta de valor 10 em duas cartas é Blackjack. Dois Blackjacks naturais empatam. 21 em três ou mais cartas não é natural.', // Fornece este texto à função ou ao componente que o envolve.
      ), // Conclui o bloco explicação de como jogar.
    ]) // Conclui a repetição dos itens.
      _painel( // Começa o painel de conteúdo.
        Column( // Começa a organização dos elementos em coluna.
          crossAxisAlignment: CrossAxisAlignment.start, // Alinha os itens da coluna pela borda inicial, à esquerda neste idioma.
          children: [ // Começa a lista de elementos que aparecem neste grupo.
            Text( // Começa o texto exibido na tela.
              regra.$1, // Usa o primeiro item do par, que é o título da regra.
              style: TextStyle(color: dourado, fontWeight: FontWeight.bold), // Destaca o título da regra em dourado e negrito.
            ), // Conclui o texto exibido na tela.
            const SizedBox(height: 8), // Reserva 8 unidades de espaço na vertical.
            Text(regra.$2, style: const TextStyle(fontSize: 13, height: 1.5)), // Mostra o segundo item do par, com a explicação da regra.
          ], // Conclui a lista de elementos da tela.
        ), // Conclui a organização dos elementos em coluna.
      ), // Conclui o painel de conteúdo.
    _legenda( // Começa o texto explicativo.
      'Modo de estudo · sem apostas\nSem divisão de mãos, dobra ou seguro.', // Fornece este texto à função ou ao componente que o envolve.
    ), // Conclui o texto explicativo.
  ]; // Conclui a lista de elementos desta página.

  // --------------------------------------------------------------------------
  // CÓPIA DAS PREFERÊNCIAS ANTES DA EDIÇÃO
  // Cria uma cópia das escolhas atuais e aplica nela a alteração desejada.
  // O controlador tenta salvar e pode recuperar as escolhas antigas se ocorrer falha.
  // --------------------------------------------------------------------------
  void _configurar(void Function(Preferencias) alterar) { // Recebe uma função que modifica uma preferência na cópia criada aqui.
    final novas = Preferencias.ler(jogo.preferencias.salvar()); // Cria uma cópia das preferências convertendo e recuperando seus campos.
    alterar(novas); // Aplica à cópia a mudança solicitada pelo controle da tela.
    jogo.configurar(novas); // Entrega a cópia ao controlador para tentar aplicar e salvar a mudança.
  } // Conclui o bloco cópia das preferências antes da edição.

  // --------------------------------------------------------------------------
  // INTERRUPTOR DE UMA PREFERÊNCIA
  // Monta uma opção com nome, valor ligado ou desligado e explicação opcional.
  // Bloqueia a edição enquanto outra operação está em andamento.
  // --------------------------------------------------------------------------
  Widget _opcao( // Define uma preferência apresentada como interruptor de ligar ou desligar.
    String nome, // Recebe o nome mostrado ao lado do interruptor.
    bool valor, // Recebe se a opção está ligada ou desligada.
    void Function(bool) alterar, { // Recebe a função que será chamada quando a pessoa mudar o interruptor.
    String? detalhe, // Recebe uma explicação opcional abaixo do nome da preferência.
  }) => _painel( // Termina os parâmetros e envolve o interruptor num painel visual.
    SwitchListTile( // Começa a opção de ligar ou desligar.
      contentPadding: EdgeInsets.zero, // Remove o espaço interno extra, pois o painel já fornece espaçamento.
      title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)), // Mostra o nome da preferência com destaque nas letras.
      subtitle: detalhe == null // Verifica se existe uma explicação adicional para mostrar.
          ? null // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
          : Text(detalhe, style: const TextStyle(fontSize: 12, height: 1.5)), // Quando existe explicação, a mostra em letras menores e com espaço entre linhas.
      value: valor, // Faz o interruptor refletir a escolha atual.
      onChanged: jogo.ocupado ? null : alterar, // Desabilita a edição durante uma operação; fora dela, aceita a mudança.
    ), // Conclui a opção de ligar ou desligar.
  ); // Conclui o painel de conteúdo.

  // --------------------------------------------------------------------------
  // PÁGINA DE CONFIGURAÇÕES
  // Reúne quantidade de baralhos, regra do 17 suave, efeitos e tema.
  // Também permite restaurar os padrões; as regras da mesa atual são preservadas.
  // --------------------------------------------------------------------------
  List<Widget> _configuracoes() { // Define os controles e textos da página de preferências.
    final preferencias = jogo.preferencias; // Cria um atalho para as escolhas atuais guardadas no controlador.
    return [ // Devolve os elementos que formarão esta página.
      _legenda('Deixe o jogo com a sua cara.'), // Mostra esta orientação com o estilo dos textos explicativos.
      const SizedBox(height: 28), // Reserva 28 unidades de espaço na vertical.
      Text( // Começa o texto exibido na tela.
        'REGRAS DA PRÓXIMA MESA', // Fornece este texto à função ou ao componente que o envolve.
        style: TextStyle(color: dourado, fontSize: 12, letterSpacing: 1.4), // Destaca os títulos das seções com cor dourada e letras espaçadas.
      ), // Conclui o texto exibido na tela.
      const SizedBox(height: 16), // Reserva 16 unidades de espaço na vertical.
      _painel( // Começa o painel de conteúdo.
        Row( // Começa a organização dos elementos em linha.
          children: [ // Começa a lista de elementos que aparecem neste grupo.
            const Expanded( // Começa a ocupação do espaço disponível.
              child: Text( // Começa o texto exibido na tela.
                'Baralhos\nPadrão clássico: 6', // Fornece este texto à função ou ao componente que o envolve.
                style: TextStyle(height: 1.7), // Aumenta o espaço entre as duas linhas da descrição de baralhos.
              ), // Conclui o texto exibido na tela.
            ), // Conclui a ocupação do espaço disponível.
            IconButton( // Começa o botão com ícone.
              tooltip: 'Diminuir baralhos', // Fornece uma descrição curta para o botão e para acessibilidade.
              onPressed: preferencias.baralhos > 1 && !jogo.ocupado // Só permite diminuir se há mais de um baralho e o controlador está livre.
                  ? () => _configurar((nova) => nova.baralhos--) // Define o toque que diminui em um a quantidade de baralhos.
                  : null, // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
              icon: const Icon(Icons.remove), // Escolhe o símbolo desenhado dentro do botão.
            ), // Conclui o botão com ícone.
            Text( // Começa o texto exibido na tela.
              '${preferencias.baralhos}', // Fornece este texto à função ou ao componente que o envolve.
              style: TextStyle(fontSize: 22, color: dourado), // Destaca o número de baralhos com letras maiores e douradas.
            ), // Conclui o texto exibido na tela.
            IconButton( // Começa o botão com ícone.
              tooltip: 'Aumentar baralhos', // Fornece uma descrição curta para o botão e para acessibilidade.
              onPressed: preferencias.baralhos < 6 && !jogo.ocupado // Só permite aumentar abaixo de seis baralhos e sem operação pendente.
                  ? () => _configurar((nova) => nova.baralhos++) // Define o toque que aumenta em um a quantidade de baralhos.
                  : null, // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
              icon: const Icon(Icons.add), // Escolhe o símbolo desenhado dentro do botão.
            ), // Conclui o botão com ícone.
          ], // Conclui a lista de elementos da tela.
        ), // Conclui a organização dos elementos em linha.
      ), // Conclui o painel de conteúdo.
      _opcao( // Começa a configuração com interruptor.
        'Banca para no soft 17', // Fornece este texto à função ou ao componente que o envolve.
        preferencias.paraNo17Suave, // Mostra se a banca está configurada para parar no 17 suave.
        (valor) => _configurar((nova) => nova.paraNo17Suave = valor), // Aplica à cópia a nova escolha sobre o 17 suave.
        detalhe: // Inicia a explicação adicional mostrada abaixo da opção.
            'Ás + 6 = 17, com Ás valendo 11.\n${preferencias.paraNo17Suave ? 'Ligado: a banca para nessa mão.' : 'Desligado: a banca compra nessa mão.'}', // Explica o 17 suave e descreve o efeito da escolha atual.
      ), // Conclui a configuração com interruptor.
      const SizedBox(height: 20), // Reserva 20 unidades de espaço na vertical.
      Text( // Começa o texto exibido na tela.
        'PREFERÊNCIAS', // Fornece este texto à função ou ao componente que o envolve.
        style: TextStyle(color: dourado, fontSize: 12, letterSpacing: 1.4), // Destaca os títulos das seções com cor dourada e letras espaçadas.
      ), // Conclui o texto exibido na tela.
      const SizedBox(height: 16), // Reserva 16 unidades de espaço na vertical.
      _opcao( // Começa a configuração com interruptor.
        'Som', // Fornece este texto à função ou ao componente que o envolve.
        preferencias.som, // Mostra se o som está habilitado nas preferências.
        (valor) => _configurar((nova) => nova.som = valor), // Aplica à cópia a nova escolha de reproduzir som.
      ), // Conclui a configuração com interruptor.
      _opcao( // Começa a configuração com interruptor.
        'Vibração', // Fornece este texto à função ou ao componente que o envolve.
        preferencias.vibracao, // Mostra se a vibração está habilitada nas preferências.
        (valor) => _configurar((nova) => nova.vibracao = valor), // Aplica à cópia a nova escolha de usar vibração.
      ), // Conclui a configuração com interruptor.
      _painel( // Começa o painel de conteúdo.
        Wrap( // Começa a organização que permite quebrar a linha.
          alignment: WrapAlignment.spaceBetween, // Espalha os elementos entre as bordas quando cabem na mesma linha.
          crossAxisAlignment: WrapCrossAlignment.center, // Centraliza os elementos na altura de cada linha.
          spacing: 14, // Deixa catorze unidades entre os elementos da mesma linha.
          runSpacing: 12, // Deixa doze unidades entre linhas quando o conteúdo precisar quebrar.
          children: [ // Começa a lista de elementos que aparecem neste grupo.
            const Text('Tema'), // Mostra o rótulo do seletor de aparência.
            SegmentedButton<bool>( // Começa o seletor de tema.
              showSelectedIcon: false, // Oculta o ícone extra de confirmação dentro da opção selecionada.
              segments: const [ // Começa a lista fixa das duas opções de tema.
                ButtonSegment(value: true, label: Text('Escuro')), // Associa verdadeiro à opção visual de tema escuro.
                ButtonSegment(value: false, label: Text('Claro')), // Associa falso à opção visual de tema claro.
              ], // Conclui o bloco página de configurações.
              selected: {preferencias.escuro}, // Marca como selecionada a opção correspondente à preferência atual.
              onSelectionChanged: jogo.ocupado // Verifica se uma operação impede mudar o tema agora.
                  ? null // Deixa esta opção sem valor neste caso; controles sem ação ficam desabilitados.
                  : (valor) => // Quando permitido, recebe o conjunto com a opção de tema escolhida.
                        _configurar((nova) => nova.escuro = valor.single), // Usa a única opção selecionada para atualizar o tema na cópia.
            ), // Conclui o seletor de tema.
          ], // Conclui a lista de elementos da tela.
        ), // Conclui a organização que permite quebrar a linha.
      ), // Conclui o painel de conteúdo.
      const SizedBox(height: 12), // Reserva 12 unidades de espaço na vertical.
      _legenda('As regras atuais da mesa são preservadas.'), // Mostra esta orientação com o estilo dos textos explicativos.
      if (jogo.aviso != null) _painel(Text(jogo.aviso!)), // Acrescenta um painel de aviso somente quando há uma mensagem.
      const SizedBox(height: 24), // Reserva 24 unidades de espaço na vertical.
      _botao( // Começa o botão reutilizável.
        'Restaurar padrões', // Fornece este texto à função ou ao componente que o envolve.
        jogo.ocupado ? null : () => jogo.configurar(Preferencias()), // Quando livre, permite substituir as escolhas pelos valores padrão.
        destaque: false, // Escolhe o botão com contorno em vez do botão preenchido.
      ), // Conclui o botão reutilizável.
    ]; // Conclui a lista de elementos desta página.
  } // Conclui o bloco página de configurações.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// DESENHO DE UMA CARTA
// Recebe uma carta, sua largura e a indicação de frente ou verso.
// A carta fechada não carrega a imagem da frente nem revela seu nome na acessibilidade.
// --------------------------------------------------------------------------
class CartaVisual extends StatelessWidget { // Define uma carta visual que depende apenas dos dados recebidos.
  const CartaVisual({ // Começa a criação do componente visual da carta.
    super.key, // Aceita uma identificação opcional usada pelo Flutter para reconhecer o componente.
    required this.carta, // Exige a carta que será representada na tela.
    this.oculta = false, // Mostra a frente por padrão, a menos que seja pedido para ocultar.
    this.largura = 90, // Usa largura 90 quando nenhuma largura diferente é informada.
  }); // Conclui a representação visual da carta.
  final Carta carta; // Guarda os dados da carta que este componente deve mostrar.
  final bool oculta; // Guarda se o componente deve esconder a frente da carta.
  final double largura; // Guarda a largura escolhida para desenhar a carta.

  // --------------------------------------------------------------------------
  // FRENTE, VERSO E ACESSIBILIDADE
  // Desenha o verso local quando a carta está oculta e a imagem quando está aberta.
  // Se não houver imagem ou ela falhar, usa uma frente desenhada no próprio aplicativo.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  Widget build(BuildContext context) => Semantics( // Monta o desenho da carta e sua descrição para leitores de tela.
    label: oculta ? 'Carta fechada' : carta.descricao, // Descreve a frente apenas quando aberta; a carta oculta mantém seu segredo.
    image: true, // Informa à acessibilidade que este componente representa uma imagem.
    child: ExcludeSemantics( // Começa a remoção de descrições repetidas.
      child: MediaQuery.withNoTextScaling( // Mantém os símbolos internos proporcionais ao desenho fixo da carta.
        child: Container( // Começa a caixa de conteúdo.
          width: largura, // Aplica a largura recebida para a carta.
          height: largura * 1.46, // Calcula a altura preservando a proporção de uma carta de baralho.
          decoration: BoxDecoration( // Começa a definição de fundo, bordas e outros detalhes da caixa.
            color: oculta ? const Color(0xFF103F33) : const Color(0xFFF7F1E4), // Usa fundo verde para o verso e claro para a frente.
            borderRadius: BorderRadius.circular(12), // Arredonda os cantos com o raio indicado.
            border: Border.all(color: const Color(0xFFDFD8C9)), // Desenha uma borda clara ao redor da carta.
            boxShadow: const [ // Começa a lista de sombras que destacam a carta do fundo.
              BoxShadow(color: Color(0x80031F19), offset: Offset(0, 3)), // Acrescenta uma sombra escura deslocada três unidades para baixo.
            ], // Conclui o bloco frente, verso e acessibilidade.
          ), // Conclui a aparência da caixa.
          clipBehavior: Clip.antiAlias, // Recorta o conteúdo nos cantos da carta suavizando suas bordas.
          child: oculta // Escolhe entre o desenho do verso e a frente da carta.
              ? Padding( // Se estiver oculta, começa o verso com uma margem interna.
                  padding: const EdgeInsets.all(6), // Aplica a mesma distância interna nos quatro lados.
                  child: DecoratedBox( // Começa a decoração ao redor do conteúdo.
                    decoration: BoxDecoration( // Começa a definição de fundo, bordas e outros detalhes da caixa.
                      border: Border.all(color: const Color(0xFFD7B25F)), // Desenha a borda dourada interna do verso.
                      borderRadius: BorderRadius.circular(8), // Arredonda os cantos com o raio indicado.
                    ), // Conclui a aparência da caixa.
                    child: CustomPaint( // Começa o desenho feito pelo aplicativo.
                      painter: const _Trama( // Seleciona o desenho local da textura do verso.
                        cor: Color(0x55BFA362), // Usa um dourado parcialmente transparente para as linhas do verso.
                        diagonal: true, // Escolhe linhas cruzadas em diagonal em vez da malha do fundo.
                      ), // Conclui o desenho da textura.
                      child: const Center( // Centraliza o símbolo decorativo do verso.
                        child: Text( // Começa o texto exibido na tela.
                          '♠\uFE0E', // Fornece este texto à função ou ao componente que o envolve.
                          style: TextStyle( // Começa a configuração da aparência deste texto.
                            fontFamily: 'Gelasio', // Escolhe a fonte usada para desenhar as letras.
                            fontFamilyFallback: ['Naipes'], // Usa a fonte de naipes quando a fonte principal não tiver o símbolo.
                            fontSize: 40, // Define o tamanho das letras deste texto.
                            color: Color(0xFFE8C778), // Colore o símbolo do verso com dourado claro.
                          ), // Conclui o estilo das letras.
                        ), // Conclui o texto exibido na tela.
                      ), // Conclui a centralização do conteúdo.
                    ), // Conclui o desenho feito pelo aplicativo.
                  ), // Conclui a decoração ao redor do conteúdo.
                ) // Conclui o espaçamento interno.
              : carta.imagem.isEmpty // Quando a carta está aberta, verifica se falta o endereço de sua imagem.
              ? _frente() // Sem endereço, desenha valor e naipe usando os componentes locais.
              : Image.network( // Com endereço, tenta carregar a imagem da frente pela internet.
                  carta.imagem, // Fornece o endereço da imagem recebido junto da carta.
                  fit: BoxFit.fill, // Preenche a área da carta com a imagem carregada.
                  loadingBuilder: (_, imagem, progresso) => // Define o que mostrar enquanto a imagem está sendo baixada.
                      progresso == null ? imagem : _frente(), // Mostra a imagem pronta ou a frente local enquanto o download continua.
                  errorBuilder: (_, erro, pilha) => _frente(), // Usa a frente local se o carregamento da imagem falhar.
                ), // Conclui a imagem da carta.
        ), // Conclui a caixa de conteúdo.
      ), // Conclui a adaptação do texto à carta.
    ), // Conclui a remoção de descrições repetidas.
  ); // Conclui a descrição para leitores de tela.

  // --------------------------------------------------------------------------
  // FRENTE DESENHADA LOCALMENTE
  // Mostra valor e naipe nos cantos e um símbolo maior no centro.
  // A cor depende do naipe e o canto inferior é girado como numa carta física.
  // --------------------------------------------------------------------------
  Widget _frente() => DefaultTextStyle( // Define uma frente de carta desenhada com textos e símbolos locais.
    style: TextStyle( // Começa a configuração da aparência deste texto.
      fontFamily: 'Gelasio', // Escolhe a fonte usada para desenhar as letras.
      fontFamilyFallback: const ['Naipes'], // Usa a fonte de naipes quando a fonte principal não tiver o símbolo.
      color: carta.vermelha ? const Color(0xFFAB3A40) : const Color(0xFF233B32), // Usa vermelho para copas e ouros, e tom escuro para os outros naipes.
      fontSize: largura / 4.5, // Define o tamanho das letras deste texto.
      fontWeight: FontWeight.w700, // Define a espessura das letras, como normal ou negrito.
    ), // Conclui o estilo das letras.
    child: Padding( // Começa o espaçamento interno.
      padding: const EdgeInsets.all(8), // Aplica a mesma distância interna nos quatro lados.
      child: Stack( // Começa a sobreposição dos elementos.
        children: [ // Começa a lista de elementos que aparecem neste grupo.
          Align( // Começa o alinhamento do conteúdo.
            alignment: Alignment.topLeft, // Coloca o valor e o naipe no canto superior esquerdo.
            child: Text( // Começa o texto exibido na tela.
              '${carta.valor}\n${carta.simbolo}\uFE0E', // Fornece este texto à função ou ao componente que o envolve.
              style: const TextStyle(height: 1.05), // Mantém as duas linhas do canto próximas uma da outra.
            ), // Conclui o texto exibido na tela.
          ), // Conclui o alinhamento do conteúdo.
          Center( // Começa a centralização do conteúdo.
            child: Text( // Começa o texto exibido na tela.
              '${carta.simbolo}\uFE0E', // Fornece este texto à função ou ao componente que o envolve.
              style: TextStyle(fontSize: largura / 2), // Faz o símbolo central ter metade da largura da carta como tamanho.
            ), // Conclui o texto exibido na tela.
          ), // Conclui a centralização do conteúdo.
          Align( // Começa o alinhamento do conteúdo.
            alignment: Alignment.bottomRight, // Coloca o segundo valor e naipe no canto inferior direito.
            child: RotatedBox( // Começa a rotação do conteúdo.
              quarterTurns: 2, // Gira o conteúdo em dois quartos de volta, ou 180 graus.
              child: Text( // Começa o texto exibido na tela.
                '${carta.valor}\n${carta.simbolo}\uFE0E', // Fornece este texto à função ou ao componente que o envolve.
                style: const TextStyle(height: 1.05), // Mantém as duas linhas do canto próximas uma da outra.
              ), // Conclui o texto exibido na tela.
            ), // Conclui a rotação do conteúdo.
          ), // Conclui o alinhamento do conteúdo.
        ], // Conclui a lista de elementos da tela.
      ), // Conclui a sobreposição dos elementos.
    ), // Conclui o espaçamento interno.
  ); // Conclui o estilo compartilhado do texto.
} // Conclui a definição desta classe.

// --------------------------------------------------------------------------
// TEXTURA DO FUNDO E DO VERSO
// Desenha linhas leves sobre o fundo ou cruzadas no verso das cartas.
// A cor e o tipo de trama determinam quando o desenho precisa ser atualizado.
// --------------------------------------------------------------------------
class _Trama extends CustomPainter { // Define um desenho personalizado para a textura de mesa e cartas.
  const _Trama({required this.cor, this.diagonal = false}); // Recebe a cor e usa malha reta por padrão, com opção de diagonais.
  final Color cor; // Guarda a cor que será usada nas linhas.
  final bool diagonal; // Guarda se as linhas devem ser cruzadas em diagonal.

  // --------------------------------------------------------------------------
  // DESENHO DAS LINHAS DA TEXTURA
  // Cria um pincel e percorre a área com linhas igualmente espaçadas.
  // A opção diagonal cruza linhas; a outra opção forma uma malha horizontal e vertical.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  void paint(Canvas tela, Size tamanho) { // Recebe a área de desenho e suas dimensões para pintar a textura.
    final pincel = Paint() // Cria o pincel virtual que desenhará as linhas.
      ..color = cor // Define a cor no mesmo pincel que acabou de ser criado.
      ..strokeWidth = .6; // Define a espessura de cada linha em 0,6 unidade.
    if (diagonal) { // Escolhe o padrão de linhas diagonais para o verso da carta.
      for ( // Começa a repetição que percorre as posições das linhas diagonais.
        double x = -tamanho.height; // Inicia antes da borda para as diagonais cobrirem toda a área.
        x < tamanho.width + tamanho.height; // Continua até ultrapassar a largura o suficiente para completar as diagonais.
        x += 12 // Avança doze unidades entre um par de linhas e o próximo.
      ) { // Termina a declaração ou condição e começa as instruções deste bloco.
        tela.drawLine( // Desenha uma linha usando os dois pontos e o pincel a seguir.
          Offset(x, 0), // Define o ponto inicial da linha no topo da área.
          Offset(x + tamanho.height, tamanho.height), // Define o ponto inferior para uma diagonal que desce para a direita.
          pincel, // Usa a cor e a espessura configuradas no pincel.
        ); // Conclui o bloco desenho das linhas da textura.
        tela.drawLine( // Desenha uma linha usando os dois pontos e o pincel a seguir.
          Offset(x, 0), // Define o ponto inicial da linha no topo da área.
          Offset(x - tamanho.height, tamanho.height), // Define o ponto inferior para uma diagonal que desce para a esquerda.
          pincel, // Usa a cor e a espessura configuradas no pincel.
        ); // Conclui o bloco desenho das linhas da textura.
      } // Conclui a repetição dos itens.
    } else { // Executa a alternativa quando a condição anterior não é atendida.
      for (double x = 0; x < tamanho.width; x += 5) { // Percorre a largura em passos de cinco unidades para desenhar linhas verticais.
        tela.drawLine(Offset(x, 0), Offset(x, tamanho.height), pincel); // Traça uma linha do topo ao fundo na posição horizontal atual.
      } // Conclui a repetição dos itens.
      for (double y = 0; y < tamanho.height; y += 5) { // Percorre a altura em passos de cinco unidades para desenhar linhas horizontais.
        tela.drawLine(Offset(0, y), Offset(tamanho.width, y), pincel); // Traça uma linha da esquerda à direita na altura atual.
      } // Conclui a repetição dos itens.
    } // Conclui a condição verificada.
  } // Conclui o bloco desenho das linhas da textura.

  // --------------------------------------------------------------------------
  // DECISÃO DE REDESENHAR A TEXTURA
  // Compara a cor e a orientação com o desenho anterior.
  // Só pede uma nova pintura quando uma dessas características muda.
  // --------------------------------------------------------------------------
  @override // Indica que esta parte fornece um comportamento previsto pela classe-base.
  bool shouldRepaint(_Trama anterior) => // Define quando é necessário substituir a textura já desenhada.
      anterior.cor != cor || anterior.diagonal != diagonal; // Solicita nova pintura somente se mudar a cor ou a orientação das linhas.
} // Conclui a definição desta classe.
