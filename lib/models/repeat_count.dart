enum RepeatType { fixed, open }

class RepeatCount {
  final RepeatType type;
  final int n;

  const RepeatCount._(this.type, this.n);

  factory RepeatCount.fixed(int n) => RepeatCount._(RepeatType.fixed, n);
  factory RepeatCount.open() => const RepeatCount._(RepeatType.open, 0);

  factory RepeatCount.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'fixed') {
      return RepeatCount.fixed(json['n'] as int);
    }
    return RepeatCount.open();
  }

  bool get isOpen => type == RepeatType.open;

  String get label {
    if (isOpen) return 'بلا عدد محدد';
    return n == 1 ? 'مرة واحدة' : '$n مرات';
  }
}
