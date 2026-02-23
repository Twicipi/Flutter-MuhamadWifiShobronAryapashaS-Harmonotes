import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (await Permission.notification.isGranted) {
      await _notifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
    }
  }

  // ✅ METHOD UTAMA: Tampilkan notifikasi apa saja
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    if (!(await Permission.notification.isGranted)) return;

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'harmonotes_channel',
          'Harmonotes',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ✅ DAILY MOTIVATION: Random message + trigger via home page
  static Future<void> showDailyMotivation() async {
    final messages = [
      'Hai! Ada ide lagu yang ingin diabadikan hari ini? 🎵',
      'Mood hari ini ceria? Coba tulis lagu dengan tempo cepat! ☀️',
      'Jangan biarkan inspirasi menguap. Catat sekarang di Harmonotes! ✨',
      'Setiap nada punya cerita. Apa cerita hari ini? 📖',
      'Hari ini, coba tulis lagu yang menggambarkan perasaanmu saat ini. 💭',
    ];
    final randomIndex = DateTime.now().second % messages.length;
    await show(
      title: 'Harmonotes 💫',
      body: messages[randomIndex],
    );
  }

  // ✅ INACTIVITY REMINDER: Trigger via home page
  static Future<void> showInactivityReminder() async {
    await show(
      title: 'Inspirasi datang lagi? ✨',
      body: 'Sudah sejam sejak lagu terakhir. Ada ide baru yang ingin dicatat?',
    );
  }

  // ✅ ACHIEVEMENT: Untuk backward compatibility (dipakai di song_provider.dart)
  static Future<void> showAchievementNotification({
    required String title,
    required String body,
  }) async {
    await show(title: title, body: body);
  }
}