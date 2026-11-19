import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SafeScaffold extends StatelessWidget {
  final String title; final Widget child; final List<Widget>? actions; final Widget? floatingActionButton;
  const SafeScaffold({super.key,required this.title,required this.child,this.actions,this.floatingActionButton});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Row(children:[Container(width:34,height:34,decoration:BoxDecoration(color:const Color(0xFF103B76),borderRadius:BorderRadius.circular(10)),child:const Icon(Icons.shield_outlined,color:Colors.white,size:21)),const SizedBox(width:10),Text(title,style:const TextStyle(fontWeight:FontWeight.w800))]),actions:actions),
    body:child,
    bottomNavigationBar:NavigationBar(selectedIndex:_index(context),onDestinationSelected:(i)=>Navigator.pushReplacementNamed(context,['/','/dashboards','/occurrences','/alerts'][i]),destinations:const [
      NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Início'),
      NavigationDestination(icon:Icon(Icons.analytics_outlined),selectedIcon:Icon(Icons.analytics),label:'Painéis'),
      NavigationDestination(icon:Icon(Icons.list_alt),label:'Registros'),
      NavigationDestination(icon:Icon(Icons.notifications_active_outlined),label:'Alertas'),
    ]),
    floatingActionButton:floatingActionButton,
  );
  int _index(BuildContext c){final r=ModalRoute.of(c)?.settings.name;return switch(r){'/dashboards'=>1,'/occurrences'=>2,'/alerts'=>3,_=>0};}
}
class PagePadding extends StatelessWidget {final Widget child;const PagePadding({super.key,required this.child});@override Widget build(BuildContext context)=>SingleChildScrollView(padding:const EdgeInsets.fromLTRB(18,12,18,100),child:child);}
class SectionTitle extends StatelessWidget {final String title;final String? subtitle;const SectionTitle(this.title,{super.key,this.subtitle});@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(top:18,bottom:10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),if(subtitle!=null)Text(subtitle!,style:Theme.of(context).textTheme.bodySmall)]));}
class KpiCard extends StatelessWidget {final String label,value;final IconData icon;final Color color;const KpiCard({super.key,required this.label,required this.value,required this.icon,this.color=const Color(0xFF103B76)});@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:color),const SizedBox(height:12),Text(value,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900,color:color)),Text(label,style:Theme.of(context).textTheme.bodySmall)])));}
class HumanNotice extends StatelessWidget {const HumanNotice({super.key});@override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFFFF2D9),borderRadius:BorderRadius.circular(14)),child:const Text('A tecnologia apoia a análise. A decisão final é sempre humana.',style:TextStyle(color:Color(0xFF604000),fontWeight:FontWeight.w700)));}
class LoadingView extends StatelessWidget {const LoadingView({super.key});@override Widget build(BuildContext context)=>const Center(child:CircularProgressIndicator());}
class EmptyView extends StatelessWidget {final String message;const EmptyView(this.message,{super.key});@override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(30),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.inbox_outlined,size:48),const SizedBox(height:12),Text(message,textAlign:TextAlign.center)])));}