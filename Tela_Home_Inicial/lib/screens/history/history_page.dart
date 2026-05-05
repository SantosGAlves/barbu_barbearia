import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _cancelBooking(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(docId)
          .update({'status': 'cancelado'});
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Agendamento cancelado com sucesso.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao cancelar."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("Meu Histórico", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user?.uid)
            // Se já tiver criado o índice no Firebase, pode voltar o orderBy aqui
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Erro ao carregar dados"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Você ainda não tem agendamentos.", style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String status = data['status'] ?? 'confirmado';

              // MÁGICA DO TEMPO AQUI:
              try {
                // Junta a data e hora (Ex: "2026-05-05 14:00:00")
                DateTime appointmentDate = DateTime.parse("${data['date']} ${data['time']}:00");
                
                // Se a data já passou e não foi cancelado, vira concluído visualmente
                if (appointmentDate.isBefore(DateTime.now()) && status == 'confirmado') {
                  status = 'concluido';
                }
              } catch (e) {
                // Se der erro ao ler a data, ignora e segue a vida
              }

              bool isCancelable = status == 'confirmado';

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['service'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text("Barbeiro: ${data['barber']}", style: const TextStyle(color: Colors.white54)),
                          ],
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 25),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.white38),
                        const SizedBox(width: 8),
                        Text(data['date'], style: const TextStyle(color: Colors.white38)),
                        const SizedBox(width: 20),
                        const Icon(Icons.access_time, size: 16, color: Colors.white38),
                        const SizedBox(width: 8),
                        Text(data['time'], style: const TextStyle(color: Colors.white38)),
                      ],
                    ),
                    if (isCancelable) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _cancelBooking(context, doc.id),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            foregroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("CANCELAR AGENDAMENTO"),
                        ),
                      ),
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'confirmado':
        color = Colors.blue;
        label = "AGENDADO";
        break;
      case 'cancelado':
        color = Colors.red;
        label = "CANCELADO";
        break;
      case 'concluido':
        color = Colors.green;
        label = "CONCLUÍDO";
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}