class FormatUtils {
  /// 숫자 포맷 (천 단위 구분)
  static String formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// 날짜 포맷
  static String formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 월 포맷
  static String formatMonth(DateTime date) {
    return '${date.year}년 ${date.month}월';
  }
}