import '../models/subscription.dart';

/// 구독 관련 유틸리티 함수들
class SubscriptionUtils {
  /// 월 환산 금액 계산
  static double getMonthlyAmount(Subscription subscription) {
    if (subscription.cycle == SubscriptionCycle.monthly) {
      return subscription.amount;
    } else {
      return subscription.amount / 12;
    }
  }

  /// D-day 계산
  static int getDaysUntilBilling(int billingDay) {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;

    // 이번 달 결제일
    DateTime billingDate = DateTime(currentYear, currentMonth, billingDay);

    // 이미 지났으면 다음 달
    if (billingDate.isBefore(today)) {
      billingDate = DateTime(currentYear, currentMonth + 1, billingDay);
    }

    final difference = billingDate.difference(today);
    return difference.inDays;
  }

  /// 구독 리스트 정렬
  static List<Subscription> sortSubscriptions(
    List<Subscription> subscriptions,
    String sortBy,
  ) {
    final sorted = List<Subscription>.from(subscriptions);
    sorted.sort((a, b) {
      // 핀 고정된 항목 먼저
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;

      // 정렬 기준
      switch (sortBy) {
        case 'amount':
          return getMonthlyAmount(b).compareTo(getMonthlyAmount(a));
        case 'date':
          return a.billingDay.compareTo(b.billingDay);
        case 'name':
          return a.name.compareTo(b.name);
        default:
          return 0;
      }
    });
    return sorted;
  }

  /// 총 월 지출 계산
  static double getTotalMonthlyAmount(List<Subscription> subscriptions) {
    return subscriptions.fold<double>(
      0,
      (sum, sub) => sum + getMonthlyAmount(sub),
    );
  }
}