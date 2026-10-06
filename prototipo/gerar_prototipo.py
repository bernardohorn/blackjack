"""Gera o projeto visual do Blackjack. Não é a implementação Flutter.

As telas são SVGs editáveis, e o HTML permite apresentar o fluxo sem rede.
Reutilizamos as mesmas funções para manter medidas, cores e componentes iguais.
"""
from pathlib import Path
from html import escape
import json

PASTA = Path(__file__).parent
TELAS = PASTA / 'telas'
TELAS.mkdir(parents=True, exist_ok=True)
VERDE = '#092F27'
PAINEL = '#164439'
OURO = '#E8C778'
MARFIM = '#F7F1E4'
SUAVE = '#B6CDC2'
VERMELHO = '#FFB5A9'


def retangulo(x, y, largura, altura, cor, raio=0, borda=None):
    return f'<rect x="{x}" y="{y}" width="{largura}" height="{altura}" rx="{raio}" fill="{cor}"' + (f' stroke="{borda}"' if borda else '') + '/>'


def texto(x, y, valor, tamanho=14, cor=MARFIM, peso=400, ancora='start', serifado=False, espaco=None):
    fonte = 'Georgia, serif' if serifado else 'Segoe UI, Arial, sans-serif'
    return f'<text x="{x}" y="{y}" fill="{cor}" font-family="{fonte}" font-size="{tamanho}" font-weight="{peso}" text-anchor="{ancora}"' + (f' letter-spacing="{espaco}"' if espaco else '') + f'>{escape(str(valor))}</text>'


def linhas(x, y, valores, tamanho=14, cor=SUAVE, entre=22, peso=400, ancora='start'):
    return ''.join(texto(x, y+i*entre, linha, tamanho, cor, peso, ancora) for i, linha in enumerate(valores))


def traço(x1, y1, x2, y2, cor='#376052'):
    return f'<path d="M{x1} {y1} L{x2} {y2}" stroke="{cor}" fill="none"/>'


def botao(y, rotulo, secundario=False, desabilitado=False, x=24, largura=342, apoio=None):
    cor = '#21473D' if desabilitado else VERDE if secundario else 'url(#ouro)'
    borda = '#34584B' if desabilitado else '#BDA466' if secundario else None
    tinta = '#90AA9C' if desabilitado else MARFIM if secundario else '#173B30'
    resultado = retangulo(x, y, largura, 54, cor, 17, borda)
    resultado += texto(x+largura/2, y+(26 if apoio else 33), rotulo, 16, tinta, 650, 'middle')
    if apoio:
        resultado += texto(x+largura/2, y+43, apoio, 11, tinta, 400, 'middle')
    return resultado


def chip(x, y, rotulo, largura=90, cor=PAINEL, tinta=OURO):
    return retangulo(x, y, largura, 27, cor, 13.5) + texto(x+largura/2, y+18, rotulo, 11, tinta, 600, 'middle')


def topo(titulo=None, detalhe=None, voltar=False):
    r = texto(26, 33, '9:41', 14, MARFIM, 650)
    r += texto(364, 33, '▮▮▮  ◔  ▰', 12, MARFIM, 500, 'end')
    if titulo:
        if voltar:
            r += retangulo(24, 65, 44, 44, '#19463B', 15)
            r += texto(46, 94, '‹', 30, MARFIM, 400, 'middle')
        r += texto(82 if voltar else 24, 94, titulo, 24, MARFIM, 600, serifado=True)
        if detalhe:
            r += texto(24, 132, detalhe, 13, SUAVE)
    return r


def base():
    return retangulo(137, 823, 116, 4, '#90A89A', 2)


def carta(x, y, valor='A', naipe='♠', largura=90, altura=130, inclinacao=0, oculta=False):
    # Valor e naipe vêm da API; o desenho pode ser local para preservar o tema.
    tinta = '#AB3A40' if naipe in ('♥', '♦') else '#233B32'
    r = f'<g transform="rotate({inclinacao} {x+largura/2} {y+altura/2})">'
    r += retangulo(x, y+4, largura, altura, '#031F19', 12)
    r += retangulo(x, y, largura, altura, '#124437' if oculta else MARFIM, 12, '#B4975D' if oculta else '#DFD8C9')
    if oculta:
        r += retangulo(x+7, y+7, largura-14, altura-14, 'url(#verso)', 7, '#BD9F61')
        r += f'<path d="M{x+largura/2} {y+altura/2-24} l19 24 -19 24 -19 -24 Z" fill="#164A3C" stroke="#D7B76F"/>'
        r += texto(x+largura/2, y+altura/2+7, '♠', 26, OURO, 400, 'middle', True)
    else:
        escala=largura/90
        canto_x=x+10*escala
        canto_y=y+25*altura/130
        naipe_y=y+44*altura/130
        r += texto(canto_x, canto_y, valor, 20*escala, tinta, 700)
        r += texto(canto_x, naipe_y, naipe, 18*escala, tinta, 400, serifado=True)
        r += texto(x+largura/2, y+altura/2+16*escala, naipe, 43*escala, tinta, 400, 'middle', True)
        r += f'<g transform="rotate(180 {x+largura/2} {y+altura/2})">' + texto(canto_x, canto_y, valor, 20*escala, tinta, 700) + texto(canto_x, naipe_y, naipe, 18*escala, tinta, 400, serifado=True) + '</g>'
    return r+'</g>'


def mao(y, cartas, ocultar_segunda=False):
    # Sobreposição conserva o canto de cada carta; no app a mão extensa terá rolagem.
    quantidade = len(cartas)
    passo = min(66, 240/max(quantidade-1, 1))
    inicio = (390-(90+(quantidade-1)*passo))/2
    return ''.join(carta(inicio+i*passo, y, oculta=True) if ocultar_segunda and i==1 else carta(inicio+i*passo, y, *c) for i, c in enumerate(cartas))


def marca(y=174, pequena=False):
    r = carta(130, y, 'A', '♠', 100, 146, -12)
    r += carta(163, y-8, 'A', '♦', 100, 146, 9)
    return r


def painel_regra(y, titulo, conteudo, altura):
    return retangulo(24, y, 342, altura, PAINEL, 18, '#386354') + texto(42, y+29, titulo, 15, OURO, 650) + linhas(42, y+54, conteudo, 13, MARFIM, 20)


def mesa(cartas_jogador, cartas_banca, pontos_jogador, pontos_banca, status, subtitulo, tipo='vez', restantes=308):
    r = topo()
    r += texto(24, 79, '♠  CLUBE 21', 18, OURO, 700, serifado=True)
    r += retangulo(322, 56, 44, 44, PAINEL, 14) + texto(344, 86, 'Ⅱ', 18, MARFIM, 600, 'middle')
    r += texto(24, 115, 'MESA 01', 10, SUAVE, 600, espaco='1.7')
    r += texto(24, 139, f'{restantes} cartas no shoe', 14, MARFIM, 600)
    r += chip(260, 112, '6 baralhos', 106)
    r += texto(24, 174, 'BANCA', 11, SUAVE, 700, espaco='1.6')
    r += chip(282, 154, str(pontos_banca)+' pts', 84, '#245245', MARFIM)
    r += mao(195, cartas_banca, '?' in str(pontos_banca))
    r += f'<path d="M35 351 Q195 316 355 351" fill="none" stroke="#77946A" stroke-opacity=".35"/>'
    r += texto(195, 358, 'B L A C K J A C K   ·   C L U B E  2 1', 10, '#B6CDC2', 500, 'middle')
    # Resultado usa texto e ícone, para não depender apenas da cor.
    tinta = VERMELHO if tipo in ('perdeu','estouro') else OURO
    r += retangulo(24, 385, 342, 71, '#3A302D' if tipo in ('perdeu','estouro') else '#21483A', 18, '#87665A' if tipo in ('perdeu','estouro') else '#7C7950')
    r += texto(195, 414, status, 22 if len(status)<21 else 19, tinta, 600, 'middle', True)
    r += texto(195, 437, subtitulo, 12, MARFIM, 400, 'middle')
    r += texto(24, 494, 'SUA MÃO', 11, SUAVE, 700, espaco='1.6')
    r += chip(282, 474, str(pontos_jogador)+' pts', 84, '#245245', tinta if tipo=='estouro' else MARFIM)
    r += mao(514, cartas_jogador)
    r += texto(195, 672, 'Ás vale 1 nesta mão' if any(c[0]=='A' for c in cartas_jogador) and tipo=='vez' else 'Sem apostas · jogue para aprender', 12, SUAVE, 400, 'middle')
    acabou = tipo not in ('vez','banca','distribuindo')
    r += botao(696, 'Pedir carta', desabilitado=tipo!='vez', largura=164, apoio='HIT · +1 carta')
    r += botao(696, 'Parar', True, tipo!='vez', 202, 164, 'STAND · vez da banca')
    r += botao(762, 'Nova rodada' if acabou else 'Rodada em andamento', desabilitado=not acabou)
    return r+base()


