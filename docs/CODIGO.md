# Entendendo o código

[← Voltar ao README](../README.md)

O aplicativo tem cinco arquivos de código próprio. Leia nesta ordem:

| Arquivo | Em uma frase |
| --- | --- |
| [`lib/regras.dart`](../lib/regras.dart) | Define as cartas, conta pontos e decide quem ganhou. |
| [`lib/api.dart`](../lib/api.dart) | Pede baralhos/cartas ao servidor e verifica as respostas. |
| [`lib/jogo.dart`](../lib/jogo.dart) | Coordena cada jogada e salva o estado no dispositivo. |
| [`lib/telas.dart`](../lib/telas.dart) | Desenha a interface e conecta os botões às ações do jogo. |
| [`lib/main.dart`](../lib/main.dart) | Liga tudo e inicia o aplicativo em português. |

Para localizar uma função durante a apresentação, abra o **[sumário com arquivos e linhas](SUMARIO.md)**. Ele inclui todos os métodos, consultas, construtores e classes do aplicativo, além dos endpoints e de perguntas rápidas. O mesmo índice geral está no início de `lib/main.dart`; cada outro arquivo tem seu índice local.

## Como ler a versão comentada

Os cinco arquivos de `lib/` estão divididos por funcionamento. Cada bloco começa com uma linha de tracinhos, um título em português e uma explicação do que faz e por que existe. Ao lado de cada linha de código, um comentário curto explica sua função, incluindo condições, parâmetros e fechamento dos blocos.

Se uma linha ficar larga no editor, ative a quebra automática de linha para ler o comentário sem rolar para os lados. Para apresentar, leia primeiro o título e a explicação do bloco. Depois acompanhe as linhas de cima para baixo. Os comentários são anotações para quem lê: não são comandos executados pelo aplicativo.

No começo de cada arquivo, `// dart format off` preserva esta disposição didática. A formatação automática do Dart normalmente move os comentários e quebra as linhas; essa instrução mantém as explicações ao lado de seus comandos. O código mantém a organização e a indentação da versão anterior.

### Pequeno dicionário de leitura

| Encontrou no código | Como explicar |
| --- | --- |
| `//` | O restante da linha é uma explicação para a pessoa que lê. |
| `class` | Define um tipo de objeto, reunindo seus dados e comportamentos. |
| `final` | Depois de receber um valor, essa variável não pode ser apontada para outro. O objeto em si ainda pode permitir alterações. |
| `const` | Define um valor constante, conhecido antes da execução. |
| `var`, `int`, `String`, `bool` | Declaram um dado; os três últimos indicam inteiro, texto e verdadeiro/falso. `var` deixa o Dart reconhecer o tipo. |
| `List` e `Map` | Uma lista ordenada de itens e uma coleção de nomes associados a valores. A primeira posição da lista é zero. |
| `if`, `else`, `&&`, `||` | Testam condições, escolhem alternativas e combinam requisitos com “e” ou “ou”. |
| `for` e `while` | Repetem uma ação para cada item ou enquanto uma condição for verdadeira. |
| `return` e `=>` | Devolvem um resultado; `return` também pode encerrar uma ação, e `=>` escreve uma função de expressão única. |
| `Future`, `async`, `await` | Representam uma operação que termina depois, permitem aguardar nela e aguardam seu resultado sem bloquear o restante da interface. |
| `try`, `catch`, `finally`, `throw` | Tentam uma operação, tratam falhas, executam a finalização e sinalizam um erro. |
| `?`, `?.`, `??` | Podem indicar dado ausente, acesso somente se houver objeto ou uma alternativa para um valor ausente. |
| `condição ? valorA : valorB` | Escolhe o primeiro valor quando a condição é verdadeira; caso contrário, escolhe o segundo. |
| `!` | Antes de uma condição, inverte verdadeiro/falso. Depois de um valor, afirma que ele não está ausente; se estiver, ocorre erro. |
| `get` e `factory` | Calculam uma informação ao consultá-la e oferecem uma forma de criar ou recuperar um objeto. |
| `Widget`, `build`, `child`, `children` | Representam um pedaço da interface, sua construção, um elemento dentro dele e uma lista de elementos dentro dele. |
| `setState` e `notifyListeners` | Pedem a atualização da tela local e avisam quem acompanha as mudanças do controlador. |
| `_` no começo de um nome | Indica que aquele recurso é interno à biblioteca Dart. |
| `()`, `{}`, `[]` | Agrupam parâmetros e expressões, delimitam blocos ou mapas, e delimitam listas ou acessam seus itens, conforme o contexto. |

