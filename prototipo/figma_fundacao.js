// Fundações e invólucros. As cenas são montadas em chamadas seguintes.
// O helper segue a receita createVariableCollection da skill figma-generate-library.
async function criarColecao(nome, modos) {
  const colecao=figma.variables.createVariableCollection(nome);
  colecao.renameMode(colecao.modes[0].modeId,modos[0]);
  return colecao;
}
const criados=[];
const pagina=await figma.getNodeByIdAsync('0:1');
await figma.setCurrentPageAsync(pagina);
pagina.name='Clube 21 · telas e funcionamento';
const fontes=[...['Regular','Medium','SemiBold','Bold'].flatMap(style=>[{family:'DM Sans',style},{family:'Lora',style}]),{family:'Roboto Mono',style:'Regular'},{family:'Noto Sans Symbols',style:'Regular'}];
await Promise.all(fontes.map(f=>figma.loadFontAsync(f)));
const rgb=c=>({r:parseInt(c.slice(1,3),16)/255,g:parseInt(c.slice(3,5),16)/255,b:parseInt(c.slice(5,7),16)/255});
const pintura=c=>({type:'SOLID',color:rgb(c)});
pagina.backgrounds=[pintura('#E9ECDD')];
const primitivas=await criarColecao('Clube 21 · valores',['Padrão']);
const semanticas=await criarColecao('Clube 21 · cores',['Padrão']);
const medidas=await criarColecao('Clube 21 · medidas',['Padrão']);
const vars={};
const nomes={'#092F27':'verde/mesa','#164439':'verde/painel','#E8C778':'ouro/destaque','#F7F1E4':'marfim/carta','#B6CDC2':'texto/apoio','#FFB5A9':'resultado/derrota','#AB3A40':'naipe/vermelho','#233B32':'naipe/preto'};
for(const hex of DADOS.cores){
  const p=figma.variables.createVariable('paleta/'+hex.slice(1),primitivas,'COLOR');
  p.scopes=[];p.setValueForMode(primitivas.defaultModeId,rgb(hex));p.setVariableCodeSyntax('WEB','var(--paleta-'+hex.slice(1).toLowerCase()+')');
  const v=figma.variables.createVariable(nomes[hex]||'paleta/'+hex.slice(1),semanticas,'COLOR');
  v.scopes=['FRAME_FILL','SHAPE_FILL','TEXT_FILL','STROKE_COLOR'];v.setValueForMode(semanticas.defaultModeId,figma.variables.createVariableAlias(p));
  v.setVariableCodeSyntax('WEB','var(--clube21-'+(nomes[hex]||hex.slice(1)).replace(/\//g,'-').toLowerCase()+')');vars[hex]=v.id;
}
const medidasIds={};
for(const [nome,valor,escopo] of [['espaco/4',4,'GAP'],['espaco/8',8,'GAP'],['espaco/12',12,'GAP'],['espaco/16',16,'GAP'],['espaco/24',24,'GAP'],['raio/carta',12,'CORNER_RADIUS'],['raio/botao',17,'CORNER_RADIUS'],['raio/chip',13.5,'CORNER_RADIUS']]){
  const v=figma.variables.createVariable(nome,medidas,'FLOAT');v.scopes=[escopo];v.setValueForMode(medidas.defaultModeId,valor);v.setVariableCodeSyntax('WEB','var(--clube21-'+nome.replace(/\//g,'-')+')');medidasIds[nome]=v.id;
}
const estilos={};
const modelos=[['DM Sans','Regular',11],['DM Sans','Regular',12],['DM Sans','Regular',13],['DM Sans','Regular',14],['DM Sans','SemiBold',11],['DM Sans','SemiBold',14],['DM Sans','SemiBold',16],['DM Sans','Bold',20],['Lora','Medium',22],['Lora','Medium',24],['Lora','Medium',36],['Lora','Medium',49],['Roboto Mono','Regular',11]];
for(const [family,style,size] of modelos){const s=figma.createTextStyle();s.name='Clube 21/'+family+'/'+style+'/'+size;s.fontName={family,style};s.fontSize=size;s.lineHeight={unit:'PIXELS',value:size*1.25};s.letterSpacing={unit:'PIXELS',value:0};estilos[family+'|'+style+'|'+size]=s.id;}
const secoes={},telas={};
for(let i=0;i<DADOS.telas.length;i++){
  const t=DADOS.telas[i];const secao=figma.createSection();secao.name=t.chave+' · '+t.nome;secao.fills=[pintura('#F7F6EC')];secao.resizeWithoutConstraints(908,1400);secao.x=120+(i%4)*980;secao.y=320+Math.floor(i/4)*1480;secoes[t.chave]=secao.id;criados.push(secao.id);
  const tela=figma.createFrame();secao.appendChild(tela);tela.name=t.chave+' / '+t.nome;tela.resize(390,844);tela.x=24;tela.y=72;tela.fills=[];tela.cornerRadius=28;tela.clipsContent=true;tela.placeholder=true;telas[t.chave]=tela.id;criados.push(tela.id);
}
const biblioteca=figma.createSection();biblioteca.name='Componentes · cartas, botões, chips e tokens';biblioteca.x=4120;biblioteca.y=320;biblioteca.resizeWithoutConstraints(1300,1500);biblioteca.fills=[pintura('#E1E7D6')];criados.push(biblioteca.id);
const resumo=figma.createAutoLayout('VERTICAL');pagina.appendChild(resumo);resumo.name='Clube 21 · apresentação do wireframe';resumo.resize(3800,160);resumo.x=120;resumo.y=80;resumo.fills=[];resumo.itemSpacing=14;resumo.primaryAxisSizingMode='AUTO';resumo.counterAxisSizingMode='FIXED';criados.push(resumo.id);
function txt(valor,family,style,size,cor){const t=figma.createText();t.fontName={family,style};t.fontSize=size;t.characters=valor;t.fills=[pintura(cor)];resumo.appendChild(t);criados.push(t.id);return t;}
txt('Blackjack · Clube 21','Lora','Medium',42,'#233B32');
txt('19 telas de alta fidelidade · 390 × 844 · textos, cartas e controles editáveis','DM Sans','SemiBold',17,'#233B32');
txt('Verde de feltro, dourado e marfim. Fluxo principal: abertura → menu → distribuição → Hit / Stand → resultado. Ao lado de cada tela: gatilhos, endpoints, dados e regras locais.','DM Sans','Regular',15,'#476553');
return {success:true,createdNodeIds:criados,mutatedNodeIds:[pagina.id],paginaId:pagina.id,secoes,telas,bibliotecaId:biblioteca.id,vars,medidasIds,estilos,colecoes:[primitivas.id,semanticas.id,medidas.id],fontes,variables:76,screenCount:19};