DEF = '''<defs>
<radialGradient id="feltro" cx="50%" cy="42%" r="80%"><stop stop-color="#155640"/><stop offset="1" stop-color="#062A22"/></radialGradient>
<linearGradient id="ouro" x2="0.8" y2="1"><stop stop-color="#F1D991"/><stop offset="1" stop-color="#D7B25F"/></linearGradient>
<pattern id="trama" width="5" height="5" patternUnits="userSpaceOnUse"><path d="M0 1 L5 1 M1 0 L1 5" stroke="#91B89C" stroke-opacity=".035"/></pattern>
<pattern id="verso" width="12" height="12" patternUnits="userSpaceOnUse"><path d="M6 0 L12 6 L6 12 L0 6 Z" fill="none" stroke="#BFA362" stroke-opacity=".27"/></pattern>
</defs>'''


def svg(conteudo, titulo):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 844" width="390" height="844" role="img" aria-label="{escape(titulo)}">{DEF}' + retangulo(0,0,390,844,'url(#feltro)') + retangulo(0,0,390,844,'url(#trama)') + conteudo + '</svg>'


def acao(x, y, largura, altura, rotulo, destino, comando='ir'):
    return dict(x=x,y=y,largura=largura,altura=altura,rotulo=rotulo,destino=destino,comando=comando)


def endpoint(gatilho, caminho, explicacao, dados='', metodo='GET'):
    return dict(gatilho=gatilho,caminho=caminho,explicacao=explicacao,dados=dados,metodo=metodo)


CRIAR = endpoint('Novo jogo / renovar mesa','/api/deck/new/shuffle/?deck_count={n}','Cria um shoe embaralhado. n vem das configurações; padrão 6. A configuração vale a partir desta mesa.','success, deck_id, shuffled, remaining; 6 × 52 = 312.')
DISTRIBUIR = endpoint('Após criar ou tocar Nova rodada','/api/deck/{deck_id}/draw/?count=4','Compra quatro cartas. Distribuição local na ordem jogador, banca, jogador, banca. A segunda da banca fica oculta.','cards[0..3], remaining; numa mesa nova de 6 decks, 308 restantes.')
PEDIR = endpoint('Pedir carta · Hit','/api/deck/{deck_id}/draw/?count=1','Compra uma carta, adiciona à mão local e recalcula os pontos. Não repetir compra automaticamente após timeout.','cards[0].code, value, suit, image; remaining atualizado.')
BANCA = endpoint('Parar · Stand, se a regra da banca exigir','/api/deck/{deck_id}/draw/?count=1','Revela a carta já conhecida localmente. Compra uma por vez enquanto soma < 17; com S17 desligado, também compra em soft 17. Em 17 ou mais, pode não haver chamada.','cards[0], remaining; a regra de parada é do Flutter.')
TELAS_DADOS = []


def adicionar(chave, nome, grupo, conteudo, ao_abrir, chamadas, local, acoes=None, nota='', exemplo=''):
    imagem = svg(conteudo, nome)
    (TELAS / f'{chave}.svg').write_text(imagem, encoding='utf-8')
    TELAS_DADOS.append(dict(chave=chave,nome=nome,grupo=grupo,svg=imagem,ao_abrir=ao_abrir,chamadas=chamadas,local=local,acoes=acoes or [],nota=nota,exemplo=exemplo))


# 01. Abertura: carrega apenas dados locais, sem gastar um novo baralho.
r = topo()+texto(195, 154, 'U M  C L Á S S I C O  N A  S U A  M Ã O', 10, SUAVE, 500, 'middle')
r += marca(243)+texto(195, 463, 'Blackjack', 49, MARFIM, 500, 'middle', True)
r += texto(195, 502, 'C L U B E   2 1', 18, OURO, 650, 'middle')
r += linhas(195, 560, ['A estratégia encontra a sorte.', 'Chegue perto de 21.'], 14, SUAVE, 24, ancora='middle')
r += retangulo(103, 718, 184, 4, '#285445', 2)+retangulo(103,718,124,4,OURO,2)+texto(195,752,'Preparando sua mesa…',12,SUAVE,400,'middle')+base()
adicionar('01-abertura','Abertura','Entrada',r,'Sem requisição à API.',[],['Lê preferências e uma eventual sessão salva.','Animação curta; não cria um shoe antecipadamente.'],[acao(0,45,390,765,'Abrir menu','02-menu')],exemplo='A barra é ilustrativa; não mede o progresso da rede.')


def menu(ativa=False):
    r = topo()+texto(24, 88, '♠  CLUBE 21', 21, OURO, 700, serifado=True)+chip(267,66,'6 baralhos',99)
    r += marca(173)+texto(195, 392, 'Sua próxima', 36, MARFIM, 500, 'middle', True)+texto(195,432,'boa jogada.',36,MARFIM,500,'middle',True)
    r += texto(195,464,'Um clássico. Um novo jeito de jogar.',13,SUAVE,400,'middle')
    r += botao(509,'Novo jogo')+botao(578,'Continuar partida',True,not ativa)
    r += texto(195,656,'Mesa 01 · 307 cartas restantes' if ativa else 'Sua partida aparecerá aqui quando começar.',12,SUAVE,400,'middle')
    r += traço(90,682,300,682)+botao(703,'Como jogar',True,False,24,164)+botao(703,'Configurações',True,False,202,164)
    r += texto(195,790,'Flutter + Deck of Cards API',11,SUAVE,400,'middle')+base()
    return r

acoes_menu=[acao(24,509,342,54,'Novo jogo','06-distribuindo','novo'),acao(24,703,164,54,'Como jogar','05-regras'),acao(202,703,164,54,'Configurações','04-configuracoes')]
adicionar('02-menu','Menu · primeira visita','Entrada',menu(),'Sem requisição ao abrir.',[CRIAR,DISTRIBUIR],['Continuar desabilitado sem sessão salva.','Novo jogo cria o shoe e só depois distribui.'],acoes_menu,nota='Chamadas sequenciais; aguardar a criação antes de usar deck_id.')
adicionar('03-menu-ativo','Menu · partida salva','Entrada',menu(True),'Sem requisição ao abrir ou continuar.',[CRIAR,DISTRIBUIR],['Restaura deck_id, mãos, restante, fase e regra da mesa no dispositivo.','Continuar retoma a mesma mesa; não compra cartas.','Novo jogo pede confirmação antes de substituir a mesa ativa.'],[acao(24,509,342,54,'Novo jogo','18-sair','substituir'),acao(24,578,342,54,'Continuar partida','08-as-flexivel'),*acoes_menu[1:]],nota='Não há endpoint de consulta de estado no catálogo público adotado. O ID isolado não reconstrói mãos locais.')


