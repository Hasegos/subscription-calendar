import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subscription.dart';
import '../utils/helpers.dart';

class AddSubscriptionModal extends StatefulWidget {
  final Subscription? subscription;
  final Function(Subscription) onSave;

  const AddSubscriptionModal({
    super.key,
    this.subscription,
    required this.onSave,
  });

  @override
  State<AddSubscriptionModal> createState() => _AddSubscriptionModalState();
}

class _AddSubscriptionModalState extends State<AddSubscriptionModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _billingDayController;
  late TextEditingController _memoController;
  late SubscriptionCycle _cycle;
  late SubscriptionCategory _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subscription?.name ?? '');
    _amountController = TextEditingController(
      text: widget.subscription?.amount.toString() ?? '',
    );
    _billingDayController = TextEditingController(
      text: widget.subscription?.billingDay.toString() ?? '1',
    );
    _memoController = TextEditingController(text: widget.subscription?.memo ?? '');
    _cycle = widget.subscription?.cycle ?? SubscriptionCycle.monthly;
    _category = widget.subscription?.category ?? SubscriptionCategory.other;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _billingDayController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final billingDay = int.tryParse(_billingDayController.text) ?? 1;
    if (billingDay < 1 || billingDay > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제일은 1~31 사이의 숫자를 입력해주세요.')),
      );
      return;
    }

    final subscription = Subscription(
      id: widget.subscription?.id ?? '',
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      cycle: _cycle,
      billingDay: billingDay,
      category: _category,
      memo: _memoController.text.trim(),
      pinned: widget.subscription?.pinned ?? false,
      createdAt: widget.subscription?.createdAt ?? '',
      reminderEnabled: widget.subscription?.reminderEnabled ?? true,
      reminderDaysBefore: widget.subscription?.reminderDaysBefore ?? 3,
    );

    widget.onSave(subscription);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? '구독 수정' : '구독 추가',
                    style: const TextStyle(
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
            ),
            // 폼
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 서비스명
                      const Text(
                        '서비스명 *',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: '넷플릭스, 유튜브 프리미엄 등',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '서비스명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // 금액
                      const Text(
                        '금액 *',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: '13900',
                          suffixText: '원',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '금액을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // 결제 주기
                      const Text(
                        '결제 주기 *',
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
                      // 결제일
                      const Text(
                        '결제일 *',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _billingDayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _BillingDayInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: '1',
                          suffixText: '일',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          helperText: '매${_cycle == SubscriptionCycle.monthly ? '월' : '년'} ${_billingDayController.text.isEmpty ? '?' : _billingDayController.text}일에 결제됩니다',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '결제일을 입력해주세요';
                          }
                          final day = int.tryParse(value);
                          if (day == null || day < 1 || day > 31) {
                            return '1~31 사이의 숫자를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // 카테고리
                      const Text(
                        '카테고리',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SubscriptionCategory.values.map((cat) {
                          return ChoiceChip(
                            label: Text(getCategoryLabel(cat)),
                            selected: _category == cat,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _category = cat;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // 메모
                      const Text(
                        '메모 (선택)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _memoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '추가 정보를 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // MVP 안내
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'MVP 기능: 리마인더는 결제일 3일 전(D-3)에 고정 알림됩니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 저장 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEditing ? '수정 완료' : '구독 추가',
                            style: const TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}

// 1-31 범위 제한 InputFormatter
class _BillingDayInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    if (value < 1) {
      return newValue.copyWith(text: '1');
    } else if (value > 31) {
      return newValue.copyWith(text: '31');
    }

    return newValue;
  }
}
