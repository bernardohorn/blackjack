# Blackjack 21 — guia de apresentação do protótipo

Este guia explica as decisões do protótipo de alta fidelidade e o contrato previsto para a futura aplicação Flutter. O protótipo é uma demonstração simulada: as cartas, identificadores e respostas exibidos são exemplos locais. Navegar pelo protótipo não compra cartas da API. As anotações ao lado das telas mostram as chamadas que a implementação Flutter deverá fazer.

## 1. O que o projeto entrega

O aplicativo oferece uma mesa de Blackjack para um jogador contra a banca, com seis baralhos por padrão, cartas visuais, pontuação, escolha entre pedir e parar, resultado e novas rodadas. O visual usa verde de mesa, dourado e cartas claras, seguindo as referências fornecidas com uma composição mais moderna.

O escopo não inclui apostas, saldo, pagamentos, divisão de mãos (split), dobra (double) ou seguro (insurance). Por isso, o resultado não promete pagamento de 3 para 2. Essa proporção só teria significado em uma versão que modelasse apostas.

As funções essenciais são criar o baralho, comprar cartas e obter suas imagens. Pontuação, decisões da banca, vitória, empate, preferências e navegação são responsabilidades locais do aplicativo.

## 2. Decisões que ajudam a explicar e manter o código

- **Seis decks, 312 cartas:** `6 × 52 = 312` antes de qualquer distribuição.
- **Mãos locais:** as cartas do jogador e da banca ficam em listas no Flutter. A documentação pública informa que pilhas remotas não funcionam com múltiplos decks.
- **Uma compra por vez:** os botões ficam desabilitados durante a requisição. Isso evita comprar cartas extras por dois toques rápidos.
- **Uma carta fechada:** a segunda carta da banca já foi recebida, mas a interface mostra o verso. Ocultar é uma decisão visual local.
- **Uma mesma mesa, várias rodadas:** novas rodadas mantêm o `deck_id` e seguem comprando do mesmo shoe. As cartas da rodada anterior ficam fora do monte.
- **Corte de 25%:** antes de iniciar uma rodada, se o restante for menor ou igual a 25% da quantidade inicial, cria-se um novo shoe. Com seis decks, `remaining <= 78` renova a mesa antes da distribuição. É uma política escolhida para este aplicativo, não uma regra imposta pela API.
- **Padrão S17:** a banca para em qualquer 17, inclusive o suave. Se a preferência for desativada, ela pede em 17 suave. A alteração de regra ou quantidade de decks vale para a próxima mesa.
- **Continuar é local:** retoma o identificador, as mãos, a fase e a contagem já guardados. Não existe consulta obrigatória ao servidor para essa ação no contrato adotado.

## 3. Endpoints principais e telas relacionadas

Base HTTP: `https://deckofcardsapi.com`. Todos os exemplos abaixo usam **GET**. Embora sejam GET, criação e compra alteram o estado no servidor; compra não deve receber repetição automática.

| Tela ou ação | Chamada prevista | Explicação |
|---|---|---|
| Abertura | Sem endpoint | Prepara tema, preferências e estado local. Não cria um baralho só para mostrar a abertura. |
| Menu → Novo jogo | `GET https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=6` | Cria um shoe embaralhado. Guarda o `deck_id` e o `remaining` retornados. |
| Distribuição inicial | `GET https://deckofcardsapi.com/api/deck/{deck_id}/draw/?count=4` | Compra as quatro cartas iniciais depois que a criação terminou com sucesso. |
| Menu → Continuar | Sem endpoint | Reabre o estado local de uma mesa ativa. O botão fica desabilitado quando não há sessão válida. |
| Mesa → Pedir (HIT) | `GET https://deckofcardsapi.com/api/deck/{deck_id}/draw/?count=1` | Adiciona a carta recebida à mão do jogador e recalcula a pontuação. |
| Mesa → Parar (STAND) | Sem endpoint direto | Encerra o turno do jogador e revela a carta fechada. Pode iniciar as compras da banca descritas na próxima linha. |
| Turno da banca | `GET https://deckofcardsapi.com/api/deck/{deck_id}/draw/?count=1` | Compra uma por vez enquanto a regra local exigir. Espera a resposta antes de decidir se precisa de outra. |
| Frente da carta | `GET {image}` | Carrega a URL PNG que veio na própria carta. Exemplo: `https://deckofcardsapi.com/static/img/AS.png`. |
| Verso da carta | `GET https://deckofcardsapi.com/static/img/back.png` | Recurso de imagem estático. Não representa uma compra e não altera o shoe. |
| Resultado | Sem endpoint | O Flutter compara as mãos e decide vitória, derrota, empate ou estouro. |
| Resultado → Nova rodada | `GET https://deckofcardsapi.com/api/deck/{deck_id}/draw/?count=4` | Se o shoe estiver acima do corte, limpa as mãos anteriores e distribui novamente no mesmo `deck_id`. |
| Nova rodada com corte atingido | `GET https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=6`, depois `GET https://deckofcardsapi.com/api/deck/{deck_id}/draw/?count=4` | Cria outro shoe antes da rodada. A segunda chamada usa o novo identificador recebido. |
| Regras | Sem endpoint | Conteúdo e exemplos locais. |
| Configurações | Sem endpoint ao editar | Tema, som e vibração são locais. A quantidade escolhida é enviada em `deck_count` apenas na criação da próxima mesa. |
| Pausar ou voltar ao menu | Sem endpoint | Mantém a sessão local para Continuar. Uma rodada inconclusiva após falha não deve ser retomada como se estivesse consistente. |

