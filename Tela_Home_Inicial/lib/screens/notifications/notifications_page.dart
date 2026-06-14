import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<void> _sendTestNotification(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Tipos para variar a cada toque
    final types = [
      {
        'type': 'booking',
        'titulo': 'Agendamento Confirmado! ✂️',
        'msg': 'Corte Padrão com Felipe em ${DateTime.now().day}/${DateTime.now().month} às 10:00.',
      },
      {
        'type': 'promo',
        'titulo': 'Promoção Especial 🔥',
        'msg': 'Hoje: Combo Barbú (Corte + Barba) com 20% de desconto!',
      },
      {
        'type': 'info',
        'titulo': 'Lembrete 📅',
        'msg': 'Seu agendamento é daqui a 2 horas. Não se atrase!',
      },
    ];

    // Escolhe um tipo aleatório baseado no segundo atual
    final picked = types[DateTime.now().second % types.length];

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .add({
      ...picked,
      'lida': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notificação "${picked['titulo']}" criada!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
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
          // ── Título ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avisos',
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                        ),
                        const Text(
                          'Central de Alertas 🔔',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // ── Botão de demonstração ──────────────────────────────────
                  if (user != null)
                    Tooltip(
                      message: 'Gerar notificação de teste',
                      child: GestureDetector(
                        onTap: () => _sendTestNotification(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add_alert_rounded,
                                  color: AppColors.primary, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Testar',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Lista de notificações reais do Firestore ──────────────────────
          if (user != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(user.uid)
                      .collection('items')
                      .orderBy('createdAt', descending: true)
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Carregando
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      );
                    }

                    // Sem dados
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Lista de notificações
                    final docs = snapshot.data!.docs;
                    return Column(
                      children: docs.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;
                        return _buildNotificationCard(
                            context, data, primaryColor);
                      }).toList(),
                    );
                  },
                ),
              ),
            )
          else
            // Usuário não logado — exibe avisos genéricos estáticos
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildStaticItem(context, index, primaryColor),
                  childCount: 3,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_none_rounded,
              color: Colors.white24, size: 48),
          SizedBox(height: 12),
          Text(
            'Nenhuma notificação ainda.',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          Text(
            'Você verá aqui confirmações de agendamento e avisos da barbearia.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white30, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, Map<String, dynamic> data, Color primaryColor) {
    final type = data['type'] as String? ?? 'info';
    final titulo = data['titulo'] as String? ?? 'Notificação';
    final msg = data['msg'] as String? ?? '';
    final lida = data['lida'] as bool? ?? false;

    final IconData icon;
    final Color iconColor;

    switch (type) {
      case 'booking':
        icon = Icons.calendar_today_rounded;
        iconColor = Colors.greenAccent;
        break;
      case 'promo':
        icon = Icons.local_offer_rounded;
        iconColor = Colors.amberAccent;
        break;
      default:
        icon = Icons.stars_rounded;
        iconColor = primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lida
            ? AppColors.cardBackground
            : AppColors.cardBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: lida
              ? Colors.white.withOpacity(0.05)
              : iconColor.withOpacity(0.25),
          width: lida ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: lida ? Colors.white70 : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (!lida)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  msg,
                  style: TextStyle(
                    color: lida ? Colors.white38 : Colors.white54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Avisos estáticos de fallback (usuário não logado)
  Widget _buildStaticItem(
      BuildContext context, int index, Color primaryColor) {
    final avisos = [
      {'titulo': 'Promoção Ativa!', 'msg': 'Corte + Barba com 20% OFF hoje.'},
      {'titulo': 'Lembrete', 'msg': 'Seu agendamento é daqui a 2 horas.'},
      {'titulo': 'Novidade', 'msg': 'Agora aceitamos pagamentos via PIX.'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: primaryColor, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(avisos[index]['titulo']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(avisos[index]['msg']!,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}