# 04. Configurações simples, com padrões explícitos e aplicação na próxima mesa.
r = topo('Configurações','Deixe o jogo com a sua cara.',True)
r += texto(24,177,'REGRAS DA PRÓXIMA MESA',10,OURO,650,espaco='1.4')
r += retangulo(24,194,342,82,PAINEL,18,'#386354')+texto(42,225,'Baralhos',16,MARFIM,600)+texto(42,251,'Padrão clássico: 6',12,SUAVE)
r += retangulo(221,212,44,44,'#2A5747',13)+texto(243,240,'−',22,MARFIM,600,'middle')+texto(287,239,'6',20,OURO,700,'middle')+retangulo(310,212,44,44,'#2A5747',12)+texto(332,240,'+',20,MARFIM,600,'middle')
r += retangulo(24,288,342,102,PAINEL,18,'#386354')+texto(42,320,'Banca para no soft 17',15,MARFIM,600)+linhas(42,345,['Ás + 6 = 17, com Ás valendo 11.','Ligado: a banca para nessa mão.'],12,SUAVE,19)
r += retangulo(300,310,48,28,OURO,14)+f'<circle cx="334" cy="324" r="10" fill="#173B30"/>'
r += texto(24,431,'PREFERÊNCIAS',10,OURO,650,espaco='1.4')
for y,t in [(449,'Som'),(516,'Vibração')]:
    r += retangulo(24,y,342,55,PAINEL,16,'#386354')+texto(42,y+34,t,16,MARFIM,600)+retangulo(300,y+14,48,28,OURO,14)+f'<circle cx="334" cy="{y+28}" r="10" fill="#173B30"/>'
r += retangulo(24,583,342,74,PAINEL,16,'#386354')+texto(42,626,'Tema',16,MARFIM,600)+retangulo(218,600,72,40,OURO,12)+texto(254,625,'Escuro',12,VERDE,650,'middle')+texto(326,625,'Claro',12,SUAVE,500,'middle')
r += texto(195,694,'As regras atuais da mesa são preservadas.',12,SUAVE,400,'middle')+botao(719,'Restaurar padrões',True)+base()
adicionar('04-configuracoes','Configurações','Informação',r,'Sem requisição à API.',[CRIAR],['Salva baralhos (1 a 6), soft 17, som, vibração e tema localmente.','Número de baralhos e soft 17 entram em vigor na próxima mesa.','Som e vibração são preferências locais; o protótipo não toca áudio.'],[acao(24,65,44,44,'Voltar ao menu','02-menu'),acao(221,212,44,44,'Diminuir baralhos','','menos'),acao(310,212,44,44,'Aumentar baralhos','','mais'),acao(290,298,64,54,'Alternar soft 17','','soft'),acao(290,449,64,55,'Alternar som','','som'),acao(290,516,64,55,'Alternar vibração','','vibracao'),acao(212,593,142,54,'Alternar tema','','tema'),acao(24,719,342,54,'Restaurar padrões','','padroes')],nota='A chamada de criação aparece como consequência futura da configuração, não como chamada desta tela.')


r=topo('Como jogar','Poucas regras. Muitas boas decisões.',True)
r+=painel_regra(165,'01  Chegue perto de 21',['Vença a banca com mais pontos,','sem ultrapassar 21. Empate não é derrota.'],103)
r+=painel_regra(281,'02  Conheça as cartas',['2 a 10 valem o número da carta.','J, Q e K valem 10. O Ás vale 1 ou 11.'],103)
r+=carta(47,401,'A','♠',56,80)+carta(89,401,'9','♥',56,80)+carta(131,401,'A','♦',56,80)+texto(217,431,'A + 9 + A = 21',16,OURO,650)+linhas(217,454,['Um Ás vale 11;','o outro vale 1.'],12,SUAVE,19)
r+=painel_regra(501,'03  Escolha sua ação',['Pedir carta (Hit): recebe mais uma carta.','Parar (Stand): encerra sua vez.'],103)
r+=painel_regra(617,'04  A vez da banca',['Compra abaixo de 17; para a partir de 17.','Soft 17 segue a configuração da mesa.','Ás + figura em 2 cartas é Blackjack.','Dois Blackjacks naturais: empate.'],139)
r+=texto(195,790,'Modo de estudo · sem apostas',12,SUAVE,400,'middle')+base()
adicionar('05-regras','Como jogar','Informação',r,'Sem requisição à API.',[],['Conteúdo estático e regras calculadas no Flutter.','21 em três ou mais cartas não é Blackjack natural.','Escopo: Hit, Stand e nova rodada; sem split, double ou seguro.'],[acao(24,65,44,44,'Voltar ao menu','02-menu')])


r=topo('Preparando a mesa','Uma nova rodada está chegando.')
r+=marca(248)+texto(195,465,'Embaralhando a sorte…',26,MARFIM,500,'middle',True)
r+=linhas(195,508,['Criando seu shoe e distribuindo cartas.','As ações ficam disponíveis em instantes.'],13,SUAVE,23,ancora='middle')
r+=retangulo(84,568,222,5,'#2A5746',3)+retangulo(84,568,135,5,OURO,3)
r+=botao(698,'Distribuindo cartas…',desabilitado=True)+base()
adicionar('06-distribuindo','Distribuição inicial','Mesa',r,'Criação e compra sequenciais em andamento.',[CRIAR,DISTRIBUIR],['Bloqueia toques duplicados durante a requisição.','Valida HTTP 2xx, success=true, deck_id e exatamente 4 cartas.','Oculta apenas o desenho da segunda carta da banca.'],nota='No protótipo as respostas são simuladas e reproduzíveis, sem consumir a API.',exemplo='Depois de criar 312 cartas, distribuir 4 deixa 308.')


imagens=[endpoint('Exibir cartas','{URL do campo image ou images.png}','Recurso estático da frente. PNG é simples no Flutter com Image.network; a carta textual local é o fallback.','value e suit permitem manter a carta legível se a imagem falhar.'),endpoint('Exibir carta fechada','/static/img/back.png','Imagem opcional do verso. No tema proposto, o verso é desenhado localmente; nenhuma compra adicional é necessária.','A carta real já está na mão local e só fica visualmente oculta.')]
r=mesa([('9','♥'),('7','♣')],[('K','♠'),('7','♦')],16,'10 + ?','Sua vez','Pedir mais uma carta ou parar?').replace(carta(183,195,'7','♦'),carta(183,195,oculta=True))
adicionar('07-sua-vez','Mesa · sua vez','Mesa',r, 'Sem chamada automática ao entrar.',[PEDIR,BANCA,*imagens],['9 + 7 = 16 pontos; resultado calculado localmente.','Pontuação da banca mostra apenas a carta visível.','Checa naturais na distribuição antes de liberar o turno.'],[acao(322,56,44,44,'Pausar mesa','18-sair'),acao(24,696,164,54,'Pedir carta','08-as-flexivel','hit'),acao(202,696,164,54,'Parar','13-derrota','stand')])

r=mesa([('9','♥'),('7','♣'),('A','♦')],[('K','♠'),('7','♦')],17,'10 + ?','Boa decisão.','Ás ajustado: você continua no jogo.',restantes=307).replace(carta(183,195,'7','♦'),carta(183,195,oculta=True))
adicionar('08-as-flexivel','Mesa · Ás flexível','Mesa',r,'Após resposta de draw?count=1.',[PEDIR,BANCA,*imagens],['9 + 7 + Ás = 17, pois o Ás passa de 11 para 1.','Atualiza remaining a partir da resposta; exemplo 308 → 307.','Os exemplos de deck_id são ilustrativos.'],[acao(322,56,44,44,'Pausar mesa','18-sair'),acao(24,696,164,54,'Pedir carta','14-estouro','hit'),acao(202,696,164,54,'Parar','09-banca','stand')],nota='Correção da referência: essa mão soma 17, não 16.')

