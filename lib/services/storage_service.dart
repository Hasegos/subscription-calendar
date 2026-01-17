import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

/// 로컬 저장소 관리 서비스
class StorageService {
  static const String _keySubscriptions = 'subscriptions';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  /// 구독 리스트 로드
  static Future<List<Subscription>> loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keySubscriptions);
    
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Subscription.fromJson(json)).toList();
  }

  /// 구독 리스트 저장
  static Future<void> saveSubscriptions(List<Subscription> subscriptions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = subscriptions.map((sub) => sub.toJson()).toList();
    await prefs.setString(_keySubscriptions, jsonEncode(jsonList));
  }

  /// 온보딩 완료 여부 확인
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  /// 온보딩 완료 표시
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  /// 모든 데이터 삭제
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}