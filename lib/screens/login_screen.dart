import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'world_intro_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
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

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFF658EF2)],
                stops: [0.48, 1.0],
              ),
            ),
          ),

          // 📋 Contenido (form) centrado
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                       Center(
                         child: Image.asset('assets/migratio_logo.png', height: isSmall ? 70 : 200),
                       ),
                       const SizedBox(height: 10),

                      // 🏷️ Título grande con texto en degradé
                      GradientText(
                        'Migratio',
                        style: TextStyle(
                          fontSize: isSmall ? 44 : 56,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .5,
                          height: 1.3,
                          shadows: const [
                            Shadow(blurRadius: 16, offset: Offset(0, 6), color: Color(0x33000000)),
                          ],
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0B6B68), Color(0xFF5F9CF7)],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: isSmall ? 22 : 26,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B6B68),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 📦 Tarjeta del formulario
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
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                labelStyle: TextStyle(fontSize: 14),
                                hintText: 'tucorreo@usuario.cl',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pass,
                              obscureText: _obscure,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                            ),
                            const SizedBox(height: 16),

                            // 🔘 Botón con degradé
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _loading
                                    ? null
                                    : () async {
                                  if (!_form.currentState!.validate()) return;
                                  setState(() => _loading = true);
                                  try {
                                    // usa read aquí para evitar rebuilds innecesarios
                                    final auth = context.read<AuthService>();
                                    final result = await auth.signIn(_email.text.trim(), _pass.text);

                                    // si tu signIn devuelve bool, valida:
                                    // if (result != true) throw Exception('Credenciales inválidas');

                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const WorldIntroScreen()),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al iniciar sesión: $e')),
                                    );
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
                                      'Entrar',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                              ),
                              child: const Text('Crear cuenta'),
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
                          Text('Protegido · América/Santiago (GMT-3)', style: TextStyle(color: Color(0x990B6B68))),
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

/// Widget de texto con degradé reutilizable
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
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
