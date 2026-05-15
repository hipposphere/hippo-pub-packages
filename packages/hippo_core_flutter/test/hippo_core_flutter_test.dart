import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class _TestBloc extends BlocBase {
  var disposed = false;

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  testWidgets('BlocProvider exposes a bloc by type', (tester) async {
    final bloc = _TestBloc();

    await tester.pumpWidget(
      BlocProvider<_TestBloc>(
        bloc: bloc,
        child: Builder(
          builder: (context) {
            expect(BlocProvider.of<_TestBloc>(context), same(bloc));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('DataSubjectBuilder rebuilds when subject changes', (tester) async {
    final subject = DataSubject.seeded('first');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DataSubjectBuilder<String>(subject: subject, builder: (context, data) => Text(data)),
      ),
    );

    expect(find.text('first'), findsOneWidget);

    subject.add('second');
    await tester.pump();

    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('common and sliver layout widgets render their children', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverGap(8),
            SliverChild(child: Text('single child')),
            SliverColumn(spacing: 4, children: [Text('column child'), Gap(8)]),
            LimitedSliverPadded(
              sliver: SliverToBoxAdapter(
                child: LimitedContainerPadded(child: Text('limited child')),
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('single child'), findsOneWidget);
    expect(find.text('column child'), findsOneWidget);
    expect(find.text('limited child'), findsOneWidget);
  });

  test('MockKeyValueStore stores and removes values', () async {
    final store = MockKeyValueStore();

    await store.setString('name', 'Hippo');
    await store.setBool('enabled', true);

    expect(await store.getString('name'), 'Hippo');
    expect(await store.getBool('enabled'), isTrue);
    expect(await store.containsKey('name'), isTrue);

    await store.removeValue('name');

    expect(await store.containsKey('name'), isFalse);
  });
}
