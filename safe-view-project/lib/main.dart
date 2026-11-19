import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/occurrence.dart';
import 'providers/app_state.dart';
import 'services/data_service.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/occurrences_screen.dart';
import 'screens/register_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(create: (_) => AppState(DataService())..initialize(), child: const SafeViewApp()));
}

class SafeViewApp extends StatelessWidget {
  const SafeViewApp({super.key});

  static const navy = Color(0xFF103B76);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final dark = state.darkMode;

        // Esquema de cores base
        final baseScheme = ColorScheme.fromSeed(
          seedColor: navy,
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: navy,
          secondary: const Color(0xFFE53935),
          surface: dark
              ? const Color(0xFF242A33)
              : Colors.white,
        );

        // Tema de alto contraste
        final scheme = state.highContrast
            ? baseScheme.copyWith(
                primary: dark ? Colors.white : Colors.black,
                onPrimary: dark ? Colors.black : Colors.white,
                secondary: dark ? Colors.yellow : Colors.black,
                onSecondary: dark ? Colors.black : Colors.white,
                outline: dark ? Colors.white : Colors.black,
              )
            : baseScheme;

        return MaterialApp(
          title: 'SafeView',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
            scaffoldBackgroundColor: dark
                ? const Color(0xFF171D26)
                : const Color(0xFFF2F4F8),
            fontFamily: 'Roboto',

            cardTheme: CardThemeData(
              elevation: 0,
              color: scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: dark
                      ? Colors.white12
                      : const Color(0xFFE0E5ED),
                ),
              ),
            ),

            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Colors.transparent,
            ),

            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: scheme.surface,
            ),
          ),

          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  state.largeText ? 1.18 : 1.0,
                ),
              ),
              child: child!,
            );
          },

          initialRoute: '/',

          routes: {
            '/': (_) => const HomeScreen(),
            '/dashboards': (_) => const DashboardScreen(),
            '/occurrences': (_) => const OccurrencesScreen(),
            '/register': (_) => const RegisterScreen(),
            '/alerts': (_) => const AlertsScreen(),
            '/settings': (_) => const SettingsScreen(),
          },

          onGenerateRoute: (settings) {
            if (settings.name == '/occurrence-detail') {
              final occurrence = settings.arguments as Occurrence;

              return MaterialPageRoute(
                builder: (_) => OccurrenceDetailScreen(
                  occurrence: occurrence,
                ),
              );
            }

            if (settings.name == '/alert-detail') {
              final alert = settings.arguments as InsightAlert;

              return MaterialPageRoute(
                builder: (_) => AlertDetailScreen(
                  alert: alert,
                ),
              );
            }

            return null;
          },
        );
      },
    );
  }
}

class OccurrenceDetailScreen extends StatelessWidget {
  final Occurrence occurrence;
  const OccurrenceDetailScreen({super.key,required this.occurrence});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Detalhe da ocorrência')),body:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _Pill(text:typeLabel(occurrence.type)),const SizedBox(height:14),
    Text(occurrence.place,style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:8),
    Text('${occurrence.region} • ${priorityLabel(occurrence.priority)}'),
    const SizedBox(height:20),Text(occurrence.description),
    const SizedBox(height:20),_InfoTile(title:'Encaminhamento sugerido',value:occurrence.routing),
    _InfoTile(title:'Câmera',value:occurrence.camera.isEmpty?'Não informada':occurrence.camera),
    _InfoTile(title:'Status',value:occurrence.status),
    const Spacer(),const _HumanDecisionBanner(),
  ])));
}
class AlertDetailScreen extends StatelessWidget {
  final InsightAlert alert;
  const AlertDetailScreen({super.key,required this.alert});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Detalhe do alerta')),body:ListView(padding:const EdgeInsets.all(20),children:[
    _Pill(text:alert.level),const SizedBox(height:14),
    Text(alert.region,style:Theme.of(context).textTheme.headlineMedium),
    Text('Confiança indicativa: ${(alert.confidence*100).round()}%'),
    const SizedBox(height:18),_InfoTile(title:'Evidência observada',value:alert.evidence),
    _InfoTile(title:'Limitações',value:alert.limitation),
    const SizedBox(height:12),const _HumanDecisionBanner(),
  ]));
}
class _InfoTile extends StatelessWidget {
  final String title,value; const _InfoTile({required this.title,required this.value});
  @override Widget build(BuildContext context)=>Card(child:ListTile(title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Padding(padding:const EdgeInsets.only(top:5),child:Text(value))));
}
class _Pill extends StatelessWidget {
  final String text; const _Pill({required this.text});
  @override Widget build(BuildContext context)=>Chip(label:Text(text),backgroundColor:const Color(0xFFE3EAFE),labelStyle:const TextStyle(color:Color(0xFF103B76),fontWeight:FontWeight.bold));
}
class _HumanDecisionBanner extends StatelessWidget {
  const _HumanDecisionBanner();
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFFFFF2D9),borderRadius:BorderRadius.circular(14)),child:const Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Icon(Icons.info_outline,color:Color(0xFF805000)),SizedBox(width:10),Expanded(child:Text('Este alerta é apenas apoio à análise. Não aciona equipes nem substitui a avaliação e a decisão de profissionais humanos.',style:TextStyle(color:Color(0xFF604000),fontWeight:FontWeight.w600)))
  ]));
}