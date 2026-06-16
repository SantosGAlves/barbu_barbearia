import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart'; // Framework nativo de Integração
import 'package:flutter_application_2/main.dart' as app;  // Importa o arquivo principal do BARBÚ

void main() {
  // REQUISITO DO VÍDEO: Garante que todo o ecossistema do Flutter e do emulador carreguem antes de iniciar
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Suíte de Testes de Integração End-to-End (E2E) — App BARBÚ', () {
    
    testWidgets('Deve executar a jornada do cliente de ponta a ponta: do Login ao Agendamento bem-sucedido', 
    (WidgetTester tester) async {
      
      // 1. SETUP: Inicializa e abre o aplicativo real direto no emulador executando o main() original
      app.main();
      
      // REQUISITO DO VÍDEO: Aguarda todas as animações e o splash screen carregarem por completo
      await tester.pumpAndSettle();

      // ===========================================================================
      // ETAPA 1: FLUXO REAL DE AUTENTICAÇÃO (LOGIN)
      // ===========================================================================
      // Localiza as caixas de texto de email, senha e botão com base nos elementos da tela
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');

      // Simula o usuário digitando as credenciais no teclado do aparelho virtual
      await tester.enterText(emailField, 'cliente_teste@barbu.com');
      await tester.enterText(passwordField, '123456');
      await tester.pumpAndSettle(); // Renderiza a digitação

      // Clica no botão de entrar para processar a autenticação com o Firebase Auth
      await tester.tap(loginButton);
      await tester.pumpAndSettle(); // Aguarda a troca de tela para a HomePage

      // ===========================================================================
      // ETAPA 2: NAVEGAÇÃO DA HOME PARA O AGENDAMENTO
      // ===========================================================================
      // Verifica se o usuário chegou na Home com sucesso procurando pelo botão de agendar
      final scheduleButton = find.widgetWithText(ElevatedButton, 'Agendar Horário');
      expect(scheduleButton, findsOneWidget); // Assert: Garante que logou e mudou de tela
      
      // Clica para abrir a tela de agendamento (BookingPage Wizard)
      await tester.tap(scheduleButton);
      await tester.pumpAndSettle();

      // ===========================================================================
      // ETAPA 3: WIZARD PASSO 0 — SELEÇÃO DE SERVIÇO
      // ===========================================================================
      // Procura pelo card de serviço do seu catálogo estático
      final serviceCard = find.text('Corte Padrão');
      expect(serviceCard, findsOneWidget);
      
      // Seleciona o serviço e avança
      await tester.tap(serviceCard);
      await tester.pumpAndSettle();

      final nextButton = find.widgetWithText(ElevatedButton, 'Próximo');
      await tester.tap(nextButton);
      await tester.pumpAndSettle(); // Avança para o passo do Barbeiro (Step 1)

      // ===========================================================================
      // ETAPA 4: WIZARD PASSO 1 — SELEÇÃO DE BARBEIRO
      // ===========================================================================
      // Seleciona o barbeiro Felipe ativo na listagem
      final barberCard = find.text('Felipe');
      expect(barberCard, findsOneWidget);
      
      await tester.tap(barberCard);
      await tester.pumpAndSettle();

      // Clica para avançar à última etapa
      await tester.tap(nextButton);
      await tester.pumpAndSettle(); // Avança para a grade horária (Step 2)

      // ===========================================================================
      // ETAPA 5: WIZARD PASSO 2 — SELEÇÃO DE HORÁRIO E GRAVAÇÃO FINAL
      // ===========================================================================
      // Escolhe o horário das 10:00 da manhã
      final timeSlot = find.text('10:00');
      expect(timeSlot, findsOneWidget);
      
      await tester.tap(timeSlot);
      await tester.pumpAndSettle();

      // Na última etapa do BARBÚ, o botão muda de nome de 'Próximo' para 'Confirmar'
      final confirmButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      expect(confirmButton, findsOneWidget);

      // Clica em confirmar para simular o encerramento do fluxo E2E e envio ao Firebase
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // ===========================================================================
      // VALIDAÇÃO FINAL (ASSERT CENTRAL DE INTEGRAÇÃO)
      // ===========================================================================
      // Garante que o fluxo não travou e o app exibiu com sucesso a mensagem de encerramento
      expect(find.text('Agendamento Confirmado! 🎉'), findsOneWidget);
    });
  });
}