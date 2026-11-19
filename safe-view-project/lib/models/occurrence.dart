enum OccurrenceType { assalto, acidente, saude }
enum Priority { baixa, media, alta }

String typeLabel(OccurrenceType t) => switch (t) {
  OccurrenceType.assalto => 'Assalto',
  OccurrenceType.acidente => 'Acidente',
  OccurrenceType.saude => 'Emergência de saúde',
};
String priorityLabel(Priority p) => switch (p) {
  Priority.baixa => 'Baixa', Priority.media => 'Média', Priority.alta => 'Alta',
};
String routeFor(OccurrenceType t) => switch (t) {
  OccurrenceType.assalto => 'Polícia',
  OccurrenceType.acidente => 'SAMU + Polícia',
  OccurrenceType.saude => 'SAMU / Ambulância',
};

class Occurrence {
  final String id, region, place, description, camera, status;
  final OccurrenceType type;
  final Priority priority;
  final DateTime createdAt;
  const Occurrence({required this.id, required this.type, required this.priority,
    required this.region, required this.place, required this.description,
    this.camera = '', this.status = 'Registrada', required this.createdAt});
  String get routing => routeFor(type);
  Map<String, dynamic> toJson() => {
    'id':id,'type':type.name,'priority':priority.name,'region':region,'place':place,
    'description':description,'camera':camera,'status':status,'createdAt':createdAt.toIso8601String()
  };
  factory Occurrence.fromJson(Map<String,dynamic> j) => Occurrence(
    id: j['id'], type: OccurrenceType.values.byName(j['type']),
    priority: Priority.values.byName(j['priority']), region: j['region'],
    place: j['place'], description: j['description'], camera: j['camera'] ?? '',
    status: j['status'] ?? 'Registrada', createdAt: DateTime.parse(j['createdAt']));
}