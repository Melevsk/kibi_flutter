import 'package:flutter_test/flutter_test.dart';
void main() {
  test('budget total rule', () {
    const balance = 300;
    const need = 100, want = 80, save = 70;
    expect(need + want + save <= balance, isTrue);
  });
  test('pet stages', () {
    int stage(int badges) => badges >= 15 ? 3 : badges >= 7 ? 2 : 1;
    expect(stage(0), 1);
    expect(stage(7), 2);
    expect(stage(15), 3);
  });
}
