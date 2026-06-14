import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../history/history_page.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';

// TESTANDO PRRRRRRRRRRRRRRRRRRRRRR


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Lista de telas na ordem das abas da bottom bar
  final List<Widget> _screens = [
    const HomePage(),
    const HistoryPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 3. Mude de 'const HomePage()' para exibir a tela conforme o índice
          _screens[_currentIndex], 
          
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
    final Color activeColor = Theme.of(context).primaryColor;

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

// Transformamos a HomePage em um StatefulWidget para gerenciar o carregamento do nome
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "Carregando..."; 
  bool _isAdmin = false; // NOVA VARIÁVEL PARA O ADMIN

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Função que busca o nome e verifica se é admin no Firebase
  Future<void> _loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          var data = userDoc.data() as Map<String, dynamic>;
          String fullName = data['name'] ?? 'Cliente';
          String firstName = fullName.split(' ')[0];
          
          // Verifica se o campo isAdmin existe e é true
          bool isAdmin = data.containsKey('isAdmin') ? data['isAdmin'] : false;

          setState(() {
            _userName = firstName;
            _isAdmin = isAdmin;
          });
        } else {
          setState(() => _userName = "Cliente");
        }
      }
    } catch (e) {
      setState(() => _userName = "Cliente");
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Sair da conta", style: TextStyle(color: Colors.white)),
        content: const Text("Tem certeza que deseja desconectar da sua conta?", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text("SAIR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

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
                    children: [
                      const Text("Bem-vindo de volta,", style: TextStyle(color: Colors.white54)),
                      Text("$_userName 💈", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _logout,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // --- BOTÃO EXCLUSIVO DE ADMIN APARECE AQUI SE FOR TRUE ---
          if (_isAdmin)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: InkWell(
                  onTap: () {
                    // Futuramente criaremos a tela de Admin e colocaremos a rota aqui!
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Painel Admin em construção!")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.amber),
                        SizedBox(width: 10),
                        Text("ACESSAR PAINEL ADMIN", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: Column(
                children: [
                  Icon(Icons.content_cut, color: primaryColor, size: 40),
                  const SizedBox(height: 5),
                  const Text("BARBÚ", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 8, fontSize: 18)),
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
                gradient: LinearGradient(colors: [primaryColor.withAlpha(200), primaryColor]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PROMOÇÃO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Text("Corte + Barba\n20% OFF", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
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
                ServiceCard(label: "AGENDAR", icon: Icons.calendar_today_rounded, onTap: () {Navigator.pushNamed(context, '/booking');}),
                // Novos botões estratégicos:
                ServiceCard(label: "FIDELIDADE", icon: Icons.star_rounded, onTap: () {Navigator.pushNamed(context, '/loyalty');}),
                ServiceCard(label: "PRODUTOS", icon: Icons.shopping_bag_rounded, onTap: () {Navigator.pushNamed(context, '/products');}),
                ServiceCard(label: "CONTATO", icon: Icons.phone_android_rounded, onTap: () {Navigator.pushNamed(context, '/profile');}),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
    final primaryColor = Theme.of(context).primaryColor;

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
            color: _isPressed ? primaryColor : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isPressed ? Colors.white30 : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: _isPressed 
              ? [BoxShadow(color: primaryColor.withOpacity(0.5), blurRadius: 20, spreadRadius: -2)]
              : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon, 
                size: 45, 
                color: _isPressed ? Colors.white : primaryColor
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