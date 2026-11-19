import 'dart:async';
import 'dart:convert';
import '../models/occurrence.dart';

/// Serviço simulado (API demonstrativa): devolve registros fictícios com latência de rede.
/// A camada de persistência local mantém o app utilizável offline.
class DataService {
  Future<List<Occurrence>> fetchOccurrences() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final now = DateTime.now();
    const rows = <List<String>>[
      ['assalto','alta','Centro','Cruzamento Central','CAM 02','Roubo a comércio relatado na região.'],
      ['saude','alta','Zona Sul','Praça das Flores','CAM 04','Pessoa caída e precisando de avaliação.'],
      ['acidente','media','Zona Norte','Av. Principal, 1200','CAM 07','Colisão entre dois veículos.'],
      ['assalto','media','Zona Leste','Terminal de ônibus','CAM 11','Furto de celular informado por cidadão.'],
      ['saude','media','Centro','Estação Central','','Pessoa com mal-estar.'],
      ['acidente','alta','Zona Oeste','Rua das Acácias','CAM 09','Atropelamento reportado.'],
      ['assalto','baixa','Zona Sul','Mercado municipal','CAM 03','Tentativa de arrombamento.'],
      ['acidente','baixa','Centro','Rua Direita','','Colisão leve sem feridos informados.'],
      ['saude','alta','Zona Leste','Hospital Municipal','CAM 12','Pessoa ferida após queda.'],
      ['assalto','alta','Centro','Praça Central','CAM 01','Roubo a pedestre reportado.'],
    ];
    return rows.asMap().entries.map((e) {
      final r=e.value;
      return Occurrence(id:'seed-${e.key}', type:OccurrenceType.values.byName(r[0]),
        priority:Priority.values.byName(r[1]), region:r[2], place:r[3], camera:r[4],
        description:r[5], createdAt:now.subtract(Duration(hours:e.key*3)));
    }).toList();
  }
  Future<String> sourceDescription() async => 'API simulada local: conjunto sintético demonstrativo SafeView v1';
}