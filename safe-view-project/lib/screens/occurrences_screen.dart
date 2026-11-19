import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/occurrence.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class OccurrencesScreen extends StatefulWidget {const OccurrencesScreen({super.key});@override State<OccurrencesScreen> createState()=>_OccurrencesScreenState();}
class _OccurrencesScreenState extends State<OccurrencesScreen>{
 OccurrenceType? type; Priority? priority; String? region;
 @override Widget build(BuildContext context)=>SafeScaffold(title:'Ocorrências',child:PagePadding(child:Consumer<AppState>(builder:(context,s,_) {
  if(s.status==LoadStatus.loading)return const LoadingView();
  final list=s.occurrences.where((o)=>(type==null||o.type==type)&&(priority==null||o.priority==priority)&&(region==null||o.region==region)).toList();
  return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const SectionTitle('Registros do território',subtitle:'Toque em um item para consultar evidências e encaminhamento sugerido.'),
   DropdownButtonFormField<OccurrenceType?>(value:type,decoration:const InputDecoration(labelText:'Tipo'),items:[const DropdownMenuItem(value:null,child:Text('Todos os tipos')),...OccurrenceType.values.map((v)=>DropdownMenuItem(value:v,child:Text(typeLabel(v))))],onChanged:(v)=>setState(()=>type=v)),
   const SizedBox(height:10),
   DropdownButtonFormField<Priority?>(value:priority,decoration:const InputDecoration(labelText:'Prioridade'),items:[const DropdownMenuItem(value:null,child:Text('Todas as prioridades')),...Priority.values.map((v)=>DropdownMenuItem(value:v,child:Text(priorityLabel(v))))],onChanged:(v)=>setState(()=>priority=v)),
   const SizedBox(height:10),
   DropdownButtonFormField<String?>(value:region,decoration:const InputDecoration(labelText:'Região'),items:[const DropdownMenuItem(value:null,child:Text('Todas as regiões')),...AppState.regions.map((v)=>DropdownMenuItem(value:v,child:Text(v)))],onChanged:(v)=>setState(()=>region=v)),
   Align(alignment:Alignment.centerRight,child:TextButton.icon(onPressed:()=>setState((){type=null;priority=null;region=null;}),icon:const Icon(Icons.filter_alt_off),label:const Text('Limpar filtros'))),
   Text('Exibindo ${list.length} de ${s.total} registros',style:Theme.of(context).textTheme.bodySmall),
   const SizedBox(height:8),
   if(list.isEmpty)const EmptyView('Nenhuma ocorrência encontrada com esses filtros.') else ...list.map((o)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:o.priority==Priority.alta?const Color(0xFFFFE1E3):const Color(0xFFE3EAFE),child:Icon(o.type==OccurrenceType.assalto?Icons.security:o.type==OccurrenceType.acidente?Icons.car_crash:Icons.medical_services,color:o.priority==Priority.alta?const Color(0xFFD10F1E):const Color(0xFF103B76))),title:Text(o.place,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${typeLabel(o.type)} • ${o.region} • ${priorityLabel(o.priority)}\n${o.routing}'),isThreeLine:true,trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.pushNamed(context,'/occurrence-detail',arguments:o)))),
  ]);
 })),floatingActionButton:FloatingActionButton.extended(onPressed:()=>Navigator.pushNamed(context,'/register'),icon:const Icon(Icons.add),label:const Text('Nova ocorrência')));
}