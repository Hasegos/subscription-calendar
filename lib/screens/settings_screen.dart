import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAllData(BuildContext context) async {
    // 첫 번째 경고
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 모든 데이터 삭제'),
        content: const Text(
          '모든 구독 데이터가 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    // 두 번째 최종 확인
    if (!context.mounted) return;
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 최종 확인'),
        content: const Text(
          '마지막 확인입니다.\n\n삭제된 데이터는 복구할 수 없습니다.\n정말로 모든 데이터를 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('영구 삭제'),
          ),
        ],
      ),
    );

    if (secondConfirm != true) return;

    // 실제 데이터 삭제
    try {
      await StorageService.clearAll();

      if (!context.mounted) return;

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 데이터가 삭제되었습니다. 앱을 재시작합니다.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 2초 후 앱 재시작 (온보딩으로 이동)
      await Future.delayed(const Duration(seconds: 2));

      if (!context.mounted) return;

      // 루트로 이동하여 앱 재시작 효과
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 앱 정보 카드
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '구독 달력',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '버전 1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '로그인 없이 사용하는 로컬 오프라인 구독 관리 앱',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 개인정보 보호
          _buildSection(
            title: '개인정보 보호',
            icon: Icons.shield,
            iconColor: Colors.green,
            children: [
              _buildInfoItem(
                icon: Icons.storage,
                title: '모든 데이터는 기기 내에만 저장됩니다',
                subtitle: '서버와 통신하지 않으며, 외부로 전송되지 않습니다',
              ),
              _buildInfoItem(
                icon: Icons.smartphone,
                title: '로그인 및 회원가입 불필요',
                subtitle: '개인 식별 정보를 수집하지 않습니다',
              ),
              _buildInfoItem(
                icon: Icons.security,
                title: '민감 정보 비수집',
                subtitle: '카드번호, 계정 정보 등을 요구하지 않습니다',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 알림 설정
          _buildSection(
            title: '알림 설정',
            icon: Icons.notifications,
            iconColor: Colors.blue,
            children: [
              ListTile(
                title: const Text('결제일 재확인'),
                subtitle: const Text('결제일 3일 전(D-3) 오전 10시 알림'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '알림',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 기본 설정
          _buildSection(
            title: '기본 설정',
            icon: Icons.tune,
            iconColor: Colors.grey,
            children: [
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('통화'),
                trailing: Text(
                  'KRW (원)',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 앱 정보
          _buildSection(
            title: '앱 정보',
            icon: Icons.info,
            iconColor: Colors.grey,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...const [
                      '• 완전 오프라인 동작',
                      '• 서버 통신 없음',
                      '• 로컬 스토리지 기반 데이터 저장',
                      '• 개인정보 및 결제정보 비수집',
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
          const SizedBox(height: 16),
          // 데이터 관리
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '데이터 관리',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '앱을 삭제하면 모든 데이터가 영구적으로 삭제됩니다. 삭제된 데이터는 복구할 수 없습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _deleteAllData(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('모든 데이터 삭제'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 버전 정보
          Center(
            child: Column(
              children: [
                Text(
                  '구독 달력 v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ for privacy-conscious users',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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