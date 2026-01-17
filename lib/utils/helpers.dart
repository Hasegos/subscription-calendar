import 'package:flutter/material.dart';
import '../models/subscription.dart';
import 'subscription_utils.dart';
import 'category_utils.dart';
import 'format_utils.dart';

/// 월 환산 금액 계산
double getMonthlyAmount(Subscription subscription) {
  return SubscriptionUtils.getMonthlyAmount(subscription);
}

/// 카테고리 한글 라벨
String getCategoryLabel(SubscriptionCategory category) {
  return CategoryUtils.getLabel(category);
}

/// 카테고리 배경 색상
Color getCategoryBackgroundColor(SubscriptionCategory category) {
  return CategoryUtils.getBackgroundColor(category);
}

/// 카테고리 텍스트 색상
Color getCategoryTextColor(SubscriptionCategory category) {
  return CategoryUtils.getTextColor(category);
}

/// D-day 계산
int getDaysUntilBilling(int billingDay) {
  return SubscriptionUtils.getDaysUntilBilling(billingDay);
}

/// 숫자 포맷 (천 단위 구분)
String formatCurrency(double amount) {
  return FormatUtils.formatCurrency(amount);
}