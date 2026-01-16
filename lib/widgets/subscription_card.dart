import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../utils/helpers.dart';
import '../constants/app_constants.dart';

/// 구독 카드 위젯
class SubscriptionCard extends StatefulWidget {
  final Subscription subscription;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePinned;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePinned,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final monthlyAmount = getMonthlyAmount(widget.subscription);
    final daysUntil = getDaysUntilBilling(widget.subscription.billingDay);

    return GestureDetector(
      onLongPress: () {
        setState(() => _showActions = !_showActions);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: getCategoryBackgroundColor(widget.subscription.category),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    widget.subscription.name[0].toUpperCase(),
                    style: TextStyle(
                      color: getCategoryTextColor(widget.subscription.category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  if (widget.subscription.pinned)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Icon(
                        Icons.push_pin,
                        size: AppIconSize.sm,
                        color: Colors.orange,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      widget.subscription.name,
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getCategoryLabel(widget.subscription.category)} · 매월 ${widget.subscription.billingDay}일',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (widget.subscription.memo?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        widget.subscription.memo!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatCurrency(monthlyAmount)}원',
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    daysUntil == 0 ? '오늘' : 'D-$daysUntil',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: daysUntil <= 3 ? Colors.red : Colors.grey.shade500,
                      fontWeight: daysUntil <= 3 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (_showActions)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionButton(
                      icon: widget.subscription.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      label: widget.subscription.pinned ? '고정 해제' : '상단 고정',
                      onPressed: widget.onTogglePinned,
                    ),
                    _ActionButton(
                      icon: Icons.edit,
                      label: '수정',
                      onPressed: widget.onEdit,
                    ),
                    _ActionButton(
                      icon: Icons.delete,
                      label: '삭제',
                      onPressed: widget.onDelete,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSize.md, color: color ?? Colors.grey.shade700),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color ?? Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
