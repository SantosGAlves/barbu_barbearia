import 'package:flutter/material.dart';
// Imports necessários para o Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/service_model.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _currentStep = 0;
  String? _selectedService;
  String? _selectedBarber;
  String? _selectedTime;
  int _selectedDayIndex = 0;

  // Variáveis de estado para carregamento e controle de banco de dados
  bool _isLoadingTimes = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _services = BarberDataService.getServices();
  // Se quiser garantir apenas 2 barbeiros, você pode editar o service_model.dart, 
  // ou definir a lista direto aqui: ['Felipe', 'Rodrigo Art']
  final List<String> _barbers = BarberDataService.getBarbers();
  
  // Todos os horários de funcionamento da barbearia
  final List<String> _allTimes = BarberDataService.getAvailableTimes();
  // Horários que sobrarão após consultarmos o banco
  List<String> _availableTimes = [];

  // Função que busca no Firebase os horários já agendados
  Future<void> _fetchAvailableTimes() async {
    if (_selectedBarber == null) return;

    setState(() {
      _isLoadingTimes = true;
      _selectedTime = null; // Reseta o horário selecionado
    });

    // Formata a data escolhida para um formato padrão (ex: 2026-04-28)
    DateTime date = DateTime.now().add(Duration(days: _selectedDayIndex));
    String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      // Vai no banco e busca agendamentos do barbeiro escolhido naquele dia
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('barber', isEqualTo: _selectedBarber)
          .where('date', isEqualTo: dateString)
          .get();

      // Extrai os horários que já estão ocupados
      List<String> bookedTimes = snapshot.docs.map((doc) => doc['time'] as String).toList();

      setState(() {
        // Filtra a lista completa, mantendo apenas os horários que NÃO estão no banco
        _availableTimes = _allTimes.where((time) => !bookedTimes.contains(time)).toList();
      });
    } catch (e) {
      debugPrint("Erro ao buscar horários: $e");
      // Em caso de erro, libera tudo por garantia (ou você pode bloquear tudo)
      setState(() => _availableTimes = List.from(_allTimes));
    } finally {
      setState(() => _isLoadingTimes = false);
    }
  }

  // Função para salvar o agendamento final no Firebase
  Future<void> _saveBooking() async {
    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      DateTime date = DateTime.now().add(Duration(days: _selectedDayIndex));
      String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Salva na coleção 'bookings'
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user?.uid,
        'service': _selectedService,
        'barber': _selectedBarber,
        'date': dateString,
        'time': _selectedTime,
        'status': 'confirmado',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
    } catch (e) {
      debugPrint("Erro ao salvar agendamento: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao agendar. Tente novamente."), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text("Reserva", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
        ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStepContent(),
          )),
          _buildBottomControl(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildServiceSelection();
      case 1: return _buildBarberSelection();
      case 2: return _buildDateTimeSelection();
      default: return const SizedBox();
    }
  }

  // PASSO 1: SERVIÇOS 
  Widget _buildServiceSelection() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final s = _services[index];
        bool isSelected = _selectedService == s['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedService = s['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Colors.white30 : Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(s['icon'], color: isSelected ? Colors.white : const Color(0xFFD32F2F), size: 30),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(s['price'], style: TextStyle(color: isSelected ? Colors.white70 : Colors.white38)),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Colors.white)
              ],
            ),
          ),
        );
      },
    );
  }

  // PASSO 2: BARBEIROS
  Widget _buildBarberSelection() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _barbers.length,
      itemBuilder: (context, index) {
        final b = _barbers[index];
        bool isSelected = _selectedBarber == b;
        return GestureDetector(
          onTap: () => setState(() => _selectedBarber = b),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? const Color(0xFFD32F2F) : Colors.transparent, width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFFD32F2F), child: Text(b[0], style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 15),
                Text(b, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (isSelected) const Icon(Icons.radio_button_checked, color: Color(0xFFD32F2F))
                else const Icon(Icons.radio_button_off, color: Colors.white10),
              ],
            ),
          ),
        );
      },
    );
  }

  // PASSO 3: CALENDÁRIO E HORÁRIOS
  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Selecione o dia", style: TextStyle(fontSize: 16, color: Colors.white54)),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: 14,
            itemBuilder: (context, index) {
              DateTime date = DateTime.now().add(Duration(days: index));
              bool isSelected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDayIndex = index);
                  // Sempre que trocar o dia, busca os horários livres daquele dia
                  _fetchAvailableTimes();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${date.day}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"][date.weekday % 7],
                        style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white38)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 15),
          child: Text("Horários disponíveis", style: TextStyle(fontSize: 16, color: Colors.white54)),
        ),
        
        // Verifica se está carregando do banco
        _isLoadingTimes 
          ? const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F))))
          : _availableTimes.isEmpty 
            ? const Expanded(child: Center(child: Text("Nenhum horário livre neste dia 😕", style: TextStyle(color: Colors.white54))))
            : Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: _availableTimes.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedTime == _availableTimes[index];
                    return ChoiceChip(
                      label: Text(_availableTimes[index]),
                      selected: isSelected,
                      selectedColor: const Color(0xFFD32F2F),
                      backgroundColor: const Color(0xFF1A1A1A),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                      onSelected: (val) => setState(() => _selectedTime = _availableTimes[index]),
                    );
                  },
                ),
              )
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: _currentStep == index ? 50 : 30,
          decoration: BoxDecoration(
            color: _currentStep >= index ? const Color(0xFFD32F2F) : Colors.white10,
            borderRadius: BorderRadius.circular(2),
          ),
        )),
      ),
    );
  }

  Widget _buildBottomControl() {
    bool canGoNext = (_currentStep == 0 && _selectedService != null) ||
                     (_currentStep == 1 && _selectedBarber != null) ||
                     (_currentStep == 2 && _selectedTime != null);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canGoNext ? const Color(0xFFD32F2F) : Colors.white10,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: canGoNext 
          ? _isSaving ? null : () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
                // Se acabou de entrar na tela de datas (Passo 3), carrega os horários
                if (_currentStep == 2) {
                  _fetchAvailableTimes();
                }
              } else {
                _saveBooking(); // Finaliza e Salva
              }
            } 
          : null,
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(_currentStep == 2 ? "CONFIRMAR" : "PRÓXIMO", 
              style: TextStyle(color: canGoNext ? Colors.white : Colors.white24)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Força o usuário a clicar no botão para voltar
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFFD32F2F), size: 80),
            const SizedBox(height: 20),
            const Text("Agendado!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text("Seu horário com $_selectedBarber foi reservado com sucesso.", 
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
              child: const Text(style: TextStyle(color: Colors.white),"Voltar para Início"),
            )
          ],
        ),
      ),
    );
  }
}