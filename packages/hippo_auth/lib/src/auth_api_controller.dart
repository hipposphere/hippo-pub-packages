import 'package:hippo_auth_api/api.dart';

class HippoAuthApiController {
  final ApiClient apiClient;

  HippoAuthApiController({required String baseUrl})
    : apiClient = ApiClient(basePath: baseUrl);


Future<test> Future<User> getCurrentUser() async {
   apiClient.
  }
}
