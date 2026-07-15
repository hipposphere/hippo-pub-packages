class FocusedTextFieldContext {
  const FocusedTextFieldContext({
    required this.available,
    this.reason,
    this.appIdentifier,
    this.appName,
    this.role,
    this.subrole,
    this.isEditable,
    this.isSecure,
    this.selectionStart,
    this.selectionLength,
    this.selectedText,
    this.textBeforeSelection,
    this.textAfterSelection,
    this.fullTextLength,
  });

  factory FocusedTextFieldContext.fromMap(Map<String, dynamic> map) {
    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return null;
    }

    return FocusedTextFieldContext(
      available: map['available'] == true,
      reason: map['reason'] as String?,
      appIdentifier: map['appIdentifier'] as String?,
      appName: map['appName'] as String?,
      role: map['role'] as String?,
      subrole: map['subrole'] as String?,
      isEditable: map['isEditable'] as bool?,
      isSecure: map['isSecure'] as bool?,
      selectionStart: asInt(map['selectionStart']),
      selectionLength: asInt(map['selectionLength']),
      selectedText: map['selectedText'] as String?,
      textBeforeSelection: map['textBeforeSelection'] as String?,
      textAfterSelection: map['textAfterSelection'] as String?,
      fullTextLength: asInt(map['fullTextLength']),
    );
  }

  final bool available;
  final String? reason;
  final String? appIdentifier;
  final String? appName;
  final String? role;
  final String? subrole;
  final bool? isEditable;
  final bool? isSecure;
  final int? selectionStart;
  final int? selectionLength;
  final String? selectedText;
  final String? textBeforeSelection;
  final String? textAfterSelection;
  final int? fullTextLength;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'available': available,
      'reason': reason,
      'appIdentifier': appIdentifier,
      'appName': appName,
      'role': role,
      'subrole': subrole,
      'isEditable': isEditable,
      'isSecure': isSecure,
      'selectionStart': selectionStart,
      'selectionLength': selectionLength,
      'selectedText': selectedText,
      'textBeforeSelection': textBeforeSelection,
      'textAfterSelection': textAfterSelection,
      'fullTextLength': fullTextLength,
    };
  }
}
