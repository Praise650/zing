import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zing/app/app.dart';
import 'package:zing/app/router.dart';
import 'package:zing/core/widgets/zing_button.dart';

import 'in_memory_storage.dart';

/// Pumps the real [ZingApp] on a phone-sized surface with fresh in-memory
/// storage. Auth redirects are off unless [router] is created with a session,
/// so any [location] can be opened directly.
Future<void> pumpZing(
  WidgetTester tester, {
  String location = '/home',
  GoRouter? router,
  String? signedInAs,
  String email = 'alex@uni.edu',
  Size logicalSize = const Size(390, 844),
}) async {
  tester.view.physicalSize = logicalSize * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final storage = InMemoryStorage();
  if (signedInAs != null) {
    storage.write('SessionCubit', {
      'onboardingSeen': true,
      'signedIn': true,
      'name': signedInAs,
      'email': email,
    });
  }
  HydratedBloc.storage = storage;

  await tester.pumpWidget(
    ZingApp(router: router ?? createRouter(initialLocation: location)),
  );
  await tester.pumpAndSettle();
}

/// A route that only renders its location, for asserting navigation.
GoRoute stubRoute(String path) => GoRoute(
  path: path,
  builder: (_, state) =>
      Scaffold(body: Center(child: Text('stub:${state.matchedLocation}'))),
);

/// Finds [finder] only inside the screen of type [T], so shared labels such as
/// the bottom-nav tab names do not cause ambiguous matches.
Finder inScreen<T extends Widget>(Finder finder) =>
    find.descendant(of: find.byType(T), matching: finder);

/// The [ZingButton] whose label is [label].
Finder zingButton(String label) => find.widgetWithText(ZingButton, label);

bool isEnabled(WidgetTester tester, String label) =>
    tester.widget<ZingButton>(zingButton(label)).onPressed != null;

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