r=mesa([('9','♥'),('7','♣'),('A','♦')],[('K','♠'),('7','♦')],17,17,'Vez da banca','17 pontos. A banca para.','banca',307)
adicionar('09-banca','Mesa · vez da banca','Mesa',r,'A carta oculta é revelada localmente.',[BANCA],['O clique em Stand muda a fase, sem endpoint específico.','Neste exemplo K + 7 = 17: a banca para sem comprar.','Se a soma fosse menor que 17, compraria uma carta por vez.','Controles bloqueados até concluir a jogada.'],nota='A chamada é condicional; neste cenário não acontece. Próximo estado: empate em 17.',exemplo='A segunda carta já veio no draw inicial. Revelá-la não exige API.')


def resultado(chave,nome,jogador,banca,pj,pb,status,sub,tipo,restantes,regra):
    adicionar(chave,nome,'Resultado',mesa(jogador,banca,pj,pb,status,sub,tipo,restantes),'Sem requisição para decidir o resultado.',[DISTRIBUIR,endpoint('Nova rodada · somente se atingiu o corte',CRIAR['caminho'],CRIAR['explicacao'],CRIAR['dados'])],regra+['Nova rodada limpa mãos e continua no mesmo shoe.','Se remaining ≤ 25% do total ou < 4, cria outro shoe antes de distribuir.'],[acao(322,56,44,44,'Voltar ao menu','03-menu-ativo'),acao(24,762,342,54,'Nova rodada','06-distribuindo','rodada')],nota='O resultado é local. As chamadas indicadas acontecem apenas ao tocar Nova rodada; se renovar, criar antes de distribuir.')


resultado('10-blackjack','Resultado · Blackjack',[('A','♠'),('K','♥')],[('10','♥'),('7','♦')],21,17,'Blackjack!','Ás + figura. Uma mão perfeita.','ganhou',308,['Natural: 21 com exatamente duas cartas.','Só declara vitória depois de excluir Blackjack natural da banca.','Sem carteira ou pagamento 3:2 no escopo deste modo.'])
resultado('11-vitoria','Resultado · vitória',[('9','♥'),('7','♣'),('A','♦')],[('K','♠'),('6','♦'),('6','♣')],17,22,'Você venceu','A banca passou de 21.','ganhou',306,['Se banca estoura e jogador não, o jogador vence.','Cenário independente do atlas. No percurso principal J17/B17, Stand termina em empate.'])
resultado('12-empate','Resultado · empate',[('9','♥'),('7','♣'),('A','♦')],[('K','♠'),('7','♦')],17,17,'Empate','17 a 17. Uma nova chance vem aí.','empate',307,['Mãos com a mesma pontuação válida empatam.','Dois naturais também empatam; natural vence 21 de 3+ cartas.'])
resultado('13-derrota','Resultado · derrota',[('9','♥'),('7','♣')],[('K','♠'),('7','♦')],16,17,'A banca venceu','17 contra 16. Tente outra estratégia.','perdeu',308,['Com ambos sem estouro, compara pontos.','Ao parar com 16, a banca de 17 vence sem comprar.'])
resultado('14-estouro','Resultado · estouro',[('9','♥'),('7','♣'),('A','♦'),('8','♥')],[('K','♠'),('7','♦')],25,17,'Você passou de 21','25 pontos. A banca vence a rodada.','estouro',306,['Após Hit, o app recalcula a mão: 9 + 7 + 1 + 8 = 25.','Estouro encerra imediatamente; banca não precisa comprar.'])


def falha(titulo,sub,linhas_detalhe,botao_principal,seguro=True):
    r=topo()+texto(24,88,'♠  CLUBE 21',21,OURO,700,serifado=True)
    r+=f'<circle cx="195" cy="271" r="46" fill="#30483B" stroke="#B89B61"/>'+texto(195,287,'!',42,OURO,500,'middle',True)
    r+=texto(195,376,titulo,29,MARFIM,500,'middle',True)+linhas(195,416,sub,14,SUAVE,23,ancora='middle')
    r+=retangulo(24,496,342,115,PAINEL,18,'#426451')+linhas(42,529,linhas_detalhe,13,MARFIM,24)
    r+=botao(657,botao_principal)+botao(725,'Voltar ao menu',True)+base()
    return r


r=falha('Não foi possível conectar',['Confira sua conexão e tente novamente.','A mesa ainda não foi criada.'],['Seu jogo não começou.','Tentar novamente cria uma nova mesa.','Nenhuma compra será repetida.'],'Tentar novamente')
adicionar('15-erro-conexao','Erro · criação da mesa','Recuperação',r,'Falha ao criar o baralho, antes de comprar cartas.',[CRIAR,DISTRIBUIR],['Mostra mensagem amigável para erro de rede, HTTP ou JSON.','Retry explícito de criação pode gerar novo ID; usa só o ID recebido.','Se a falha aconteceu em draw, usa a próxima tela de recuperação.'],[acao(24,657,342,54,'Tentar novamente','06-distribuindo','novo'),acao(24,725,342,54,'Voltar ao menu','02-menu')])
r=falha('Rodada interrompida',['A conexão caiu ao pedir uma carta.','Não sabemos se a compra foi concluída.'],['Para manter a rodada correta,','reinicie a mesa com um novo baralho.','A rodada atual será encerrada.'],'Reiniciar mesa')
adicionar('16-compra-incerta','Erro · compra sem confirmação','Recuperação',r,'Timeout ou resposta inválida após enviar draw.',[CRIAR,DISTRIBUIR],['Bloqueia a mesa: a API pode já ter removido a carta.','Nunca repete draw cegamente, nem inventa endpoint de reconciliação.','Reiniciar abandona deck_id e mãos atuais e cria outra mesa.','Aplica-se também a ID inválido/expirado; preserva apenas preferências.'],[acao(24,657,342,54,'Reiniciar mesa','06-distribuindo','novo'),acao(24,725,342,54,'Voltar ao menu','02-menu','invalidar')],nota='Voltar ao menu invalida esta sessão; Continuar fica indisponível.')

r=topo('Renovando a mesa','Um baralho novo, a mesma experiência.')
r+=marca(253)+texto(195,470,'Hora de renovar o shoe',27,MARFIM,500,'middle',True)+linhas(195,510,['O corte foi atingido entre rodadas.','Vamos criar outro shoe antes de distribuir.'],13,SUAVE,23,ancora='middle')
r+=chip(91,578,'78 / 312 cartas',208)+botao(698,'Preparando nova rodada…',desabilitado=True)+base()
adicionar('17-renovar-shoe','Mesa · renovação do shoe','Recuperação',r,'Nova rodada com remaining ≤ 25% ou < 4.',[CRIAR,DISTRIBUIR],['Decisão do projeto: corte em 25%, aplicado somente entre rodadas.','Padrão de 6 decks: renova em 78 ou menos.','Novo deck_id substitui o anterior; inicia distribuição após validação.','Se faltar carta no meio da rodada, interrompe; não mistura shoes.'],nota='shuffle?remaining=true não devolve cartas compradas; não corrige um shoe vazio.')

