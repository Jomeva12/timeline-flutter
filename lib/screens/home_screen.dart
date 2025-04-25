import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timeline/screens/timeline/timeline_screen.dart';
import '../providers/vuelo_provider.dart';
import '../widgets/curve_appbar_clipper.dart';
import 'empresa/empresas_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DateTime> _diasConVuelos = [];
  late VueloProvider _vueloProvider;
  bool _isLoading = true;
  DateTime? _currentMonth;

  @override
  void initState() {
    super.initState();
    _vueloProvider = Provider.of<VueloProvider>(context, listen: false);
    debugPrint('🚀 Iniciando carga inicial de días con vuelos');
    _cargarDiasConVuelos(DateTime.now());
  }

  Future<void> _cargarDiasConVuelos(DateTime mes) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    debugPrint('📅 Solicitando días con vuelos para: ${mes.year}-${mes.month}');
    final dias = await _vueloProvider.getDiasConVuelos(mes);

    if (!mounted) return;
    setState(() {
      _diasConVuelos = dias.toSet().toList();
      _isLoading = false;
      debugPrint('✅ Días con vuelos cargados: ${_diasConVuelos.map((d) => '${d.year}-${d.month}-${d.day}').join(', ')}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // AppBar personalizado con curva
          ClipPath(
            clipper: CurvedAppBarClipper(),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ Color(0xFF4A90E2), // azul pastel
                    Color(0xFF072A4E),],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, 4),
                      blurRadius: 10),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Itinerarios SMR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        switch (value) {
                          case 'empresas':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EmpresasScreen()),
                            );
                            break;

                          case 'copy_url':
                            const url = 'https://itinerarios-70663.web.app';
                            Clipboard.setData(const ClipboardData(text: url));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('URL copiada al portapapeles')),
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'empresas',
                          child: Text('🏢 Empresa', style: TextStyle(fontSize: 14)),
                        ),
                        const PopupMenuItem(
                          value: 'copy_url',
                          child: Text('📋 Copiar URL', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Calendario debajo del AppBar
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              todayHighlightColor: Colors.blueAccent,
              selectionDecoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                appointmentDisplayCount: 1,
                showAgenda: false,
              ),
              appointmentTextStyle: const TextStyle(
                fontSize: 8, // Reducir el tamaño de la fuente
                color: Colors.red,
              ),
              dataSource: _VuelosDataSource(_diasConVuelos),
              onViewChanged: (ViewChangedDetails details) {
                if (details.visibleDates.isNotEmpty) {
                  final newMonth = details.visibleDates[details.visibleDates.length ~/ 2];

                  if (_currentMonth?.month != newMonth.month || _currentMonth?.year != newMonth.year) {
                    _currentMonth = newMonth;
                    _cargarDiasConVuelos(newMonth);
                  } else {
                    debugPrint('⏭️ Mismo mes, no se recarga');
                  }
                }
              },
              onTap: (CalendarTapDetails details) {
                if (details.date != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimelineScreen(selectedDate: details.date),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _VuelosDataSource extends CalendarDataSource {
  _VuelosDataSource(List<DateTime> diasConVuelos) {
    appointments = diasConVuelos.map((fecha) => Appointment(
      startTime: DateTime(fecha.year, fecha.month, fecha.day),
      endTime: DateTime(fecha.year, fecha.month, fecha.day, 23, 59),
      subject: '•', // Punto más pequeño
      color: Colors.red,
      isAllDay: true,
    )).toList();
  }
}
