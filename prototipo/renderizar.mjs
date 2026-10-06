// Converte os vetores em PNGs de alta resolução, sem depender de conexão.
import { createRequire } from 'node:module';
import { readFile, readdir } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';
const require = createRequire(import.meta.url);
const sharp = require('C:/Users/Bernardo/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp');
const pasta = dirname(fileURLToPath(import.meta.url));
const arquivos = (await readdir(join(pasta, 'telas'))).filter(nome => nome.endsWith('.svg'));
await Promise.all(arquivos.map(async nome => {
  await sharp(await readFile(join(pasta, 'telas', nome)), { density: 144 }).png().toFile(join(pasta, 'telas', nome.replace('.svg','.png')));
}));
const html = await readFile(join(pasta, 'index.html'),'utf8');
const codigo = html.match(/<script>\s*([\s\S]*?)<\/script>/)[1];
new vm.Script(codigo);
console.log(arquivos.length + ' PNGs gerados; sintaxe JavaScript validada.');
