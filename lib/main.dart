import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.init(); // carga token de SharedPreferences
  runApp(MigratioApp(auth: auth));
}

class MigratioApp extends StatelessWidget {
  final AuthService auth;
  const MigratioApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Migratio',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF4C6EF5),
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (_, a, __) => a.isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}
