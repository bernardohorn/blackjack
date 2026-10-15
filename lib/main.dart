// Ponto de entrada: conecta o armazenamento, a API e a interface.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'api.dart';
import 'jogo.dart';
import 'telas.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Clube21(jogo: Jogo(ApiBaralho(http.Client()), MemoriaLocal())));
}

class Clube21 extends StatefulWidget {
  const Clube21({super.key, required this.jogo});
  final Jogo jogo;
  @override
  State<Clube21> createState() => _Clube21State();
}

class _Clube21State extends State<Clube21> {
  @override
  void initState() {
    super.initState();
    widget.jogo.carregar();
  }

  @override
  void dispose() {
    widget.jogo.dispose();
    super.dispose();
  }

  // Reconstrói o tema imediatamente quando a preferência claro/escuro muda.
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.jogo,
    builder: (context, _) {
      final escuro = widget.jogo.preferencias.escuro;
      final cores = ColorScheme.fromSeed(
        seedColor: const Color(0xFFD8B65D),
        brightness: escuro ? Brightness.dark : Brightness.light,
        primary: escuro ? const Color(0xFFE8C778) : const Color(0xFF765819),
        surface: escuro ? const Color(0xFF103F33) : const Color(0xFFF6F3E8),
      );
      return MaterialApp(
        title: 'Clube 21',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Naipes'],
          colorScheme: cores,
          scaffoldBackgroundColor: cores.surface,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8C778),
              foregroundColor: const Color(0xFF123C30),
              minimumSize: const Size(double.infinity, 54),
              textStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              foregroundColor: cores.onSurface,
              side: BorderSide(color: cores.primary.withValues(alpha: .55)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
        home: Telas(jogo: widget.jogo),
      );
    },
  );
}
