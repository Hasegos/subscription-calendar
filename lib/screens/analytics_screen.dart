import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/subscription.dart';
import '../utils/helpers.dart';
import 'savings_simulator_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Subscription> subscriptions;

  const AnalyticsScreen({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final totalMonthly = subscriptions.fold<double>(
      0,
      (sum, sub) => sum + getMonthlyAmount(sub),
    );

    // 카테고리별 집계
    final categoryData = <SubscriptionCategory, double>{};
    for (var sub in subscriptions) {
      final monthly = getMonthlyAmount(sub);
      categoryData[sub.category] = (categoryData[sub.category] ?? 0) + monthly;
    }

    // Top 3 구독
    final topSubscriptions = List<Subscription>.from(subscriptions)
      ..sort((a, b) => getMonthlyAmount(b).compareTo(getMonthlyAmount(a)))
      ..take(3);

    final now = DateTime.now();
    final currentMonth = '${now.year}년 ${now.month}월 분석';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          currentMonth,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavingsSimulatorScreen(
                    subscriptions: subscriptions,
                  ),
                ),
              );
            },
            child: Text('✂️ 절감 계산')
          )
        ],
      ),
      body: subscriptions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '등록된 구독이 없습니다',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '구독을 추가하면 분석 데이터가 표시됩니다',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 요약 카드들
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.attach_money,
                        iconColor: Colors.blue,
                        label: '월 총 지출',
                        value: formatCurrency(totalMonthly),
                        unit: '원',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.inventory,
                        iconColor: Colors.purple,
                        label: '구독 개수',
                        value: subscriptions.length.toString(),
                        unit: '개',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 카테고리별 지출 (파이 차트)
                if (categoryData.isNotEmpty) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '카테고리별 지출',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: categoryData.entries.map((entry) {
                                  final percentage = (entry.value / totalMonthly * 100);
                                  return PieChartSectionData(
                                    value: entry.value,
                                    title: '${percentage.toStringAsFixed(0)}%',
                                    color: _getCategoryChartColor(entry.key),
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...categoryData.entries.map((entry) {
                            final percentage = (entry.value / totalMonthly * 100);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: _getCategoryChartColor(entry.key),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        getCategoryLabel(entry.key),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${formatCurrency(entry.value)}원',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Top 3 지출
                if (topSubscriptions.isNotEmpty) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '지출 TOP 3',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...topSubscriptions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final sub = entry.value;
                            final monthly = getMonthlyAmount(sub);
                            final percentage = (monthly / totalMonthly * 100);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade500,
                                          Colors.blue.shade600,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Chip(
                                          label: Text(
                                            getCategoryLabel(sub.category),
                                            style: TextStyle(
                                              fontSize: 10,
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
                                        '${formatCurrency(monthly)}원',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // 향후 확장 기능
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade100, Colors.grey.shade200],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '향후 확장 기능',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...const [
                        '• 월별 지출 추이 그래프',
                        '• 절감 추천 (미사용 구독 알림)',
                        '• 연간 지출 분석',
                      ].map((text) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Color _getCategoryChartColor(SubscriptionCategory category) {
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

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}