import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre   = TextEditingController();
  final _apellido = TextEditingController();
  final _email    = TextEditingController();
  final _pass     = TextEditingController();

  String _tipo = 'trabajador';
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const SizedBox.shrink(),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 🎨 Fondo con degradé
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFF658EF2)],
                stops: [0.48, 1.0],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo (opcional)
                      Center(
                        child: Image.asset('assets/migratio_logo.png',
                            height: isSmall ? 60 : 120),
                      ),
                      const SizedBox(height: 10),

                      // Título con gradiente
                      GradientText(
                        'Migratio',
                        style: TextStyle(
                          fontSize: isSmall ? 42 : 54,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .5,
                          height: 1.2,
                          shadows: const [
                            Shadow(blurRadius: 16, offset: Offset(0, 6), color: Color(0x33000000)),
                          ],
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Color(0xFF0B6B68), Color(0xFF5F9CF7)],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: isSmall ? 22 : 26,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B6B68),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tarjeta del formulario
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(color: Color(0x14000000), offset: Offset(0, 10), blurRadius: 26),
                          ],
                          border: Border.all(color: const Color(0x110B6B68)),
                        ),
                        child: Column(
                          children: [
                            // Nombre y Apellido
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nombre,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre',
                                      prefixIcon: Icon(Icons.person_outline),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _apellido,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Apellido',
                                      prefixIcon: Icon(Icons.person_2_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'tucorreo@usuario.cl',
                                prefixIcon: Icon(Icons.alternate_email),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                              (v == null || !v.contains('@')) ? 'Email inválido' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pass,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6' : null,
                            ),
                            const SizedBox(height: 12),

                            const SizedBox(height: 16),

                            // Botón con gradiente
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _loading
                                    ? null
                                    : () async {
                                  if (!_form.currentState!.validate()) return;
                                  setState(() => _loading = true);
                                  try {
                                    await auth.signUp({
                                      'nombre'       : _nombre.text.trim(),
                                      'apellido'     : _apellido.text.trim(),
                                      'email'        : _email.text.trim(),
                                      'password'     : _pass.text,
                                      'tipo_usuario' : _tipo,
                                    });
                                    if (context.mounted) Navigator.pop(context); // volver al login o Home
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _loading = false);
                                  }
                                },
                                style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                                  backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                                  elevation: const WidgetStatePropertyAll(0),
                                  overlayColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.06)),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0B6B68), Color(0xFF5F9CF7)],
                                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(
                                      height: 22, width: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                    )
                                        : const Text(
                                      'Crear y entrar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shield_outlined, size: 18, color: Color(0x990B6B68)),
                          SizedBox(width: 8),
                          Text('Protegido · América/Santiago (GMT-3)',
                              style: TextStyle(color: Color(0x990B6B68))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText(
      this.text, {
        super.key,
        this.style,
        required this.gradient,
      });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }
}