r=mesa([('9','♥'),('7','♣'),('A','♦')],[('K','♠'),('7','♦')],17,'10 + ?','Sua vez','Pedir mais uma carta ou parar?',restantes=307).replace(carta(183,195,'7','♦'),carta(183,195,oculta=True))
r+=retangulo(0,44,390,772,'#041C17',0)+retangulo(24,264,342,332,'#17483B',24,'#78845B')+texto(195,313,'Pausar a mesa?',28,MARFIM,500,'middle',True)
r+=linhas(195,349,['Sua partida fica salva neste dispositivo.','Você pode voltar quando quiser.'],13,SUAVE,23,ancora='middle')
r+=botao(402,'Continuar jogando',False,False,42,306)+botao(468,'Salvar e ir ao menu',True,False,42,306)+texto(195,566,'Novo jogo substitui a mesa após confirmar.',12,SUAVE,400,'middle')+base()
adicionar('18-sair','Pausa e confirmação','Entrada',r,'Sem requisição à API.',[],['Pausar salva mãos, fase, deck_id, remaining e regras vigentes.','A mesma confirmação também protege a substituição da mesa por Novo jogo.','Neste protótipo, a sessão é mantida só em memória durante a navegação.'],[acao(42,402,306,54,'Continuar jogando','08-as-flexivel','retomar'),acao(42,468,306,54,'Salvar e ir ao menu','03-menu-ativo','pausar')],nota='A implementação Flutter deverá persistir a sessão para retomada após fechar o app.')
resultado('19-blackjack-banca','Resultado · Blackjack da banca',[('K','♦'),('Q','♣')],[('A','♠'),('K','♥')],20,21,'Blackjack da banca','Natural vence a sua mão de 20.','perdeu',308,['A banca tem Ás + figura nas duas cartas iniciais.','Encerramento local na distribuição: jogador não recebe turno.','Se o jogador também tiver natural, mostra empate.'])

(PASTA/'telas.json').write_text(json.dumps(TELAS_DADOS,ensure_ascii=False,indent=2),encoding='utf-8')


