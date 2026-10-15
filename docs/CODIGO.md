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
