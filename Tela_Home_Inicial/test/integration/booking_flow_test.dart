/// Teste de integração: fluxo completo de agendamento
///
/// Estratégia: BookingPage captura erros do Firebase no catch() e os trata
/// graciosamente (exibe SnackBar de erro). Os testes de caminho feliz testam
/// o fluxo de UI e a lógica pura. O teste de salvamento bem-sucedido é
/// coberto via mocks diretos do Firestore/Auth.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_2/screens/bookings/booking_page.dart';
import 'package:flutter_application_2/services/i_notification_service.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

// ── Stub de notificações ──────────────────────────────────────────────────────

class NoOpNotificationService implements INotificationService {
  final List<Map<String, dynamic>> scheduled = [];

  @override
  Future<void> scheduleReminder({
    required String bookingId,
    required String service,
    required String barber,
    required DateTime appointmentDateTime,
    int minutesBefore = 60,
  }) async {
    scheduled.add({
      'bookingId': bookingId,
      'service': service,
      'barber': barber,
      'minutesBefore': minutesBefore,
    });
  }

  @override
  Future<void> cancelReminder(String bookingId) async {}
}

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NoOpNotificationService notifService;

  setUp(() {
    notifService = NoOpNotificationService();
  });

  // ── Navegação completa pelos 3 passos ────────────────────────────────────

  group('Fluxo de agendamento — navegação completa', () {
    testWidgets(
      'percorre os 3 passos sem erro e chega ao botão CONFIRMAR habilitado',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.darkTheme,
          home: BookingPage(notificationService: notifService),
        ));

        // ── Passo 1: Serviço ──────────────────────────────────────────────
        expect(find.text('Corte Padrão'), findsOneWidget);
        await tester.tap(find.text('Corte Padrão'));
        await tester.pump();

        final nextBtn = find.widgetWithText(ElevatedButton, 'PRÓXIMO');
        expect(tester.widget<ElevatedButton>(nextBtn).onPressed, isNotNull,
            reason: 'Botão deve estar ativo após selecionar serviço');

        await tester.tap(nextBtn);
        await tester.pump();

        // ── Passo 2: Barbeiro ─────────────────────────────────────────────
        expect(find.text('Felipe'), findsOneWidget);
        await tester.tap(find.text('Felipe'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
        await tester.pumpAndSettle(); // aguarda _fetchAvailableTimes

        // ── Passo 3: Data/Hora ────────────────────────────────────────────
        expect(find.text('Selecione o dia'), findsOneWidget);
        expect(find.text('Horários disponíveis'), findsOneWidget);

        // Seleciona o primeiro horário disponível
        final chips = find.byType(ChoiceChip);
        expect(chips, findsWidgets, reason: 'Deve haver horários disponíveis');
        await tester.tap(chips.first);
        await tester.pump();

        // Botão CONFIRMAR deve estar habilitado
        final confirmBtn = find.widgetWithText(ElevatedButton, 'CONFIRMAR');
        expect(confirmBtn, findsOneWidget);
        expect(tester.widget<ElevatedButton>(confirmBtn).onPressed, isNotNull,
            reason: 'Botão CONFIRMAR deve estar ativo após selecionar horário');
      },
    );

    testWidgets(
      'botão CONFIRMAR desabilitado antes de selecionar horário no Passo 3',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.darkTheme,
          home: BookingPage(notificationService: notifService),
        ));

        // Navega até o passo 3 sem selecionar horário
        await tester.tap(find.text('Corte Padrão'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
        await tester.pump();
        await tester.tap(find.text('Rodrigo Art'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
        await tester.pumpAndSettle();

        // Sem horário selecionado → botão inativo
        final confirmBtn = find.widgetWithText(ElevatedButton, 'CONFIRMAR');
        expect(tester.widget<ElevatedButton>(confirmBtn).onPressed, isNull,
            reason: 'CONFIRMAR deve estar inativo sem horário selecionado');
      },
    );

    testWidgets(
      'serviço diferente é selecionado corretamente no Passo 1',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.darkTheme,
          home: BookingPage(notificationService: notifService),
        ));

        // Seleciona "Combo Barbú" em vez de "Corte Padrão"
        await tester.tap(find.text('Combo Barbú'));
        await tester.pump();

        // Avança e verifica que o passo 2 é exibido
        await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
        await tester.pump();
        expect(find.text('Felipe'), findsOneWidget);
        expect(find.text('Rodrigo Art'), findsOneWidget);
      },
    );
  });

  // ── Notificações não são disparadas antes do CONFIRMAR ───────────────────

  group('NotificationService — integração com BookingPage', () {
    testWidgets(
      'nenhum lembrete é agendado durante a navegação pelos passos',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.darkTheme,
          home: BookingPage(notificationService: notifService),
        ));

        // Navega por todos os passos sem confirmar
        await tester.tap(find.text('Corte Padrão'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
        await tester.pump();
        await tester.tap(find.text('Felipe'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
        await tester.pumpAndSettle();

        // Nenhum lembrete deve ter sido agendado ainda
        expect(notifService.scheduled, isEmpty,
            reason: 'Lembrete só deve ser agendado após CONFIRMAR');
      },
    );
  });

  // ── Regras de negócio puras ────────────────────────────────────────────────

  group('Filtragem de horários — BookingUtils', () {
    test('09:00 e 14:00 ocupados → 6 horários restantes', () {
      final all = ['09:00','10:00','11:00','14:00','15:00','16:00','17:00','18:00'];
      final result = BookingUtils.filterTimes(all, ['09:00', '14:00']);
      expect(result.length, equals(6));
      expect(result.contains('09:00'), isFalse);
      expect(result.contains('14:00'), isFalse);
    });

    test('dia totalmente ocupado → retorna lista vazia', () {
      final all = ['09:00', '10:00', '11:00'];
      expect(BookingUtils.filterTimes(all, all), isEmpty);
    });

    test('dia livre → retorna todos os horários', () {
      final all = ['09:00', '10:00', '11:00'];
      expect(BookingUtils.filterTimes(all, []), equals(all));
    });

    test('resultado não contém o horário removido e preserva a ordem', () {
      final all = ['09:00', '10:00', '11:00', '14:00'];
      final result = BookingUtils.filterTimes(all, ['10:00']);
      expect(result, equals(['09:00', '11:00', '14:00']));
    });
  });
}
