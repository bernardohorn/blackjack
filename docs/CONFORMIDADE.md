# Conformidade com a documentação e o wireframe

[← Voltar ao README](../README.md)

Auditoria de 14/10/2026. Referências: [wireframe de alta fidelidade](referencias/wireframe.pdf), com 19 estados, e [documentação Deck of Cards API + Flutter](referencias/api-flutter.pdf). A referência visual define os fluxos do aplicativo; o documento técnico também descreve endpoints genéricos da API que não são necessários neste jogo.

## Resultado

Os 19 estados previstos estão implementados e renderizados nos testes da interface. As chamadas do fluxo usam os métodos, caminhos e quantidades previstos. Pontuação, resultado, configurações e retomada permanecem locais. A aderência funcional não equivale a uma garantia de ausência de defeitos ou a uma cópia de todos os pixels: as adaptações visuais e os limites de validação estão registrados abaixo.

## Conferência das 19 telas

Cada captura abaixo vem da própria interface Flutter, com dados fixos de teste. Os nomes e números acompanham a referência. A navegação em produção decide qual estado mostrar a partir da partida real.

| Estado | Tela | Comportamento conferido |
| --- | --- | --- |
| 01 | [Abertura](imagens/01-abertura.png) | Lê preferências e sessão; mostra a preparação sem consultar a API. |
| 02 | [Menu sem partida](imagens/02-menu.png) | Continuar fica desabilitado; Novo jogo inicia a criação. |
| 03 | [Menu com partida](imagens/03-menu-ativo.png) | Retoma as mãos locais; Novo jogo pede confirmação antes de substituir. |
| 04 | [Configurações](imagens/04-configuracoes.png) | 1–6 baralhos, S17/H17, som, vibração e tema; regras aplicadas na próxima mesa. |
| 05 | [Como jogar](imagens/05-regras.png) | Explica objetivo, valores, ações e regra da banca; sem chamadas remotas. |
| 06 | [Distribuição](imagens/06-distribuindo.png) | Aguarda criar o shoe, valida a resposta e compra quatro cartas; ações bloqueadas. |
| 07 | [Sua vez](imagens/07-sua-vez.png) | Pedir compra uma carta; Parar revela a carta local e entrega o turno. |
| 08 | [Ás flexível](imagens/08-as-flexivel.png) | 9 + 7 + A = 17; mostra o ajuste do Ás e mantém as ações disponíveis. |
| 09 | [Vez da banca](imagens/09-banca.png) | Revela as cartas e compra uma por vez quando necessário; jogador bloqueado. |
| 10 | [Blackjack do jogador](imagens/10-blackjack.png) | Natural nas duas cartas iniciais encerra a rodada sem compras extras. |
| 11 | [Vitória](imagens/11-vitoria.png) | Vitória por pontuação ou estouro da banca; Nova rodada disponível. |
| 12 | [Empate](imagens/12-empate.png) | Empate por pontos ou dois naturais; resultado calculado localmente. |
| 13 | [Derrota](imagens/13-derrota.png) | Comparação de pontos, painel de derrota e possibilidade de nova rodada. |
| 14 | [Estouro do jogador](imagens/14-estouro.png) | Encerra imediatamente; a banca não compra cartas adicionais. |
| 15 | [Erro ao criar a mesa](imagens/15-erro-conexao.png) | Tentar novamente cria outro shoe; nenhuma compra antiga é repetida. |
| 16 | [Compra incerta](imagens/16-compra-incerta.png) | Invalida a mesa; reinicia com outro baralho; Continuar fica indisponível. |
| 17 | [Renovação do shoe](imagens/17-renovar-shoe.png) | Só entre rodadas: corte em 25% ou menos, ou menos de quatro cartas. |
| 18 | [Pausa](imagens/18-sair.png) | Continuar jogando ou Salvar e ir ao menu; retomada sem compra remota. |
| 19 | [Blackjack da banca](imagens/19-blackjack-banca.png) | Natural da banca é resolvido na distribuição; dois naturais resultam em empate. |

Evidências: [`wireframe_test.dart`](../test/wireframe_test.dart) para os estados visuais; [`jogo_test.dart`](../test/jogo_test.dart) para transições, requisições e recuperação; [`regras_test.dart`](../test/regras_test.dart) para pontuação e resultado.

## Conferência dos endpoints

Base: `https://deckofcardsapi.com/api/deck/`. Todas as chamadas abaixo usam **GET**. O app não possui backend próprio nem exige endpoints adicionais.

| Ação | Caminho e parâmetros | Sequência e validação |
| --- | --- | --- |
| Novo jogo, reiniciar após falha ou renovar shoe | `new/shuffle/?deck_count=N` | N entre 1 e 6; exige `success: true`, ID, `shuffled: true` e N × 52 cartas. |
| Distribuir rodada | `{deck_id}/draw/?count=4` | Só após confirmar o shoe; alterna jogador, banca, jogador, banca. |
| Pedir carta | `{deck_id}/draw/?count=1` | Uma chamada por ação; valida ID, quantidade, contagem restante, código, valor e naipe. |
| Compra da banca | `{deck_id}/draw/?count=1` | Uma carta por vez, até a regra de parada. |
| Imagem de carta aberta | URL de `images.png`, com alternativa em `image` | Carregamento de imagem; se falhar, usa frente local com valor e naipe. |
| Carta fechada | Nenhum | Verso local; a imagem/nome da frente não é exposta pela interface nem por acessibilidade. |
| Abrir menu, regras e configurações; salvar/continuar; revelar; calcular resultado | Nenhum | Usa dados já disponíveis no dispositivo. |

