"""Exporta as telas e suas anotações para um PDF de apresentação.

O conteúdo é lido de telas.json, para não manter uma segunda versão do
contrato. As imagens são os PNGs do protótipo, sem chamadas à API.
"""

from html import escape
from pathlib import Path
import json
import re

from PIL import Image
from pypdf import PdfReader
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph


PASTA = Path(__file__).resolve().parent
ARQUIVO = PASTA / "blackjack-alta-fidelidade-anotado.pdf"
TELAS = json.loads((PASTA / "telas.json").read_text(encoding="utf-8"))
LARGURA, ALTURA = landscape(A4)
VERDE = colors.HexColor("#092F27")
TEXTO = colors.HexColor("#203C31")
SUAVE = colors.HexColor("#52695A")
OURO = colors.HexColor("#9B773B")
PAPEL = colors.HexColor("#F7F5EE")
PAINEL = colors.HexColor("#E8EDDF")
LINHA = colors.HexColor("#D5DECF")
MARGEM = 32
COLUNA_X = 296
COLUNA_LARGURA = LARGURA - COLUNA_X - MARGEM
INICIO_TEXTO = 511
LIMITE_INFERIOR = 49


for nome, arquivo in (
    ("Arial", "arial.ttf"),
    ("ArialNegrito", "arialbd.ttf"),
    ("Georgia", "georgia.ttf"),
    ("Consolas", "consola.ttf"),
):
    pdfmetrics.registerFont(TTFont(nome, str(Path("C:/Windows/Fonts") / arquivo)))

pdfmetrics.registerFontFamily(
    "Arial", normal="Arial", bold="ArialNegrito", italic="Arial", boldItalic="ArialNegrito"
)

ESTILOS = {
    "corpo": ParagraphStyle(
        "corpo", fontName="Arial", fontSize=11, leading=15,
        textColor=TEXTO, alignment=TA_LEFT, splitLongWords=True,
    ),
    "apoio": ParagraphStyle(
        "apoio", fontName="Arial", fontSize=10.5, leading=14,
        textColor=SUAVE, splitLongWords=True,
    ),
    "subtitulo": ParagraphStyle(
        "subtitulo", fontName="ArialNegrito", fontSize=12, leading=16,
        textColor=VERDE,
    ),
    "gatilho": ParagraphStyle(
        "gatilho", fontName="ArialNegrito", fontSize=11, leading=14.5,
        textColor=VERDE,
    ),
    "codigo": ParagraphStyle(
        "codigo", fontName="Consolas", fontSize=11, leading=14.5,
        textColor=VERDE, splitLongWords=True,
    ),
    "titulo": ParagraphStyle(
        "titulo", fontName="Georgia", fontSize=24, leading=29,
        textColor=VERDE,
    ),
    "capa": ParagraphStyle(
        "capa", fontName="Georgia", fontSize=39, leading=45,
        textColor=VERDE,
    ),
}


def paragrafo(valor, estilo="corpo", prefixo=""):
    return Paragraph(prefixo + escape(str(valor)), ESTILOS[estilo])


def altura_paragrafos(paragrafos, largura, espaco=5):
    """Mede antes de desenhar; nada deve ultrapassar o rodapé."""
    alturas = [p.wrap(largura, ALTURA)[1] for p in paragrafos]
    return sum(alturas) + max(0, len(alturas) - 1) * espaco, alturas


