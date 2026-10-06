const criados=new Set(),mudados=new Set();
const pagina=await figma.getNodeByIdAsync(ESTADO.paginaId);
await figma.setCurrentPageAsync(pagina);
await Promise.all(ESTADO.fontes.map(f=>figma.loadFontAsync(f)));
const biblioteca=await figma.getNodeByIdAsync(ESTADO.bibliotecaId);
const variaveis=await Promise.all(Object.values(ESTADO.vars).map(id=>figma.variables.getVariableByIdAsync(id)));
const cores={};Object.keys(ESTADO.vars).forEach((k,i)=>cores[k]=variaveis[i]);
const medidas=await Promise.all(Object.values(ESTADO.medidasIds).map(id=>figma.variables.getVariableByIdAsync(id)));
const espacos={};Object.keys(ESTADO.medidasIds).forEach((k,i)=>espacos[k]=medidas[i]);
const componentes={...ESTADO.componentes};
const componentesNos={};
if(Object.keys(componentes).length){const cc=await Promise.all(Object.values(componentes).map(v=>figma.getNodeByIdAsync(v.id)));Object.keys(componentes).forEach((k,i)=>componentesNos[k]=cc[i]);}
const rgb=c=>({r:parseInt(c.slice(1,3),16)/255,g:parseInt(c.slice(3,5),16)/255,b:parseInt(c.slice(5,7),16)/255});
function cor(c,opacidade=1){if(!c||c==='none')return [];const p={type:'SOLID',color:rgb(c),opacity:opacidade};return [cores[c]?figma.variables.setBoundVariableForPaint(p,'color',cores[c]):p];}
function guardar(n,profundo=false){criados.add(n.id);if(profundo&&'findAll' in n)for(const c of n.findAll(()=>true))criados.add(c.id);return n;}
const I=[[1,0,0],[0,1,0]];
function mult(a,b){return [[a[0][0]*b[0][0]+a[0][1]*b[1][0],a[0][0]*b[0][1]+a[0][1]*b[1][1],a[0][0]*b[0][2]+a[0][1]*b[1][2]+a[0][2]],[a[1][0]*b[0][0]+a[1][1]*b[1][0],a[1][0]*b[0][1]+a[1][1]*b[1][1],a[1][0]*b[0][2]+a[1][1]*b[1][2]+a[1][2]]];}
function mover(x,y){return [[1,0,x],[0,1,y]];}
function giro(ang,cx,cy){const r=ang*Math.PI/180,c=Math.cos(r),s=Math.sin(r);return [[c,-s,cx-c*cx+s*cy],[s,c,cy-s*cx-c*cy]];}
function tipografia(a){const family=(a['font-family']||'').includes('Georgia')||(a['font-family']||'').includes('Lora')?'Lora':'DM Sans';const peso=Number(a['font-weight']||400);return {family,style:peso>=700?'Bold':peso>=600?'SemiBold':peso>=500?'Medium':'Regular'};}
function texto(p,a,valor,M=I){
 const n=guardar(figma.createText());const font=tipografia(a),size=Number(a['font-size']||14);n.name=valor.slice(0,65);n.fontName=font;n.fontSize=size;n.lineHeight={unit:'PIXELS',value:size*1.25};n.characters=valor;n.fills=cor(a.fill||'#F7F1E4');
 const estilo=ESTADO.estilos[font.family+'|'+font.style+'|'+size];if(estilo)n.textStyleId=estilo;
 if(a['letter-spacing'])n.letterSpacing={unit:'PIXELS',value:Number(a['letter-spacing'])};
 p.appendChild(n);let x=Number(a.x||0);const ancora=a['text-anchor'];if(ancora==='middle')x-=n.width/2;if(ancora==='end')x-=n.width;n.relativeTransform=mult(M,mover(x,Number(a.y||0)-size));return n;
}
function ouro(){return [{type:'GRADIENT_LINEAR',gradientTransform:[[0.8,0.6,0],[-0.6,0.8,0.3]],gradientStops:[{position:0,color:{...rgb('#F1D991'),a:1}},{position:1,color:{...rgb('#D7B25F'),a:1}}]}];}
function feltro(){return [{type:'GRADIENT_RADIAL',gradientTransform:[[0.625,0,0.1875],[0,0.625,0.2375]],gradientStops:[{position:0,color:{...rgb('#155640'),a:1}},{position:1,color:{...rgb('#062A22'),a:1}}]}];}
function retangulo(p,a,M=I){if(a.fill==='url(#trama)')return null;const n=guardar(figma.createRectangle());n.name=a.fill==='url(#feltro)'?'Feltro · gradiente vetorial':'Retângulo';n.resize(Number(a.width),Number(a.height));n.cornerRadius=Number(a.rx||0);n.fills=a.fill==='url(#feltro)'?feltro():a.fill==='url(#ouro)'?ouro():a.fill?.startsWith('url(')?[]:cor(a.fill||'#000000',Number(a['fill-opacity']||1));if(a.stroke)n.strokes=cor(a.stroke);if(a['stroke-width'])n.strokeWeight=Number(a['stroke-width']);p.appendChild(n);n.relativeTransform=mult(M,mover(Number(a.x||0),Number(a.y||0)));if(a.opacity)n.opacity=Number(a.opacity);return n;}
function vetor(p,a,M=I,w=390,h=844){const attrs=Object.entries(a).map(([k,v])=>k+'="'+String(v).replace(/"/g,'&quot;')+'"').join(' ');const s='<svg xmlns="http://www.w3.org/2000/svg" width="'+w+'" height="'+h+'" viewBox="0 0 '+w+' '+h+'"><path '+attrs+'/></svg>';const n=guardar(figma.createNodeFromSvg(s),true);n.name='Detalhe vetorial';p.appendChild(n);n.relativeTransform=M;return n;}
function componenteBase(chave,nome,w,h){const c=guardar(figma.createComponent());biblioteca.appendChild(c);c.name=nome;c.description='Elemento reutilizável do wireframe Clube 21. Textos expostos como propriedades editáveis.';c.resize(w,h);c.fills=[];const idx=Object.keys(componentes).length;c.x=24+(idx%3)*400;c.y=84+Math.floor(idx/3)*200;componentesNos[chave]=c;componentes[chave]={id:c.id};return c;}
function carta(p,d){const vermelha=['♥','♦'].includes(d.naipe),tipo=d.oculta?'verso':vermelha?'vermelha':'preta';const chave='carta|'+d.w+'|'+d.h+'|'+tipo;let c=componentesNos[chave];
 if(!c){c=componenteBase(chave,'Carta / '+d.w+' / '+tipo,d.w,d.h+4);retangulo(c,{x:0,y:4,width:d.w,height:d.h,rx:12,fill:'#031F19'});retangulo(c,{x:0,y:0,width:d.w,height:d.h,rx:12,fill:d.oculta?'#124437':'#F7F1E4',stroke:d.oculta?'#B4975D':'#DFD8C9'});
  if(d.oculta){retangulo(c,{x:7,y:7,width:d.w-14,height:d.h-14,rx:7,fill:'none',stroke:'#BD9F61'});const linhas=[];for(let y=10;y<d.h-10;y+=12)for(let x=10;x<d.w-10;x+=12)linhas.push('M'+x+' '+(y-5)+'l5 5 -5 5 -5 -5Z');vetor(c,{d:linhas.join(' '),fill:'none',stroke:'#BFA362','stroke-opacity':'.27','stroke-width':'.65'},I,d.w,d.h);vetor(c,{d:'M'+d.w/2+' '+(d.h/2-24)+'l19 24 -19 24 -19 -24Z',fill:'#164A3C',stroke:'#D7B76F'},I,d.w,d.h);texto(c,{x:d.w/2,y:d.h/2+7,'font-family':'Lora','font-size':26,'text-anchor':'middle',fill:'#E8C778'},'♠');}
  else{const tinta=vermelha?'#AB3A40':'#233B32';const rank=c.addComponentProperty('Valor','TEXT','A'),suit=c.addComponentProperty('Naipe','TEXT',vermelha?'♥':'♠');componentes[chave].rank=rank;componentes[chave].suit=suit;
   for(const mat of [I,giro(180,d.w/2,d.h/2)]){const n=texto(c,{...d.estilo[0],fill:tinta},'A',mat);n.componentPropertyReferences={characters:rank};const s=texto(c,{...d.estilo[1],fill:tinta},'♠',mat);s.componentPropertyReferences={characters:suit};}
   const central=texto(c,{...d.estilo[2],fill:tinta},'♠');central.componentPropertyReferences={characters:suit};
  }
 }
 const n=guardar(c.createInstance(),true);n.name=d.oculta?'Carta fechada da banca':d.valor+' '+d.naipe;p.appendChild(n);if(!d.oculta)n.setProperties({[componentes[chave].rank]:d.valor,[componentes[chave].suit]:d.naipe});n.relativeTransform=mult(giro(d.giro,d.x+d.w/2,d.y+d.h/2),mover(d.x,d.y));return n;
}
function controle(p,d){const a=d.a;const txts=d.textos;const chave=d.tipo+'|'+a.fill+'|'+(a.stroke||'')+'|'+txts.length+'|'+txts[0].fill;let c=componentesNos[chave];
 if(!c){c=componenteBase(chave,(d.tipo==='botao'?'Botão':'Chip')+' / '+(a.fill==='url(#ouro)'?'principal':a.fill==='#21473D'?'desabilitado':'contorno')+' / '+txts.length+' linhas',Number(a.width),Number(a.height));c.layoutMode='VERTICAL';c.primaryAxisAlignItems='CENTER';c.counterAxisAlignItems='CENTER';c.primaryAxisSizingMode='FIXED';c.counterAxisSizingMode='FIXED';c.itemSpacing=txts.length>1?2:0;c.fills=a.fill==='url(#ouro)'?ouro():cor(a.fill);if(a.stroke)c.strokes=cor(a.stroke);c.cornerRadius=Number(a.rx||0);c.setBoundVariable('topLeftRadius',espacos[d.tipo==='botao'?'raio/botao':'raio/chip']);c.setBoundVariable('topRightRadius',espacos[d.tipo==='botao'?'raio/botao':'raio/chip']);c.setBoundVariable('bottomLeftRadius',espacos[d.tipo==='botao'?'raio/botao':'raio/chip']);c.setBoundVariable('bottomRightRadius',espacos[d.tipo==='botao'?'raio/botao':'raio/chip']);
  componentes[chave].props=[];for(let i=0;i<txts.length;i++){const t=texto(c,{...txts[i],x:0,y:0,'text-anchor':'start'},i?'Apoio':'Rótulo');const prop=c.addComponentProperty(i?'Apoio':'Rótulo','TEXT',i?'Apoio':'Rótulo');t.componentPropertyReferences={characters:prop};componentes[chave].props.push(prop);t.layoutSizingHorizontal='HUG';t.layoutSizingVertical='HUG';}
 }
 const n=guardar(c.createInstance(),true);p.appendChild(n);n.name=txts[0].texto;n.resize(Number(a.width),Number(a.height));n.x=Number(a.x);n.y=Number(a.y);const props={};txts.forEach((t,i)=>props[componentes[chave].props[i]]=t.texto);n.setProperties(props);return n;
}
function desenhar(p,d,M=I){
 if(d.tipo==='carta')return carta(p,d);if(d.tipo==='botao'||d.tipo==='chip')return controle(p,d);const a=d.a||{};
 if(d.tipo==='text')return texto(p,a,d.texto,M);if(d.tipo==='rect')return retangulo(p,a,M);if(d.tipo==='path')return vetor(p,a,M);
 if(d.tipo==='circle'){const n=guardar(figma.createEllipse());n.resize(Number(a.r)*2,Number(a.r)*2);n.fills=cor(a.fill);if(a.stroke)n.strokes=cor(a.stroke);p.appendChild(n);n.relativeTransform=mult(M,mover(Number(a.cx)-Number(a.r),Number(a.cy)-Number(a.r)));return n;}
 if(d.tipo==='g'){const r=/rotate\(([-.\d]+) ([-.\d]+) ([-.\d]+)\)/.exec(a.transform||'');const T=r?mult(M,giro(Number(r[1]),Number(r[2]),Number(r[3]))):M;for(const ch of d.filhos)desenhar(p,ch,T);}
}
function textoNota(p,valor,tam=13,forte=false,mono=false,tinta='#304E3D'){
 const n=guardar(figma.createText());n.name=valor.slice(0,60);n.fontName={family:mono?'Roboto Mono':'DM Sans',style:forte?'SemiBold':'Regular'};n.fontSize=tam;n.lineHeight={unit:'PIXELS',value:mono?tam*1.5:tam*1.45};n.fills=cor(tinta);n.textAutoResize='HEIGHT';n.resize(364,24);n.characters=valor;p.appendChild(n);n.layoutSizingHorizontal='FIXED';return n;
}
const anotacoes={},contagens=[];
for(const meta of DADOS.telas){
 const [secao,tela]=await Promise.all([figma.getNodeByIdAsync(ESTADO.secoes[meta.chave]),figma.getNodeByIdAsync(ESTADO.telas[meta.chave])]);
 if(tela.children.length)throw new Error('Tela já preenchida: '+meta.chave);
 for(const d of meta.cena)desenhar(tela,d);
 tela.placeholder=false;mudados.add(tela.id);mudados.add(secao.id);
 const titulo=guardar(figma.createText());titulo.fontName={family:'DM Sans',style:'SemiBold'};titulo.fontSize=19;titulo.characters=meta.chave.slice(0,2)+' · '+meta.nome;titulo.fills=cor('#233B32');secao.appendChild(titulo);titulo.x=24;titulo.y=24;
 const nota=guardar(figma.createAutoLayout('VERTICAL'));secao.appendChild(nota);nota.name='Funcionamento / '+meta.nome;nota.resize(400,900);nota.x=454;nota.y=72;nota.fills=[];nota.itemSpacing=10;nota.paddingLeft=0;nota.paddingRight=0;nota.paddingTop=0;nota.paddingBottom=0;nota.primaryAxisSizingMode='AUTO';nota.counterAxisSizingMode='FIXED';anotacoes[meta.chave]=nota.id;
 textoNota(nota,'API + FLUTTER',11,true,false,'#7B7745');textoNota(nota,meta.ao_abrir,15,true);textoNota(nota,'Base: https://deckofcardsapi.com',11,false,true);
 if(!meta.chamadas.length)textoNota(nota,'Endpoint desta tela: nenhum.',13,true);
 for(const chamada of meta.chamadas){const bloco=guardar(figma.createAutoLayout('VERTICAL'));nota.appendChild(bloco);bloco.name=chamada.gatilho;bloco.resize(400,160);bloco.fills=cor('#E9ECDD');bloco.cornerRadius=12;bloco.paddingLeft=18;bloco.paddingRight=18;bloco.paddingTop=14;bloco.paddingBottom=14;bloco.itemSpacing=7;bloco.primaryAxisSizingMode='AUTO';bloco.counterAxisSizingMode='FIXED';textoNota(bloco,'Gatilho · '+chamada.gatilho,13,true);textoNota(bloco,chamada.metodo+' '+chamada.caminho,11,false,true);textoNota(bloco,chamada.explicacao);if(chamada.dados)textoNota(bloco,'Dados · '+chamada.dados,12);}
 textoNota(nota,'No Flutter · regras e estado local',14,true);for(const frase of meta.local)textoNota(nota,'• '+frase,12);if(meta.nota)textoNota(nota,'Observação · '+meta.nota,12);if(meta.exemplo)textoNota(nota,'Exemplo · '+meta.exemplo,12);
 if(meta.chave==='04-configuracoes')textoNota(nota,'Figma mostra os valores de referência. A alteração de preferências pode ser experimentada no protótipo HTML.',11,false,false,'#5B705B');
 secao.resizeWithoutConstraints(908,Math.max(964,nota.y+nota.height+36));
 const ns=tela.findAll(()=>true);const tipos={};for(const n of ns)tipos[n.type]=(tipos[n.type]||0)+1;contagens.push({chave:meta.chave,id:tela.id,width:tela.width,height:tela.height,descendentes:ns.length,tipos});
}
biblioteca.resizeWithoutConstraints(1300,Math.max(1500,84+Math.ceil(Object.keys(componentes).length/3)*200));mudados.add(biblioteca.id);
return {success:true,createdNodeIds:[...criados],mutatedNodeIds:[...mudados],componentes,anotacoes,contagens,screenCount:DADOS.telas.length};
