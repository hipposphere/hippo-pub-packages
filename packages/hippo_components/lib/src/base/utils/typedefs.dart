import 'package:flutter/widgets.dart';

typedef ContextVoidCallback = void Function(BuildContext context);

typedef Contextable<T> = T Function(BuildContext context);

T contextValue<T>(BuildContext context, T value) => value;

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
