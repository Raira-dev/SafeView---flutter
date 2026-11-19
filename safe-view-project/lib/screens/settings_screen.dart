import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {const SettingsScreen({super.key});
 @override Widget build(BuildContext context)=>SafeScaffold(title:'Preferências e privacidade',child:PagePadding(child:Consumer<AppState>(builder:(context,s,_)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const SectionTitle('Acessibilidade'),
  SwitchListTile(title:const Text('Texto ampliado'),subtitle:const Text('Aumenta a escala dos textos.'),value:s.largeText,onChanged:s.setLargeText),
  SwitchListTile(title:const Text('Alto contraste'),subtitle:const Text('Realça a leitura dos elementos.'),value:s.highContrast,onChanged:s.setHighContrast),
  SwitchListTile(title:const Text('Modo escuro'),value:s.darkMode,onChanged:s.setDarkMode),
  const SectionTitle('Privacidade e consentimento'),
  Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Text('O SafeView não solicita nome, CPF, telefone ou outros identificadores. As ocorrências criadas pelo usuário ficam armazenadas localmente no dispositivo. A fonte demonstrativa contém dados sintéticos.'),
   const SizedBox(height:12),
   SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Concordo com o uso dos dados demonstrativos'),value:s.consent,onChanged:s.setConsent),
  ]))),
  const SectionTitle('Sobre os dados'),
  const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Fonte: serviço/API simulada com registros sintéticos para fins acadêmicos. O app mantém cache local e permite registrar ocorrências sem conexão. Nenhuma decisão de alto impacto é automatizada.'))),
 ]))));
}