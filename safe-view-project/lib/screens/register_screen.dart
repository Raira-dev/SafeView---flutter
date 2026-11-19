import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/occurrence.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {const RegisterScreen({super.key});@override State<RegisterScreen> createState()=>_RegisterScreenState();}
class _RegisterScreenState extends State<RegisterScreen>{
 final form=GlobalKey<FormState>(); final place=TextEditingController(),description=TextEditingController(),camera=TextEditingController();
 OccurrenceType? type; Priority? priority; String? region; bool saving=false;
 @override void dispose(){place.dispose();description.dispose();camera.dispose();super.dispose();}
 String? requiredChoice(Object? v,String label)=>v==null?'Selecione $label.':null;
 @override Widget build(BuildContext context)=>SafeScaffold(title:'Registrar ocorrência',child:PagePadding(child:Form(key:form,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const SectionTitle('Novo registro',subtitle:'Informe apenas os dados necessários. Não inclua nomes, documentos ou contatos pessoais.'),
  DropdownButtonFormField<OccurrenceType>(decoration:const InputDecoration(labelText:'Tipo da ocorrência'),items:OccurrenceType.values.map((v)=>DropdownMenuItem(value:v,child:Text(typeLabel(v)))).toList(),onChanged:(v)=>setState(()=>type=v),validator:(v)=>requiredChoice(v,'o tipo')),
  const SizedBox(height:14),
  DropdownButtonFormField<Priority>(decoration:const InputDecoration(labelText:'Prioridade'),items:Priority.values.map((v)=>DropdownMenuItem(value:v,child:Text(priorityLabel(v)))).toList(),onChanged:(v)=>setState(()=>priority=v),validator:(v)=>requiredChoice(v,'a prioridade')),
  const SizedBox(height:14),
  DropdownButtonFormField<String>(decoration:const InputDecoration(labelText:'Região'),items:AppState.regions.map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>region=v),validator:(v)=>requiredChoice(v,'a região')),
  const SizedBox(height:14),
  TextFormField(controller:place,decoration:const InputDecoration(labelText:'Local',hintText:'Ex.: Cruzamento Central'),maxLength:100,validator:(v){final x=v?.trim()??'';return x.length<3?'Informe o local com 3 a 100 caracteres.':null;}),
  const SizedBox(height:8),
  TextFormField(controller:description,decoration:const InputDecoration(labelText:'Descrição',hintText:'Descreva a situação com informações úteis.'),minLines:3,maxLines:5,maxLength:500,validator:(v){final x=v?.trim()??'';return x.length<10?'A descrição deve ter de 10 a 500 caracteres.':null;}),
  const SizedBox(height:8),
  TextFormField(controller:camera,decoration:const InputDecoration(labelText:'Câmera (opcional)',hintText:'CAM 02'),maxLength:7,validator:(v){final x=(v??'').trim().toUpperCase();return x.isNotEmpty&&!RegExp(r'^CAM ?\d{1,3}$').hasMatch(x)?'Use o formato CAM 02.':null;}),
  const SizedBox(height:12),
  FilledButton.icon(onPressed:saving?null:_submit,icon:const Icon(Icons.save_outlined),label:Text(saving?'Salvando...':'Enviar registro')),
  const SizedBox(height:14),const Text('O encaminhamento exibido é uma sugestão por regra e não representa acionamento automático de equipes.',style:TextStyle(fontSize:12)),
 ]))));
 Future<void> _submit() async {
  if(!form.currentState!.validate())return;
  setState(()=>saving=true);
  await context.read<AppState>().addOccurrence(type:type!,priority:priority!,region:region!,place:place.text.trim(),description:description.text.trim(),camera:camera.text.trim().toUpperCase());
  if(!mounted)return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Ocorrência salva neste dispositivo.')));
  Navigator.pushReplacementNamed(context,'/occurrences');
 }
}