<div align="center">

# ♠ Clube 21

**Blackjack em português. Sem apostas. Uma boa jogada de cada vez.**

[![Verificação](https://github.com/bernardohorn/blackjack/actions/workflows/verificar.yml/badge.svg)](https://github.com/bernardohorn/blackjack/actions/workflows/verificar.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart)

[Executar o app](docs/EXECUTAR.md) · [Ver as 19 telas](docs/TELAS.md) · [Conformidade](docs/CONFORMIDADE.md) · [Entender o código](docs/CODIGO.md)

<img src="docs/imagens/02-menu.png" width="240" alt="Menu do Clube 21">
<img src="docs/imagens/07-sua-vez.png" width="240" alt="Mesa de Blackjack, turno do jogador">
<img src="docs/imagens/04-configuracoes.png" width="240" alt="Configurações da próxima mesa e preferências">

</div>

## O projeto

Aplicativo Flutter de Blackjack, baseado no [wireframe de 19 estados](docs/referencias/wireframe.pdf) e na [documentação da API](docs/referencias/api-flutter.pdf). O jogador enfrenta a banca usando cartas reais da **Deck of Cards API**. As regras, os pontos e a partida salva são controlados pelo aplicativo.

- Pedir carta, parar, jogar outra rodada e continuar uma partida salva.
- Ás flexível, Blackjack natural, vitória, derrota, empate e estouro.
- De 1 a 6 baralhos; banca para no 17 suave por padrão, com opção de comprar.
- Tema claro ou escuro, som e vibração conforme o suporte do dispositivo.
- Tratamento de falhas de rede e armazenamento, sem repetir compras incertas.
- Interface e nomes do domínio em português, com **cinco arquivos Dart divididos por blocos e comentados linha a linha** para facilitar a apresentação.

## Entrega final

- **[Baixar c21original.apk](https://github.com/bernardohorn/blackjack/raw/refs/heads/main/c21original.apk)**: versão Android 0.1.0+1, release universal, com cerca de 48 MiB. Requer Android 7.0 ou superior e internet para jogar.
- **[Documentação final em PDF](documentacao_final_clube21.pdf)**: integração com a API, regras, arquitetura, 19 telas, testes e instalação nas seis plataformas, atualizados a partir do documento original.

Para instalar, copie o APK para o Android, abra o arquivo e autorize a instalação pela origem utilizada. O pacote usa **assinatura de desenvolvimento** para demonstração; a instalação em aparelho físico ainda precisa ser conferida. O PDF inclui o SHA-256 do arquivo e os comandos para verificar sua integridade.

## Começar em poucos minutos

Instale o [Flutter 3.47.2](https://docs.flutter.dev/install), o Git e o Chrome. O Dart já vem com o Flutter. Depois, no terminal:

```sh
git clone https://github.com/bernardohorn/blackjack.git
cd blackjack
flutter doctor -v
flutter pub get
flutter run -d chrome
```

Abra **Novo jogo** e mantenha a conexão com a internet para criar o baralho e comprar cartas. Não é preciso conta, chave de API, banco de dados nem arquivo `.env`.

### Escolha seu dispositivo

| Destino | Onde preparar e compilar | Guia |
| --- | --- | --- |
| Navegador em computador, celular ou tablet | Windows, macOS ou Linux | [Web e acesso pelo Wi-Fi](docs/EXECUTAR.md#web-computador-celular-e-tablet) |
| Android: celular, tablet ou emulador | Windows, macOS ou Linux | [Android e APK](docs/EXECUTAR.md#android) |
| iPhone e iPad | macOS com Xcode | [iOS](docs/EXECUTAR.md#iphone-e-ipad-ios) |
| Aplicativo Windows | Windows com Visual Studio e C++ | [Windows](docs/EXECUTAR.md#windows) |
| Aplicativo macOS | macOS com Xcode | [macOS](docs/EXECUTAR.md#macos) |
| Aplicativo Linux | Linux com ferramentas de compilação e GStreamer | [Linux](docs/EXECUTAR.md#linux) |

Os seis projetos de plataforma estão incluídos. O [relatório de conformidade](docs/CONFORMIDADE.md#validação-e-limites) distingue testes executados, compilação e validação em aparelhos reais. Compilar uma plataforma exige o ambiente indicado acima.

## Organização

```text
c21original.apk                 APK Android final para instalação direta
documentacao_final_clube21.pdf  Documentação consolidada da entrega
lib/                            Código do aplicativo: telas, jogo, regras e API
test/                           Testes de regras, HTTP, persistência e interface
assets/                         Fontes com suas licenças e som local
docs/                           Guias, auditoria, capturas e PDFs de referência
android/ ios/                   Projetos de integração para celulares e tablets
web/                            Página inicial e ícone do navegador
windows/ macos/ linux/ Projetos de integração para computadores
.github/workflows/              Verificação automática no GitHub
```

Os protótipos antigos continuam no histórico Git. Os dois PDFs de referência ficam em `docs/referencias/`; arquivos temporários, caches e builds intermediários ficam fora do versionamento. O APK final da raiz é incluído intencionalmente para facilitar a entrega. O `pubspec.lock` registra as versões das dependências usadas pelo aplicativo.

## Qualidade

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

A [verificação no GitHub](https://github.com/bernardohorn/blackjack/actions) executa análise, testes e compilações. Os pacotes web e Android de demonstração ficam nos artefatos da execução quando o respectivo job termina com sucesso. Os testes não consomem a API pública.

## Documentação e créditos

| Documento | O que você encontra |
| --- | --- |
| [Documentação final](documentacao_final_clube21.pdf) | Documento consolidado com contrato, telas, implementação e dados do APK |
| [Como executar](docs/EXECUTAR.md) | Instalação, comandos, distribuição e problemas comuns em cada plataforma |
| [Guia do código](docs/CODIGO.md) | Leitura dos blocos comentados, dicionário para iniciantes e o que cada parte faz |
| [Conformidade](docs/CONFORMIDADE.md) | Os 19 estados, endpoints, regras e diferenças justificadas |
| [Galeria](docs/TELAS.md) | Capturas reproduzíveis da própria interface Flutter |
| [Wireframe original](docs/referencias/wireframe.pdf) | Referência visual e comportamento por tela |
| [Documentação técnica original](docs/referencias/api-flutter.pdf) | Contrato e exemplos de integração |

Cartas: [Deck of Cards API](https://deckofcardsapi.com/). Fontes: [Gelasio](https://github.com/google/fonts/tree/main/ofl/gelasio) e [Noto Sans Symbols 2](https://github.com/google/fonts/tree/main/ofl/notosanssymbols2), com licenças OFL em `assets/fontes/`. O som de carta é um recurso local do projeto.
