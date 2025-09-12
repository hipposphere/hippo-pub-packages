import 'package:hippo_utils/src/store/store.dart';
import 'impl/stub.dart'
    if (dart.library.io) 'impl/io.dart'
    if (dart.library.js_interop) 'impl/web.dart'
    as impl;

FileStore getCommonFileStore({required CommonFileStoreOptions options}) {
  return impl.getCommonFileStore(options);
}

class CommonFileStoreOptions {
  final String storePath;

  const CommonFileStoreOptions({required this.storePath});
}
