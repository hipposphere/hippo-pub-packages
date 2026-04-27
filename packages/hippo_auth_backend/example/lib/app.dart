import 'package:dart_edge_http_server/dart_edge_http_server.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';

void main() async {
  final app = DartEdge<void>();

  final database = SqliteDatabase.inMemory();

  final authOptions = HippoAuthBackendOptions(database: database);

  final authBackend = HippoAuthBackend();

  app.mountNativeHttpRoute();

  app.listen(port: 3000);
}
