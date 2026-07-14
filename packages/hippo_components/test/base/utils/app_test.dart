import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';

void main() {
  testWidgets('builder wraps the navigator and every pushed route', (tester) async {
    const shellKey = ValueKey<String>('app-shell');

    await tester.pumpWidget(
      App(
        brightness: Brightness.light,
        builder: (context, child) => Stack(
          key: shellKey,
          fit: StackFit.expand,
          children: [
            ?child,
            const IgnorePointer(child: Align(child: Text('Global overlay'))),
          ],
        ),
        home: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const Center(child: Text('Next page'))),
                );
              },
              child: const Text('Open page'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Global overlay'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('Open page'), matching: find.byKey(shellKey)),
      findsOneWidget,
    );

    await tester.tap(find.text('Open page'));
    await tester.pumpAndSettle();

    expect(find.text('Next page'), findsOneWidget);
    expect(find.text('Global overlay'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('Next page'), matching: find.byKey(shellKey)),
      findsOneWidget,
    );
  });
}
