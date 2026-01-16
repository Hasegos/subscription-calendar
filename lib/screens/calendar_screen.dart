import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/subscription.dart';
import '../utils/helpers.dart';

class CalendarScreen extends StatefulWidget {
  final List<Subscription> subscriptions;

  const CalendarScreen({
    super.key,
    required this.subscriptions,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<int, List<Subscription>> get _subscriptionsByDay {
    final map = <int, List<Subscription>>{};
    for (var sub in widget.subscriptions) {
      if (!map.containsKey(sub.billingDay)) {
        map[sub.billingDay] = [];
      }
      map[sub.billingDay]!.add(sub);
    }
    return map;
  }

  List<Subscription> _getSubscriptionsForDay(DateTime day) {
    return _subscriptionsByDay[day.day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubscriptions = _selectedDay != null
        ? _getSubscriptionsForDay(_selectedDay!)
        : <Subscription>[];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '${_focusedDay.year}년 ${_focusedDay.month}월',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 캘린더
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              locale: 'ko_KR',
              headerVisible: false,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDay = null;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: _getSubscriptionsForDay,
            ),
          ),
          const SizedBox(height: 16),
          // 선택된 날짜의 구독 리스트
          Expanded(
            child: _selectedDay != null
                ? selectedSubscriptions.isEmpty
                    ? Center(
                        child: Text(
                          '결제 예정인 구독이 없습니다',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${_selectedDay!.month}월 ${_selectedDay!.day}일 결제 예정',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: selectedSubscriptions.length + 1,
                              itemBuilder: (context, index) {
                                if (index == selectedSubscriptions.length) {
                                  // 총액 카드
                                  final total = selectedSubscriptions.fold<double>(
                                    0,
                                    (sum, sub) => sum + getMonthlyAmount(sub),
                                  );
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      border: Border.all(color: Colors.blue.shade200),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '이 날 총 결제 금액',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${formatCurrency(total)}원',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final sub = selectedSubscriptions[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    sub.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Chip(
                                                    label: Text(
                                                      getCategoryLabel(sub.category),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: getCategoryTextColor(sub.category),
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        getCategoryBackgroundColor(sub.category),
                                                    padding: EdgeInsets.zero,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${formatCurrency(getMonthlyAmount(sub))}원',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (sub.cycle == SubscriptionCycle.yearly)
                                                  Text(
                                                    '연간 결제',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.notifications,
                                                size: 14,
                                                color: Colors.blue.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'D-3 알림 예정',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade500, Colors.blue.shade600],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.notifications, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    '이번 주 결제 예정',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '향후 확장 기능으로 개발 예정',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '주별 필터링 및 알림 세부 설정',
                                style: TextStyle(
                                  color: Colors.blue.shade200,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
