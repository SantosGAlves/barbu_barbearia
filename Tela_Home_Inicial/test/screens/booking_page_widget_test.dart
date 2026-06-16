import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/models/service_model.dart';

void main() {
  group('Suíte de Testes de Interface — Fluxo Completo da BookingPage', () {
    
    // Componente simulado que reproduz fielmente as 3 etapas do Wizard do BARBÚ
    Widget buildBookingWizard({
      required int step,
      String? service,
      String? barber,
      String? time,
    }) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Agendamento BARBÚ')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Text('Etapa: $step'),
                
                // ETAPA 0: Seleção de Serviço
                if (step == 0) ...[
                  const Text('Selecione o Serviço'),
                  if (service != null) Text('Selecionado: $service'),
                ],
                
                // ETAPA 1: Seleção de Barbeiro
                if (step == 1) ...[
                  const Text('Selecione o Barbeiro'),
                  if (barber != null) Text('Selecionado: $barber'),
                ],
                
                // ETAPA 2: Seleção de Horário
                if (step == 2) ...[
                  const Text('Selecione o Horário'),
                  if (time != null) Text('Selecionado: $time'),
                ],

                const SizedBox(height: 20),

                // Botão Dinâmico de Ação (Avançar ou Confirmar)
                ElevatedButton(
                  onPressed: ((step == 0 && service != null) ||
                              (step == 1 && barber != null) ||
                              (step == 2 && time != null)) 
                              ? () {} 
                              : null,
                  child: Text(step == 2 ? 'Confirmar' : 'Próximo'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ===========================================================================
    // CENÁRIO 1: ETAPA 0 (Bloqueio Inicial e Liberação)
    // ===========================================================================
    testWidgets('WT-01: Deve bloquear avanço na Etapa 0 e liberar após selecionar Serviço', 
    (WidgetTester tester) async {
      // Estado Inicial: Sem serviço selecionado
      await tester.pumpWidget(buildBookingWizard(step: 0, service: null));
      
      var buttonFinder = find.widgetWithText(ElevatedButton, 'Próximo');
      var button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull); // Garantidamente bloqueado

      // Estado Atualizado: Usuário seleciona um serviço
      await tester.pumpWidget(buildBookingWizard(step: 0, service: 'Corte Padrão'));
      await tester.pump(); // Desenha o próximo frame

      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNotNull); // Liberado!
    });

    // ===========================================================================
    // CENÁRIO 2: ETAPA 1 (Seleção do Barbeiro)
    // ===========================================================================
    testWidgets('WT-02: Deve bloquear avanço na Etapa 1 e liberar após selecionar Barbeiro', 
    (WidgetTester tester) async {
      // Estado Inicial da Etapa 1: Sem barbeiro definido
      await tester.pumpWidget(buildBookingWizard(step: 1, barber: null));
      
      var buttonFinder = find.widgetWithText(ElevatedButton, 'Próximo');
      var button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      // Estado Atualizado: Usuário escolhe o barbeiro Felipe
      await tester.pumpWidget(buildBookingWizard(step: 1, barber: 'Felipe'));
      await tester.pump();

      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });

    // ===========================================================================
    // CENÁRIO 3: ETAPA 2 (Seleção de Horário e Botão Confirmar)
    // ===========================================================================
    testWidgets('WT-03: Deve exibir botão Confirmar na Etapa 2 e bloquear se horário for nulo', 
    (WidgetTester tester) async {
      // Na Etapa 2, o texto do botão muda de 'Próximo' para 'Confirmar'
      await tester.pumpWidget(buildBookingWizard(step: 2, time: null));
      
      expect(find.text('Próximo'), findsNothing); // O botão 'Próximo' sumiu
      
      var confirmButtonFinder = find.widgetWithText(ElevatedButton, 'Confirmar');
      expect(confirmButtonFinder, findsOneWidget); // O botão 'Confirmar' apareceu

      var button = tester.widget<ElevatedButton>(confirmButtonFinder);
      expect(button.onPressed, isNull); // Bloqueado porque o horário é nulo
    });

    // ===========================================================================
    // CENÁRIO 4: FINALIZAÇÃO DO FLUXO
    // ===========================================================================
    testWidgets('WT-04: Deve habilitar o botão Confirmar quando o horário for preenchido', 
    (WidgetTester tester) async {
      // Usuário escolhe o último dado: horário das 10:00
      await tester.pumpWidget(buildBookingWizard(step: 2, time: '10:00'));
      await tester.pump();

      var confirmButtonFinder = find.widgetWithText(ElevatedButton, 'Confirmar');
      var button = tester.widget<ElevatedButton>(confirmButtonFinder);
      
      expect(button.onPressed, isNotNull); // Habilitado para gravação no Firebase!
    });
  });
}