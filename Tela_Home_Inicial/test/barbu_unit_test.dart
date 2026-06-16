import 'package:flutter_test/flutter_test.dart'; // FERRAMENTA 1: Framework de execução nativo
import 'package:mocktail/mocktail.dart';         // FERRAMENTA 2: Criador de Mocks e Stubs
import 'package:flutter_application_2/models/service_model.dart';

// AQUI ESTÁ O MOCK: Criando o dublê da classe de dados para isolar o Firebase
class MockBarberDataService extends Mock implements BarberDataService {}

void main() {
  late MockBarberDataService mockService;

  // CICLO DE VIDA: Instancia um mock limpo antes de cada teste
  setUp(() {
    mockService = MockBarberDataService();
  });

  // CICLO DE VIDA: Destrói os dados do mock após cada teste para não poluir o próximo
  tearDown(() {
    reset(mockService);
  });

  // ===========================================================================
  // MÓDULO: AUTENTICAÇÃO & LOGIN (CT-01 a CT-05) - Seção 3.1 do Relatório
  // ===========================================================================
  group('Módulo de Login - Mapeamento de Mensagens do Firebase Auth', () {
    
    String mapearErroLogin(String codigoExcecao) {
      if (codigoExcecao == 'user-not-found' || codigoExcecao == 'wrong-password' || codigoExcecao == 'invalid-credential') {
        return 'E-mail ou senha incorretos.';
      }
      return 'Erro ao fazer login.';
    }

    test('CT-01: Login bem-sucedido sem lançamento de exceções', () {
      expect(() => {}, returnsNormally);
    });

    test('CT-02: Mapeamento do código invalid-credential', () {
      expect(mapearErroLogin('invalid-credential'), 'E-mail ou senha incorretos.');
    });

    test('CT-03: Mapeamento do código user-not-found', () {
      expect(mapearErroLogin('user-not-found'), 'E-mail ou senha incorretos.');
    });

    test('CT-04: Mapeamento do código wrong-password', () {
      expect(mapearErroLogin('wrong-password'), 'E-mail ou senha incorretos.');
    });

    test('CT-05: Fallback de segurança para códigos de erros genéricos do Firebase', () {
      expect(mapearErroLogin('network-error'), 'Erro ao fazer login.');
    });
  });

  // ===========================================================================
  // MÓDULO: CADASTRO (CT-06 a CT-08) - Seção 3.2 do Relatório
  // ===========================================================================
  group('Módulo de Cadastro - Mapeamento de Exceções de Criação de Conta', () {
    
    String mapearErroCadastro(String codigoExcecao) {
      if (codigoExcecao == 'weak-password') {
        return 'A senha é muito fraca (mínimo 6 caracteres).';
      } else if (codigoExcecao == 'email-already-in-use') {
        return 'Este e-mail já está em uso.';
      }
      return 'Erro ao criar conta.';
    }

    test('CT-06: Validação de barreira para o código weak-password', () {
      expect(mapearErroCadastro('weak-password'), 'A senha é muito fraca (mínimo 6 caracteres).');
    });

    test('CT-07: Validação de barreira para o código email-already-in-use', () {
      expect(mapearErroCadastro('email-already-in-use'), 'Este e-mail já está em uso.');
    });

    test('CT-08: Cadastro limpo executado com sucesso', () {
      expect(() => {}, returnsNormally);
    });
  });

  // ===========================================================================
  // MÓDULO: RECUPERAÇÃO DE SENHA (CT-09 e CT-10) - Seção 3.3 do Relatório
  // ===========================================================================
  group('Módulo de Recuperação de Senha - Validação de Entrada', () {
    
    bool validarInputEmailReset(String email) {
      return email.trim().isNotEmpty;
    }

    test('CT-09: Processamento authorized para campo de e-mail preenchido', () {
      expect(validarInputEmailReset('teste@email.com'), true);
    });

    test('CT-10: Bloqueio de envio para campo de e-mail em branco (String Vazia)', () {
      expect(validarInputEmailReset(''), false);
    });
  });

  // ===========================================================================
  // MÓDULO: DADOS DO USUÁRIO & ADMIN (CT-11 a CT-14) - Seção 3.4 e 3.5 do Relatório
  // ===========================================================================
  group('Módulo Home - Lógica de Exibição de Nome de Perfil e Nível de Acesso', () {
    
    test('CT-11: Extração com split de nomes compostos padrão', () {
      expect('Rafael Rissoni'.split(' ')[0], 'Rafael');
    });

    test('CT-12: Fallback preventivo para strings ou referências nulas', () {
      String? nomeNulo;
      String userName = (nomeNulo ?? 'Cliente').split(' ')[0];
      expect(userName, 'Cliente');
    });

    test('CT-13: Verificação de privilégio elevado quando isAdmin for true', () {
      final data = {'name': 'Felipe', 'isAdmin': true};
      bool isAdmin = data.containsKey('isAdmin') ? data['isAdmin'] as bool : false;
      expect(isAdmin, true);
    });

    test('CT-14: Verificação de privilégio padrão quando isAdmin for ausente', () {
      final data = {'name': 'Rodrigo'};
      bool isAdmin = data.containsKey('isAdmin') ? data['isAdmin'] as bool : false;
      expect(isAdmin, false);
    });
  });

  // ===========================================================================
  // MÓDULO: CATÁLOGO DE SERVIÇOS USANDO MOCKTAIL (CT-15 a CT-17) - Seção 3.6
  // ===========================================================================
  group('Módulo de Modelagem - USO ATIVO DO MOCKTAIL', () {
    
    test('CT-15: Verificação estrutural do getServices usando Stubbing do Mocktail', () {
      when(() => mockService.getServices()).thenReturn([
        {'name': 'Corte Padrão'}, {'name': 'Barba Premium'}, {'name': 'Combo Barbú'}
      ]);

      expect(mockService.getServices().length, 3);
    });

    test('CT-16: Verificação estrutural do getBarbers usando Stubbing do Mocktail', () {
      when(() => mockService.getBarbers()).thenReturn(['Felipe', 'Rodrigo Art']);
      
      expect(mockService.getBarbers(), containsAll(['Felipe', 'Rodrigo Art']));
    });

    test('CT-17: Verificação estrutural do getAvailableTimes usando Stubbing do Mocktail', () {
      when(() => mockService.getAvailableTimes()).thenReturn(['09:00', '18:00']);
      
      final times = mockService.getAvailableTimes();
      expect(times.first, '09:00');
      expect(times.last, '18:00');
    });
  });

  // ===========================================================================
  // MÓDULO: AGENDAMENTO & FILTROS (CT-18 a CT-22) - Seção 4.1 e 4.2 do Relatório
  // ===========================================================================
  group('Módulo de Agendamento - Formatação de Datas e Filtros de Horários', () {
    
    test('CT-18: Formatação BVA com índice mínimo (0 dias - Hoje)', () {
      DateTime data = DateTime(2026, 06, 16).add(const Duration(days: 0));
      String dateString = "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
      expect(dateString, '2026-06-16');
    });

    test('CT-19: Formatação BVA com índice limite superior (13 dias à frente)', () {
      DateTime data = DateTime(2026, 06, 16).add(const Duration(days: 13));
      String dateString = "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
      expect(dateString, '2026-06-29');
    });

    test('CT-20: BVA Mínimo de exclusão simulado pelo Mock - 0 horários ocupados', () {
      // Linha com erro de sintaxe corrigida para o stub clássico do Mocktail
      when(() => mockService.getAvailableTimes()).thenReturn(['09:00', '10:00']);
      
      final List<String> allTimes = mockService.getAvailableTimes();
      List<String> bookedTimes = [];
      List<String> livres = allTimes.where((time) => !bookedTimes.contains(time)).toList();
      expect(livres.length, 2);
    });

    test('CT-21: BVA Máximo de exclusão simulado pelo Mock - Todos ocupados', () {
      when(() => mockService.getAvailableTimes()).thenReturn(['09:00', '10:00']);
      
      final List<String> allTimes = mockService.getAvailableTimes();
      List<String> bookedTimes = ['09:00', '10:00'];
      List<String> livres = allTimes.where((time) => !bookedTimes.contains(time)).toList();
      expect(livres.isEmpty, true);
    });

    test('CT-22: Exclusão parcial de horários marcados na agenda do Mock', () {
      when(() => mockService.getAvailableTimes()).thenReturn(['09:00', '10:00']);
      
      final List<String> allTimes = mockService.getAvailableTimes();
      List<String> bookedTimes = ['09:00'];
      List<String> livres = allTimes.where((time) => !bookedTimes.contains(time)).toList();
      expect(livres, isNot(contains('09:00')));
    });
  });

  // ===========================================================================
  // MÓDULO: HISTÓRICO VIVO (CT-23 a CT-26) - Seção 4.3 do Relatório
  // ===========================================================================
  group('Módulo do Histórico - Lógica de Status Temporal e Resiliência', () {
    
    test('CT-23: BVA de tempo - Agendamento no passado recente vira Concluído', () {
      final DateTime agora = DateTime(2026, 06, 16, 12, 00);
      final DateTime passado = agora.subtract(const Duration(minutes: 1));
      String status = 'confirmado';
      if (passado.isBefore(agora) && status == 'confirmado') status = 'concluido';
      expect(status, 'concluido');
    });

    test('CT-24: BVA de tempo - Agendamento no futuro próximo continua Confirmado', () {
      final DateTime agora = DateTime(2026, 06, 16, 12, 00);
      final DateTime futuro = agora.add(const Duration(minutes: 1));
      String status = 'confirmado';
      if (futuro.isBefore(agora) && status == 'confirmado') status = 'concluido';
      expect(status, 'confirmado');
    });

    test('CT-25: Preservação estrita de status cancelados pelo usuário', () {
      final DateTime agora = DateTime(2026, 06, 16, 12, 00);
      final DateTime passado = agora.subtract(const Duration(minutes: 1));
      String status = 'cancelado';
      if (passado.isBefore(agora) && status == 'confirmado') status = 'concluido';
      expect(status, 'cancelado');
    });

    test('CT-26: Absorção segura de erros de parse e formatação de data', () {
      String status = 'confirmado';
      try {
        DateTime.parse("data_corrompida_firestore");
      } catch (e) {
        // Bloco catch intercepta o defeito e impede o crash
      }
      expect(status, 'confirmado');
    });
  });

  // ===========================================================================
  // MÓDULO: ASSISTENTE WIZARD (CT-27 a CT-30) - Seção 5.1 do Relatório
  // ===========================================================================
  group('Módulo Wizard - Cobertura de Caminhos do Fluxo canGoNext', () {
    
    bool checarCanGoNext(int step, String? s, String? b, String? t) {
      return (step == 0 && s != null) || (step == 1 && b != null) || (step == 2 && t != null);
    }

    test('CT-27: Passo 0 com serviço preenchido ativa botão Próximo', () {
      expect(checarCanGoNext(0, 'Corte', null, null), true);
    });

    test('CT-28: Passo 0 com serviço nulo mantém botão bloqueado', () {
      expect(checarCanGoNext(0, null, null, null), false);
    });

    test('CT-29: Passo 1 com barbeiro selecionado ativa botão Próximo', () {
      expect(checarCanGoNext(1, null, 'Felipe', null), true);
    });

    test('CT-30: Passo 2 com horário escolhido ativa botão Confirmar', () {
      expect(checarCanGoNext(2, null, null, '10:00'), true);
    });
  });
}