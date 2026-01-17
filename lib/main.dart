import 'package:flutter/material.dart';
import 'models/subscription.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/add_subscription_modal.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko_KR', null);
  // 알림 서비스 초기화
  await NotificationService.initialize();
  await NotificationService.requestPermission();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '구독 매니저',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Pretendard', // 한글 폰트 사용 권장
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showOnboarding = true;
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hasVisited = await StorageService.isOnboardingComplete();
    final subscriptions = await StorageService.loadSubscriptions();

    setState(() {
      _showOnboarding = !hasVisited;
      _subscriptions = subscriptions;
      _isLoading = false;
    });
    
    // 구독 알림 스케줄링
    if (subscriptions.isNotEmpty) {
      await NotificationService.scheduleAllReminders(subscriptions);
    }
  }

  Future<void> _saveSubscriptions() async {
    await StorageService.saveSubscriptions(_subscriptions);
    // 알림 재스케줄링
    await NotificationService.scheduleAllReminders(_subscriptions);
  }

  void _handleStartApp() async {
    await StorageService.completeOnboarding();
    setState(() {
      _showOnboarding = false;
    });
  }

  void _addSubscription(Subscription subscription) {
    setState(() {
      _subscriptions.add(subscription);
    });
    _saveSubscriptions();
  }

  void _updateSubscription(String id, Subscription subscription) {
    setState(() {
      final index = _subscriptions.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subscriptions[index] = subscription.copyWith(
          id: id,
          createdAt: _subscriptions[index].createdAt,
        );
      }
    });
    _saveSubscriptions();
  }

  void _deleteSubscription(String id) {
    setState(() {
      _subscriptions.removeWhere((s) => s.id == id);
    });
    // 해당 구독의 알림 취소
    NotificationService.cancelNotification(id);
    _saveSubscriptions();
  }

  void _togglePinned(String id) {
    setState(() {
      final index = _subscriptions.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subscriptions[index] = _subscriptions[index].copyWith(
          pinned: !_subscriptions[index].pinned,
        );
      }
    });
    _saveSubscriptions();
  }

  void _showAddSubscriptionModal({Subscription? subscription}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubscriptionModal(
        subscription: subscription,
        onSave: (newSubscription) {
          if (subscription != null) {
            _updateSubscription(subscription.id, newSubscription);
          } else {
            final sub = newSubscription.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              createdAt: DateTime.now().toIso8601String(),
            );
            _addSubscription(sub);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(onStart: _handleStartApp);
    }

    final screens = [
      HomeScreen(
        subscriptions: _subscriptions,
        onEdit: (sub) => _showAddSubscriptionModal(subscription: sub),
        onDelete: _deleteSubscription,
        onTogglePinned: _togglePinned,
      ),
      CalendarScreen(subscriptions: _subscriptions),
      AnalyticsScreen(subscriptions: _subscriptions),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
              onPressed: () => _showAddSubscriptionModal(),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '분석',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}