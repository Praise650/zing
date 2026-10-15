import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zing/app/app.dart';

import 'helpers/in_memory_storage.dart';

void main() {
  setUp(() => HydratedBloc.storage = InMemoryStorage());

  testWidgets('app starts on onboarding', (tester) async {
    await tester.pumpWidget(const ZingApp());
    await tester.pumpAndSettle();
    expect(find.text('Turn your notes into study materials'), findsOneWidget);
  });
}
