"""Prepara as cenas para o Figma sem modificar os SVGs ou o protótipo HTML.

Textos, botões, chips e cartas viram camadas nativas. A ordem das camadas
permanece a do SVG, inclusive a sobreposição da confirmação sobre a mesa.
"""
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET

PASTA = Path(__file__).parent
def nome(e):
    return e.tag.split('}')[-1]
def comando(e):
    a = dict(e.attrib)
    return {'tipo': nome(e), 'a': a, 'texto': ''.join(e.itertext()) if nome(e)=='text' else '',
            'filhos': [comando(c) for c in e]}
def cena(svg):
    itens = [e for e in ET.fromstring(svg) if nome(e)!='defs']
    saida=[]
    i=0
    while i<len(itens):
        e=itens[i]
        a=e.attrib
        if nome(e)=='g' and len(e)>1 and nome(e[1])=='rect':
            face=e[1].attrib
            ts=[t for t in e if nome(t)=='text']
            giro=re.match(r'rotate\(([-.\d]+) ([-.\d]+) ([-.\d]+)\)', a.get('transform',''))
            if giro and float(face.get('width',0)) in (90,100):
                saida.append({'tipo':'carta','x':float(face['x']),'y':float(face['y']),
                  'w':float(face['width']),'h':float(face['height']),'giro':float(giro[1]),
                  'oculta':face['fill']=='#124437','valor':''.join(ts[0].itertext()) if ts else 'A',
                  'naipe':''.join(ts[1].itertext()) if len(ts)>1 else '♠',
                  'estilo': [dict(t.attrib, x=float(t.attrib['x'])-float(face['x']),
                       y=float(t.attrib['y'])-float(face['y'])) for t in ts]})
                i+=1
                continue
        if nome(e)=='rect' and i+1<len(itens) and nome(itens[i+1])=='text':
            t=itens[i+1]
            h=float(a.get('height',0))
            if h in (27,54) and t.attrib.get('text-anchor')=='middle':
                textos=[dict(t.attrib,texto=''.join(t.itertext()))]
                passo=2
                if h==54 and i+2<len(itens) and nome(itens[i+2])=='text':
                    t2=itens[i+2]
                    if t2.attrib.get('text-anchor')=='middle' and float(t2.attrib['y'])<float(a['y'])+54:
                        textos.append(dict(t2.attrib,texto=''.join(t2.itertext())))
                        passo=3
                saida.append({'tipo':'botao' if h==54 else 'chip','a':dict(a),'textos':textos})
                i+=passo
                continue
        saida.append(comando(e))
        i+=1
    return saida

telas=json.loads((PASTA/'telas.json').read_text(encoding='utf-8'))
for tela in telas:
    tela['cena']=cena(tela.pop('svg'))
cores=sorted(set(re.findall(r'#[0-9A-Fa-f]{6}', json.dumps(telas))))
(PASTA/'figma_cenas.json').write_text(json.dumps({'telas':telas,'cores':cores},ensure_ascii=False,separators=(',',':')),encoding='utf-8')
print(f'{len(telas)} cenas nativas, {len(cores)} cores; nenhum SVG/HTML alterado.')
