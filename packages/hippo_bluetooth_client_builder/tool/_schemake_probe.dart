import 'package:schemake/dart_gen.dart';
import 'package:schemake/schemake.dart';

void main() {
  const payload = Objects('Payload', {
    'command': Property(Strings()),
    'count': Property(Nullable(Ints())),
  });
  final out = generateDartClasses([payload]);
  print(out.toString());
}
