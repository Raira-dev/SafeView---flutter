import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _asked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_asked) {
      _asked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _consent());
    }
  }

  Future<void> _consent() async {
    if (!mounted) return;
    final state = context.read<AppState>();
    if (state.consent) return;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacidade e transparência'),
        content: const Text(
          'O SafeView usa registros demonstrativos e salva ocorrências localmente neste dispositivo. '
          'Não solicitamos nome, documento ou contato. Você concorda com o uso desses dados '
          'para visualizar os indicadores?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Não concordo'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Concordo'),
          ),
        ],
      ),
    );
    if (accepted == true) await state.setConsent(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      title: 'SafeView',
      actions: [
        IconButton(
          tooltip: 'Configurações de acessibilidade e privacidade',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(Icons.tune),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
      child: PagePadding(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            if (state.status == LoadStatus.loading) return const LoadingView();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF103B76), Color(0xFF1D5596)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Observe. Alerta. Protege.',
                        style: TextStyle(
                          color: Color(0xFFBFD0FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Monitoramento que protege e ajuda vidas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Inteligência territorial para acompanhar ocorrências e apoiar respostas mais rápidas.',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton(
                            onPressed: () => Navigator.pushNamed(context, '/dashboards'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD10F1E),
                            ),
                            child: const Text('Ver painéis'),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, '/alerts'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text('Ver alertas'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.cloud_off),
                        title: Text(state.errorMessage!),
                        trailing: IconButton(
                          onPressed: state.retry,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  ),
                const SectionTitle(
                  'Visão geral',
                  subtitle: 'Indicadores calculados a partir dos registros disponíveis',
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.55,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    KpiCard(
                      label: 'Ocorrências registradas',
                      value: '${state.total}',
                      icon: Icons.assignment_outlined,
                    ),
                    KpiCard(
                      label: 'Prioridade alta',
                      value: '${state.highPriorityPercent}%',
                      icon: Icons.priority_high,
                      color: const Color(0xFFD10F1E),
                    ),
                    KpiCard(
                      label: 'Região com mais registros',
                      value: state.topRegion,
                      icon: Icons.location_on_outlined,
                    ),
                    KpiCard(
                      label: 'Encaminhamentos sugeridos',
                      value: '${state.routedCount}',
                      icon: Icons.health_and_safety_outlined,
                      color: const Color(0xFF16734A),
                    ),
                  ],
                ),
                const SectionTitle('O que o SafeView acompanha'),
                const _Feature(
                  icon: Icons.local_police_outlined,
                  title: 'Segurança pública',
                  desc: 'Assaltos e ocorrências de segurança por região.',
                ),
                const _Feature(
                  icon: Icons.car_crash_outlined,
                  title: 'Acidentes',
                  desc: 'Registros de trânsito e prioridade de atendimento.',
                ),
                const _Feature(
                  icon: Icons.medical_services_outlined,
                  title: 'Emergências de saúde',
                  desc: 'Ocorrências que podem demandar SAMU ou ambulância.',
                ),
                const SectionTitle('Impacto social'),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.volunteer_activism,
                      color: Color(0xFF16734A),
                      size: 32,
                    ),
                    title: const Text('Registros com encaminhamento sugerido'),
                    subtitle: const Text(
                      'Indicador de apoio à articulação entre comunidade e serviços públicos.',
                    ),
                    trailing: Text(
                      '${state.routedCount}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const HumanNotice(),
                const SizedBox(height: 16),
                Text(
                  'Fonte: conjunto sintético demonstrativo SafeView. Não representa ocorrências oficiais.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _Feature({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF103B76), size: 30),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(desc),
        ),
      );
}