import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  runApp(App(brightness: Brightness.light, home: HomePage()));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Hippo Auth Example',
      backAction: null,
      body: ScrollableView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              Button(
                onTap: () => openHippoAuthExamplePage(
                  context: context,
                  baseUrl: Uri.parse('http://localhost:3005/auth'),
                ),
                label: 'Test localhost:3005',
              ),
              Gap(8),
              Button(
                label: 'Custom URL',
                onTap: () async {
                  final text = await GetTextModal().open(context);
                  if (text != null) {
                    if (!context.mounted) return;
                    openHippoAuthExamplePage(
                      context: context,
                      baseUrl: Uri.parse(text),
                    );
                  }
                },
              ),
            ],
          ),
          SliverGap(64),
        ],
      ),
    );
  }
}

Future<void> openHippoAuthExamplePage({
  required BuildContext context,
  required Uri baseUrl,
}) async {
  final hippoAuthBloc = HippoAuthBloc.create(
    baseUrl: baseUrl,
    sessionStore: MockKeyValueStore(),
  );
  await Routing.openPage(
    context,
    MultiBlocProvider(
      blocDefiners: [BlocDefiner<HippoAuthBloc>(bloc: hippoAuthBloc)],
      child: const _HippoAuthExamplePage(),
    ),
  );
}

class _HippoAuthExamplePage extends StatelessWidget {
  const _HippoAuthExamplePage();

  @override
  Widget build(BuildContext context) {
    final hippoAuthBloc = HippoAuthBloc.of(context);
    return HippoAuthWrapper(
      loadingBuilder: (context) =>
          Center(child: CircularProgressIndicator.adaptive()),
      loginBuilder: (context) => HippoAuthLoginFlow(),
      childBuilder: (context, session) => PageContainer(
        title: 'Logged in!',
        body: LimitedContainerPadded(
          alignment: Alignment.center,
          child: Button(
            onTap: hippoAuthBloc.loginController.signOut,
            label: 'Logout',
          ),
        ),
      ),
    );
  }
}