`{deck_id}` é uma variável: na aplicação, ela deve ser substituída pelo identificador devolvido pela criação. O identificador mostrado no protótipo é fictício.

### Ordem da distribuição

Uma única compra com `count=4` evita quatro viagens de rede. A lista recebida é distribuída alternadamente:

1. `cards[0]`: primeira carta do jogador.
2. `cards[1]`: primeira carta da banca, visível.
3. `cards[2]`: segunda carta do jogador.
4. `cards[3]`: segunda carta da banca, visualmente fechada até a resolução.

Se a criação falhar, não se faz a compra. Se a compra falhar ou ficar inconclusiva, a mesa não passa para “Sua vez”.

## 4. O que vem da API e o que precisa ser validado

| Campo | Significado | Validação prevista |
|---|---|---|
| Status HTTP | Resultado do transporte | Aceitar apenas respostas HTTP 2xx antes de interpretar o conteúdo. |
| `success` | A operação foi aceita | Exigir `true`; um HTTP 200 com `success: false` continua sendo uma falha. |
| `deck_id` | Identificador do shoe | Exigir texto não vazio. Nas compras, deve corresponder à mesa ativa. |
| `remaining` | Cartas disponíveis no monte principal | Aceitar inteiro ou texto numérico válido; rejeitar ausência, valor negativo ou conteúdo inválido. Não confundir com pontuação. |
| `shuffled` | Baralho embaralhado | Esperado na criação; não exigir em respostas de compra que não o incluam. |
| `cards` | Cartas retiradas pela compra | Exigir a quantidade solicitada e validar cada carta antes de atualizar o estado. |
| `code` | Código compacto da carta | Exemplos: `AS`, `0H`, `KD`. Não usar o código como chave única da interface: seis decks podem conter cartas com o mesmo código. |
| `value` | Valor legível | `ACE`, `2` a `10`, `JACK`, `QUEEN` ou `KING`. A pontuação é calculada localmente. |
| `suit` | Naipe | `SPADES`, `DIAMONDS`, `CLUBS` ou `HEARTS`. A UI pode traduzir para espadas, ouros, paus e copas. |
| `image` | URL PNG principal | Usar para a frente da carta e oferecer representação local quando a imagem falhar. |
| `images` | Variantes PNG/SVG | Campo opcional. A ausência não deve impedir uma carta válida de funcionar. |

**Atenção ao dez:** o código compacto usa **zero**, não `10`. Uma carta de dez de copas tem `code: "0H"`, enquanto seu `value` é `"10"`. O código identifica a carta; o valor legível serve ao cálculo dos pontos.

O corpo deve ser um JSON no formato esperado. Uma resposta ausente ou malformada não pode produzir uma mão parcialmente atualizada. A atualização de cartas, fase e contagem deve acontecer depois da validação do conjunto da resposta.

## 5. Regras locais que a banca pode perguntar

### Pontuação e ases

Cartas de 2 a 10 valem seu número; valete, dama e rei valem 10. Cada ás começa valendo 11. Enquanto o total ultrapassar 21 e ainda existir um ás valendo 11, reduz-se o total em 10 para fazer esse ás valer 1.

Exemplos: `A + K = 21`; `A + 9 + A = 21`; `9 + 7 + A = 17`; `K + 8 + 7 = 25`, um estouro. O exemplo antigo que mostrava 16 para `9 + 7 + A` precisava ser corrigido.

### Blackjack natural e 21 comum

**Blackjack natural** é 21 com as duas primeiras cartas: um ás e uma carta de valor 10. **21 comum** é uma soma de 21 com três ou mais cartas. O natural tem precedência sobre o 21 comum.

