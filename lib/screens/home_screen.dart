import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  final List<Subscription> subscriptions;
  final Function(Subscription) onEdit;
  final Function(String) onDelete;
  final Function(String) onTogglePinned;

  const HomeScreen({
    super.key,
    required this.subscriptions,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePinned,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _sortBy = 'amount'; // 'amount', 'date', 'name'
  bool _showSortMenu = false;

  double get _totalMonthlyAmount {
    return widget.subscriptions.fold(
      0,
      (sum, sub) => sum + getMonthlyAmount(sub),
    );
  }

  List<Subscription> get _filteredAndSorted {
    var filtered = widget.subscriptions.where((sub) {
      return sub.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      // 핀 고정된 항목 먼저
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;

      // 정렬 기준
      switch (_sortBy) {
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

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = '${now.year}년 ${now.month}월';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              currentMonth,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: Colors.grey),
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'amount',
                    child: Text(
                      '금액순',
                      style: TextStyle(
                        color: _sortBy == 'amount' ? Colors.blue : Colors.black,
                        fontWeight: _sortBy == 'amount' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date',
                    child: Text(
                      '결제일순',
                      style: TextStyle(
                        color: _sortBy == 'date' ? Colors.blue : Colors.black,
                        fontWeight: _sortBy == 'date' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name',
                    child: Text(
                      '이름순',
                      style: TextStyle(
                        color: _sortBy == 'name' ? Colors.blue : Colors.black,
                        fontWeight: _sortBy == 'name' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '구독 서비스 검색',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 월 지출 요약 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade500, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번 달 총 구독료',
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatCurrency(_totalMonthlyAmount)}원',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 ${widget.subscriptions.length}개 구독 중',
                          style: TextStyle(
                            color: Colors.blue.shade100,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 구독 리스트
          _filteredAndSorted.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _searchQuery.isNotEmpty
                              ? '검색 결과가 없습니다'
                              : '등록된 구독이 없습니다',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '+ 버튼을 눌러 구독을 추가하세요',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subscription = _filteredAndSorted[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SubscriptionCard(
                            subscription: subscription,
                            onEdit: () => widget.onEdit(subscription),
                            onDelete: () => widget.onDelete(subscription.id),
                            onTogglePinned: () => widget.onTogglePinned(subscription.id),
                          ),
                        );
                      },
                      childCount: _filteredAndSorted.length,
                    ),
                  ),
                ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

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

    return Card(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.subscription.pinned)
                            Icon(
                              Icons.push_pin,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                          if (widget.subscription.pinned) const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.subscription.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              getCategoryLabel(widget.subscription.category),
                              style: TextStyle(
                                fontSize: 12,
                                color: getCategoryTextColor(widget.subscription.category),
                              ),
                            ),
                            backgroundColor: getCategoryBackgroundColor(widget.subscription.category),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            '매월 ${widget.subscription.billingDay}일',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showActions ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () {
                    setState(() {
                      _showActions = !_showActions;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatCurrency(monthlyAmount)}원',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.subscription.cycle == SubscriptionCycle.yearly)
                      Text(
                        '연간 ${formatCurrency(widget.subscription.amount)}원',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
                if (widget.subscription.memo != null && widget.subscription.memo!.isNotEmpty)
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.subscription.memo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
              ],
            ),
            if (_showActions) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onTogglePinned,
                      icon: const Icon(Icons.push_pin, size: 16),
                      label: Text(widget.subscription.pinned ? '고정 해제' : '상단 고정'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('수정'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('구독 삭제'),
                            content: Text('${widget.subscription.name} 구독을 삭제하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete();
                                },
                                child: const Text('삭제', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('삭제'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
