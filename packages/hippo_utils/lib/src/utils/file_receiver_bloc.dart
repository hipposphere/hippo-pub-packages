import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hippo_utils/hippo_utils.dart';

class FileReceiverBloc extends BlocBase {
  FileReceiverBloc() {
    _init();
  }

  Future<void> _init() async {
    const fileChannel = MethodChannel('hippo_utils/file');
    fileChannel.setMethodCallHandler((call) async {
      if (call.method == 'onFileOpened') {
        final String path = call.arguments;

        // ignore: avoid_print
        print('Received file at: $path');
        fileSubject.add(path);
      }
    });
  }

  final fileSubject = DataSubject<String?>.seeded(null);

  void removeFile() {
    fileSubject.add(null);
  }

  @override
  void dispose() {}

  static FileReceiverBloc of(BuildContext context) {
    return BlocProvider.of<FileReceiverBloc>(context);
  }
}
