# Como executar o Clube 21

[← Voltar ao README](../README.md)

Este guia cobre os seis destinos do Flutter. No celular e no tablet, você também pode usar a versão web sem instalar ferramentas de desenvolvimento no aparelho.

## 1. Preparar o computador

1. Instale o [Git](https://git-scm.com/downloads).
2. Instale o [Flutter SDK 3.47.2](https://docs.flutter.dev/install) e adicione sua pasta `bin` ao `PATH`. Essa versão inclui o Dart 3.13.2 usado neste projeto. Para reproduzir os testes, utilize a mesma versão.
3. Feche e abra novamente o terminal.
4. Execute `flutter --version` e `flutter doctor -v`. Corrija os requisitos **da plataforma que deseja usar**. Para web, por exemplo, não é preciso configurar Xcode.
5. Baixe o projeto e suas dependências:

```sh
git clone https://github.com/bernardohorn/blackjack.git
cd blackjack
flutter pub get
flutter devices
```

Todos os comandos seguintes partem da pasta `blackjack`. O `flutter devices` lista os identificadores que podem substituir `ID_DO_DISPOSITIVO` nos exemplos. Esse texto é um marcador: use o ID mostrado no seu terminal.

## Web: computador, celular e tablet

### No próprio computador

1. Instale o Chrome.
2. Execute:

```sh
flutter run -d chrome
```

O Flutter abre o navegador. Também é possível usar `flutter run -d edge` no Windows, se o Edge aparecer em `flutter devices`. Para outro navegador, use o servidor da próxima seção e abra manualmente o endereço exibido.

### No celular ou tablet pelo Wi-Fi

1. Conecte o computador e o aparelho à mesma rede.
2. No computador, execute:

```sh
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8765
```

3. Descubra o IPv4 local do computador: `ipconfig` no Windows, `ipconfig getifaddr en0` no macOS (Wi-Fi) ou `hostname -I` no Linux. Se a interface de rede for diferente, consulte os ajustes de rede do sistema.
4. No navegador do celular, abra `http://IP_DO_COMPUTADOR:8765`. Por exemplo, `http://192.168.1.10:8765`.
5. Se solicitado pelo firewall, permita o servidor somente na rede privada que está usando.

**Não use `127.0.0.1` no celular para acessar o computador:** esse endereço aponta para o próprio aparelho. Redes de visitantes podem impedir a comunicação entre dispositivos. O terminal e o computador precisam continuar ligados.

Use Chrome/Edge/Firefox/Safari atuais compatíveis com Flutter Web. A disponibilidade de vibração, áudio e instalação na tela inicial depende do navegador; o jogo continua funcionando sem esses efeitos. A versão web usa a internet para as cartas e não oferece jogo offline completo.

### Gerar a versão para hospedagem

```sh
flutter build web --release
python -m http.server 8765 --directory build/web
```

O segundo comando é apenas uma forma de pré-visualizar o resultado e exige Python 3 (`py -m http.server ...` também funciona no Windows). Abra `http://localhost:8765`. Não abra `index.html` diretamente pelo explorador de arquivos.

Publique **todo o conteúdo** de `build/web/` em uma hospedagem estática com HTTPS. Se o endereço usar uma subpasta, gere com a base correta. Exemplo para `/blackjack/`:

```sh
flutter build web --release --base-href /blackjack/
```

## Android

Pode ser preparado em Windows, macOS ou Linux.

1. Instale o [Android Studio e os componentes indicados pelo Flutter](https://docs.flutter.dev/platform-integration/android/setup): SDK, Platform Tools, Command-line Tools e, se usar emulador, Android Emulator.
2. Execute `flutter doctor --android-licenses` e aceite as licenças que deseja utilizar.
3. Confira `flutter doctor -v`. O projeto usa o JDK fornecido pelo Android Studio; a compilação Java do app tem alvo 17.
4. Escolha uma forma de executar:
   - **Aparelho real:** habilite as opções de desenvolvedor e a depuração USB, conecte o cabo e aceite a autorização no aparelho. No Windows, instale o driver do fabricante se necessário.
   - **Emulador:** no Device Manager do Android Studio, crie e inicie um aparelho virtual.
5. Execute:

```sh
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

### Gerar e instalar um APK para demonstração

```sh
flutter build apk --debug
```

Arquivo gerado: `build/app/outputs/flutter-apk/app-debug.apk`.

Copie o APK para o Android e abra-o, autorizando a instalação pela origem usada. Com o aparelho conectado e o `adb` no PATH, também é possível instalar assim:

```sh
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Para uma compilação otimizada: `flutter build apk --release`. A configuração atual usa **assinatura de desenvolvimento**, inclusive no modo release. Para publicar em loja, configure seu identificador e uma chave de assinatura própria seguindo o [guia oficial](https://docs.flutter.dev/deployment/android). Não versione chaves, senhas ou `key.properties`.

## iPhone e iPad (iOS)

A compilação nativa exige **um Mac**. Em Windows ou Linux, use a versão web no Safari do aparelho.

1. Instale o Xcode compatível com o Flutter e conclua a configuração inicial, incluindo as plataformas iOS.
2. Configure as ferramentas de linha de comando, aceite a licença do Xcode e execute `flutter doctor -v`. Siga o [guia oficial de iOS](https://docs.flutter.dev/platform-integration/ios/setup) para a sua versão do Xcode e os gerenciadores de dependências exigidos pelos plugins.
3. Execute `flutter pub get`.
4. Abra um simulador de iPhone ou iPad pelo Xcode (ou Device Hub, conforme sua versão) e execute:

```sh
flutter devices
flutter run -d ID_DO_SIMULADOR
```

Para um aparelho real:

1. Conecte o iPhone/iPad, confie no computador e habilite o Modo de Desenvolvedor quando solicitado.
2. Abra `ios/Runner.xcworkspace` no Xcode.
3. Em **Runner → Signing & Capabilities**, escolha seu Team e um Bundle Identifier disponível para sua conta.
4. Selecione o aparelho e execute pelo Xcode ou com `flutter run -d ID_DO_DISPOSITIVO`.

Para verificar compilação de simulador, sem assinatura:

```sh
flutter build ios --simulator --debug
```

Para gerar um pacote destinado a distribuição, com assinatura e permissões da sua conta configuradas, use `flutter build ipa --release`. Publicação e TestFlight exigem a configuração correspondente no Apple Developer; o repositório não contém certificados.

## Windows

1. Use um computador Windows.
2. Instale uma versão atual do **Visual Studio** com a carga de trabalho **Desenvolvimento para desktop com C++**, MSVC, CMake e Windows SDK. O Visual Studio Code sozinho não fornece esse compilador. Consulte o [guia oficial](https://docs.flutter.dev/platform-integration/windows/setup).
3. Use Visual Studio 2022 ou posterior para este projeto. Na máquina da auditoria, o Visual Studio 2019 falhou ao compilar as corrotinas C++ do plugin de áudio.
4. Execute:

```sh
flutter doctor -v
flutter run -d windows
```

Para gerar o aplicativo:

```sh
flutter build windows --release
```

O executável fica em `build/windows/x64/runner/Release/` em uma compilação x64. Distribua **essa pasta inteira**, incluindo DLLs e `data/`; copiar somente o `.exe` não funciona. Use a arquitetura correspondente ao computador de destino e instale o runtime do Visual C++ quando necessário.

## macOS

1. Use um Mac, instale o Xcode e conclua sua configuração inicial.
2. Instale os componentes de plugins indicados por `flutter doctor -v`, conforme o [guia oficial](https://docs.flutter.dev/platform-integration/macos/setup).
3. Execute:

```sh
flutter pub get
flutter run -d macos
```

Para gerar o aplicativo:

```sh
flutter build macos --release
```

O pacote `.app` fica em `build/macos/Build/Products/Release/`. O projeto inclui a permissão de cliente de rede nos entitlements de debug e release para consultar a API. Distribuição pública fora do seu ambiente de desenvolvimento pode exigir assinatura e notarização da Apple.

## Linux

Use uma distribuição compatível com Flutter desktop. Em Ubuntu/Debian, instale as ferramentas de compilação, GTK e as bibliotecas de áudio:

```sh
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good
flutter doctor -v
flutter pub get
flutter run -d linux
```

Os nomes dos pacotes variam em outras distribuições. Consulte [Flutter para Linux](https://docs.flutter.dev/platform-integration/linux/setup) e os [requisitos do plugin de áudio](https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers_linux/README.md).

Para gerar o aplicativo:

```sh
flutter build linux --release
```

Distribua todo o diretório `build/linux/x64/release/bundle/` para um Linux compatível (o caminho varia por arquitetura). O computador de destino também precisa das bibliotecas GTK e GStreamer de execução.

## Testar antes de entregar

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

A automação em `.github/workflows/verificar.yml` executa essas verificações e compila as plataformas em seus respectivos sistemas. Testes de regras e interface usam um servidor simulado: não precisam de internet nem consomem cartas reais.

Para regenerar as 19 capturas da documentação, defina `FLUTTER_ROOT` como a pasta onde instalou o SDK:

```powershell
# Windows / PowerShell: ajuste o caminho da sua instalação.
$env:FLUTTER_ROOT = 'C:\flutter'
flutter test test/wireframe_test.dart --dart-define=EXPORTAR_TELAS=true
```

```sh
# macOS / Linux: ajuste o caminho da sua instalação.
export FLUTTER_ROOT="$HOME/development/flutter"
flutter test test/wireframe_test.dart --dart-define=EXPORTAR_TELAS=true
```

## Problemas comuns

| Sintoma | O que fazer |
| --- | --- |
| `flutter` não é reconhecido | Corrija o PATH para a pasta `flutter/bin` e reabra o terminal. |
| Nenhum dispositivo encontrado | Abra o emulador ou conecte/autorize o aparelho; confira `flutter devices` e `flutter doctor -v`. |
| Falha de SDK, JDK, Xcode ou compilador | Corrija o item da plataforma no `flutter doctor -v`; use os requisitos das seções acima. |
| O telefone não abre o servidor web | Confira IPv4 do computador, mesma rede, firewall e isolamento da rede de visitantes. |
| “Não foi possível conectar” | Confira a conexão e a disponibilidade da API; toque em “Tentar novamente”. |
| “Rodada interrompida” | A compra pode ter ocorrido no servidor. Reinicie a mesa; repetir a compra antiga poderia consumir cartas extras. |
| “Não foi possível salvar” | Confira espaço e permissão de armazenamento. Na web, evite modos que bloqueiem armazenamento local. |
| A partida não aparece em outro dispositivo | A partida é salva apenas naquele dispositivo e, na web, naquele navegador e endereço. Não existe sincronização por conta. |
| Som ou vibração não funcionam | Confira as preferências, volume e suporte do navegador/aparelho. Esses efeitos são opcionais. |
| A mesa salva expirou | A API remove baralhos inativos; o app descarta sessões com 14 dias sem compra e permite iniciar uma nova. |

Recarregar a página preserva uma partida já salva. Limpar os dados do navegador/aplicativo a remove. Fechar durante uma operação remota exige iniciar uma nova mesa para evitar restaurar cartas desatualizadas.