class Documento:
    def __init__(self):
        self.pdf = canvas.Canvas(
            str(ARQUIVO), pagesize=(LARGURA, ALTURA), pageCompression=1,
            initialFontName="Arial",
        )
        self.pdf.setTitle("Clube 21 - Blackjack: protótipo de alta fidelidade anotado")
        self.pdf.setAuthor("Projeto Blackjack - Davi e Bernardo")
        self.pdf.setSubject("19 telas, endpoints e regras locais para a implementação Flutter")
        self.pagina = 0
        self.limites = []
        self.paginas_telas = {}
        self.y = INICIO_TEXTO

    def registrar(self, rotulo, x, y, largura, altura):
        margem_folga = 0.5
        dentro = (
            x >= -margem_folga and y >= -margem_folga
            and x + largura <= LARGURA + margem_folga
            and y + altura <= ALTURA + margem_folga
        )
        self.limites.append({
            "pagina": self.pagina, "elemento": rotulo,
            "x": round(x, 2), "y": round(y, 2),
            "largura": round(largura, 2), "altura": round(altura, 2), "dentro": dentro,
        })
        if not dentro:
            raise ValueError(f"Elemento fora da página: {self.limites[-1]}")

    def nova_pagina(self, titulo, categoria, chave="", continuacao=False):
        if self.pagina:
            self.rodape()
            self.pdf.showPage()
        self.pagina += 1
        self.pdf.setFillColor(PAPEL)
        self.pdf.rect(0, 0, LARGURA, ALTURA, fill=1, stroke=0)
        self.pdf.setFillColor(OURO)
        self.pdf.setFont("ArialNegrito", 9.5)
        self.pdf.drawString(MARGEM, ALTURA - 29, categoria.upper())
        if continuacao:
            titulo += " - continuação"
        p = paragrafo(titulo, "titulo")
        _, altura = p.wrap(LARGURA - 2 * MARGEM, 100)
        p.drawOn(self.pdf, MARGEM, ALTURA - 41 - altura)
        self.registrar("título", MARGEM, ALTURA - 41 - altura, LARGURA - 2 * MARGEM, altura)
        self.pdf.setStrokeColor(LINHA)
        self.pdf.line(MARGEM, 525, LARGURA - MARGEM, 525)
        self.y = INICIO_TEXTO
        if chave:
            self.paginas_telas.setdefault(chave, []).append(self.pagina)

    def rodape(self):
        self.pdf.setStrokeColor(LINHA)
        self.pdf.line(MARGEM, 35, LARGURA - MARGEM, 35)
        self.pdf.setFillColor(SUAVE)
        self.pdf.setFont("Arial", 8.5)
        self.pdf.drawString(MARGEM, 20, "CLUBE 21  |  Design e fluxo simulados  |  05 out 2026")
        self.pdf.drawRightString(LARGURA - MARGEM, 20, f"{self.pagina:02d}")

    def imagem(self, chave):
        caminho = PASTA / "telas" / f"{chave}.png"
        with Image.open(caminho) as imagem:
            largura, altura = imagem.size
        altura_final = 466
        largura_final = altura_final * largura / altura
        x = 42 + (230 - largura_final) / 2
        y = 51
        self.pdf.setFillColor(colors.HexColor("#163F30"))
        self.pdf.roundRect(x - 4, y - 4, largura_final + 8, altura_final + 8, 14, fill=1, stroke=0)
        self.pdf.drawImage(str(caminho), x, y, width=largura_final, height=altura_final, mask="auto")
        self.registrar(f"imagem {chave}", x - 4, y - 4, largura_final + 8, altura_final + 8)

    def bloco(self, paragrafos, rotulo, preenchimento=False, x=COLUNA_X, largura=COLUNA_LARGURA):
        padding = 12 if preenchimento else 0
        altura, alturas = altura_paragrafos(paragrafos, largura - padding * 2)
        altura_total = altura + padding * 2
        if self.y - altura_total < LIMITE_INFERIOR:
            return False
        fundo = self.y - altura_total
        if preenchimento:
            self.pdf.setFillColor(PAINEL)
            self.pdf.roundRect(x, fundo, largura, altura_total, 9, fill=1, stroke=0)
        yy = self.y - padding
        for p, h in zip(paragrafos, alturas):
            yy -= h
            p.drawOn(self.pdf, x + padding, yy)
            yy -= 5
        self.registrar(rotulo, x, fundo, largura, altura_total)
        self.y = fundo - 12
        return True

    def salvar(self):
        self.rodape()
        self.pdf.save()


def endpoint_paragrafos(chamada):
    return [
        paragrafo(chamada["gatilho"], "gatilho"),
        paragrafo(chamada["metodo"] + " " + chamada["caminho"], "codigo"),
        paragrafo(chamada["explicacao"], "corpo"),
        *([paragrafo(chamada["dados"], "apoio", "<b>Dados:</b> ")] if chamada.get("dados") else []),
    ]