MODELO = '''<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Clube 21 · Protótipo de alta fidelidade</title><style>
:root{--verde:#092f27;--ouro:#b38a3e;--papel:#f3f1e9;--texto:#203c31;--suave:#576b60;--linha:#dbded3}
*{box-sizing:border-box}body{margin:0;background:var(--papel);color:var(--texto);font:15px/1.6 'Segoe UI',Arial,sans-serif}button,a{touch-action:manipulation}button{font:inherit;cursor:pointer}button:focus-visible,a:focus-visible{outline:3px solid #b28c45;outline-offset:4px}header{padding:24px 36px;border-bottom:1px solid var(--linha);display:flex;align-items:center;gap:30px;background:#faf9f3}header .marca{font:24px Georgia,serif;white-space:nowrap}header .marca span{color:#a68139}header p{margin:0;color:var(--suave);font-size:13px}header .descricao{flex:1}header .selo{border:1px solid #bbc8b5;padding:7px 12px;border-radius:99px;color:#526449;font-size:11px;letter-spacing:.8px;white-space:nowrap}.barra{padding:17px 36px;display:flex;gap:9px;align-items:center;border-bottom:1px solid var(--linha);flex-wrap:wrap}.barra button,.acao-demo{padding:9px 15px;border-radius:9px;border:1px solid #c4cfc1;background:transparent;color:var(--texto)}.barra button[aria-pressed="true"],.acao-demo{background:var(--verde);color:#f6efd9;border-color:var(--verde)}.barra .separador{flex:1}.barra .ajuda{font-size:12px;color:var(--suave)}main{max-width:1540px;margin:auto}.estudio{display:grid;grid-template-columns:225px minmax(400px,1fr) minmax(330px,440px);gap:28px;padding:30px 36px}.lista{padding-top:5px}.lista .grupo{font-size:10px;letter-spacing:1.8px;text-transform:uppercase;color:#687a68;margin:18px 0 8px}.lista .grupo:first-child{margin-top:0}.lista button{display:block;text-align:left;width:100%;padding:9px 12px;margin:3px 0;border:0;border-radius:9px;background:transparent;color:#4f6757;font-size:12px;line-height:1.4}.lista button.ativa{background:#e0e5d7;color:#1b4735;font-weight:650}.lista button span{font-size:10px;color:#7b876e;margin-right:8px}.palco{text-align:center;background-image:radial-gradient(#c7cebc 1px,transparent 1px);background-size:18px 18px;border-radius:18px;padding:24px 15px}.etiqueta{display:flex;justify-content:space-between;align-items:center;max-width:390px;margin:0 auto 16px;font-size:10px;letter-spacing:1.1px;color:#657460;text-transform:uppercase}.telefone{width:100%;max-width:390px;aspect-ratio:390/844;position:relative;margin:auto;border-radius:34px;overflow:hidden;box-shadow:0 18px 45px #123d2728,0 0 0 7px #18362c,0 0 0 8px #496052;background:#092f27}.telefone svg{width:100%;height:auto;display:block}.toque{position:absolute;opacity:0;border:0;background:transparent;border-radius:15px;z-index:2}.toque:focus-visible{opacity:1;outline:3px solid #e8c778;outline-offset:-3px;background:#e8c77818;color:transparent}.legenda-celular{max-width:390px;margin:24px auto 0;font-size:12px;color:#5a6d58}.painel{padding:6px 0}.sobretitulo{font-size:10px;letter-spacing:1.7px;text-transform:uppercase;color:#7f824e}.painel h1{font:30px/1.25 Georgia,serif;margin:10px 0 16px}.contexto{font-size:13px;color:#526a5b;padding-bottom:17px;border-bottom:1px solid var(--linha)}.endpoint{padding:18px 0;border-bottom:1px solid var(--linha)}.endpoint h3{margin:0 0 10px;font-size:13px}.endpoint code{font:12px/1.6 Consolas,monospace;word-break:break-word;display:block;color:#294a38;background:#e5e8dc;padding:12px;border-radius:9px}.metodo{display:inline-block;color:#5a713e;font-size:10px;letter-spacing:1px;font-weight:700;margin-bottom:6px}.endpoint p{font-size:12px;color:#55675a;margin:9px 0 0}.endpoint .dados{color:#384f3d}.local h3{font-size:13px;margin:18px 0 10px}.local ul{padding-left:18px;font-size:12px;color:#4b6352}.local li{margin:7px 0}.nota{padding:12px 14px;border-left:3px solid #b09a54;background:#e8e8d8;font-size:12px;color:#52604b;margin:16px 0}.catalogo{font-size:12px;margin-top:17px}.catalogo a{color:#526537}footer{display:flex;gap:20px;padding:20px 36px;border-top:1px solid var(--linha);font-size:11px;color:#66775f;flex-wrap:wrap}footer a{color:#516c49}.avisos{padding:10px 36px;background:#e8eadc;color:#4e654b;font-size:12px;min-height:40px}.atlas{padding:32px 36px;display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:28px}.mini{background:transparent;border:0;text-align:left;color:var(--texto);padding:0}.mini img{width:100%;border-radius:19px;box-shadow:0 6px 22px #17382317}.mini strong{display:block;font-size:12px;margin-top:13px}.mini span{font-size:11px;color:#6b7a66}.fluxo{padding:38px;max-width:1060px;margin:auto}.fluxo h2{font:31px Georgia,serif}.fluxo p{color:#596b59}.passos{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin:30px 0}.passo{padding:22px;background:#e7eadf;border-radius:15px}.passo b{display:block;margin-bottom:12px}.passo code{display:block;word-break:break-word;font-size:12px;margin:12px 0;color:#416046}.passo p{font-size:13px}.guia{padding:36px;max-width:1000px;margin:auto}.guia h2{font:30px Georgia,serif}.guia table{width:100%;border-collapse:collapse;font-size:13px}.guia th,.guia td{padding:14px 10px;text-align:left;border-bottom:1px solid #cdd5c4;vertical-align:top}.guia code{word-break:break-word}.guia details{margin:20px 0;border-top:1px solid var(--linha);padding-top:15px}.guia summary{cursor:pointer;font-weight:600}.guia a{color:#527241}[hidden]{display:none!important}.tema-claro svg rect[fill="url(#feltro)"]{fill:#dbe4ce}.tema-claro svg text[fill="#F7F1E4"],.tema-claro svg text[fill="#B6CDC2"]{fill:#214634}.tema-claro svg rect[fill="#164439"],.tema-claro svg rect[fill="#19463B"]{fill:#c2d2b6}.tema-claro svg text[fill="#E8C778"]{fill:#725821}
@media(max-width:1150px){.estudio{grid-template-columns:185px minmax(330px,1fr);gap:25px}.painel{grid-column:1/-1;max-width:820px;margin:auto}.painel .chamadas{display:grid;grid-template-columns:1fr 1fr;gap:18px}.lista button{padding:9px 5px}.selo{display:none}}@media(max-width:680px){header{padding:20px;gap:18px;align-items:flex-start}.marca{font-size:20px!important}header .descricao{font-size:12px}.barra{padding:12px 20px}.ajuda{width:100%;order:5}.estudio{display:flex;flex-direction:column;padding:22px 20px;gap:22px}.lista{display:flex;overflow:auto;gap:7px;padding:0 0 8px}.lista .grupo{display:none}.lista button{flex:0 0 160px;margin:0;padding:10px}.palco{padding:20px 12px}.painel .chamadas{display:block}.painel h1{font-size:27px}.passos{grid-template-columns:1fr}.fluxo,.guia{padding:24px 20px}.atlas{padding:24px 20px;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}.mini strong{font-size:11px}footer{padding:20px}.avisos{padding:10px 20px}}
.tema-claro svg rect[fill="#21483A"],.tema-claro svg rect[fill="#245245"],.tema-claro svg rect[fill="#21473D"],.tema-claro svg rect[fill="#17483B"],.tema-claro svg rect[fill="#2A5747"],.tema-claro svg rect[fill="#30483B"]{fill:#c6d8bc}.tema-claro svg rect[fill="#092F27"]{fill:#d5e1cb}.tema-claro svg rect[fill="#3A302D"]{fill:#ead4c9}.tema-claro svg text[fill="#FFB5A9"]{fill:#9a342b}.tema-claro svg text[fill="#90AA9C"]{fill:#5a7461}
</style></head><body>
<header><div class="marca"><span>♠</span> Clube 21</div><div class="descricao"><p>Blackjack · estudo de interface para Flutter</p><p>Alta fidelidade / versão 1.0 / 05 out 2026</p></div><div class="selo">19 TELAS E ESTADOS · 390 × 844</div></header>
<div class="barra" aria-label="Modo de apresentação"><button data-modo="prototipo" aria-pressed="true">Protótipo</button><button data-modo="atlas" aria-pressed="false">Todas as telas</button><button data-modo="fluxo" aria-pressed="false">Fluxo da API</button><button data-modo="guia" aria-pressed="false">Guia técnico</button><span class="separador"></span><button id="reproduzir">Reproduzir fluxo</button><span class="ajuda">Clique nos botões do celular para navegar.</span></div>
<div class="avisos" id="aviso" aria-live="polite">Demonstração local: os endpoints estão documentados, e as respostas são simuladas.</div>
<main>
<section class="estudio" id="prototipo"><nav class="lista" id="lista" aria-label="Telas do protótipo"></nav><div class="palco"><div class="etiqueta"><span id="numero">01 / 19</span><span>Prévia mobile</span></div><div class="telefone" id="telefone"></div><p class="legenda-celular" id="legenda">Todos os textos e valores do jogo são ilustrativos.</p></div><aside class="painel" id="painel" aria-label="Explicação técnica da tela"></aside></section>
<section class="atlas" id="atlas" hidden aria-label="Visão geral das telas"></section>
<section class="fluxo" id="fluxo" hidden><span class="sobretitulo">API + REGRAS LOCAIS</span><h2>O baralho vem da API.<br>A partida é conduzida pelo Flutter.</h2><p>Base URL: <a href="https://deckofcardsapi.com/" target="_blank" rel="noreferrer">https://deckofcardsapi.com</a>. Cada requisição usa GET e o mesmo deck_id da mesa.</p><div class="passos"><div class="passo"><b>01 · Criar a mesa</b><code>GET /api/deck/new/shuffle/?deck_count=6</code><p>Retorna deck_id e 312 cartas. Guardar o ID; a criação não distribui cartas.</p></div><div class="passo"><b>02 · Distribuir</b><code>GET /api/deck/{deck_id}/draw/?count=4</code><p>308 cartas restantes. Alternar jogador/banca, ocultar a segunda da banca e checar naturais.</p></div><div class="passo"><b>03 · Sua decisão</b><code>GET /api/deck/{deck_id}/draw/?count=1</code><p>Hit compra uma. Stand revela a banca localmente; ela só compra quando a regra exigir.</p></div><div class="passo"><b>04 · Calcular o resultado</b><code>Sem endpoint de pontuação ou vencedor</code><p>Flutter ajusta os ases, compara mãos, trata naturais, empate e estouro.</p></div><div class="passo"><b>05 · Nova rodada</b><code>GET /api/deck/{deck_id}/draw/?count=4</code><p>Limpar mãos, manter o shoe. Corte em 25% renova antes de distribuir; não devolver cartas a cada rodada.</p></div><div class="passo"><b>06 · Tratar uma falha</b><code>Não repetir draw após timeout</code><p>A compra pode ter sido processada. Interromper e oferecer uma nova mesa com outro deck_id.</p></div></div><button class="acao-demo" data-ir="02-menu">Experimentar o fluxo</button></section>
<section class="guia" id="guia" hidden><span class="sobretitulo">DECISÕES PARA A APRESENTAÇÃO</span><h2>Uma base pequena, clara e explicável.</h2><p>Este artefato define o design e o comportamento. A aplicação Flutter será a próxima etapa. As referências foram refinadas com tipografia clássica, feltro verde, cartas em marfim e ações em dourado.</p><table><thead><tr><th>Parte</th><th>Responsabilidade</th></tr></thead><tbody><tr><td>API</td><td>Criar shoe, retirar cartas, embaralhar e oferecer imagens. Não calcula pontos.</td></tr><tr><td>Modelos em Dart</td><td>Carta, mão e estado de jogo; conversão de JSON e pontuação com Ás flexível.</td></tr><tr><td>Controlador</td><td>Coordenar Hit, Stand, fases, bloqueio durante rede, resultados e erros.</td></tr><tr><td>Telas Flutter</td><td>Renderizar estado e enviar comandos ao controlador. Textos, nomes próprios e comentários em português.</td></tr><tr><td>Persistência local</td><td>Preferências e sessão completa. deck_id sozinho não reconstrói a mesa.</td></tr></tbody></table><details open><summary>Escolhas de escopo</summary><p>1 a 6 baralhos (padrão 6), banca para no soft 17 por padrão. Sem apostas, carteira, split, double ou seguro. Pilhas remotas não são usadas porque são incompatíveis com múltiplos decks. A rodada seguinte continua no shoe até o corte de 25%. As regras e a quantidade de baralhos só mudam na próxima mesa.</p></details><details><summary>Contrato e validações</summary><p>Validar HTTP 2xx e success=true; deck_id não vazio; cartas suficientes; remaining inteiro (aceitar string numérica). Campos images são opcionais. O código da carta dez usa 0, por exemplo 0H; value vem como 10. Timeout de 10 segundos, erro amigável e fallback textual para imagem.</p></details><details><summary>Outros endpoints documentados (fora do fluxo principal)</summary><table><tr><td>Ordenado / teste</td><td><code>GET /api/deck/new/</code><br><code>GET /api/deck/new/shuffle/?cards=AS,KH,2C,7D</code></td></tr><tr><td>Reembaralhar</td><td><code>GET /api/deck/{deck_id}/shuffle/</code><br><code>GET /api/deck/{deck_id}/shuffle/?remaining=true</code><p>remaining=true só mistura cartas ainda no monte; não recupera as compradas.</p></td></tr><tr><td>Pilhas · somente 1 deck</td><td><code>GET /api/deck/{deck_id}/pile/{pilha}/add/?cards=AS,KH</code><br><code>GET /api/deck/{deck_id}/pile/{pilha}/list/</code><br><code>GET /api/deck/{deck_id}/pile/{pilha}/shuffle/</code><br><code>GET /api/deck/{deck_id}/pile/{pilha}/draw/?count=1</code><br><code>GET /api/deck/{deck_id}/pile/{pilha}/draw/bottom/?count=1</code><br><code>GET /api/deck/{deck_id}/pile/{pilha}/draw/random/?count=1</code></td></tr><tr><td>Retorno opcional</td><td><code>GET /api/deck/{deck_id}/return/?cards=AS,KH</code><br><code>GET /api/deck/{deck_id}/pile/{pilha}/return/?cards=AS,KH</code></td></tr><tr><td>Verso / frente</td><td><code>GET /static/img/back.png</code><br><code>GET {URL retornada em image}</code></td></tr></table></details><details><summary>Para levar ao Figma</summary><p>Importe os arquivos SVG da pasta telas: cada um mede 390 × 844 e conserva formas e textos vetoriais. Eles são telas para importar, não um arquivo .fig nativo. Para revisar fora do Figma, abra index.html ou o PDF anotado.</p></details><p><a href="GUIA_APRESENTACAO.md">Ler roteiro completo de apresentação</a> · <a href="https://deckofcardsapi.com/" target="_blank" rel="noreferrer">Documentação oficial</a></p></section>
</main><footer><span>Protótipo para avaliação · sem chamadas reais à API</span><span>Referência: documentação técnica anexada, páginas 4, 15 e 16</span><a href="https://deckofcardsapi.com/" target="_blank" rel="noreferrer">Deck of Cards API</a><span>SVG editável + PNG + PDF anotado</span></footer>
<script id="dados" type="application/json">__DADOS__</script>
<script>
// A navegação é uma demonstração determinística. Nenhuma requisição HTTP é enviada.
const telas = JSON.parse(document.getElementById('dados').textContent);
const porChave = Object.fromEntries(telas.map(tela => [tela.chave, tela]));
let atual = '01-abertura', anterior = '02-menu', sessao = false, maoAtual = '07-sua-vez', pendente;
let preferencias = {baralhos:6, soft:true, som:true, vibracao:true, claro:false};
let mesa = {baralhos:6, soft:true, restantes:308, total:312, rodada:1};
let substituir = false, modo = 'prototipo';
const telefone = document.getElementById('telefone'), painel = document.getElementById('painel');
const aviso = document.getElementById('aviso');
const escapar = valor => String(valor).replace(/[&<>\"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;'}[c]));
function informar(mensagem){ aviso.textContent = mensagem; }
function exibirModo(novoModo){ modo=novoModo; ['prototipo','atlas','fluxo','guia'].forEach(id=>document.getElementById(id).hidden=id!==novoModo); document.querySelectorAll('[data-modo]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.modo===novoModo))); }
function mostrar(chave, manterAviso=false){
  clearTimeout(pendente); anterior=atual; atual=chave; const tela=porChave[chave];
  if(/^(07|08|10|11|12|13|14|19)-/.test(chave))maoAtual=chave;
  telefone.innerHTML=tela.svg; telefone.classList.toggle('tema-claro',preferencias.claro);
  document.getElementById('numero').textContent=String(telas.indexOf(tela)+1).padStart(2,'0')+' / '+telas.length;
  document.getElementById('legenda').textContent=tela.exemplo || 'Toque nas ações do celular. Valores ilustrativos.';
  document.querySelectorAll('[data-tela]').forEach(b=>{b.classList.toggle('ativa',b.dataset.tela===chave); b.setAttribute('aria-current',b.dataset.tela===chave?'page':'false');});
  painel.innerHTML=`<span class="sobretitulo">${escapar(tela.grupo)} · integração e comportamento</span><h1>${escapar(tela.nome)}</h1><div class="contexto"><strong>Ao abrir:</strong> ${escapar(tela.ao_abrir)}</div><div class="chamadas">${tela.chamadas.map(c=>`<section class="endpoint"><h3>${escapar(c.gatilho)}</h3><span class="metodo">${escapar(c.metodo)}</span><code>${escapar(c.caminho)}</code><p>${escapar(c.explicacao)}</p>${c.dados?`<p class="dados"><b>Dados:</b> ${escapar(c.dados)}</p>`:''}</section>`).join('')}</div><div class="local"><h3>O Flutter resolve localmente</h3><ul>${tela.local.map(item=>`<li>${escapar(item)}</li>`).join('')}</ul></div>${tela.nota?`<div class="nota">${escapar(tela.nota)}</div>`:''}<div class="catalogo">Base das URLs: <a href="https://deckofcardsapi.com/" target="_blank" rel="noreferrer">deckofcardsapi.com</a></div>`;
  tela.acoes.forEach(a=>{const b=document.createElement('button');b.className='toque';b.setAttribute('aria-label',a.rotulo);b.style.cssText=`left:${a.x/390*100}%;top:${a.y/844*100}%;width:${a.largura/390*100}%;height:${a.altura/844*100}%`;b.addEventListener('click',()=>executar(a));telefone.append(b);});
  if(sessao) ajustarMesa();
  if(chave==='04-configuracoes') atualizarConfiguracoes();
  if(!manterAviso) informar('Tela '+String(telas.indexOf(tela)+1).padStart(2,'0')+': '+tela.nome+'. Respostas e valores simulados.');
}
function aguardar(chave, mensagem){ pendente=setTimeout(()=>{mostrar(chave,true);informar(mensagem);},1000); }
function atualizarConfiguracoes(){
  const textos=[...telefone.querySelectorAll('text')];
  textos.find(t=>t.getAttribute('x')==='287').textContent=preferencias.baralhos;
  textos.find(t=>t.textContent==='Padrão clássico: 6').textContent='Escolhido: '+preferencias.baralhos+' baralhos';
  [324,477,544].forEach((y,i)=>{const ligado=[preferencias.soft,preferencias.som,preferencias.vibracao][i]; const ponto=telefone.querySelector(`circle[cy="${y}"]`);ponto.setAttribute('cx',ligado?'334':'314');const trilho=[...telefone.querySelectorAll('rect')].find(r=>r.getAttribute('x')==='300'&&+r.getAttribute('y')===y-14);if(trilho)trilho.setAttribute('fill',ligado?'#E8C778':'#668576');});
  const explicacao=textos.find(t=>t.textContent==='Ligado: a banca para nessa mão.');if(explicacao&&!preferencias.soft)explicacao.textContent='Desligado: compra nessa mão.';
  const selecao=telefone.querySelector('rect[x="218"][y="600"]');
  selecao.setAttribute('x',preferencias.claro?'290':'218');
  textos.find(t=>t.textContent==='Escuro').setAttribute('fill',preferencias.claro?'#B6CDC2':'#173B30');
  textos.find(t=>t.textContent==='Claro').setAttribute('fill',preferencias.claro?'#173B30':'#B6CDC2');
  informar('Configurações locais · '+preferencias.baralhos+' baralhos · soft 17 '+(preferencias.soft?'para':'compra')+' · tema '+(preferencias.claro?'claro':'escuro')+'. Aplicação na próxima mesa.');
}
function ajustarMesa(){
  [...telefone.querySelectorAll('text')].forEach(t=>{
    if(t.textContent.endsWith('cartas no shoe'))t.textContent=mesa.restantes+' cartas no shoe';
    if(t.textContent==='6 baralhos')t.textContent=mesa.baralhos+' baralhos';
    if(t.textContent.startsWith('Mesa 01 ·'))t.textContent='Mesa 01 · '+mesa.restantes+' cartas restantes';
  });
}
function executar(acao){
  const comando=acao.comando;
  if(['menos','mais','soft','som','vibracao','tema','padroes'].includes(comando)){
    if(comando==='menos')preferencias.baralhos=Math.max(1,preferencias.baralhos-1);
    if(comando==='mais')preferencias.baralhos=Math.min(6,preferencias.baralhos+1);
    if(['soft','som','vibracao'].includes(comando))preferencias[comando]=!preferencias[comando];
    if(comando==='tema')preferencias.claro=!preferencias.claro;
    if(comando==='padroes')preferencias={baralhos:6,soft:true,som:true,vibracao:true,claro:false};
    mostrar('04-configuracoes',true);return;
  }
  if(comando==='substituir'){substituir=true;mostrar('18-sair');personalizarConfirmacao();return;}
  if(comando==='retomar'){substituir=false;mostrar(maoAtual);return;}
  if(comando==='pausar'&&substituir){substituir=false;iniciar(true);return;}
  if(comando==='pausar'){sessao=true;mostrar('03-menu-ativo');return;}
  if(comando==='novo'){iniciar(true);return;}
  if(comando==='rodada'){iniciar(false);return;}
  if(comando==='hit'){
    const destino=atual==='07-sua-vez'?'08-as-flexivel':'14-estouro';
    telefone.querySelectorAll('button.toque').forEach(b=>b.disabled=true);informar('GET draw/?count=1 · ações bloqueadas enquanto aguardamos a carta.');
    pendente=setTimeout(()=>{mesa.restantes--;maoAtual=destino;sessao=true;mostrar(destino,true);informar(destino==='14-estouro'?'Resposta simulada: 8 → 25 pontos. Estouro calculado localmente.':'Resposta simulada: Ás → 17 pontos; Ás ajustado para 1.');},650);return;
  }
  if(comando==='stand'){
    const veioDe=atual;mostrar('09-banca',true);informar('Stand: revelar a carta já comprada. Neste cenário, K + 7 = 17: nenhuma compra da banca.');
    if(veioDe==='07-sua-vez'){
      // O estado intermediário deste caso usa a mão anterior, com duas cartas.
      const temporario=document.createElement('div');temporario.innerHTML=porChave['13-derrota'].svg;
      const textosTemp=[...temporario.querySelectorAll('text')];textosTemp.find(t=>t.textContent==='A banca venceu').textContent='Vez da banca';textosTemp.find(t=>t.textContent==='17 contra 16. Tente outra estratégia.').textContent='17 pontos. A banca para.';
      textosTemp.find(t=>t.textContent==='Nova rodada').textContent='Rodada em andamento';telefone.innerHTML=temporario.innerHTML;ajustarMesa();
      informar('Stand: banca com 17 supera jogador com 16. Sem compra de carta.');
      pendente=setTimeout(()=>{maoAtual='13-derrota';mostrar('13-derrota',true);informar('Resultado local: 17 da banca contra 16 do jogador.');},1100);
    }else{aguardar('12-empate','Resultado local: 17 × 17. Empate, sem requisição adicional.');}return;
  }
  if(comando==='invalidar')sessao=false;
  let destino=acao.destino;
  if(acao.rotulo==='Continuar partida')destino=maoAtual;
  if(destino==='02-menu'&&sessao)destino='03-menu-ativo';
  if(destino==='03-menu-ativo'&&!sessao)sessao=true;
  if(destino==='18-sair'){maoAtual=atual;substituir=false;}
  mostrar(destino);
}
function iniciar(novaMesa){
  const renovar=!novaMesa&&(mesa.restantes<=mesa.total*.25||mesa.restantes<4);
  if(novaMesa||renovar)mesa={baralhos:preferencias.baralhos,soft:preferencias.soft,restantes:preferencias.baralhos*52,total:preferencias.baralhos*52,rodada:0};
  mesa.rodada++;mesa.restantes-=4;sessao=true;maoAtual='07-sua-vez';mostrar(renovar?'17-renovar-shoe':'06-distribuindo',true);
  informar((novaMesa||renovar?'GET new/shuffle/?deck_count='+mesa.baralhos+' → ':'Mesmo deck_id → ')+'GET draw/?count=4. Rodada '+mesa.rodada+'.');
  aguardar('07-sua-vez','Distribuição simulada concluída: jogador 16; banca 10 + ?; '+mesa.restantes+' cartas restantes.');
}
function personalizarConfirmacao(){
  const textos=[...telefone.querySelectorAll('text')];
  textos.find(t=>t.textContent==='Pausar a mesa?').textContent='Substituir a mesa?';
  textos.find(t=>t.textContent==='Sua partida fica salva neste dispositivo.').textContent='A mesa atual será encerrada.';
  textos.find(t=>t.textContent==='Você pode voltar quando quiser.').textContent='Seu novo jogo terá outro baralho.';
  textos.find(t=>t.textContent==='Continuar jogando').textContent='Manter a mesa atual';
  textos.find(t=>t.textContent==='Salvar e ir ao menu').textContent='Confirmar novo jogo';
  telefone.querySelector('[aria-label="Salvar e ir ao menu"]').setAttribute('aria-label','Confirmar novo jogo');
}
document.querySelectorAll('[data-modo]').forEach(b=>b.addEventListener('click',()=>exibirModo(b.dataset.modo)));
document.querySelectorAll('[data-ir]').forEach(b=>b.addEventListener('click',()=>{exibirModo('prototipo');mostrar(b.dataset.ir);}));
document.getElementById('reproduzir').addEventListener('click',()=>{clearTimeout(pendente);sessao=false;exibirModo('prototipo');mostrar('01-abertura',true);informar('Abertura: leitura local de preferências. Em seguida, toque em Novo jogo.');aguardar('02-menu','Pronto para começar. Toque em Novo jogo no celular.');});
let ultimoGrupo='';
telas.forEach((t,i)=>{
  if(t.grupo!==ultimoGrupo){const g=document.createElement('div');g.className='grupo';g.textContent=t.grupo;document.getElementById('lista').append(g);ultimoGrupo=t.grupo;}
  const b=document.createElement('button');b.dataset.tela=t.chave;b.innerHTML='<span>'+String(i+1).padStart(2,'0')+'</span>'+escapar(t.nome);b.addEventListener('click',()=>{exibirModo('prototipo');mostrar(t.chave);});document.getElementById('lista').append(b);
  const mini=document.createElement('button');mini.className='mini';mini.innerHTML='<img src="telas/'+t.chave+'.png" alt="'+escapar(t.nome)+'" loading="lazy"><strong>'+String(i+1).padStart(2,'0')+' · '+escapar(t.nome)+'</strong><span>'+escapar(t.grupo)+'</span>';mini.addEventListener('click',()=>{exibirModo('prototipo');mostrar(t.chave);window.scrollTo(0,0);});document.getElementById('atlas').append(mini);
});
mostrar(atual,true);
</script></body></html>'''

# O JSON está embutido no arquivo para a demonstração funcionar até offline.
dados_json=json.dumps(TELAS_DADOS,ensure_ascii=False).replace('</','<\\/')
(PASTA/'index.html').write_text(MODELO.replace('__DADOS__',dados_json),encoding='utf-8')
print(f'{len(TELAS_DADOS)} telas SVG e protótipo criados em {PASTA}')
