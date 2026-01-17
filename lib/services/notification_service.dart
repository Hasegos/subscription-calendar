import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/subscription.dart';

/// 로컬 알림 관리 서비스
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// 알림 서비스 초기화
  static Future<void> initialize() async {
    if (_initialized) return;

    // 타임존 초기화
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// 알림 권한 요청
  static Future<bool> requestPermission() async {
    // Android 13+ 권한 요청
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS 권한 요청 (DarwinPlugin 타입이 없는 버전 대비)
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // 그 외 플랫폼은 별도 권한 요청 없음
    return true;
  }

  /// 구독 리마인더 알림 스케줄링
  static Future<void> scheduleSubscriptionReminder(Subscription subscription) async {
    if (!subscription.reminderEnabled) return;

    // 기존 알림 제거
    await _notifications.cancel(subscription.id.hashCode);

    final nowTz = tz.TZDateTime.now(tz.local);

    // 다음 결제일 (billingDay가 29~31이어도 월말로 보정)
    DateTime billingDate = _getNextBillingDate(subscription.billingDay);

    // 리마인더 날짜 = 결제일 - N일
    DateTime reminderDate = billingDate.subtract(
      Duration(days: subscription.reminderDaysBefore),
    );

    // reminderDate의 10:00로 TZDateTime 만들기 (copyWith 금지)
    tz.TZDateTime scheduledDate = _toLocal10AM(reminderDate);

    // 이미 지났다면 다음 사이클로 넘김 (무한루프 방지 가드)
    int guard = 0;
    while (!scheduledDate.isAfter(nowTz) && guard < 12) {
      billingDate = _getNextBillingDate(
        subscription.billingDay,
        from: billingDate.add(const Duration(days: 1)),
      );

      reminderDate = billingDate.subtract(
        Duration(days: subscription.reminderDaysBefore),
      );

      scheduledDate = _toLocal10AM(reminderDate);
      guard++;
    }

    // 그래도 과거면 스케줄링 안 함
    if (!scheduledDate.isAfter(nowTz)) return;

    const androidDetails = AndroidNotificationDetails(
      'subscription_reminders',
      '구독 결제 리마인더',
      channelDescription: '구독 서비스 결제일 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      subscription.id.hashCode,
      '💰 결제 예정 알림',
      '${subscription.name} - ${subscription.reminderDaysBefore}일 후 결제됩니다 (${subscription.billingDay}일)',
      scheduledDate, // TZDateTime
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // matchDateTimeComponents: DateTimeComponents.dateAndTime, // 필요 시 반복 설정
    );
  }

  /// 모든 구독 알림 스케줄링
  static Future<void> scheduleAllReminders(List<Subscription> subscriptions) async {
    await cancelAllNotifications();

    for (final subscription in subscriptions) {
      if (subscription.reminderEnabled) {
        await scheduleSubscriptionReminder(subscription);
      }
    }
  }

  /// 특정 알림 취소
  static Future<void> cancelNotification(String subscriptionId) async {
    await _notifications.cancel(subscriptionId.hashCode);
  }

  /// 모든 알림 취소
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 알림 탭 핸들러
  static void _onNotificationTap(NotificationResponse response) {
    // TODO: payload 보고 특정 화면 이동 로직 필요하면 추가
  }

  /// 다음 결제일 계산 (billingDay가 그 달의 마지막 일보다 크면 월말로 보정)
  /// - from: 기준 날짜(미지정 시 현재 시각)
  static DateTime _getNextBillingDate(int billingDay, {DateTime? from}) {
    final base = from ?? DateTime.now();

    int year = base.year;
    int month = base.month;

    // 이번 달 결제일(월말 clamp)
    final dayThisMonth = _clampDayToMonth(year, month, billingDay);
    var candidate = DateTime(year, month, dayThisMonth);

    // 이미 지났거나(또는 오늘)면 다음 달로
    if (!candidate.isAfter(base)) {
      month += 1;
      if (month == 13) {
        month = 1;
        year += 1;
      }

      final dayNextMonth = _clampDayToMonth(year, month, billingDay);
      candidate = DateTime(year, month, dayNextMonth);
    }

    return candidate;
  }

  /// 특정 연/월에 존재하는 마지막 날 기준으로 billingDay를 보정
  static int _clampDayToMonth(int year, int month, int billingDay) {
    final lastDay = _daysInMonth(year, month);
    if (billingDay < 1) return 1;
    if (billingDay > lastDay) return lastDay;
    return billingDay;
  }

  static int _daysInMonth(int year, int month) {
    // 다음 달 0일 = 이번 달 말일
    return DateTime(year, month + 1, 0).day;
  }

  /// DateTime을 로컬 타임존의 "오전 10시" TZDateTime으로 변환
  static tz.TZDateTime _toLocal10AM(DateTime date) {
    final base = tz.TZDateTime.from(date, tz.local);
    return tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      base.day,
      10,
      0,
      0,
    );
  }
}
