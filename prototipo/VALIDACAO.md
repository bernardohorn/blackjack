# Verificação do protótipo

Conferido em 05/10/2026.

Foram revisadas as 19 telas no navegador. Nenhum texto ultrapassou os
limites do SVG e não houve erro ou aviso no console. A apresentação foi
verificada em larguras de desktop e celular, sem transbordamento da página.

Os percursos de distribuição, Hit com Ás flexível, Stand aos 16, empate
aos 17, próxima rodada no mesmo shoe, pausa/retomada, configuração e
seleção do tema claro foram exercitados. Cartas da banca ficam ocultas
até a fase correta. Os dados da demonstração são simulados.

O PDF tem 23 páginas e todas as 19 telas. As duas anotações mais extensas
continuam em outra página para preservar a leitura. A validação conferiu
os títulos, endpoints, explicações, dados e condições de telas.json,
fontes incorporadas e limites de 148 blocos de texto. Capa, fluxo,
vez da banca e anotações extensas foram renderizados e inspecionados.

A integração HTTP real e a persistência após fechar o aplicativo deverão
ser verificadas na etapa de implementação Flutter. Esta validação cobre
o design e a navegação do protótipo.

O arquivo do Figma foi conferido com 19 telas de 390 × 844, 19 anotações,
38 conexões de navegação e 751 textos nativos. Os naipes utilizam vetores
clássicos editáveis. A interface não foi importada como imagem achatada.
A captura final da mesa anotada está em `figma_preview.png`.
