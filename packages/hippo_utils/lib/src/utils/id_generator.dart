import 'package:uuid/v4.dart' as uuid_v4;

class IdGenerator {
  const IdGenerator._();

  static String uuidV4() {
    return uuid_v4.UuidV4().generate();
  }
}