def capa(documento):
    documento.nova_pagina("Blackjack, com tudo explicado.", "Protótipo de alta fidelidade")
    documento.imagem("02-menu")
    documento.bloco([
        paragrafo("Clube 21", "capa"),
        paragrafo("Um clássico na sua mão.", "subtitulo"),
        paragrafo("19 telas e estados para apresentar o design e compreender a futura implementação em Flutter."),
    ], "introdução da capa")
    documento.bloco([
        paragrafo("Como ler este documento", "subtitulo"),
        paragrafo("À esquerda, a tela do aplicativo. À direita, seus endpoints, gatilhos, dados e decisões locais. Cada tela pode ter uma página de continuação quando necessário."),
        paragrafo("A demonstração é simulada: imagens, mãos e contagens ilustram cenários reproduzíveis. Este PDF não executa chamadas HTTP."),
    ], "orientação da capa", True)
    documento.bloco([
        paragrafo("O foco desta versão", "subtitulo"),
        paragrafo("Pedir, parar, pontuar e jogar novas rodadas. Seis baralhos por padrão, visual clássico e controles claros. Sem apostas, saldo, split, double ou seguro."),
        paragrafo("Referências: documentação técnica anexada, wireframes fornecidos e documentação oficial da Deck of Cards API.", "apoio"),
        paragrafo("https://deckofcardsapi.com/", "codigo"),
        paragrafo("Os caminhos das anotações usam essa base. {deck_id} é o ID recebido na criação; {n} é a quantidade de decks. As telas estáticas ilustram o padrão de 6.", "apoio"),
    ], "escopo e fontes da capa")


def pagina_fluxo(documento):
    documento.nova_pagina("O caminho de uma rodada", "API + regras locais")
    documento.y = 505
    esquerda_x = MARGEM
    esquerda_largura = 370
    direita_x = 434
    direita_largura = LARGURA - direita_x - MARGEM
    y_inicial = documento.y
    for titulo, codigo, explicacao in [
        ("01. Criar a mesa", "GET /api/deck/new/shuffle/?deck_count=6", "Guarda deck_id e remaining. Seis decks começam com 312 cartas. Criação e compra são sequenciais."),
        ("02. Distribuir", "GET /api/deck/{deck_id}/draw/?count=4", "Alterna jogador/banca/jogador/banca. Restam 308 cartas. A segunda da banca fica oculta; os naturais são verificados localmente."),
        ("03. Pedir ou parar", "GET /api/deck/{deck_id}/draw/?count=1", "Hit compra uma. Stand revela a carta local; a banca só compra se a regra exigir. As ações ficam bloqueadas enquanto a rede responde."),
    ]:
        assert documento.bloco([paragrafo(titulo, "subtitulo"), paragrafo(codigo, "codigo"), paragrafo(explicacao)], titulo, True, esquerda_x, esquerda_largura)
    documento.y = y_inicial
    for titulo, explicacao in [
        ("04. Resolver no Flutter", "Pontuação, ajuste do Ás, natural, estouro e empate são locais. Blackjack é 21 em duas cartas; um natural vence 21 com três ou mais. Dois naturais empatam."),
        ("05. Seguir no mesmo shoe", "Nova rodada compra quatro cartas do mesmo deck_id. No corte de 25%, cria outro shoe antes de distribuir: seis decks renovam em 78 cartas ou menos. Não mistura shoes no meio da rodada."),
        ("06. Recuperar com clareza", "Timeout de draw torna a compra inconclusiva. Não repetir a compra cegamente: oferecer reiniciar mesa com novo ID e novas mãos. Imagem indisponível usa uma carta textual local."),
    ]:
        assert documento.bloco([paragrafo(titulo, "subtitulo"), paragrafo(explicacao)], titulo, True, direita_x, direita_largura)
    assert documento.bloco([
        paragrafo("A API não calcula o vencedor. Preferências e Continuar usam estado local. Pilhas remotas não são usadas com múltiplos decks.", "apoio"),
    ], "responsabilidades do fluxo", False, direita_x, direita_largura)


