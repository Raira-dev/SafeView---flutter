import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/occurrence.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {const DashboardScreen({super.key});
 @override Widget build(BuildContext context)=>SafeScaffold(title:'Painéis territoriais',child:PagePadding(child:Consumer<AppState>(builder:(context,s,_) {
  if(s.status==LoadStatus.loading)return const LoadingView();
  if(s.isEmpty)return const EmptyView('Ainda não há dados para montar os painéis.');
  return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const HumanNotice(),
   const SectionTitle('Painel 1 • Tipos de ocorrência',subtitle:'Distribuição dos registros por categoria'),
   _ChartCard(title:'Ocorrências por tipo',items:{for(final t in OccurrenceType.values)typeLabel(t):s.countType(t)},total:s.total),
   const SectionTitle('Painel 2 • Prioridade',subtitle:'Nível de prioridade informado nos registros'),
   _ChartCard(title:'Distribuição por prioridade',items:{for(final p in Priority.values)priorityLabel(p):s.countPriority(p)},total:s.total),
   const SectionTitle('Painel 3 • Território',subtitle:'Concentração absoluta por região'),
   _ChartCard(title:'Registros por região',items:{for(final r in AppState.regions)r:s.countRegion(r)},total:s.total),
   const SectionTitle('Leitura dos indicadores'),
   Card(child:Padding(padding:const EdgeInsets.all(16),child:Text('Total analisado: ${s.total}. A região com mais registros é ${s.topRegion}. ${s.highPriorityPercent}% dos registros estão classificados com prioridade alta. Os gráficos mostram contagens da amostra disponível, não taxas por habitante nem risco real.'))),
  ]);
 })));
}
class _ChartCard extends StatelessWidget {final String title;final Map<String,int> items;final int total;const _ChartCard({required this.title,required this.items,required this.total});
 @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:12),
  ...items.entries.map((e){final double pct = total == 0 ? 0.0 : (e.value / total).toDouble();return Padding(padding:const EdgeInsets.only(bottom:13),child:Column(children:[
   Row(children:[Expanded(child:Text(e.key)),Text('${e.value} (${(pct*100).round()}%)',style:const TextStyle(fontWeight:FontWeight.bold))]),
   const SizedBox(height:6),ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:pct,minHeight:11,backgroundColor:Theme.of(context).colorScheme.surfaceContainerHighest,color:const Color(0xFF103B76))),
  ]));}),
 ])));
}