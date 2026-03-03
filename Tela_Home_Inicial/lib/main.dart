import 'package:flutter/material.dart';

void main() => runApp(const BarbeariaPremiumApp());

class BarbeariaPremiumApp extends StatelessWidget {
  const BarbeariaPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD32F2F),
        splashFactory: InkRipple.splashFactory, 
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: 450, 
            child: const MainNavigation(),
          ),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      // Stack para garantir que o corpo ocupe tudo e o rodapé flutue ou fique na base
      body: Stack(
        children: [
          const HomePage(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCustomBottomBar(),
          ),
        ],
      ),
    );
  }

  // Rodapé Customizado com o mesmo estilo dos ServiceCards
  Widget _buildCustomBottomBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_filled,
            label: 'Início',
            isSelected: _currentIndex == 0,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          _NavBarItem(
            icon: Icons.history,
            label: 'Histórico',
            isSelected: _currentIndex == 1,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          _NavBarItem(
            icon: Icons.notifications_none,
            label: 'Avisos',
            isSelected: _currentIndex == 2,
            onTap: () => setState(() => _currentIndex = 2),
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            isSelected: _currentIndex == 3,
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ],
      ),
    );
  }
}

// Widget de item do rodapé com a mesma fluidez do ServiceCard
class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFD32F2F);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : (widget.isSelected ? 1.05 : 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.isSelected ? activeColor : Colors.white38,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                color: widget.isSelected ? activeColor : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Bem-vindo de volta,", style: TextStyle(color: Colors.white54)),
                      Text("João Silva 💈", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFD32F2F),
                    child: Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: const [
                  Icon(Icons.content_cut, color: Color(0xFFD32F2F), size: 40),
                  SizedBox(height: 5),
                  Text("BARBÚ", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 8, fontSize: 18)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFEF5350)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PROMOÇÃO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const Text("Corte + Barba\n20% OFF", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Resgatar Agora"),
                  )
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 30, 24, 15),
              child: Text("Nossos Serviços", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ServiceCard(label: "AGENDAR", icon: Icons.calendar_today_rounded, onTap: () {}),
                ServiceCard(label: "BARBEIROS", icon: Icons.content_cut_rounded, onTap: () {}),
                ServiceCard(label: "GALERIA", icon: Icons.photo_library_rounded, onTap: () {}),
                ServiceCard(label: "CONTATO", icon: Icons.phone_android_rounded, onTap: () {}),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Espaço para não cobrir o rodapé
        ],
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.label, required this.icon, required this.onTap});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFFD32F2F) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isPressed ? Colors.white30 : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: _isPressed 
              ? [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.5), blurRadius: 20, spreadRadius: -2)]
              : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon, 
                size: 45, 
                color: _isPressed ? Colors.white : const Color(0xFFD32F2F)
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isPressed ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}