import 'package:flutter/widgets.dart';
import 'package:hippo_utils/package_info_plus.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key});

  @override
  Widget build(BuildContext context) {
    final future = PackageInfo.fromPlatform();
    return FutureBuilder<PackageInfo>(
      future: future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return SizedBox();
        }
        return Text('Version: ${data.version} (${data.buildNumber})\n', textAlign: TextAlign.start);
      },
    );
  }
}
