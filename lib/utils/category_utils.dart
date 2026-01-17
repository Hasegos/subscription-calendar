import 'package:flutter/material.dart';
import '../models/subscription.dart';

/// 카테고리 한글 라벨
class CategoryUtils {
  static String getLabel(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.video:
        return '영상';
      case SubscriptionCategory.music:
        return '음악';
      case SubscriptionCategory.cloud:
        return '클라우드';
      case SubscriptionCategory.productivity:
        return '생산성';
      case SubscriptionCategory.other:
        return '기타';
    }
  }

  /// 카테고리 배경 색상
  static Color getBackgroundColor(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.video:
        return Color(0xFFDBEAFE);
      case SubscriptionCategory.music:
        return Color(0xFFEDE9FE);
      case SubscriptionCategory.cloud:
        return Color(0xFFD1FAE5);
      case SubscriptionCategory.productivity:
        return Color(0xFFFEF3C7);
      case SubscriptionCategory.other:
        return Color(0xFFF3F4F6);
    }
  }

  /// 카테고리 텍스트 색상
  static Color getTextColor(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.video:
        return Color(0xFF1E40AF);
      case SubscriptionCategory.music:
        return Color(0xFF6B21A8);
      case SubscriptionCategory.cloud:
        return Color(0xFF065F46);
      case SubscriptionCategory.productivity:
        return Color(0xFF92400E);
      case SubscriptionCategory.other:
        return Color(0xFF374151);
    }
  }

  /// 차트 색상
  static Color getChartColor(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.video:
        return Colors.blue;
      case SubscriptionCategory.music:
        return Colors.purple;
      case SubscriptionCategory.cloud:
        return Colors.green;
      case SubscriptionCategory.productivity:
        return Colors.orange;
      case SubscriptionCategory.other:
        return Colors.grey;
    }
  }
}
