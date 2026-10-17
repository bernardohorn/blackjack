# Sumário do código para apresentação

[Voltar ao README](../README.md) · [Guia para iniciantes](CODIGO.md)

Use esta página para localizar uma parte do aplicativo pelo assunto, pelo nome da função ou pelo endpoint. O sumário geral também está no começo de `lib/main.dart`; os outros arquivos de `lib/` têm seus próprios índices.

**Como ler:** início e fim são linhas inclusivas da declaração, do nome da função até seu fechamento. Os comentários de título imediatamente anteriores ajudam a explicar o bloco. No editor, abra o arquivo e use **Ir para linha**; no VS Code, o atalho é `Ctrl+G`. No GitHub, os links das tabelas levam ao trecho indicado.

**Manutenção:** os números já consideram os cabeçalhos inseridos nesta edição. Ao acrescentar, remover ou mover linhas, atualize os sumários; a pesquisa pelo nome completo continua funcionando.

## Perguntas rápidas do professor

| Pergunta | Onde procurar | O que explicar |
| --- | --- | --- |
| Onde o app começa? | [lib/main.dart:171-174](../lib/main.dart#L171-L174) | Conecta os componentes e chama runApp. |
| Onde muda o tema e o idioma? | [lib/main.dart:217-268](../lib/main.dart#L217-L268) | Configura português e aparência do aplicativo. |
| Onde são calculados os pontos e o Ás? | [lib/regras.dart:101-113](../lib/regras.dart#L101-L113) | Soma a mão e ajusta ases para evitar estouro. |
| Como decide quem ganhou? | [lib/regras.dart:138-181](../lib/regras.dart#L138-L181) | Respeita a prioridade de estouro, naturais e comparação. |
| Onde está a regra da banca? | [lib/regras.dart:128-131](../lib/regras.dart#L128-L131) | Aplica a parada em 17 e a opção de 17 suave. |
| Onde chama a API para criar o baralho? | [lib/api.dart:113-127](../lib/api.dart#L113-L127) | Usa new/shuffle e confere o total de cartas. |
| Onde compra e valida uma carta? | [lib/api.dart:134-177](../lib/api.dart#L134-L177) | Usa draw; verifica identidade, quantidade, contagem e cartas. |
| Onde configura URL, GET e timeout? | [lib/api.dart:67-87](../lib/api.dart#L67-L87) | Centraliza endereço, envio e validações comuns. |
| Onde trata erro e evita compra duplicada? | [lib/jogo.dart:159-197](../lib/jogo.dart#L159-L197) | Bloqueia ações paralelas, salva pendência e trata a falha. |
| Onde salva a partida? | [lib/jogo.dart:111-118](../lib/jogo.dart#L111-L118) | Monta o JSON que MemoriaLocal grava no dispositivo. |
| Onde recupera uma partida salva? | [lib/jogo.dart:125-152](../lib/jogo.dart#L125-L152) | Confere formato, pendência e expiração. |
| Onde distribui as quatro cartas? | [lib/jogo.dart:239-251](../lib/jogo.dart#L239-L251) | Alterna jogador e banca e verifica naturais. |
| Onde acontece Pedir carta? | [lib/jogo.dart:271-279](../lib/jogo.dart#L271-L279) | Compra uma carta e resolve 21 ou estouro. |
| Onde a banca joga sozinha? | [lib/jogo.dart:296-306](../lib/jogo.dart#L296-L306) | Compra uma por vez enquanto a regra exigir. |
| Onde renova o baralho no corte? | [lib/jogo.dart:219-232](../lib/jogo.dart#L219-L232) | Consulta Mesa.renovar e cria outro shoe quando necessário. |
| Onde ficam os botões da partida? | [lib/telas.dart:655-787](../lib/telas.dart#L655-L787) | Monta Pedir carta, Parar, Nova rodada e mensagens. |
| Onde ficam as configurações? | [lib/telas.dart:921-1017](../lib/telas.dart#L921-L1017) | Mostra controles de baralhos, banca, efeitos e tema. |
| Onde oculta a carta da banca? | [lib/telas.dart:1042-1098](../lib/telas.dart#L1042-L1098) | Escolhe verso ou frente e protege a descrição acessível. |
| Onde trata imagem indisponível? | [lib/telas.dart:1042-1098](../lib/telas.dart#L1042-L1098) | Mostra a frente local enquanto carrega ou se ocorrer erro. |

## Endpoints e pontos de chamada

O aplicativo utiliza dois endpoints de cartas, ambos por GET. `N` é a quantidade enviada; `{deck_id}` é o identificador real recebido na criação. Não há servidor próprio, autenticação ou endpoint para calcular pontos.

| Endereço | Implementação | Linha que monta o caminho | Uso |
| --- | --- | --- | --- |
| `GET https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=N` | [lib/api.dart:113-127](../lib/api.dart#L113-L127) | [linha 114](../lib/api.dart#L114) | Criar shoe (N de 1 a 6). |
| `GET https://deckofcardsapi.com/api/deck/{deck_id}/draw/?count=N` | [lib/api.dart:134-177](../lib/api.dart#L134-L177) | [linha 141](../lib/api.dart#L141) | Comprar cartas: N=4 na distribuição; N=1 nas jogadas. |

| Ação do jogo | Função e intervalo | Relação com a API |
| --- | --- | --- |
| Novo jogo | `Jogo.novoJogo()` — [lib/jogo.dart:204-212](../lib/jogo.dart#L204-L212) | Cria shoe e depois distribui. |
| Renovar shoe | `Jogo.novaRodada()` — [lib/jogo.dart:219-232](../lib/jogo.dart#L219-L232) | Cria outro shoe quando atinge o corte. |
| Distribuir quatro cartas | `Jogo._distribuir()` — [lib/jogo.dart:239-251](../lib/jogo.dart#L239-L251) | draw com count=4. |
| Jogador pede carta | `Jogo.pedirCarta()` — [lib/jogo.dart:271-279](../lib/jogo.dart#L271-L279) | draw com count=1, via _comprar. |
| Banca compra cartas | `Jogo._jogarBanca()` — [lib/jogo.dart:296-306](../lib/jogo.dart#L296-L306) | draw com count=1 por compra, via _comprar. |
| Compra compartilhada | `Jogo._comprar()` — [lib/jogo.dart:258-264](../lib/jogo.dart#L258-L264) | Chama ApiBaralho.comprar e atualiza a mesa. |
| Requisição HTTP e prazo | `ApiBaralho._consultar()` — [lib/api.dart:67-87](../lib/api.dart#L67-L87) | Uma tentativa GET, com prazo de espera configurado. |

As imagens têm URLs variáveis: a preferência por `images.png` e a alternativa `image` estão em [lib/api.dart:155](../lib/api.dart#L155); o carregamento está em [lib/telas.dart:1088](../lib/telas.dart#L1088). A carta fechada usa desenho local. Menu, regras, pontuação, revelação, pausa e retomada não chamam endpoints de cartas.

## Todas as declarações do aplicativo

A lista inclui funções, métodos, consultas `get`, construtores, classes e opções `enum`. Uma classe agrupa dados e funções; o construtor com o mesmo nome cria um objeto dessa classe. Funções internas sem nome, como ações de botões, estão dentro do intervalo do método que as contém.

### lib/main.dart

Entrada do app, idioma, tema e ligação dos componentes.

| Nome completo | Tipo | Início e fim | O que faz |
| --- | --- | --- | --- |
| `main` | função | [lib/main.dart:171-174](../lib/main.dart#L171-L174) | Define a primeira função executada ao abrir o aplicativo. |
| `Clube21` | classe | [lib/main.dart:181-186](../lib/main.dart#L181-L186) | Define o componente principal, cujo estado acompanha o ciclo do app. |
| `Clube21` | construtor | [lib/main.dart:182-182](../lib/main.dart#L182-L182) | Recebe o controlador obrigatório e a identificação opcional do componente. |
| `Clube21.createState` | método | [lib/main.dart:185-185](../lib/main.dart#L185-L185) | Cria o objeto que cuidará da abertura, do tema e da limpeza. |
| `_Clube21State` | classe | [lib/main.dart:193-269](../lib/main.dart#L193-L269) | Define o estado associado ao componente principal. |
| `_Clube21State.initState` | método | [lib/main.dart:195-198](../lib/main.dart#L195-L198) | Define a preparação executada uma vez quando o estado é criado. |
| `_Clube21State.dispose` | método | [lib/main.dart:206-209](../lib/main.dart#L206-L209) | Define a limpeza feita quando este objeto deixa de ser usado. |
| `_Clube21State.build` | método | [lib/main.dart:217-268](../lib/main.dart#L217-L268) | Define a interface principal que acompanha mudanças no controlador. |

### lib/regras.dart

Cartas, pontos, naturais, resultados e dados salvos.

| Nome completo | Tipo | Início e fim | O que faz |
| --- | --- | --- | --- |
| `Fase` | opções | [lib/regras.dart:45-45](../lib/regras.dart#L45-L45) | Nomeia as três etapas possíveis de uma rodada. |
| `Carta` | classe | [lib/regras.dart:52-94](../lib/regras.dart#L52-L94) | Define quais dados e cálculos pertencem a uma carta. |
| `Carta` | construtor | [lib/regras.dart:53-53](../lib/regras.dart#L53-L53) | Cria a carta com um código e uma imagem opcional, vazia por padrão. |
| `Carta.valor` | consulta | [lib/regras.dart:57-57](../lib/regras.dart#L57-L57) | Lê o valor na primeira posição e traduz o código 0 para dez. |
| `Carta.simbolo` | consulta | [lib/regras.dart:58-59](../lib/regras.dart#L58-L59) | Define a leitura do símbolo gráfico do naipe. |
| `Carta.vermelha` | consulta | [lib/regras.dart:60-60](../lib/regras.dart#L60-L60) | Marca copas e ouros como cartas vermelhas. |
| `Carta.pontos` | consulta | [lib/regras.dart:61-61](../lib/regras.dart#L61-L61) | Conta Ás como 11, números pelo valor e figuras como 10. |
| `Carta.descricao` | consulta | [lib/regras.dart:68-79](../lib/regras.dart#L68-L79) | Monta o nome completo da carta para leitura em português. |
| `Carta.salvar` | método | [lib/regras.dart:86-86](../lib/regras.dart#L86-L86) | Converte a carta em dois campos simples para poder salvá-la. |
| `Carta.ler` | construtor | [lib/regras.dart:87-93](../lib/regras.dart#L87-L93) | Reconstrói uma carta a partir dos campos recebidos. |
| `pontuar` | função | [lib/regras.dart:101-113](../lib/regras.dart#L101-L113) | Soma a mão e reduz ases de 11 para 1 quando necessário. |
| `natural` | função | [lib/regras.dart:120-121](../lib/regras.dart#L120-L121) | Reconhece Blackjack natural: duas cartas somando 21. |
| `bancaCompra` | função | [lib/regras.dart:128-131](../lib/regras.dart#L128-L131) | Decide quando a banca compra, incluindo a regra do 17 suave. |
| `resultado` | função | [lib/regras.dart:138-181](../lib/regras.dart#L138-L181) | Decide vitória, derrota, empate, natural e estouro. |
| `Preferencias` | classe | [lib/regras.dart:188-218](../lib/regras.dart#L188-L218) | Agrupa as escolhas do jogador que podem ser salvas. |
| `Preferencias` | construtor | [lib/regras.dart:189-195](../lib/regras.dart#L189-L195) | Começa a criação das preferências com valores padrão. |
| `Preferencias.salvar` | método | [lib/regras.dart:204-210](../lib/regras.dart#L204-L210) | Devolve um mapa de campos simples para o salvamento deste objeto. |
| `Preferencias.ler` | construtor | [lib/regras.dart:211-217](../lib/regras.dart#L211-L217) | Recupera as preferências a partir dos campos guardados. |
| `Mesa` | classe | [lib/regras.dart:225-292](../lib/regras.dart#L225-L292) | Define os dados necessários para jogar e retomar uma mesa. |
| `Mesa` | construtor | [lib/regras.dart:226-231](../lib/regras.dart#L226-L231) | Começa a criação de uma mesa com informações obrigatórias. |
| `Mesa.renovar` | consulta | [lib/regras.dart:239-239](../lib/regras.dart#L239-L239) | Pede renovação com 25% ou menos do total, ou menos de quatro cartas. |
| `Mesa.salvar` | método | [lib/regras.dart:246-256](../lib/regras.dart#L246-L256) | Devolve um mapa de campos simples para o salvamento deste objeto. |
| `Mesa.ler` | construtor | [lib/regras.dart:263-291](../lib/regras.dart#L263-L291) | Define a reconstrução e a validação de uma mesa salva. |

### lib/api.dart

URLs, prazo de espera e validação das respostas da API.

| Nome completo | Tipo | Início e fim | O que faz |
| --- | --- | --- | --- |
| `ApiBaralho` | classe | [lib/api.dart:57-178](../lib/api.dart#L57-L178) | Define o componente responsável por conversar com o serviço de cartas. |
| `ApiBaralho` | construtor | [lib/api.dart:58-58](../lib/api.dart#L58-L58) | Recebe o cliente HTTP e usa dez segundos como prazo padrão. |
| `ApiBaralho._consultar` | método | [lib/api.dart:67-87](../lib/api.dart#L67-L87) | Monta a URL HTTPS, envia GET e confere a resposta comum. |
| `ApiBaralho._restantes` | método | [lib/api.dart:94-106](../lib/api.dart#L94-L106) | Valida a contagem de cartas recebida da API. |
| `ApiBaralho.criar` | método | [lib/api.dart:113-127](../lib/api.dart#L113-L127) | Cria um shoe embaralhado com a quantidade escolhida de baralhos. |
| `ApiBaralho.comprar` | método | [lib/api.dart:134-177](../lib/api.dart#L134-L177) | Compra cartas e valida ID, quantidade, contagem, valor e naipe. |

### lib/jogo.dart

Turnos, compras, renovação, salvamento e recuperação.

| Nome completo | Tipo | Início e fim | O que faz |
| --- | --- | --- | --- |
| `Armazenamento` | classe | [lib/jogo.dart:65-68](../lib/jogo.dart#L65-L68) | Define as operações que qualquer forma de armazenamento precisa oferecer. |
| `Armazenamento.ler` | método | [lib/jogo.dart:66-66](../lib/jogo.dart#L66-L66) | Exige uma leitura que pode devolver texto salvo ou nada, após uma espera. |
| `Armazenamento.salvar` | método | [lib/jogo.dart:67-67](../lib/jogo.dart#L67-L67) | Exige uma gravação de texto que informa quando terminou. |
| `MemoriaLocal` | classe | [lib/jogo.dart:75-82](../lib/jogo.dart#L75-L82) | Implementa a leitura e a gravação usando o armazenamento do dispositivo. |
| `MemoriaLocal.ler` | método | [lib/jogo.dart:78-78](../lib/jogo.dart#L78-L78) | Lê o texto guardado na entrada clube21. |
| `MemoriaLocal.salvar` | método | [lib/jogo.dart:80-81](../lib/jogo.dart#L80-L81) | Define a gravação do texto fornecido. |
| `Jogo` | classe | [lib/jogo.dart:89-350](../lib/jogo.dart#L89-L350) | Define o controlador capaz de avisar as telas sobre mudanças no jogo. |
| `Jogo` | construtor | [lib/jogo.dart:90-94](../lib/jogo.dart#L90-L94) | Começa a criação do controlador e a definição de suas dependências. |
| `Jogo._salvar` | método | [lib/jogo.dart:111-118](../lib/jogo.dart#L111-L118) | Guarda preferências, mesa e marca de operação pendente. |
| `Jogo.carregar` | método | [lib/jogo.dart:125-152](../lib/jogo.dart#L125-L152) | Recupera a partida; rejeita pendência, dados inválidos e expiração. |
| `Jogo._executar` | método | [lib/jogo.dart:159-197](../lib/jogo.dart#L159-L197) | Bloqueia ações simultâneas, salva antes/depois e trata falhas. |
| `Jogo.novoJogo` | método | [lib/jogo.dart:204-212](../lib/jogo.dart#L204-L212) | Cria outro shoe e distribui as quatro primeiras cartas. |
| `Jogo.novaRodada` | método | [lib/jogo.dart:219-232](../lib/jogo.dart#L219-L232) | Continua no shoe ou renova após o corte de 25%. |
| `Jogo._distribuir` | método | [lib/jogo.dart:239-251](../lib/jogo.dart#L239-L251) | Compra quatro cartas, alterna as mãos e verifica naturais. |
| `Jogo._comprar` | método | [lib/jogo.dart:258-264](../lib/jogo.dart#L258-L264) | Centraliza a compra e atualiza contagem e horário. |
| `Jogo.pedirCarta` | método | [lib/jogo.dart:271-279](../lib/jogo.dart#L271-L279) | Compra uma carta; verifica estouro ou passagem automática ao atingir 21. |
| `Jogo.parar` | método | [lib/jogo.dart:286-289](../lib/jogo.dart#L286-L289) | Entrega a vez à banca sem mudar a mão do jogador. |
| `Jogo._jogarBanca` | método | [lib/jogo.dart:296-306](../lib/jogo.dart#L296-L306) | Revela a mão, compra conforme a regra e encerra a rodada. |
| `Jogo.configurar` | método | [lib/jogo.dart:313-328](../lib/jogo.dart#L313-L328) | Define a tentativa de aplicar e salvar novas preferências. |
| `Jogo.limparErro` | método | [lib/jogo.dart:335-338](../lib/jogo.dart#L335-L338) | Define a ação que retira a mensagem de erro atual. |
| `Jogo.dispose` | método | [lib/jogo.dart:346-349](../lib/jogo.dart#L346-L349) | Define a limpeza feita quando este objeto deixa de ser usado. |

### lib/telas.dart

Menu, mesa, configurações, botões, cartas e textura.

| Nome completo | Tipo | Início e fim | O que faz |
| --- | --- | --- | --- |
| `Pagina` | opções | [lib/telas.dart:79-79](../lib/telas.dart#L79-L79) | Dá um nome a cada página disponível na navegação. |
| `Telas` | classe | [lib/telas.dart:86-91](../lib/telas.dart#L86-L91) | Define a interface que acompanha qual página está aberta. |
| `Telas` | construtor | [lib/telas.dart:87-87](../lib/telas.dart#L87-L87) | Recebe o controlador e a identificação opcional deste componente. |
| `Telas.createState` | método | [lib/telas.dart:90-90](../lib/telas.dart#L90-L90) | Cria o estado que guarda a navegação e os efeitos sonoros. |
| `_TelasState` | classe | [lib/telas.dart:98-1018](../lib/telas.dart#L98-L1018) | Define os dados e comportamentos locais das páginas. |
| `_TelasState.jogo` | consulta | [lib/telas.dart:101-101](../lib/telas.dart#L101-L101) | Oferece um atalho para o controlador recebido pelo componente. |
| `_TelasState.dourado` | consulta | [lib/telas.dart:102-102](../lib/telas.dart#L102-L102) | Obtém a cor de destaque adequada ao tema atual. |
| `_TelasState.escuro` | consulta | [lib/telas.dart:103-103](../lib/telas.dart#L103-L103) | Consulta se a apresentação deve usar o tema escuro. |
| `_TelasState.dispose` | método | [lib/telas.dart:111-114](../lib/telas.dart#L111-L114) | Define a limpeza feita quando este objeto deixa de ser usado. |
| `_TelasState._retorno` | método | [lib/telas.dart:121-136](../lib/telas.dart#L121-L136) | Define os efeitos opcionais produzidos após um toque. |
| `_TelasState._abrir` | método | [lib/telas.dart:143-143](../lib/telas.dart#L143-L143) | Troca a página escolhida e pede ao Flutter para atualizar a interface. |
| `_TelasState._confirmar` | método | [lib/telas.dart:150-191](../lib/telas.dart#L150-L191) | Define uma pergunta que devolverá a escolha de confirmar ou não. |
| `_TelasState._novoJogo` | método | [lib/telas.dart:198-212](../lib/telas.dart#L198-L212) | Define o que a interface faz quando a pessoa pede um novo jogo. |
| `_TelasState._voltar` | método | [lib/telas.dart:219-233](../lib/telas.dart#L219-L233) | Define o retorno ao menu e a confirmação de pausa. |
| `_TelasState.build` | método | [lib/telas.dart:241-293](../lib/telas.dart#L241-L293) | Monta a página e controla o comportamento de voltar do sistema. |
| `_TelasState._cabecalho` | método | [lib/telas.dart:300-335](../lib/telas.dart#L300-L335) | Define o cabeçalho como elementos dispostos lado a lado. |
| `_TelasState._titulo` | método | [lib/telas.dart:342-353](../lib/telas.dart#L342-L353) | Define um título com texto obrigatório, tamanho padrão e cor opcional. |
| `_TelasState._legenda` | método | [lib/telas.dart:360-368](../lib/telas.dart#L360-L368) | Define um texto explicativo com aparência padronizada. |
| `_TelasState._selo` | método | [lib/telas.dart:375-388](../lib/telas.dart#L375-L388) | Define uma pequena caixa arredondada para uma informação curta. |
| `_TelasState._painel` | método | [lib/telas.dart:395-406](../lib/telas.dart#L395-L406) | Define uma caixa de conteúdo com destaque opcional de derrota. |
| `_TelasState._botao` | método | [lib/telas.dart:413-460](../lib/telas.dart#L413-L460) | Define a construção de um botão reutilizável. |
| `_TelasState._marca` | método | [lib/telas.dart:467-496](../lib/telas.dart#L467-L496) | Define o espaço e as cartas decorativas da marca. |
| `_TelasState._abertura` | método | [lib/telas.dart:503-516](../lib/telas.dart#L503-L516) | Define os elementos mostrados durante a abertura do aplicativo. |
| `_TelasState._menu` | método | [lib/telas.dart:523-569](../lib/telas.dart#L523-L569) | Define os elementos e ações do menu principal. |
| `_TelasState._carregando` | método | [lib/telas.dart:576-611](../lib/telas.dart#L576-L611) | Define o conteúdo mostrado enquanto a mesa é preparada. |
| `_TelasState._erro` | método | [lib/telas.dart:618-648](../lib/telas.dart#L618-L648) | Define as mensagens e ações da página de falha. |
| `_TelasState._mesa` | método | [lib/telas.dart:655-787](../lib/telas.dart#L655-L787) | Monta as mãos, mensagens, resultado e botões Pedir/Parar/Nova rodada. |
| `_TelasState._mao` | método | [lib/telas.dart:794-837](../lib/telas.dart#L794-L837) | Define a exibição de uma mão, permitindo ocultar a segunda carta. |
| `_TelasState._regras` | método | [lib/telas.dart:844-881](../lib/telas.dart#L844-L881) | Define os elementos da página que ensina a jogar. |
| `_TelasState._configurar` | método | [lib/telas.dart:888-892](../lib/telas.dart#L888-L892) | Recebe uma função que modifica uma preferência na cópia criada aqui. |
| `_TelasState._opcao` | método | [lib/telas.dart:899-914](../lib/telas.dart#L899-L914) | Define uma preferência apresentada como interruptor de ligar ou desligar. |
| `_TelasState._configuracoes` | método | [lib/telas.dart:921-1017](../lib/telas.dart#L921-L1017) | Define os controles e textos da página de preferências. |
| `CartaVisual` | classe | [lib/telas.dart:1025-1144](../lib/telas.dart#L1025-L1144) | Define uma carta visual que depende apenas dos dados recebidos. |
| `CartaVisual` | construtor | [lib/telas.dart:1026-1031](../lib/telas.dart#L1026-L1031) | Começa a criação do componente visual da carta. |
| `CartaVisual.build` | método | [lib/telas.dart:1042-1098](../lib/telas.dart#L1042-L1098) | Escolhe frente/verso, acessibilidade e carregamento da imagem. |
| `CartaVisual._frente` | método | [lib/telas.dart:1105-1143](../lib/telas.dart#L1105-L1143) | Define uma frente de carta desenhada com textos e símbolos locais. |
| `_Trama` | classe | [lib/telas.dart:1151-1201](../lib/telas.dart#L1151-L1201) | Define um desenho personalizado para a textura de mesa e cartas. |
| `_Trama` | construtor | [lib/telas.dart:1152-1152](../lib/telas.dart#L1152-L1152) | Recebe a cor e usa malha reta por padrão, com opção de diagonais. |
| `_Trama.paint` | método | [lib/telas.dart:1162-1191](../lib/telas.dart#L1162-L1191) | Recebe a área de desenho e suas dimensões para pintar a textura. |
| `_Trama.shouldRepaint` | método | [lib/telas.dart:1199-1200](../lib/telas.dart#L1199-L1200) | Define quando é necessário substituir a textura já desenhada. |

Os testes ficam em `test/`. Este índice cobre o código do aplicativo em `lib/`; os arquivos gerados de Android, iOS, web e desktop são projetos de integração de plataforma.