Os naturais das duas mãos são verificados depois da distribuição. Se ambos tiverem natural, o resultado é empate. Se apenas a banca tiver natural, o jogador perde. Se apenas o jogador tiver natural, vence. A aplicação não anuncia “vitória automática” antes dessa verificação. Um natural encerra a rodada sem fazer a banca comprar cartas adicionais.

Quando não há natural, o jogador pode pedir ou parar. Se estourar, perde imediatamente: a banca não precisa continuar comprando. Se o jogador parar sem estourar, a banca segue sua regra e depois se comparam os totais. Banca estourada significa vitória do jogador; totais iguais significam empate; a maior soma válida vence.

### O que é soft 17

Uma mão é **suave** quando pelo menos um ás ainda vale 11. `A + 6 = 17` é um 17 suave. `10 + 7 = 17` é um 17 duro. Para identificar a mão suave, não basta existir um ás: é necessário saber se ele permaneceu valendo 11 depois dos ajustes.

Com **S17 ativado**, a banca compra abaixo de 17 e para em qualquer 17 ou mais. Com **S17 desativado**, ela também compra em 17 suave. Acima de 17, ela para. Essa decisão é do Flutter; não há endpoint de soft 17.

## 6. Contador, corte e continuidade

O valor `remaining` é o restante no monte **depois** da operação. Com seis decks:

| Momento | Contagem consistente |
|---|---|
| Shoe recém-criado | 312 |
| Quatro cartas iniciais distribuídas | 308 |
| Jogador pediu uma carta | 307 |
| Banca pediu mais uma carta | 306 |
| Próxima rodada comprou quatro cartas do mesmo shoe | 302 |

O contador mostrado deve acompanhar as respostas; não permanecer em 312 enquanto as mãos já têm cartas. No protótipo simulado, o contador segue essa mesma lógica.

O corte é verificado **entre rodadas**. Se há 78 cartas ou menos no shoe de seis decks, a próxima rodada cria um novo shoe e passa para 312 antes da nova compra de quatro cartas. Não se troca de `deck_id` no meio de uma rodada válida. Para uma configuração com outra quantidade de decks, o limite corresponde a `25% × quantidade de decks × 52`.

Continuar exige guardar juntos o `deck_id`, o restante, as mãos, a fase e as regras adotadas pela mesa. Guardar apenas o identificador não reconstrói uma rodada. A API pode descartar um baralho após duas semanas sem atividade. Se o servidor informar que o ID deixou de existir, a sessão é encerrada e uma nova mesa começa com mãos novas.

O antigo `GET /api/deck/{id}/` para “verificar estado” não aparece no catálogo publicado usado neste projeto. O fluxo não depende desse endpoint. As anotações de Continuação devem indicar restauração local.

## 7. Erros e respostas da interface

| Situação | Resposta prevista |
|---|---|
| Criando mesa ou comprando carta | Indicador de carregamento; bloquear ações conflitantes e toques repetidos. |
| Falha ao criar shoe | Exibir erro com “Tentar novamente”. Nenhuma rodada começou; outra tentativa cria uma nova mesa. |
| Timeout de compra | Exibir “Rodada inconclusiva” e “Reiniciar mesa”. Não repetir a mesma compra automaticamente. |
| Resposta de compra inválida ou quantidade divergente | Preservar a última visualização, bloquear a rodada e oferecer iniciar nova mesa. A compra pode ter alterado o servidor. |
| `success: false` ou HTTP fora de 2xx | Exibir uma mensagem compreensível; decidir a recuperação conforme a operação e a validade da sessão. |
| ID expirado ou inválido | Descartar a sessão e criar um shoe novo. Não anexar as mãos antigas a esse novo ID. |
| Cartas insuficientes | Não enviar uma compra que exceda o restante conhecido. A política de corte reduz esse risco; uma inconsistência exige reiniciar a mesa. |
| Imagem indisponível | Mostrar carta local com valor/naipe ou placeholder. A partida continua porque as regras usam os dados, não os pixels da imagem. |

**Por que não repetir o HIT após um timeout?** O pedido pode ter chegado ao servidor, retirado uma carta e perdido a resposta no caminho. Repetir compraria outra carta, deixando o aplicativo sem saber qual foi a primeira. O contrato adotado não oferece uma forma confiável de recuperar aquela resposta. Reiniciar a mesa de forma explícita evita continuar uma rodada com estado divergente.

O cliente pode adotar um timeout de 10 segundos, como no PDF técnico. Timeout é o prazo de espera da aplicação; não é prova de que a operação foi cancelada no servidor.

