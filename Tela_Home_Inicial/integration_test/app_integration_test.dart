import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart'; 
import 'package:flutter_application_2/main.dart' as app;  

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Suíte de Testes de Integração End-to-End (E2E) — App BARBÚ', () {
    
    testWidgets('Deve executar a jornada do cliente de ponta a ponta: do Login ao Agendamento bem-sucedido', 
    (WidgetTester tester) async {
      
      // 1. SETUP: Inicializa o aplicativo
      app.main();
      
      // Aguarda 4 segundos para a SplashScreen sair da tela e depois estabiliza
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // ===========================================================================
      // ETAPA 1: FLUXO REAL DE AUTENTICAÇÃO (LOGIN)
      // ===========================================================================
      // O aplicativo utiliza TextField
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;
      
      // Procura pelo texto exato do botão de login
      final loginButton = find.text('ENTRAR');

      // Simula a digitação
      await tester.enterText(emailField, 'teste@gmail.com');
      await tester.enterText(passwordField, 'teste123');
      await tester.pumpAndSettle(); 

      // Clica para logar
      await tester.tap(loginButton);
      // Aguarda o Firebase Auth responder e navegar para a Home
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(); 

      // ===========================================================================
      // ETAPA 2: NAVEGAÇÃO DA HOME PARA O AGENDAMENTO
      // ===========================================================================
      // Na Home, procuramos o ServiceCard com o texto 'AGENDAR'
      final scheduleButton = find.text('AGENDAR');
      expect(scheduleButton, findsOneWidget); 
      
      await tester.tap(scheduleButton);
      await tester.pumpAndSettle();

      // ===========================================================================
      // ETAPA 3: WIZARD PASSO 0 — SELEÇÃO DE SERVIÇO
      // ===========================================================================
      final serviceCard = find.text('Corte Padrão');
      expect(serviceCard, findsOneWidget);
      
      await tester.tap(serviceCard);
      await tester.pumpAndSettle();

      // O botão do seu app está em maiúsculo
      final nextButton = find.text('PRÓXIMO');
      await tester.tap(nextButton);
      await tester.pumpAndSettle(); 

      // ===========================================================================
      // ETAPA 4: WIZARD PASSO 1 — SELEÇÃO DE BARBEIRO
      // ===========================================================================
      final barberCard = find.text('Felipe');
      expect(barberCard, findsOneWidget);
      
      await tester.tap(barberCard);
      await tester.pumpAndSettle();

      await tester.tap(find.text('PRÓXIMO'));
      await tester.pumpAndSettle(); 

      // ===========================================================================
      // ETAPA 5: WIZARD PASSO 2 — SELEÇÃO DE HORÁRIO E GRAVAÇÃO FINAL
      // ===========================================================================
      // Aguarda um instante extra pois o app busca horários no Firestore
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Escolhe o horário das 10:00 da manhã
      final timeSlot = find.text('10:00');
      // Dica: Se esse teste falhar aqui no futuro, pode ser porque as 10:00 
      // já foram agendadas no Firebase e o botão não apareceu na tela.
      expect(timeSlot, findsOneWidget);
      
      await tester.tap(timeSlot);
      await tester.pumpAndSettle();

      // O botão muda para 'CONFIRMAR'
      final confirmButton = find.text('CONFIRMAR');
      expect(confirmButton, findsOneWidget);

      await tester.tap(confirmButton);
      // Aguarda a gravação no banco de dados
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // ===========================================================================
      // VALIDAÇÃO FINAL (ASSERT CENTRAL DE INTEGRAÇÃO)
      // ===========================================================================
      // Valida o título do pop-up de sucesso que existe no código
      expect(find.text('Agendado!'), findsOneWidget);
    });
  });
}