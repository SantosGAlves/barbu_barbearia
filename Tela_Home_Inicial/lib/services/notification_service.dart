import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Serviço centralizado para notificações locais agendadas.
/// Funciona offline, sem backend, sem custo extra.
class NotificationService {
  NotificationService._(); // Classe utilitária — sem instância

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Detalhes do canal Android (obrigatório Android 8+)
  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'barbu_channel',         // ID único do canal
    'Barbú — Lembretes',     // Nome visível ao usuário
    channelDescription: 'Lembretes dos seus agendamentos na Barbú',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  static const NotificationDetails _details =
      NotificationDetails(android: _androidDetails);

  // ── Inicialização ──────────────────────────────────────────────────────────

  /// Deve ser chamado uma vez em main() antes de runApp().
  static Future<void> init() async {
    // Inicializa banco de fusos horários
    tz.initializeTimeZones();

    // Tenta detectar fuso do dispositivo; usa Brasília como fallback
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(initSettings);

    // Pede permissão em Android 13+ e iOS
    await _requestPermissions();
  }

  // ── Permissões ─────────────────────────────────────────────────────────────

  static Future<void> _requestPermissions() async {
    // Android 13+
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    // iOS
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(
        alert: true, badge: true, sound: true);
  }

  // ── Agendamento de lembrete ────────────────────────────────────────────────

  /// Agenda um lembrete [minutesBefore] minutos antes do agendamento.
  /// Se o horário calculado já passou, não agenda nada.
  ///
  /// [bookingId] é usado como ID único da notificação para poder
  /// cancelar se o agendamento for cancelado no futuro.
  static Future<void> scheduleBookingReminder({
    required String bookingId,
    required String service,
    required String barber,
    required DateTime appointmentDateTime,
    int minutesBefore = 60,
  }) async {
    // Notificações locais não funcionam na web
    if (kIsWeb) return;

    final reminderTime =
        appointmentDateTime.subtract(Duration(minutes: minutesBefore));

    // Não agenda se o lembrete já passou
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint(
          '[NotificationService] Lembrete ignorado — horário já passou.');
      return;
    }

    final tzReminder = tz.TZDateTime.from(reminderTime, tz.local);

    // Usa os primeiros 9 dígitos do bookingId como ID inteiro único
    final notifId = bookingId.hashCode.abs() % 999999999;

    final horaFormatada =
        '${appointmentDateTime.hour.toString().padLeft(2, '0')}:'
        '${appointmentDateTime.minute.toString().padLeft(2, '0')}';

    await _plugin.zonedSchedule(
      notifId,
      'Lembrete de corte ✂️',
      '$service com $barber hoje às $horaFormatada — em $minutesBefore min!',
      tzReminder,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );

    debugPrint(
        '[NotificationService] Lembrete agendado para $tzReminder (notifId: $notifId)');
  }

  /// Cancela o lembrete de um agendamento pelo seu ID.
  static Future<void> cancelReminder(String bookingId) async {
    if (kIsWeb) return;
    final notifId = bookingId.hashCode.abs() % 999999999;
    await _plugin.cancel(notifId);
    debugPrint('[NotificationService] Lembrete cancelado (notifId: $notifId)');
  }

  /// Cancela TODOS os lembretes agendados.
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