## 8. Arquitetura Flutter mínima sugerida

Uma estrutura pequena e explicável é suficiente. Não é necessário copiar toda a arquitetura de um projeto grande ou implementar os endpoints opcionais para jogar.

| Arquivo sugerido | Responsabilidade |
|---|---|
| `main.dart` | Inicializa o aplicativo, define o tema e mostra a navegação principal. |
| `modelos.dart` | Define `Carta`, `Mao`, `EstadoMesa`, `FaseRodada` e `Preferencias`; concentra a pontuação e a leitura do JSON. |
| `servico_baralho.dart` | Contém `criarBaralho` e `comprarCartas`, monta URLs com `Uri`, valida HTTP/JSON e aplica timeout. Recebe um cliente HTTP para permitir testes sem rede. |
| `controlador_mesa.dart` | Contém `iniciarMesa`, `pedirCarta`, `parar`, `novaRodada` e a regra da banca. Atualiza o estado e notifica a interface, por exemplo com `ChangeNotifier`. |
| `telas.dart` | Mostra menu, mesa, regras, configurações e feedback. Reaproveita componentes de carta, botão e placar. |

Para reduzir camadas sem misturar responsabilidades, um repositório separado pode ser dispensado nesta versão: o controlador orquestra o serviço. Widgets não devem fazer chamadas HTTP nem recalcular regras isoladamente.

Os nomes do código escrito pela equipe podem ficar em português. Chaves JSON como `deck_id` e `remaining`, valores recebidos como `ACE` e nomes exigidos pela biblioteca permanecem como publicados. Comentários devem explicar **por que** uma decisão existe: ajuste de ás, bloqueio durante compra, corte e timeout. Comentar cada atribuição óbvia tornaria a apresentação mais difícil.

Testes úteis na implementação final: ases flexíveis, natural contra natural, natural contra 21 comum, estouro, S17/H17, distribuição alternada, corte e rejeição de resposta inválida. O serviço deve ser substituído por respostas simuladas nesses testes, evitando depender da disponibilidade da rede.

## 9. Catálogo completo de referência, fora do fluxo principal

O PDF técnico lista os 15 itens abaixo. Esta lista explica o contrato, mas não obriga a aplicação a usá-los. Os itens já adotados pelo fluxo principal são identificados; todos os demais são opcionais. **Pilhas são reservadas a uma demonstração separada de um único deck.** Não são associadas a telas da mesa de seis decks.

| Nº | Endpoint relativo à base | Finalidade e uso |
|---|---|---|
| 1 | `/api/deck/new/shuffle/?deck_count={n}` | Criar shoe embaralhado; já usado no fluxo principal, com `n=6` por padrão. |
| 2 | `/api/deck/new/` | Opcional: criar baralho ordenado. Curingas via `?jokers_enabled=true` não fazem parte deste Blackjack. |
| 3 | `/api/deck/new/shuffle/?cards={csv}` | Opcional: baralho parcial para testar valores conhecidos. Embaralhado não significa ordem determinística. |
| 4 | `/api/deck/{deck_id}/draw/?count={n}` | Comprar do monte; já usado com `n=4` ou `n=1`. |
| 5 | `/api/deck/{deck_id}/shuffle/` | Opcional: reembaralhamento completo do mesmo ID. O projeto escolheu criar outro shoe no corte. |
| 6 | `/api/deck/{deck_id}/shuffle/?remaining=true` | Opcional: embaralhar só o monte restante. Não repõe cartas já compradas nem resolve um shoe vazio. |
| 7 | `/api/deck/{deck_id}/pile/{pile}/add/?cards={csv}` | Opcional, somente 1 deck: criar/adicionar à pilha cartas previamente compradas. |
| 8 | `/api/deck/{deck_id}/pile/{pile}/shuffle/` | Opcional, somente 1 deck: embaralhar uma pilha. |
| 9 | `/api/deck/{deck_id}/pile/{pile}/list/` | Opcional, somente 1 deck: listar cartas e contagem da pilha. |
| 10 | `/api/deck/{deck_id}/pile/{pile}/draw/?count={n}` | Opcional, somente 1 deck: retirar do topo. `?cards={csv}` permite seleção por código em vez de quantidade. |
| 11 | `/api/deck/{deck_id}/pile/{pile}/draw/bottom/?count={n}` | Opcional, somente 1 deck: retirar do fundo. |
| 12 | `/api/deck/{deck_id}/pile/{pile}/draw/random/?count={n}` | Opcional, somente 1 deck: retirar aleatoriamente. |
| 13 | `/api/deck/{deck_id}/return/` ou `/api/deck/{deck_id}/return/?cards={csv}` | Opcional: devolver cartas compradas ao monte. Não usado no ciclo escolhido. |
| 14 | `/api/deck/{deck_id}/pile/{pile}/return/` ou `/api/deck/{deck_id}/pile/{pile}/return/?cards={csv}` | Opcional, somente 1 deck: devolver cartas da pilha ao monte. |
| 15 | `/static/img/back.png` | Imagem estática do verso; já usada pela interface. |

