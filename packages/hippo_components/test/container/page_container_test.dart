import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';

void main() {
  testWidgets('page containers tolerate transient negative top padding', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(390, 844), padding: EdgeInsets.only(top: -44)),
          child: PageContainer(title: 'Title', body: SizedBox()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const CupertinoApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(390, 844), padding: EdgeInsets.only(top: -44)),
          child: PlatformPageContainer(title: 'Title', body: SizedBox()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
