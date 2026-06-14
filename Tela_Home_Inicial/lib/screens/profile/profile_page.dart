import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _userName = data['name'] ?? 'Cliente';
            _userEmail = user.email ?? '';
            _userPhone = data['phone'] ?? '';
          });
        } else {
          setState(() {
            _userName = user.displayName ?? 'Cliente';
            _userEmail = user.email ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Tem certeza que deseja desconectar da sua conta?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SAIR',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Cabeçalho ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Perfil',
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const Text('Minha Conta 👤',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ),

          // ── Card do Usuário ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.85),
                      primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white))
                    : Row(
                        children: [
                          // Avatar com inicial
                          CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                Colors.white.withOpacity(0.2),
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userEmail,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_userPhone.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _userPhone,
                                    style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Botão de editar (rascunho)
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Edição de perfil em breve!'),
                              ));
                            },
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white70),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // ── Próximos Agendamentos ───────────────────────────────────────────
          if (user != null) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: Text('Próximos Agendamentos',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('userId', isEqualTo: user.uid)
                      .where('status', isEqualTo: 'confirmado')
                      // orderBy removido: exigiria índice composto no Firestore.
                      // Ordenamos client-side abaixo.
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ));
                    }

                    // Erro real do Firestore (ex: regras de segurança)
                    if (snapshot.hasError) {
                      return _buildEmptyBookings(
                          msg: 'Erro ao carregar agendamentos.');
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return _buildEmptyBookings();
                    }

                    // Ordena por data+hora no lado do cliente
                    final docs = snapshot.data!.docs.toList()
                      ..sort((a, b) {
                        final dataA = a.data() as Map<String, dynamic>;
                        final dataB = b.data() as Map<String, dynamic>;
                        final dtA =
                            '${dataA['date'] ?? ''}T${dataA['time'] ?? ''}';
                        final dtB =
                            '${dataB['date'] ?? ''}T${dataB['time'] ?? ''}';
                        return dtA.compareTo(dtB);
                      });

                    // Pega só os 3 primeiros após ordenar
                    final upcoming = docs.take(3).toList();

                    return Column(
                      children: upcoming.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;
                        return _buildBookingCard(data);
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],

          // ── Ações do Perfil ─────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text('Configurações',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.history_rounded,
                    label: 'Ver Histórico de Cortes',
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text(
                            'Acesse a aba Histórico na barra inferior.'),
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildActionTile(
                    icon: Icons.notifications_none_rounded,
                    label: 'Minhas Notificações',
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text(
                            'Acesse a aba Avisos na barra inferior.'),
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Sair da Conta',
                    isDestructive: true,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ),

          // ── Informações da Barbearia ────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Text('A Barbearia',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    // Logo / Título
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: const Icon(
                                Icons.content_cut_rounded,
                                color: AppColors.primary,
                                size: 28),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('BARBÚ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 6,
                                      color: Colors.white)),
                              Text('Barbearia Premium',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                        color: Colors.white12, height: 1),

                    // Endereço
                    _buildInfoTile(
                      icon: Icons.location_on_rounded,
                      title: 'Endereço',
                      subtitle:
                          'Rua das Tesouras, 123 — Centro\nSua Cidade - SP, CEP 00000-000',
                      onTap: () => _launchUrl(
                          'https://maps.google.com/?q=Barbearia+Barbu'),
                    ),

                    const Divider(
                        color: Colors.white12, height: 1),

                    // Horário
                    _buildInfoTile(
                      icon: Icons.access_time_rounded,
                      title: 'Horário de Funcionamento',
                      subtitle:
                          'Seg – Sex: 09h às 19h\nSábado: 09h às 17h\nDomingo: Fechado',
                    ),

                    const Divider(
                        color: Colors.white12, height: 1),

                    // WhatsApp
                    _buildInfoTile(
                      icon: Icons.chat_rounded,
                      title: 'WhatsApp',
                      subtitle: '(11) 9 9999-9999',
                      onTap: () => _launchUrl(
                          'https://wa.me/5511999999999?text=Ol%C3%A1%2C%20vim%20pelo%20app%20Barb%C3%BA!'),
                    ),

                    const Divider(
                        color: Colors.white12, height: 1),

                    // Instagram
                    _buildInfoTile(
                      icon: Icons.photo_camera_rounded,
                      title: 'Instagram',
                      subtitle: '@barbu.barbearia',
                      onTap: () => _launchUrl(
                          'https://instagram.com/barbu.barbearia'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _buildEmptyBookings({String msg = 'Nenhum agendamento futuro.'}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              color: Colors.white24, size: 28),
          SizedBox(width: 14),
          Text(msg,
              style:
                  TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.content_cut_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['service'] ?? 'Serviço',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                  '${data['date'] ?? ''} às ${data['time'] ?? ''} — ${data['barber'] ?? ''}',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Confirmado',
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.primary : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDestructive
                ? AppColors.primary.withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          height: 1.5)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.open_in_new_rounded,
                  color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
