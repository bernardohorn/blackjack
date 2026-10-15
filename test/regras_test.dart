// Exemplos do wireframe e casos de borda das regras locais.
import 'package:flutter_test/flutter_test.dart';
import 'package:clube_21/regras.dart';

List<Carta> mao(String codigos) =>
    codigos.split(' ').map((codigo) => Carta(codigo)).toList();

void main() {
  test('ases flexíveis e estouro', () {
    expect(pontuar(mao('AS 9H AD')), (pontos: 21, suave: true));
    expect(pontuar(mao('9H 7C AS')), (pontos: 17, suave: false));
    expect(pontuar(mao('AS AH AD AC 9H')), (pontos: 13, suave: false));
    expect(pontuar(mao('KS QH 2D')).pontos, 22);
  });
  test('natural exige duas cartas e supera 21 comum', () {
    expect(natural(mao('AS KH')), isTrue);
    expect(natural(mao('AS 0H')), isTrue);
    expect(natural(mao('7S 7H 7D')), isFalse);
    expect(resultado(mao('AS KH'), mao('7S 7H 7D')).titulo, 'Blackjack!');
    expect(
      resultado(mao('7S 7H 7D'), mao('AS KH')).titulo,
      'Blackjack da banca',
    );
    expect(resultado(mao('AS KH'), mao('AD QC')).titulo, 'Empate');
  });
  test('banca respeita soft 17 e sempre para no 17 rígido', () {
    expect(bancaCompra(mao('AS 6H'), true), isFalse);
    expect(bancaCompra(mao('AS 6H'), false), isTrue);
    expect(bancaCompra(mao('AS 6H KS'), false), isFalse);
    expect(bancaCompra(mao('9S 7H'), true), isTrue);
    expect(bancaCompra(mao('AS 7H'), false), isFalse);
  });
  test('vitória, derrota, empate e estouro seguem a prioridade correta', () {
    expect(resultado(mao('9S 7H'), mao('KS 7D')).titulo, 'A banca venceu');
    expect(resultado(mao('9S 8H'), mao('KS 7D')).titulo, 'Empate');
    expect(resultado(mao('KS 9H'), mao('KS 7D')).titulo, 'Você venceu');
    expect(resultado(mao('9S 7H'), mao('KS QH 2D')).titulo, 'Você venceu');
    expect(
      resultado(mao('KS QH 2D'), mao('KS QH 3D')).titulo,
      'Você passou de 21',
    );
  });
}
