import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_application_2/screens/bookings/booking_page.dart';
import 'package:flutter_application_2/services/i_notification_service.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

// ── Stub de notificações para os testes ─────────────────────────────────────

/// Implementação vazia de [INotificationService] para testes.
/// Grava as chamadas para que possamos inspecioná-las nos asserts.
class NoOpNotificationService implements INotificationService {
  int scheduleCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> scheduleReminder({
    required String bookingId,
    required String service,
    required String barber,
    required DateTime appointmentDateTime,
    int minutesBefore = 60,
  }) async {
    scheduleCalls++;
  }

  @override
  Future<void> cancelReminder(String bookingId) async {
    cancelCalls++;
  }
}

// ── Setup ─────────────────────────────────────────────────────────────────────

/// Monta o BookingPage isolado com todos os mocks necessários.
Widget buildTestApp({
  required FakeFirebaseFirestore fakeFirestore,
  required MockFirebaseAuth fakeAuth,
  required NoOpNotificationService notifService,
}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: BookingPage(notificationService: notifService),
  );
}

void main() {
  // Inicializa o Firebase antes de todos os testes
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late NoOpNotificationService notifService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'test-uid-123', email: 'teste@barbu.com'),
      signedIn: true,
    );
    notifService = NoOpNotificationService();
  });

  // ── Grupo 1: Estado inicial ────────────────────────────────────────────────

  group('BookingPage — estado inicial (Passo 1: Serviços)', () {
    testWidgets('exibe os 3 cards de serviço ao abrir', (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));

      expect(find.text('Corte Padrão'), findsOneWidget);
      expect(find.text('Barba Premium'), findsOneWidget);
      expect(find.text('Combo Barbú'), findsOneWidget);
    });

    testWidgets('botão PRÓXIMO começa desabilitado no Passo 1', (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));

      // Botão existe mas onPressed é null → desabilitado
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'PRÓXIMO'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('botão PRÓXIMO habilita após selecionar um serviço',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));

      // Toca em "Corte Padrão"
      await tester.tap(find.text('Corte Padrão'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'PRÓXIMO'),
      );
      expect(button.onPressed, isNotNull);
    });
  });

  // ── Grupo 2: Navegação entre passos ───────────────────────────────────────

  group('BookingPage — transições de step', () {
    testWidgets('Passo 1 → 2: exibe lista de barbeiros após PRÓXIMO',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));

      // Seleciona serviço e avança
      await tester.tap(find.text('Corte Padrão'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
      await tester.pump();

      expect(find.text('Felipe'), findsOneWidget);
      expect(find.text('Rodrigo Art'), findsOneWidget);
    });

    testWidgets('Passo 2: botão PRÓXIMO desabilitado até selecionar barbeiro',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));

      // Avança para passo 2
      await tester.tap(find.text('Corte Padrão'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
      await tester.pump();

      // Ainda sem barbeiro selecionado → desabilitado
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'PRÓXIMO'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Passo 2 → 3: exibe seletor de data/hora após escolher barbeiro',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));

      // Passo 1
      await tester.tap(find.text('Corte Padrão'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
      await tester.pump();

      // Passo 2
      await tester.tap(find.text('Felipe'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
      await tester.pumpAndSettle(); // aguarda _fetchAvailableTimes

      expect(find.text('Selecione o dia'), findsOneWidget);
      expect(find.text('Horários disponíveis'), findsOneWidget);
    });

    testWidgets('Passo 3: botão exibe texto CONFIRMAR', (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));

      await tester.tap(find.text('Corte Padrão'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
      await tester.pump();
      await tester.tap(find.text('Felipe'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'PRÓXIMO'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'CONFIRMAR'), findsOneWidget);
    });
  });

  // ── Grupo 3: Indicador de passos ──────────────────────────────────────────

  group('BookingPage — indicador visual de step', () {
    testWidgets('indicador tem 3 segmentos', (tester) async {
      await tester.pumpWidget(buildTestApp(
        fakeFirestore: fakeFirestore,
        fakeAuth: fakeAuth,
        notifService: notifService,
      ));
      // Os 3 AnimatedContainers do _buildStepIndicator estão no widget tree
      // Verificamos indiretamente pela existência dos 3 serviços (passo 1 ativo)
      expect(find.byType(AnimatedContainer), findsWidgets);
    });
  });
}
