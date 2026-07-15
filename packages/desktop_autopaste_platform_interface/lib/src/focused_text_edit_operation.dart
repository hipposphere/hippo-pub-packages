class FocusedTextEditOperation {
  const FocusedTextEditOperation({
    required this.start,
    required this.end,
    required this.replacement,
  });

  factory FocusedTextEditOperation.replaceRange({
    required int start,
    required int end,
    required String replacement,
  }) {
    return FocusedTextEditOperation(
      start: start,
      end: end,
      replacement: replacement,
    );
  }

  factory FocusedTextEditOperation.insert({
    required int offset,
    required String text,
  }) {
    return FocusedTextEditOperation(
      start: offset,
      end: offset,
      replacement: text,
    );
  }

  final int start;
  final int end;
  final String replacement;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start': start,
      'end': end,
      'replacement': replacement,
    };
  }
}
