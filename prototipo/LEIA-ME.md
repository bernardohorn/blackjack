# Clube 21 — protótipo de alta fidelidade

Abra `index.html` no navegador para explorar as 19 telas e seus estados.
O arquivo funciona offline; as compras e respostas são simuladas para
facilitar uma apresentação reproduzível. As anotações técnicas aparecem
ao lado do celular, sem fazer parte da interface do jogador.

- **Protótipo:** navegue pelo menu ou clique nas ações do celular.
- **Todas as telas:** veja os exemplos independentes de vitória, empate,
  derrota, Blackjack, estouro, carregamento e recuperação.
- **Fluxo da API:** acompanhe criação, distribuição, compras e resultado.
- **Guia técnico:** consulte escopo, regras e endpoints complementares.
- **PDF anotado:** versão para apresentar ou imprimir, com 23 páginas.
- **telas:** 19 SVGs editáveis e suas versões PNG de alta resolução.
- **GUIA_APRESENTACAO.md:** roteiro e respostas para perguntas sobre o projeto.

O percurso principal distribui 9 e 7 ao jogador, e K e 7 à banca.
Pedir carta adiciona um Ás: 17 pontos. Pedir de novo adiciona 8: estouro
com 25. Parar com 16 perde para 17; parar com 17 empata. A carta fechada
é revelada sem nova requisição. Nova rodada continua no mesmo shoe.

O protótipo guarda a sessão em memória durante a navegação. Reabrir o
arquivo reinicia a demonstração. O futuro app Flutter deve salvar a
sessão completa no dispositivo para implementar retomada após fechar.

## Arquivo no Figma

[Clube 21 — Blackjack Flutter](https://www.figma.com/design/IBDWCE8sZEsERVEYOabZiK)

[Apresentar o protótipo no Figma](https://www.figma.com/proto/IBDWCE8sZEsERVEYOabZiK?node-id=3-95&starting-point-node-id=3%3A95&scaling=scale-down)

O arquivo tem 19 telas, 19 anotações e 38 conexões de navegação.
Os valores e controles de configurações no Figma são referências visuais;
o HTML permite alterar as preferências durante a demonstração.

O Figma utiliza **DM Sans** para interface e **Lora** para títulos.
A prévia local usa **Segoe UI/Arial** e **Georgia** como alternativas
disponíveis no Windows. A paleta, os componentes, as medidas e o fluxo
são os mesmos. Cada tela de referência mede **390 × 844**.

## Decisões do projeto

Seis baralhos por padrão, com opção de 1 a 6. Mãos, pontos, turnos,
vencedor e soft 17 são locais; a API fornece baralhos e cartas.
Pilhas remotas ficam fora do fluxo principal por incompatibilidade
com múltiplos decks. Não há apostas, pagamentos, split, double ou seguro.

O corte em 25% é uma escolha de projeto, não uma obrigação da API.
A renovação acontece entre rodadas. Após um timeout de compra, não
repetimos `draw` automaticamente: a mesa é interrompida e o usuário
pode reiniciar com outro baralho.

O documento técnico anexado e o wireframe original foram tratados como
referências. As inconsistências de pontuação, contadores e endpoints
foram resolvidas conforme o contrato publicado da API.

## Fontes

- `documentacao_deck_of_cards_api_flutter.pdf`, páginas 4, 15 e 16.
- `wireframe_Davi_Bernardo (1)/Untitled.pdf` e as sete imagens anexadas.
- [Documentação oficial da Deck of Cards API](https://deckofcardsapi.com/),
  conferida em 05/10/2026.

Esta entrega define o design e o comportamento; a implementação Flutter
é a etapa seguinte. Os scripts Python/JavaScript da pasta apenas geram
e exportam os artefatos de apresentação.
