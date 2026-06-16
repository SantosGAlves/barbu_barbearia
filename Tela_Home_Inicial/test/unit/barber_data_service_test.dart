// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/models/service_model.dart';
import 'package:flutter_application_2/screens/bookings/booking_page.dart';

void main() {
  // ── BarberDataService ────────────────────────────────────────────────────

  group('BarberDataService — catálogo de dados', () {
    test('getServices() retorna exatamente 3 serviços', () {
      expect(BarberDataService.getServices().length, equals(3));
    });

    test('cada serviço possui os campos name, price e icon', () {
      for (final service in BarberDataService.getServices()) {
        expect(service.containsKey('name'), isTrue,
            reason: 'Falta o campo "name"');
        expect(service.containsKey('price'), isTrue,
            reason: 'Falta o campo "price"');
        expect(service.containsKey('icon'), isTrue,
            reason: 'Falta o campo "icon"');
      }
    });

    test('nomes dos serviços são únicos (sem duplicatas)', () {
      final names =
          BarberDataService.getServices().map((s) => s['name']).toList();
      expect(names.toSet().length, equals(names.length));
    });

    test('getBarbers() retorna exatamente 2 barbeiros', () {
      expect(BarberDataService.getBarbers().length, equals(2));
    });

    test('getBarbers() contém Felipe e Rodrigo Art', () {
      final barbers = BarberDataService.getBarbers();
      expect(barbers, containsAll(['Felipe', 'Rodrigo Art']));
    });

    test('getAvailableTimes() retorna 8 horários', () {
      expect(BarberDataService.getAvailableTimes().length, equals(8));
    });

    test('todos os horários estão no formato HH:MM', () {
      final timeRegex = RegExp(r'^\d{2}:\d{2}$');
      for (final time in BarberDataService.getAvailableTimes()) {
        expect(timeRegex.hasMatch(time), isTrue,
            reason: '"$time" não segue o padrão HH:MM');
      }
    });

    test('horários não têm duplicatas', () {
      final times = BarberDataService.getAvailableTimes();
      expect(times.toSet().length, equals(times.length));
    });

    test('horários estão em ordem crescente', () {
      final times = BarberDataService.getAvailableTimes();
      final sorted = [...times]..sort();
      expect(times, equals(sorted));
    });
  });

  // ── BookingUtils — lógica de filtragem de horários ─────────────────────

  group('BookingUtils.filterTimes — regra de negócio principal', () {
    final allTimes = ['09:00', '10:00', '11:00', '14:00', '15:00'];

    test('sem horários ocupados → retorna todos', () {
      final result = BookingUtils.filterTimes(allTimes, []);
      expect(result, equals(allTimes));
    });

    test('remove corretamente os horários ocupados', () {
      final result = BookingUtils.filterTimes(allTimes, ['09:00', '14:00']);
      expect(result, equals(['10:00', '11:00', '15:00']));
      expect(result.contains('09:00'), isFalse);
      expect(result.contains('14:00'), isFalse);
    });

    test('com todos os horários ocupados → retorna lista vazia', () {
      final result = BookingUtils.filterTimes(allTimes, allTimes);
      expect(result, isEmpty);
    });

    test('horário ocupado inexistente na lista → não afeta resultado', () {
      final result = BookingUtils.filterTimes(allTimes, ['08:00', '20:00']);
      expect(result, equals(allTimes)); // nada removido
    });

    test('preserva a ordem original dos horários', () {
      final result = BookingUtils.filterTimes(allTimes, ['11:00']);
      expect(result, equals(['09:00', '10:00', '14:00', '15:00']));
    });

    test('não modifica a lista original (imutabilidade)', () {
      final original = ['09:00', '10:00', '11:00'];
      BookingUtils.filterTimes(original, ['09:00']);
      expect(original.length, equals(3)); // intacta
    });
  });
}
