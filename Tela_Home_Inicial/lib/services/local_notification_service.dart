import 'i_notification_service.dart';
import 'notification_service.dart';

/// Implementação real de [INotificationService].
/// Delega para o [NotificationService] estático (flutter_local_notifications).
/// Usada em produção; nos testes é substituída por [NoOpNotificationService].
class LocalNotificationService implements INotificationService {
  const LocalNotificationService();

  @override
  Future<void> scheduleReminder({
    required String bookingId,
    required String service,
    required String barber,
    required DateTime appointmentDateTime,
    int minutesBefore = 60,
  }) =>
      NotificationService.scheduleBookingReminder(
        bookingId: bookingId,
        service: service,
        barber: barber,
        appointmentDateTime: appointmentDateTime,
        minutesBefore: minutesBefore,
      );

  @override
  Future<void> cancelReminder(String bookingId) =>
      NotificationService.cancelReminder(bookingId);
}
