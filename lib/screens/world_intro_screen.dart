import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class WorldIntroScreen extends StatefulWidget {
  const WorldIntroScreen({super.key});

  @override
  State<WorldIntroScreen> createState() => _WorldIntroScreenState();
}

class _WorldIntroScreenState extends State<WorldIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradé
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFF658EF2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.48, 1.0],
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _PopularDestinationsCard(
                    onTapCountry: (country, label) {
                      if (country != null) {
                        _openCountryModal(context, country);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pronto podrás explorar $label. '
                                  'Por ahora solo tenemos Chile 😉',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Globo + texto
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        SizedBox(
                          width: isSmall ? 240 : 320,
                          height: isSmall ? 240 : 320,
                        child:
                        AnimatedBuilder(
                          animation: _spin, builder: (ctx, _)
                        { return Transform( transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                         ..rotateY(_spin.value * 2 * math.pi),
                          alignment: Alignment.center,
                          child: Image.asset( 'assets/globe.png', fit: BoxFit.contain, ),
                            );
                          },
                         ),
                        ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  offset: Offset(0, 8),
                                  blurRadius: 18,
                                )
                              ],
                            ),
                            child: const Text(
                              'Selecciona un destino popular para ver datos, '
                                  'locaciones y tendencias.\n'
                                  'Por ahora estamos enfocados en Chile 🇨🇱.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // (podrías agregar un botón para ir al Home si quieres)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== Card tipo maqueta: Popular Destinations (PAÍSES) ======

class _PopularDestinationsCard extends StatelessWidget {
  final void Function(Country? country, String label) onTapCountry;

  const _PopularDestinationsCard({
    required this.onTapCountry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header azul con título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF658EF2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const Text(
              'Popular Destinations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),

          // Lista de países
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _popularCountries.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0x11000000),
            ),
            itemBuilder: (context, index) {
              final item = _popularCountries[index];
              return InkWell(
                onTap: () => onTapCountry(item.country, item.title),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.black45,
                        ),
                        onPressed: () => onTapCountry(
                          item.country,
                          item.title,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Modelo de item de la lista de países populares
class PopularCountryItem {
  final String title;
  final String subtitle;
  final Country? country; // solo Chile tiene Country real por ahora

  const PopularCountryItem({
    required this.title,
    required this.subtitle,
    this.country,
  });
}

const List<String> _monthLabels = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

/// Lista de países para la card (maqueta como la imagen)
final List<PopularCountryItem> _popularCountries = [
  PopularCountryItem(
    title: 'Chile',
    subtitle: 'South America',
    country: _chile, // este sí abre el modal
  ),
  PopularCountryItem(
    title: 'Berlin',
    subtitle: 'Germany, Western Europe',
  ),
  PopularCountryItem(
    title: 'Venice',
    subtitle: 'Italy, Western Europe',
  ),
  PopularCountryItem(
    title: 'Cape Town',
    subtitle: 'South Africa, Africa',
  ),
  PopularCountryItem(
    title: 'Kioto',
    subtitle: 'Japan, East Asia',
  ),
  PopularCountryItem(
    title: 'Sam Francisco',
    subtitle: 'USA, North America',
  ),
];

/// ====== Modal de país (dos pestañas) ======
void _openCountryModal(BuildContext context, Country c) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return DefaultTabController(
        length: 2,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scroll) {
            return Column(
              children: [
                // Header + Tabs
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF658EF2),
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${c.flag}  ${c.name}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    c.continent,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const TabBar(
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor: Color(0xEEFFFFFF),
                          tabs: [
                            Tab(icon: Icon(Icons.insights), text: 'Overview'),
                            Tab(
                              icon: Icon(Icons.place_outlined),
                              text: 'Locaciones',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Contenido
                Expanded(
                  child: TabBarView(
                    children: [
                      _CountryOverviewTab(country: c, controller: scroll),
                      _CountryLocationsTab(country: c, controller: scroll),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

/// ====== TAB 1: Overview (métricas + carrusel + gráfico) ======
class _CountryOverviewTab extends StatelessWidget {
  final Country country;
  final ScrollController controller;
  const _CountryOverviewTab({
    required this.country,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cards = country.popularDestinations;

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _KpiCard(
                title: 'Gente',
                value: '${_fmtK(country.userEngagement)} de personas',
              ),
              _KpiCard(
                title: 'Ranking de sobreturismo',
                value: '${country.overtourismRank}th',
              ),
              _KpiCard(
                title: 'Mejores zonas',
                value: '${country.locationsCovered}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Popular Destinations',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: PageController(viewportFraction: .86),
              itemCount: cards.length,
              itemBuilder: (_, i) => _DestinationCard(d: cards[i]),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Historical Visitors Data',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: _MiniLineChart(
              values: country.monthlyVisitors,
              xLabels: _monthLabels,
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Ir'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== TAB 2: Locaciones ======
class _CountryLocationsTab extends StatelessWidget {
  final Country country;
  final ScrollController controller;
  const _CountryLocationsTab({
    required this.country,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          for (final loc in country.locations)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Imagen o placeholder
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: loc.asset != null
                          ? Image.asset(loc.asset!, fit: BoxFit.cover)
                          : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0B6B68),
                              Color(0xFF5F9CF7)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          loc.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Ir'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== UI helpers ======

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x110B6B68)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final Destination d;
  const _DestinationCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0x110B6B68)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 120,
                height: double.infinity,
                child: d.asset != null
                    ? Image.asset(d.asset!, fit: BoxFit.cover)
                    : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0B6B68), Color(0xFF5F9CF7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title,
                        style:
                        const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      d.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini line chart con labels en ejes
class _MiniLineChart extends StatelessWidget {
  final List<int> values;
  final List<String>? xLabels; // opcional

  const _MiniLineChart({
    required this.values,
    this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(values, xLabels: xLabels),
      child: Container(),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<int> v;
  final List<String>? xLabels;

  _LinePainter(this.v, {this.xLabels});

  @override
  void paint(Canvas canvas, Size size) {
    if (v.isEmpty) return;

    // Margen interno para dejar espacio a labels
    const double left = 40;
    const double rightPadding = 8;
    const double top = 12;
    const double bottomPadding = 26; // deja espacio para labels X
    final double bottom = size.height - bottomPadding;

    // Ejes
    final paintAxis = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    // Eje X
    canvas.drawLine(
      Offset(left, bottom),
      Offset(size.width - rightPadding, bottom),
      paintAxis,
    );
    // Eje Y
    canvas.drawLine(
      Offset(left, top),
      Offset(left, bottom),
      paintAxis,
    );

    final minV = v.reduce(math.min).toDouble();
    final maxV = v.reduce(math.max).toDouble();
    final range = (maxV - minV == 0) ? 1 : (maxV - minV);

    final paintLine = Paint()
      ..color = const Color(0xFF0B6B68)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final usableWidth = (size.width - rightPadding) - left;
    final usableHeight = bottom - top;

    for (int i = 0; i < v.length; i++) {
      final t = v.length > 1 ? i / (v.length - 1) : 0.0;
      final x = left + usableWidth * t;
      final y = bottom - ((v[i] - minV) / range) * (usableHeight - 8);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paintLine);

    // ====== Labels ======
    const textStyle = TextStyle(
      color: Colors.black54,
      fontSize: 10,
    );

    // Labels Y: min y max (formato K)
    final minLabel = _fmtK(minV.toInt());
    final maxLabel = _fmtK(maxV.toInt());

    // min (abajo)
        {
      final tp = TextPainter(
        text: TextSpan(text: minLabel, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(left - tp.width - 4, bottom - tp.height / 2),
      );
    }

    // max (arriba)
        {
      final tp = TextPainter(
        text: TextSpan(text: maxLabel, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(left - tp.width - 4, top - tp.height / 2),
      );
    }

    // Labels X: meses o índices
    for (int i = 0; i < v.length; i++) {
      final t = v.length > 1 ? i / (v.length - 1) : 0.0;
      final x = left + usableWidth * t;

      final label = (xLabels != null && i < xLabels!.length)
          ? xLabels![i]
          : '${i + 1}';

      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final dx = x - tp.width / 2;
      final dy = bottom + 4; // un poco bajo el eje X
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.v != v || oldDelegate.xLabels != xLabels;
}

/// ====== Datos de Chile (dummy para UI) ======
class Country {
  final String code;
  final String name;
  final String continent;
  final String flag;
  final int userEngagement;
  final int overtourismRank;
  final int locationsCovered;
  final List<Destination> popularDestinations;
  final List<LocationCard> locations;
  final List<int> monthlyVisitors;

  Country({
    required this.code,
    required this.name,
    required this.continent,
    required this.flag,
    required this.userEngagement,
    required this.overtourismRank,
    required this.locationsCovered,
    required this.popularDestinations,
    required this.locations,
    required this.monthlyVisitors,
  });
}

class Destination {
  final String title;
  final String description;
  final String? asset;
  final String? imageUrl;

  Destination({
    required this.title,
    required this.description,
    this.asset,
    this.imageUrl,
  });
}

class LocationCard {
  final String title;
  final String? asset;
  LocationCard(this.title, this.asset);
}

String _fmtK(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

final _chile = Country(
  code: 'CL',
  name: 'Chile',
  continent: 'South America',
  flag: '🇨🇱',
  userEngagement: 18480432,
  overtourismRank: 27,
  locationsCovered: 24,
  popularDestinations: [
    Destination(
      title: 'Valparaíso',
      description: 'Cerro Alegre, ascensores, murales y puerto histórico.',
      asset: 'assets/valparaiso.webp',
      imageUrl:
      'https://i0.wp.com/unaguiaenmimaleta.com/wp-content/uploads/2024/07/Que-hacer-en-Valparaiso-32.jpg?fit=1170%2C780&ssl=1',
    ),
    Destination(
      title: 'Viña del Mar',
      description: 'Playas, Quinta Vergara y vida costera.',
      asset: 'assets/viña_del_mar.webp',
      imageUrl:
      'https://www.google.com/url?sa=i&url=https%3A%2F%2Fmodenapatagonia.com%2Fvalparaiso-o-vina-del-mar-cual-elegir%2F&psig=AOvVaw1eANmuYQJchR5ewILQlIRK&ust=1763057791707000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCOjU4Jmc7ZADFQAAAAAdAAAAABAE',
    ),
    Destination(
      title: 'Torres del Paine',
      description: 'Parque Nacional icónico con trekking y glaciares.',
      asset: 'assets/torres.jpg',
      imageUrl: 'https://www.conaf.cl/wp-content/uploads/2024/06/DSC1972.jpg',
    ),
    Destination(
      title: 'San Pedro de Atacama',
      description: 'Desierto, salares y cielos estrellados.',
      asset: 'assets/atacama.jpg',
      imageUrl:
      'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.trekkingchile.com%2Fes%2Fsan-pedro-de-atacama-caminatas-y-excursiones%2F&psig=AOvVaw0tVIuqRLWw8Po6ounn4oLh&ust=1763057724623000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJCCuo2c7ZADFQAAAAAdAAAAABAE',
    ),
  ],
  locations: [
    LocationCard('Valparaíso', 'assets/valparaiso.webp'),
    LocationCard('Viña del Mar', 'assets/viña_del_mar.webp'),
    LocationCard('Torres del Paine', 'assets/torres.jpg'),
  ],
  monthlyVisitors: [
    720000,
    450000,
    380000,
    410000,
    390000,
    510000,
    560000,
    600000,
    470000,
    650000,
    680000,
    730000,
  ],
);
