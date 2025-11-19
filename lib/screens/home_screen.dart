import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final tipo = auth.user?['tipo_usuario'] ?? 'turista';
    final nombre = auth.user?['nombre'] ?? 'John';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x658EF2), Color(0xFFFFFFFF), Color(0xFF658EF2)],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Color(0x658EF2),
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Salir',
                onPressed: () => auth.signOut(),
                icon: const Icon(Icons.logout),
              ),
            ],
            bottom: const TabBar(
              indicatorWeight: 3,
              tabs: [
                Tab(icon: Icon(Icons.map_outlined), text: 'Mapa'),
                Tab(icon: Icon(Icons.person_outline), text: 'Perfil'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              SafeArea(child: MapScreen()),
              SafeArea(child: ProfileScreen()),
            ],
          ),
        ),
      ),
    );
  }
}
