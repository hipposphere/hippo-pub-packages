class Utils {
  const Utils._();

  static TReturn? ifNotNull<TInput, TReturn>(
    TInput? value,
    TReturn Function(TInput value) callback,
  ) {
    if (value != null) {
      return callback(value);
    }
    return null;
  }

  static TReturn? tryIfNotNull<TInput, TReturn>(
    TInput? value,
    TReturn Function(TInput value) callback,
  ) {
    if (value != null) {
      try {
        return callback(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static int? parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else if (value is double) {
      return value.toInt();
    }
    return null;
  }

  static double? parseDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value);
    } else if (value is int) {
      return value.toDouble();
    }
    return null;
  }
}
