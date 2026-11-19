import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class AlertsScreen extends StatelessWidget {const AlertsScreen({super.key});
 @override Widget build(BuildContext context)=>SafeScaffold(title:'Alertas preditivos',child:PagePadding(child:Consumer<AppState>(builder:(context,s,_) {
  if(s.status==LoadStatus.loading)return const LoadingView();
  return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const HumanNotice(),
   const SectionTitle('Sinais para acompanhamento',subtitle:'Regras transparentes aplicadas à amostra de ocorrências. Não são previsões clínicas ou policiais validadas.'),
   if(s.alerts.isEmpty)const EmptyView('Nenhum alerta foi gerado. Registre ocorrências para atualizar a análise.')
   else ...s.alerts.map((a)=>Card(child:ListTile(leading:const CircleAvatar(backgroundColor:Color(0xFFFFE1E3),child:Icon(Icons.notifications_active,color:Color(0xFFD10F1E))),title:Text(a.region,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${a.level} • ${a.count} registros • confiança indicativa ${(a.confidence*100).round()}%'),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.pushNamed(context,'/alert-detail',arguments:a)))),
   const SectionTitle('Como os alertas são gerados'),
   const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('A regra sinaliza regiões com dois ou mais registros, ou pelo menos um registro de prioridade alta. A confiança indicativa é uma pontuação heurística ilustrativa baseada na proporção de registros da região; não foi treinada nem calibrada com dados históricos reais.'))),
   const SectionTitle('Limitações e vieses'),
   const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Os dados são sintéticos, pequenos e não representam a população. Regiões com maior acesso a câmeras ou canais de denúncia podem parecer mais críticas. Não há ajuste por população, horário, sazonalidade ou subnotificação. Com poucos registros, mudanças na amostra alteram muito os resultados.'))),
  ]);
 })));
}