`{csv}` é uma lista de códigos separados por vírgula, por exemplo `AS,0H,KD`. Parâmetros são construídos com `Uri`, e não pela concatenação de texto fornecido pelo usuário. A compra combinada `/api/deck/new/draw/?count=4` é documentada como atalho, mas não é usada aqui: criar explicitamente com `deck_count=6` torna a configuração da mesa clara.

## 10. Glossário e respostas rápidas para a apresentação

| Termo | Como explicar |
|---|---|
| API | Serviço externo que fornece baralho e cartas por requisições HTTP. |
| Endpoint | Endereço de uma operação ou recurso da API. |
| Query string | Parâmetros depois de `?`, como `deck_count=6` e `count=4`. |
| JSON | Formato dos dados recebidos, com campos como `cards` e `remaining`. |
| Deck | Um baralho de 52 cartas. |
| Shoe | Conjunto de baralhos do qual a mesa compra cartas. Neste padrão, seis decks. |
| Dealer / banca | Adversário controlado pelas regras locais do aplicativo. |
| HIT / pedir | Comprar outra carta para a mão do jogador. |
| STAND / parar | Encerrar o turno do jogador. Não tem um endpoint próprio. |
| Bust / estouro | Pontuação acima de 21. |
| Push / empate | Resultado igual para as mãos conforme as regras adotadas. |
| Natural | Blackjack de duas cartas; tem precedência sobre um 21 de três ou mais. |
| Mão suave | Mão com pelo menos um ás ainda valendo 11. |
| S17 / H17 | Banca para / pede em 17 suave. |
| Corte | Limite escolhido para renovar o shoe antes da próxima rodada. |
| Estado | Dados que descrevem a mesa naquele momento: cartas, fase, regras e contagem. |
| DTO / modelo | Estrutura que transforma o JSON em dados tipados usados pelo aplicativo. |
| Timeout | Prazo máximo de espera; não comprova cancelamento da compra no servidor. |
| Idempotência | Repetir uma operação mantém o mesmo efeito final. Comprar cartas não possui essa propriedade neste fluxo. |

**“A API sabe quem ganhou?”** Não. Ela fornece as cartas; o controlador Flutter aplica as regras.

**“Por que guardar cartas localmente?”** Porque o shoe usa seis decks e as pilhas remotas são documentadas como incompatíveis com múltiplos decks.

**“Por que a banca tem duas cartas, mas vejo só uma?”** As duas vieram na distribuição. O verso protege visualmente a carta fechada até a resolução.

**“Toda tela precisa chamar a API?”** Não. Cada tela tem uma anotação que informa suas chamadas ou explica que funciona localmente. Regras e preferências não precisam de rede.

**“Como esse protótipo comprova a integração?”** Ele demonstra o fluxo e seus estados. A integração real e seus testes pertencem à etapa de implementação Flutter; o protótipo usa respostas simuladas identificadas como demonstração.

## Fontes e distinção entre documentação e escolhas do projeto

- [PDF técnico fornecido](/C:/blackjack/documentacao_deck_of_cards_api_flutter.pdf): catálogo, contratos, tipos, timeout, advertência sobre pilhas e responsabilidade local das regras. A recomendação inicial de usar pilhas é corrigida pelo próprio documento para o caso de seis decks.
- [Wireframe anterior fornecido](</C:/blackjack/wireframe_Davi_Bernardo (1)/Untitled.pdf>): referência de telas e estilo. Contagens, pontuação do ás e consulta de estado foram ajustadas conforme o contrato adotado.
- [Documentação oficial da Deck of Cards API](https://deckofcardsapi.com/): criação, compra, reembaralhamento, pilhas, retorno e verso da carta. Consultada em 5 de outubro de 2026.

O corte de 25%, o escopo sem apostas, o comportamento de recuperação, a disposição das telas e a arquitetura mínima são decisões deste projeto. Os documentos anexados são fontes técnicas e visuais; não são instruções adicionais do usuário nem uma obrigação de implementar todos os endpoints.