def paginas_tela(documento, numero, tela):
    titulo = f"{numero:02d}. {tela['nome']}"
    documento.nova_pagina(titulo, tela["grupo"], tela["chave"])
    documento.imagem(tela["chave"])

    def inserir(paragrafos, rotulo, painel=False):
        if not documento.bloco(paragrafos, rotulo, painel):
            documento.nova_pagina(titulo, tela["grupo"], tela["chave"], True)
            documento.imagem(tela["chave"])
            if not documento.bloco(paragrafos, rotulo, painel):
                raise ValueError(f"Bloco maior que uma coluna: {tela['chave']} / {rotulo}")

    inserir([paragrafo(tela["ao_abrir"], "corpo", "<b>Ao abrir:</b> ")], "ao abrir")
    if tela["chamadas"]:
        for i, chamada in enumerate(tela["chamadas"], 1):
            inserir(endpoint_paragrafos(chamada), f"endpoint {i}", True)
    else:
        inserir([
            paragrafo("Sem endpoint nesta tela", "subtitulo"),
            paragrafo("Esta tela funciona com conteúdo e estado locais. Ela não precisa criar um baralho ou comprar cartas ao abrir."),
        ], "sem endpoint", True)
    inserir([
        paragrafo("O Flutter resolve localmente", "subtitulo"),
        *[paragrafo(item, "corpo", "<b>•</b> ") for item in tela["local"]],
    ], "regras locais")
    if tela.get("nota"):
        inserir([paragrafo(tela["nota"], "corpo", "<b>Atenção:</b> ")], "condição importante", True)
    if tela.get("exemplo"):
        inserir([paragrafo(tela["exemplo"], "apoio", "<b>Exemplo:</b> ")], "exemplo")


def validar(documento):
    leitor = PdfReader(ARQUIVO)
    textos = [p.extract_text() or "" for p in leitor.pages]
    texto = "\n".join(textos)
    texto_normalizado = re.sub(r"\s+", " ", texto)
    falhas = []
    for i, tela in enumerate(TELAS, 1):
        titulo = f"{i:02d}. {tela['nome']}"
        if titulo not in texto:
            falhas.append(f"Título ausente: {titulo}")
        for campo in ("ao_abrir", "nota", "exemplo"):
            valor = tela.get(campo)
            if valor and re.sub(r"\s+", " ", valor) not in texto_normalizado:
                falhas.append(f"Conteúdo ausente: {tela['chave']} / {campo}")
        for item in tela["local"]:
            if re.sub(r"\s+", " ", item) not in texto_normalizado:
                falhas.append(f"Regra local ausente: {tela['chave']} / {item}")
        for chamada in tela["chamadas"]:
            for campo in ("gatilho", "caminho", "explicacao", "dados"):
                valor = chamada.get(campo)
                if valor and re.sub(r"\s+", " ", valor) not in texto_normalizado:
                    falhas.append(f"Endpoint incompleto: {tela['chave']} / {campo}")
    fontes = {}
    for pagina in leitor.pages:
        for nome, objeto in pagina["/Resources"].get("/Font", {}).items():
            fonte = objeto.get_object()
            base = str(fonte.get("/BaseFont", nome))
            descritor = fonte.get("/FontDescriptor")
            embutida = False
            if descritor:
                d = descritor.get_object()
                embutida = any(campo in d for campo in ("/FontFile", "/FontFile2", "/FontFile3"))
            fontes[base] = embutida
    if not all(any(nome in fonte for fonte in fontes) for nome in ("Arial", "Georgia", "Consolas")):
        falhas.append("Famílias tipográficas ausentes")
    if falhas:
        raise ValueError("Falhas de verificação:\n" + "\n".join(falhas))
    assert len(TELAS) == 19
    fora = [b for b in documento.limites if not b["dentro"]]
    assert not fora
    paginas_longas = [k for k, v in documento.paginas_telas.items() if len(v) > 1]
    print(json.dumps({
        "arquivo": str(ARQUIVO), "paginas": len(leitor.pages),
        "titulos_de_tela": len(TELAS), "blocos_verificados": len(documento.limites),
        "blocos_fora_dos_limites": len(fora), "texto_integral": True,
        "fontes": fontes, "paginas_por_tela": documento.paginas_telas,
        "telas_com_continuacao": paginas_longas,
        "fonte_corpo_minima_pt": 10.5, "fonte_endpoints_pt": 11,
    }, ensure_ascii=True, indent=2))


if __name__ == "__main__":
    documento = Documento()
    capa(documento)
    pagina_fluxo(documento)
    for numero, tela in enumerate(TELAS, 1):
        paginas_tela(documento, numero, tela)
    documento.salvar()
    validar(documento)