Código: [`api.dart`](../lib/api.dart). Contrato testado em [`api_test.dart`](../test/api_test.dart); URLs completas e ordem conferidas em [`jogo_test.dart`](../test/jogo_test.dart).

O catálogo técnico inclui reembaralhar, devolver cartas e manipular pilhas. O wireframe pede **um novo shoe** na renovação; por isso essas operações não fazem parte do app. Pilhas não são usadas no shoe de múltiplos baralhos. Não se cria uma chamada de reconciliação para tentar adivinhar uma compra cuja resposta se perdeu.

A API pública é a fonte de cartas e do valor `remaining`. Uma resposta HTTP inválida, `success` falso, JSON incorreto, compra parcial ou contagem inconsistente invalida a operação. O prazo de cada chamada é de 10 segundos; não há repetição automática de compras. O contrato público pode ser consultado na [documentação oficial da Deck of Cards API](https://deckofcardsapi.com/).

## Regras e persistência

- Ás começa valendo 11 e passa a 1 quando necessário, incluindo mãos com vários ases.
- J, Q e K valem 10; natural exige exatamente duas cartas. Dois naturais empatam.
- Ao atingir 21 com mais cartas, o turno passa automaticamente à banca. Estourar encerra sem novas compras da banca.
- A banca para em 17 suave por padrão. Desligar essa opção habilita compra no 17 suave.
- Mudanças de quantidade de baralhos e regra de 17 não alteram a mesa já criada; valem para a próxima, inclusive a renovada pelo corte.
- Tema, som e vibração são preferências locais. Efeitos indisponíveis não interrompem o jogo.
- A sessão salva contém as duas mãos, o ID do shoe, as regras, a contagem, a fase e a data da última compra. O salvamento ocorre após cada ação confirmada.
- Antes de uma operação, uma marca persistida impede recuperar uma mão antiga caso o app seja fechado durante o envio. Após compra incerta, a sessão fica indisponível para retomada.
- Sessões locais com 14 dias sem compra são descartadas, compatíveis com a expiração por inatividade informada pela API. Falhas anteriores a esse prazo também recebem tratamento de erro.
- O escopo não inclui apostas, saldo, seguro, divisão de mãos, dobrar ou conta de usuário.

## Ajustes feitos na auditoria

Foram alinhados os painéis de resultado, as mensagens de Ás flexível e renovação, a disposição das cartas sobrepostas, as cores, a textura de feltro, o seletor de tema e o modal de pausa. A abertura e a vez da banca têm uma breve pausa visual para que sejam percebidas mesmo quando nenhuma compra adicional é necessária. A contagem da API aceita número inteiro ou texto numérico e rejeita valores fracionários. Falhas de gravação apresentam uma mensagem específica de armazenamento.

## Adaptações visuais deliberadas

| Referência | Aplicativo |
| --- | --- |
| Prancha fixa de 390 × 844 | Conteúdo responsivo, área segura do sistema, largura limitada e rolagem quando necessário. Teste adicional com 320 pixels e texto a 160%. |
| Georgia e Segoe UI | Gelasio nos títulos e Roboto no texto; fontes abertas/fornecidas pelo Flutter, com Noto Sans Symbols 2 incluída para os naipes. A tipografia não é pixel a pixel idêntica. |
| Relógio e barras de um aparelho ilustrado | As barras pertencem ao sistema real; o app não desenha relógio ou bateria fictícios. |
| Cartas ilustrativas do protótipo | Cartas aleatórias da API; imagens oficiais quando disponíveis, frente local em caso de ausência/falha. A galeria usa essa frente local e dados determinísticos. |
| Tema escuro mostrado nas pranchas | Tema escuro alinhado à referência e variante clara funcional, conforme o seletor previsto. |

## Validação e limites

| Verificação | Evidência |
| --- | --- |
| Formatação e análise | `dart format` sem alterações e `flutter analyze` sem problemas, executados localmente. |
| Regras, API, persistência e interface | `flutter test`: **47 testes aprovados**, incluindo os 19 estados da referência. |
| Imagens da documentação | Exportação reproduzível dos widgets Flutter em 390 × 844, com resolução 2×. Não é captura de um telefone físico. |
| Web | Compilação release local e no GitHub; rodada com a API real, pausa e retomada após recarregar a página verificadas no navegador. |
| Android | Compilação do APK debug local e no GitHub; execução em aparelho físico ainda precisa ser conferida no dispositivo de destino. |
| Windows | **Compilação release aprovada no GitHub.** A tentativa local com Visual Studio 2019 falhou no plugin de áudio; use compilador atual, conforme o guia de execução. |
| iOS, macOS e Linux | **Compilações aprovadas no GitHub:** simulador iOS em debug, macOS e Linux em release. Execução em aparelhos reais ainda não validada. |
| Compilações nos sistemas de destino | Todas as seis plataformas compilaram na [execução 38658824175](https://github.com/bernardohorn/blackjack/actions/runs/38658824175), referente ao código do commit [`889a701`](https://github.com/bernardohorn/blackjack/commit/889a7018d07a5ce1756241e7f2711cf9a3e0a99d). Os pacotes web e APK estão nos artefatos dessa execução. |

A disponibilidade do serviço externo, o hardware de vibração/áudio e as permissões do sistema podem variar. Uma compilação bem-sucedida não substitui uma rodada completa no aparelho em que o projeto será apresentado.
