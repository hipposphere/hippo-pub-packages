import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:hippo_utils/hippo_utils.dart';

class LinkReceiverBloc extends BlocBase {
  final AppLinks appLinks;

  LinkReceiverBloc() : appLinks = AppLinks() {
    _init();
  }

  Future<void> _init() async {
    appLinks.getInitialLink().then((link) {
      linkSubject.add(link);
    });
    appLinks.uriLinkStream.listen((link) {
      linkSubject.add(link);
    });
  }

  final linkSubject = DataSubject<Uri?>.seeded(null);

  void removeLink() {
    linkSubject.add(null);
  }

  @override
  void dispose() {}

  static LinkReceiverBloc of(BuildContext context) {
    return BlocProvider.of<LinkReceiverBloc>(context);
  }
}
