/// Interface que abstrai o serviço de notificações locais.
/// Permite injetar um stub/mock nos testes sem depender de hardware.
abstract class INotificationService {
  Future<void> scheduleReminder({
    required String bookingId,
    required String service,
    required String barber,
    required DateTime appointmentDateTime,
    int minutesBefore = 60,
  });

  Future<void> cancelReminder(String bookingId);
}