Essa edição alterou comentários e guias de leitura. As instruções executáveis foram comparadas com a versão anterior e preservadas. Os projetos de plataforma gerados pelo Flutter e os testes continuam separados do código do aplicativo.

## Exemplo: o que acontece ao pedir carta?

1. O botão em `telas.dart` chama `jogo.pedirCarta()`.
2. `jogo.dart` bloqueia outros toques e salva uma marca de operação pendente.
3. `api.dart` faz **uma** requisição para comprar **uma** carta e confere a resposta inteira.
4. `regras.dart` recalcula os pontos, reduzindo os ases de 11 para 1 quando necessário.
5. O jogo encerra por estouro ou passa à banca ao atingir 21. Caso contrário, aguarda outra escolha.
6. O estado completo é salvo; a interface recebe a atualização e mostra as novas cartas.

Se a resposta da compra se perder, não sabemos se a API consumiu a carta. Por isso, a mesa é invalidada e o aplicativo oferece um novo baralho. A marca pendente também protege contra fechamento durante a operação.

## Termos do projeto

- **Carta:** código, valor, naipe, imagem e nome acessível em português.
- **Shoe:** conjunto de 1 a 6 baralhos usados na mesa.
- **Mesa:** identificador remoto, regras daquela mesa, cartas restantes, mãos, rodada e fase.
- **Fase:** jogador, banca ou rodada concluída.
- **Natural:** 21 nas duas cartas iniciais; vence um 21 feito com mais cartas.
- **Mão suave:** mão em que um Ás ainda vale 11.
- **Preferências:** regras da próxima mesa, tema, som e vibração.

## Por que o código está separado assim?

As regras funcionam sem Flutter nem internet. A API fica em um lugar só. O controlador pode ser testado com armazenamento e servidor em memória. As telas compartilham pequenos componentes para cartas, botões e painéis.

Os nomes do domínio e os comentários são em português. Palavras obrigatórias de Dart/Flutter (`class`, `Widget`, `build`, `Future`) e campos do contrato remoto (`deck_id`, `remaining`, `cards`) mantêm seus nomes originais. Os diretórios de plataforma contêm também código gerado pelo Flutter, preservado para facilitar atualizações.

## Onde alterar cada coisa?

| Quero alterar… | Procure por… |
| --- | --- |
| Pontuação, natural ou regra da banca | `pontuar`, `natural`, `bancaCompra` e `resultado`, em `regras.dart` |
| Endereço, prazo ou validação HTTP | `ApiBaralho`, em `api.dart` |
| Sequência das jogadas ou retomada | `Jogo`, em `jogo.dart` |
| Aparência e textos das telas | `Telas` e `CartaVisual`, em `telas.dart` |
| Tema global, idioma e dependências iniciais | `Clube21`, em `main.dart` |

## O que os testes protegem?

`regras_test.dart` verifica pontuação e resultados. `api_test.dart` confere o contrato e a ausência de repetição após timeout. `jogo_test.dart` cobre distribuição, turnos, corte do shoe, toques repetidos, persistência e falhas. `telas_test.dart` verifica navegação, carta oculta, tema, textos ampliados e largura de 320 pixels. `wireframe_test.dart` renderiza os 19 estados previstos e pode exportar a galeria.

A galeria usa dados fixos para tornar os estados reproduzíveis. No aplicativo normal, as cartas vêm da API e são aleatórias.
