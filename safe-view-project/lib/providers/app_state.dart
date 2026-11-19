import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/occurrence.dart';
import '../services/data_service.dart';

enum LoadStatus { loading, ready, error }

class AppState extends ChangeNotifier {
  static const regions = ['Centro','Zona Norte','Zona Sul','Zona Leste','Zona Oeste'];
  final DataService _service;
  AppState(this._service);
  List<Occurrence> _items=[];
  LoadStatus status=LoadStatus.loading;
  String? errorMessage;
  bool darkMode=false, highContrast=false, largeText=false, consent=false;
  bool get isEmpty => _items.isEmpty;
  List<Occurrence> get occurrences => List.unmodifiable(_items);
  int get total => _items.length;
  int countType(OccurrenceType t)=>_items.where((o)=>o.type==t).length;
  int countPriority(Priority p)=>_items.where((o)=>o.priority==p).length;
  int countRegion(String r)=>_items.where((o)=>o.region==r).length;
  int get highPriorityPercent => total==0?0:(countPriority(Priority.alta)*100/total).round();
  String get topRegion {
    if (_items.isEmpty) return '—';
    return regions.reduce((a,b)=>countRegion(a)>=countRegion(b)?a:b);
  }
  int get routedCount => _items.where((o)=>o.routing.isNotEmpty).length;

  Future<void> initialize() async {
    status=LoadStatus.loading; notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    consent=prefs.getBool('consent')??false;
    darkMode=prefs.getBool('darkMode')??false;
    highContrast=prefs.getBool('highContrast')??false;
    largeText=prefs.getBool('largeText')??false;
    final cached=prefs.getString('occurrences');
    if(cached!=null) {
      try { _items=(jsonDecode(cached) as List).map((e)=>Occurrence.fromJson(e)).toList(); }
      catch (_) { _items=[]; }
    }
    try {
      final remote=await _service.fetchOccurrences();
      // O conjunto simulado é usado como fonte inicial; registros locais são preservados.
      final local=_items.where((o)=>!o.id.startsWith('seed-')).toList();
      _items=[...local,...remote];
      await _save();
      status=LoadStatus.ready;
    } catch (_) {
      status=LoadStatus.ready; // cache local continua disponível
      errorMessage='Sem conexão com a fonte de dados. Exibindo dados salvos neste dispositivo.';
    }
    notifyListeners();
  }
  Future<void> retry() async { status=LoadStatus.loading; errorMessage=null; notifyListeners(); await initialize(); }
  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    await p.setString('occurrences',jsonEncode(_items.map((e)=>e.toJson()).toList()));
  }
  Future<void> addOccurrence({required OccurrenceType type,required Priority priority,
    required String region,required String place,required String description,String camera=''}) async {
    final item=Occurrence(id:'local-${DateTime.now().microsecondsSinceEpoch}',type:type,
      priority:priority,region:region,place:place,description:description,camera:camera,
      createdAt:DateTime.now());
    _items.insert(0,item); await _save(); notifyListeners();
  }
  Future<void> setConsent(bool value) async { consent=value; final p=await SharedPreferences.getInstance(); await p.setBool('consent',value); notifyListeners(); }
  Future<void> setDarkMode(bool v) async {darkMode=v; final p=await SharedPreferences.getInstance(); await p.setBool('darkMode',v); notifyListeners();}
  Future<void> setHighContrast(bool v) async {highContrast=v; final p=await SharedPreferences.getInstance(); await p.setBool('highContrast',v); notifyListeners();}
  Future<void> setLargeText(bool v) async {largeText=v; final p=await SharedPreferences.getInstance(); await p.setBool('largeText',v); notifyListeners();}

  List<InsightAlert> get alerts {
    final result=<InsightAlert>[];
    for(final region in regions) {
      final count=countRegion(region);
      final high=_items.where((o)=>o.region==region&&o.priority==Priority.alta).length;
      if(count>=2 || high>=1) {
        final confidence=(0.55+(count/total.clamp(1,999))*0.35).clamp(0.55,0.90).toDouble();
        result.add(InsightAlert(region:region,count:count,highCount:high,
          confidence:confidence, evidence:'$count registros na região; $high com prioridade alta.',
          limitation:'Amostra sintética e pequena; não representa taxa populacional, causalidade ou previsão validada. Eventos não reportados não entram no cálculo.'));
      }
    }
    result.sort((a,b)=>b.count.compareTo(a.count));
    return result;
  }
}
class InsightAlert {
  final String region,evidence,limitation; final int count,highCount; final double confidence;
  const InsightAlert({required this.region,required this.count,required this.highCount,
    required this.confidence,required this.evidence,required this.limitation});
  String get level => highCount>=2?'Atenção elevada':'Monitoramento';
}