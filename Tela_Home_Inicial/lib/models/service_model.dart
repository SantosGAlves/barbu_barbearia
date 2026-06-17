import 'package:flutter/material.dart';

class BarberDataService {
  List<Map<String, dynamic>> getServices() {
    return [
      {'name': 'Corte Padrão', 'price': 'R\$ 45,00', 'icon': Icons.content_cut},
      {'name': 'Barba Premium', 'price': 'R\$ 35,00', 'icon': Icons.face},
      {'name': 'Combo Barbú', 'price': 'R\$ 70,00', 'icon': Icons.star},
    ];
  }

  List<String> getBarbers() {
    return ['Felipe', 'Rodrigo Art'];
  }

  List<String> getAvailableTimes() {
    return ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00', '18:00'];
  }
}