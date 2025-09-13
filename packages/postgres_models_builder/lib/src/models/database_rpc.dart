import 'package:postgres_models_builder/src/models/database_rpc_argument.dart';
import 'package:postgres_models_builder/src/util.dart';

class DatabaseRpc {
  /// A unique name for the function if there are for example multiple functions with
  /// the same name but different arguments for overloading which is often the case in postgres
  final String uniqueFunctionName;
  final String functionName;
  final String returnType;
  final List<DatabaseRpcArgument> arguments;

  const DatabaseRpc({
    required this.uniqueFunctionName,
    required this.functionName,
    required this.returnType,
    required this.arguments,
  });

  String get dartClassName =>
      '${uniqueFunctionName.convertSnakeCaseToCamelCase().toUpperCaseFirst()}Rpc';

  @override
  String toString() {
    return 'DatabaseRpc(functionName: $functionName, returnType: $returnType arguments: $arguments)';
  }
}
