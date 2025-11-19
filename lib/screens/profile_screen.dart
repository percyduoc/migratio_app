import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _email = TextEditingController();
  final _descripcion = TextEditingController();

  String _tipo = 'trabajador';
  bool _loading = false;

  // Experiencia (puedes mapear esto desde tu backend si ya lo tienes)
  int _nivel = 1;
  double _xp = 20;       // XP actual
  double _xpToNext = 100; // XP necesario para subir de nivel

  // Países visitados (por ahora solo Chile)
  final List<_Pais> _paises = [const _Pais('Chile', '🇨🇱')];

  Image? _pigeon;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    final u = auth.user ?? {};
    _nombre.text = (u['nombre'] ?? '') as String;
    _apellido.text = (u['apellido'] ?? '') as String;
    _email.text = (u['email'] ?? '') as String;
    _tipo = (u['tipo_usuario'] ?? _tipo) as String;
    _descripcion.text = (u['descripcion'] ?? '') as String;

    // Opcional: si tienes estos campos en backend, úsalo:
    // _nivel = (u['nivel'] as int?) ?? _nivel;
    // _xp = (u['xp'] as num?)?.toDouble() ?? _xp;
    // _xpToNext = (u['xp_to_next'] as num?)?.toDouble() ?? _xpToNext;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pigeon ??= Image.asset('assets/pigeon_3.png');
    precacheImage(_pigeon!.image, context);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _email.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  double get _xpProgress =>
      _xpToNext <= 0 ? 0 : (_xp / _xpToNext).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // HEADER (sin TabBar adentro)
          Container(
            height: 180, // si aún ves clipping, sube a 196-200
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B6B68), Color(0xFF5F9CF7)],
                begin: Alignment.centerLeft, end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              bottom: false, // <- clave: no agregar padding inferior
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/pigeon_3.png',
                        width: 80, height: 80, fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Mi Perfil',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),

          // TABBAR (afuera del header y con Material)
          const Material(
            color: Colors.transparent,
            child: TabBar(
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(icon: Icon(Icons.person_outline), text: 'Perfil'),
                Tab(icon: Icon(Icons.image_outlined), text: 'Pigeon'),
              ],
            ),
          ),

          // Contenido de tabs
          Expanded(
            child: TabBarView(
              children: [
                // ---------- TAB 1: PERFIL ----------
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      // Card: Experiencia
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _CardTitle(
                              icon: Icons.stars_outlined,
                              title: 'Experiencia',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Nivel $_nivel',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text('${_xp.toStringAsFixed(0)} / ${_xpToNext.toStringAsFixed(0)} XP'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _xpProgress,
                                minHeight: 10,
                                backgroundColor: const Color(0x110B6B68),
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF0B6B68),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card: Descripción
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _CardTitle(
                              icon: Icons.description_outlined,
                              title: 'Descripción',
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _descripcion,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Cuéntanos algo sobre ti…',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card: Países visitados
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _CardTitle(
                              icon: Icons.public_outlined,
                              title: 'Países visitados',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _paises
                                  .map((p) => _FlagChip(flag: p.flag, name: p.name))
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Siempre podemos conoser mas.',
                              style: TextStyle(
                                color: Colors.black.withOpacity(.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card: Datos y formulario (nombre, apellido, email, tipo)
                      _Card(
                        child: Form(
                          key: _form,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nombre,
                                      decoration: const InputDecoration(
                                        labelText: 'Nombre',
                                        prefixIcon: Icon(Icons.person_outline),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Requerido'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _apellido,
                                      decoration: const InputDecoration(
                                        labelText: 'Apellido',
                                        prefixIcon:
                                        Icon(Icons.person_2_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Requerido'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _email,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.alternate_email),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),

                              const SizedBox(height: 16),

                              // Guardar cambios
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                    if (!_form.currentState!.validate()) {
                                      return;
                                    }
                                    setState(() => _loading = true);
                                    try {
                                      // Serializa países (simple). Si tu backend acepta arrays, envía la lista.
                                      final paisesCsv = _paises
                                          .map((e) => e.name)
                                          .join(',');

                                      await auth.updateProfile({
                                        'nombre': _nombre.text.trim(),
                                        'apellido':
                                        _apellido.text.trim(),
                                        'tipo_usuario': _tipo,
                                        'descripcion':
                                        _descripcion.text.trim(),
                                        'paises_visitados': paisesCsv,
                                        // Opcional si tu backend lo soporta:
                                        // 'nivel': _nivel,
                                        // 'xp': _xp,
                                        // 'xp_to_next': _xpToNext,
                                      });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Perfil actualizado')));
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                            content:
                                            Text('Error: $e')));
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _loading = false);
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                    padding: const WidgetStatePropertyAll(
                                        EdgeInsets.zero),
                                    elevation:
                                    const WidgetStatePropertyAll(0),
                                    backgroundColor:
                                    const WidgetStatePropertyAll(
                                        Colors.transparent),
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF0B6B68),
                                          Color(0xFF5F9CF7)
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child:
                                        CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                          : const Text(
                                        'Guardar cambios',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                            FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- TAB 2: SOLO PIGEON ----------
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/pigeon_3.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Widgets auxiliares ==========

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 10))
        ],
        border: Border.all(color: const Color(0x110B6B68)),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _CardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0B6B68)),
        const SizedBox(width: 8),
        Text(title,
            style:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String flag;
  final String name;
  const _FlagChip({required this.flag, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x330B6B68)),
        color: const Color(0x0F0B6B68),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Pais {
  final String name;
  final String flag; // Usa emojis por simplicidad (🇨🇱). Luego puedes migrar a assets/banderas.
  const _Pais(this.name, this.flag);
}
