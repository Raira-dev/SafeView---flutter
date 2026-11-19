import 'package:flutter_test/flutter_test.dart';
import 'package:safeview/models/occurrence.dart';

void main() {
  test('encaminhamento mantém as regras do SafeView original', () {
    expect(routeFor(OccurrenceType.assalto), 'Polícia');
    expect(routeFor(OccurrenceType.acidente), 'SAMU + Polícia');
    expect(routeFor(OccurrenceType.saude), 'SAMU / Ambulância');
  });
  test('rótulos das prioridades são apresentados em português', () {
    expect(priorityLabel(Priority.alta), 'Alta');
    expect(priorityLabel(Priority.media), 'Média');
    expect(priorityLabel(Priority.baixa), 'Baixa');
  });
}