// lib/screens/map_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../models/lugar.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  final _map = MapController();
  late ApiClient _api;
  List<Lugar> _lugares = [];
  LatLng _center = const LatLng(defaultCenterLat, defaultCenterLon);
  LatLng? _myPos;

  Image? _meImg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _meImg ??= Image.asset('assets/pigeon_3.png');
    precacheImage(_meImg!.image, context);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _api = ApiClient(auth);
    _load();
    _locate();
  }

  // ========== Data ==========
  Future<void> _load() async {
    try {
      final list = await _api.getList('/api/lugares/status');
      setState(() {
        _lugares = (list as List)
            .map((e) => Lugar.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      if (_lugares.isNotEmpty) _fitToMarkers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar lugares: $e')),
      );
    }
  }

  Future<void> _locate() async {
    try {
      final pos = await LocationService().current();
      if (pos != null) {
        setState(() {
          _myPos = LatLng(pos.latitude, pos.longitude);
          _center = _myPos!;
        });
        _map.move(_center, 15);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación no disponible. Revisa permisos/GPS.'),
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiempo de espera agotado al obtener ubicación')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ubicación no disponible: $e')),
      );
    }
  }

  void _fitToMarkers() {
    final points = _lugares.map((l) => LatLng(l.lat, l.lon)).toList();
    if (_myPos != null) points.add(_myPos!);
    if (points.isEmpty) return;

    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLon = points.first.longitude, maxLon = points.first.longitude;
    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLon = min(minLon, p.longitude);
      maxLon = max(maxLon, p.longitude);
    }
    final center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
    _map.move(center, 13);
  }

  // ========== Helpers ==========
  Color _colorFor(Lugar l) {
    switch (l.semaforo) {
      case 'verde':
        return const Color(0xFF2ECC71);
      case 'amarillo':
        return const Color(0xFFF1C40F);
      case 'rojo':
        return const Color(0xFFE74C3C);
      default:
        return Colors.blueGrey;
    }
  }

  double _ocupacion(Lugar l) {
    final actual = (l.countNow ?? 0).toDouble();
    final cap = (l.capacidadMaxima ?? 0).toDouble();
    if (cap <= 0) return 0;
    return (actual / cap).clamp(0.0, 1.0);
  }

  String _fmtHoraLocal(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final l = dt.toLocal();
    final hh = l.hour.toString().padLeft(2, '0');
    final mm = l.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }


  Future<Map<String, dynamic>?> _fetchMetrics(String sourceId, {int minutes = 60}) async {
    try {
      final resp = await _api.getMap(
        '/metrics?source_id=${Uri.encodeComponent(sourceId)}&minutes=$minutes',
      );
      final now = resp['now'];
      if (now is Map<String, dynamic>) return now;
      return null;
    } catch (_) {
      return null;
    }
  }


  // ========== UI ==========
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final markers = <Marker>[];

    for (final l in _lugares) {
      markers.add(
        Marker(
          width: 44,
          height: 44,
          point: LatLng(l.lat, l.lon),
          child: GestureDetector(
            onTap: () => _openLugarSheet(l),
            child: Tooltip(
              message: '${l.nombre}\nActivos: ${l.countNow ?? '-'}'
                  '\nCap: ${l.capacidadMaxima ?? '-'}'
                  '\nSemáforo: ${l.semaforo ?? '-'}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colorFor(l),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8)
                  ],
                ),
                child: const Center(
                    child: Icon(Icons.location_on, color: Colors.white)),
              ),
            ),
          ),
        ),
      );
    }


    // Mi posición
    if (_myPos != null) {
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: _myPos!,
          child: Tooltip(
            message: 'Tú',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,

              ),

              child: _meImg != null
                  ? FittedBox(
                fit: BoxFit.contain,
                child: _meImg!,
              )
                  : Image.asset(
                'assets/pigeon_3.png',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    }


    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13,
              interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.migratio.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FilledButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar')),
                const SizedBox(width: 8),
                FilledButton.tonal(
                    onPressed: _locate,
                    child: const Icon(Icons.my_location)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openLugarSheet(Lugar l) {
    final occBase = _ocupacion(l);
    final colorBase = _colorFor(l);
    final hasSource = (l.sourceId ?? '').isNotEmpty;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.42,
          minChildSize: 0.30,
          maxChildSize: 0.85,
          builder: (ctx, scroll) {
            return SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((l.imageUrl ?? '').isNotEmpty) ...[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 300,
                          height: 200,
                          child: Image.network(
                            l.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _GradientTitle(text: l.nombre),
                  const SizedBox(height: 4),
                  if ((l.comuna ?? '').isNotEmpty || (l.region ?? '').isNotEmpty)
                    Text(
                      '${l.comuna ?? ''}${(l.comuna?.isNotEmpty == true && l.region?.isNotEmpty == true) ? ', ' : ''}${l.region ?? ''}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  const SizedBox(height: 12),
                  _InfoTile(icon: Icons.place_outlined, label: 'Dirección', value: l.direccion ?? '—'),
                  _InfoTile(icon: Icons.people_outline, label: 'Capacidad', value: '${l.capacidadMaxima ?? '—'}'),

                  _InfoTile(icon: Icons.traffic_outlined, label: 'Semáforo', value: l.semaforo ?? '—'),
                  const SizedBox(height: 12),


                  if (!hasSource) ...[
                    const Text('Sin cámara asociada a este lugar.', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    _OcupacionBar(value: occBase, color: colorBase),
                  ] else
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchMetrics(l.sourceId!, minutes: 60),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: LinearProgressIndicator(minHeight: 4),
                          );
                        }

                        final now = snap.data;
                        if (now == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Métricas no disponibles', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 8),
                              _OcupacionBar(value: occBase, color: colorBase),
                            ],
                          );
                        }

                        final count = now['count'] as num?;
                        final prom = now['prom'] as num?;
                        final max = now['max'] as num?;
                        final min = now['min'] as num?;
                        final fps = now['fps'] as num?;
                        final trend = now['trend30s'] as num?;
                        final ts = now['timestamp'] as String?;
                        final capPct = now['capacidad_pct'] as num?;
                        final disp = now['disponibles'] as num?;
                        final sem = now['semaforo'] as String?;

                        final occ = capPct != null
                            ? (capPct.toDouble() / 100.0).clamp(0.0, 1.0)
                            : occBase;


                        final color = (sem != null)
                            ? _colorFor(Lugar(
                          id: l.id,
                          nombre: l.nombre,
                          lat: l.lat,
                          lon: l.lon,
                          semaforo: sem,
                        ))
                            : colorBase;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _KpiChip(label: 'Activos', value: count?.toStringAsFixed(0) ?? '—'),

                                _KpiChip(label: 'Maximo', value: max?.toStringAsFixed(0) ?? '—'),
                                _KpiChip(label: 'Mín', value: min?.toStringAsFixed(0) ?? '—'),




                                _KpiChip(label: 'Hora', value: _fmtHoraLocal(ts)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _OcupacionBar(value: occ, color: color),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GradientButton(
                          text: 'Ver más',
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: navegar a detalle si lo necesitas
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _map.move(LatLng(l.lat, l.lon), 16);
                          },
                          icon: const Icon(Icons.navigation_outlined),
                          label: const Text('Ir'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ===== Estilos/Widgets auxiliares =====

class _GradientTitle extends StatelessWidget {
  final String text;
  const _GradientTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF0B6B68), Color(0xFF5F9CF7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF0B6B68)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
    );
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final bool up;
  const _KpiChip({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.up = true,
  });

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFF0B6B68);
    final emphColor = up ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: (emphasize ? emphColor : base).withOpacity(.35)),
        color: (emphasize ? emphColor : base).withOpacity(.06),
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 12, color: emphasize ? emphColor : base),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _OcupacionBar extends StatelessWidget {
  final double value;
  final Color color;
  const _OcupacionBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Ocupación', style: TextStyle(fontWeight: FontWeight.w600)),
          Text('${(value * 100).round()}%'),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: const Color(0x110B6B68),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B6B68), Color(0xFF5F9CF7)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: const Text(
            'Ver más',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
