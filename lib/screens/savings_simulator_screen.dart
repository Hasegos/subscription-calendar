import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subscription.dart';
import '../utils/helpers.dart';

class SavingsSimulatorScreen extends StatefulWidget {
  final List<Subscription> subscriptions;

  const SavingsSimulatorScreen({
    super.key,
    required this.subscriptions,
  });

  @override
  State<SavingsSimulatorScreen> createState() => _SavingsSimulatorScreenState();
}

class _SavingsSimulatorScreenState extends State<SavingsSimulatorScreen> {
  late Map<String, bool> _activeSubscriptions;
  List<SimulatedSubscription> _simulatedSubscriptions = [];
  
  @override
  void initState() {
    super.initState();
    // 초기에는 모든 구독이 활성화 상태
    _activeSubscriptions = {
      for (var sub in widget.subscriptions) sub.id: true,
    };
  }

  double get _originalMonthlyTotal {
    return widget.subscriptions.fold<double>(
      0,
      (sum, sub) => sum + getMonthlyAmount(sub),
    );
  }

  double get _currentMonthlyTotal {
    double total = 0;
    // 활성화된 기존 구독
    for (var sub in widget.subscriptions) {
      if (_activeSubscriptions[sub.id] == true) {
        total += getMonthlyAmount(sub);
      }
    }
    // 시뮬레이션으로 추가된 구독
    for (var simSub in _simulatedSubscriptions) {
      total += simSub.monthlyAmount;
    }
    return total;
  }

  double get _monthlySavings {
    return _originalMonthlyTotal - _currentMonthlyTotal;
  }

  double get _yearlySavings {
    return _monthlySavings * 12;
  }

  int get _removedCount {
    return _activeSubscriptions.values.where((active) => !active).length;
  }

  int get _addedCount {
    return _simulatedSubscriptions.length;
  }

  void _showAddSimulatedSubscription() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSimulatedSubscriptionModal(
        onAdd: (simSub) {
          setState(() {
            _simulatedSubscriptions.add(simSub);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _resetSimulation() {
    setState(() {
      _activeSubscriptions = {
        for (var sub in widget.subscriptions) sub.id: true,
      };
      _simulatedSubscriptions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = _monthlySavings > 0;
    final isSpending = _monthlySavings < 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '절감 시뮬레이션',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _resetSimulation,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('초기화'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 변동 요약 카드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSaving
                    ? [Colors.green.shade500, Colors.green.shade600]
                    : isSpending
                        ? [Colors.red.shade500, Colors.red.shade600]
                        : [Colors.blue.shade500, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isSaving ? Colors.green : isSpending ? Colors.red : Colors.blue)
                      .withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSaving
                          ? Icons.trending_down
                          : isSpending
                              ? Icons.trending_up
                              : Icons.trending_flat,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isSaving
                          ? '월 ${formatCurrency(_monthlySavings.abs())}원 절감'
                          : isSpending
                              ? '월 ${formatCurrency(_monthlySavings.abs())}원 증가'
                              : '변동 없음',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '원래 월 지출',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${formatCurrency(_originalMonthlyTotal)}원',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '시뮬레이션 월 지출',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${formatCurrency(_currentMonthlyTotal)}원',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white30, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '연간 절감/증가',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${isSaving ? '-' : isSpending ? '+' : ''}${formatCurrency(_yearlySavings.abs())}원',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_removedCount > 0 || _addedCount > 0) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_removedCount > 0)
                        Chip(
                          label: Text(
                            '제거: $_removedCount개',
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.zero,
                        ),
                      if (_addedCount > 0)
                        Chip(
                          label: Text(
                            '추가: $_addedCount개',
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 기존 구독 목록
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '현재 구독',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.subscriptions.length - _removedCount}/${widget.subscriptions.length}개',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.subscriptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '등록된 구독이 없습니다',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...widget.subscriptions.map((sub) {
              final isActive = _activeSubscriptions[sub.id] ?? true;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isActive ? Colors.grey.shade200 : Colors.red.shade200,
                  ),
                ),
                child: CheckboxListTile(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      _activeSubscriptions[sub.id] = value ?? true;
                    });
                  },
                  title: Text(
                    sub.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Chip(
                        label: Text(
                          getCategoryLabel(sub.category),
                          style: TextStyle(
                            fontSize: 10,
                            color: getCategoryTextColor(sub.category),
                          ),
                        ),
                        backgroundColor: getCategoryBackgroundColor(sub.category),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '매${sub.cycle == SubscriptionCycle.monthly ? '월' : '년'} ${sub.billingDay}일',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  secondary: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatCurrency(getMonthlyAmount(sub))}원',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isActive ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (sub.cycle == SubscriptionCycle.yearly)
                        Text(
                          '연간',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          const SizedBox(height: 24),
          // 가상 구독 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '가상 구독 추가',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddSimulatedSubscription,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('추가'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_simulatedSubscriptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '새로운 구독을 추가하면\n금액 변동을 미리 확인할 수 있습니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...(_simulatedSubscriptions.asMap().entries.map((entry) {
              final index = entry.key;
              final simSub = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    simSub.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '월 ${formatCurrency(simSub.monthlyAmount)}원',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red.shade400),
                    onPressed: () {
                      setState(() {
                        _simulatedSubscriptions.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }).toList()),
          const SizedBox(height: 24),
          // 도움말
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '시뮬레이션 팁',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• 체크 해제: 해당 구독을 해지했을 때의 절감액 확인\n'
                        '• 가상 추가: 새 구독을 시작했을 때의 지출 증가 확인\n'
                        '• 실제 구독 데이터는 변경되지 않습니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 가상 구독 데이터 모델
class SimulatedSubscription {
  final String name;
  final double monthlyAmount;

  SimulatedSubscription({
    required this.name,
    required this.monthlyAmount,
  });
}

// 가상 구독 추가 모달
class _AddSimulatedSubscriptionModal extends StatefulWidget {
  final Function(SimulatedSubscription) onAdd;

  const _AddSimulatedSubscriptionModal({
    required this.onAdd,
  });

  @override
  State<_AddSimulatedSubscriptionModal> createState() =>
      _AddSimulatedSubscriptionModalState();
}

class _AddSimulatedSubscriptionModalState
    extends State<_AddSimulatedSubscriptionModal> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  SubscriptionCycle _cycle = SubscriptionCycle.monthly;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (_nameController.text.trim().isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서비스명과 금액을 입력해주세요')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final monthlyAmount = _cycle == SubscriptionCycle.monthly ? amount : amount / 12;

    widget.onAdd(SimulatedSubscription(
      name: _nameController.text.trim(),
      monthlyAmount: monthlyAmount,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '가상 구독 추가',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '서비스명',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '예: 디즈니+',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '금액',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '9900',
                  suffixText: '원',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '결제 주기',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('매월')),
                      selected: _cycle == SubscriptionCycle.monthly,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _cycle = SubscriptionCycle.monthly;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('매년')),
                      selected: _cycle == SubscriptionCycle.yearly,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _cycle = SubscriptionCycle.yearly;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '시뮬레이션에 추가',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
