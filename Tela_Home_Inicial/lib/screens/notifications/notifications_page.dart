import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Título da Página seguindo o estilo da sua Home
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Avisos", 
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const Text("Central de Alertas 🔔", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),

          // Lista de Avisos
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildNotificationItem(context, index, primaryColor),
                childCount: 3, // Quantidade de avisos fake
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index, Color primaryColor) {
    final avisos = [
      {"titulo": "Promoção Ativa!", "msg": "Corte + Barba com 20% OFF hoje."},
      {"titulo": "Lembrete", "msg": "Seu agendamento é daqui a 2 horas."},
      {"titulo": "Novidade", "msg": "Agora aceitamos pagamentos via PIX."},
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
                Text(avisos[index]["titulo"]!, 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(avisos[index]["msg"]!, 
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}