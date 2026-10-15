import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zing/features/authentication/presentation/session_cubit.dart';

import '../../helpers/in_memory_storage.dart';

void main() {
  setUp(() => HydratedBloc.storage = InMemoryStorage());

  test('starts signed out with onboarding unseen', () {
    final s = SessionCubit().state;
    expect(s.signedIn, isFalse);
    expect(s.onboardingSeen, isFalse);
  });

  test('completeOnboarding marks it seen', () {
    final c = SessionCubit()..completeOnboarding();
    expect(c.state.onboardingSeen, isTrue);
  });

  test('signUp trims input and signs in', () {
    final c = SessionCubit()
      ..signUp(name: '  Ada Lovelace ', email: ' ada@x.com ');
    expect(c.state.signedIn, isTrue);
    expect(c.state.onboardingSeen, isTrue);
    expect(c.state.name, 'Ada Lovelace');
    expect(c.state.email, 'ada@x.com');
    expect(c.state.firstName, 'Ada');
    expect(c.state.initial, 'A');
  });

  group('signIn', () {
    test('derives a display name from the email for a new user', () {
      final c = SessionCubit()..signIn(email: 'grace.hopper@navy.mil');
      expect(c.state.name, 'Grace Hopper');
      expect(c.state.signedIn, isTrue);
    });

    test('keeps the stored name for the same email, any case', () {
      final c = SessionCubit()
        ..signUp(name: 'Ada Lovelace', email: 'ada@x.com')
        ..signOut()
        ..signIn(email: 'ADA@x.com');
      expect(c.state.name, 'Ada Lovelace');
    });

    test('replaces the name when a different email signs in', () {
      final c = SessionCubit()
        ..signUp(name: 'Ada Lovelace', email: 'ada@x.com')
        ..signOut()
        ..signIn(email: 'bob@x.com');
      expect(c.state.name, 'Bob');
    });

    test('falls back to "Student" when nothing usable is in the email', () {
      final c = SessionCubit()..signIn(email: '...@x.com');
      expect(c.state.name, 'Student');
    });
  });

  test('signOut keeps profile data but clears signedIn', () {
    final c = SessionCubit()
      ..signUp(name: 'Ada', email: 'ada@x.com')
      ..signOut();
    expect(c.state.signedIn, isFalse);
    expect(c.state.name, 'Ada');
  });

  test('initial is "?" when there is no name', () {
    expect(const SessionState().initial, '?');
  });

  test('persists and restores the session', () async {
    final c = SessionCubit()..signUp(name: 'Ada', email: 'ada@x.com');
    await c.close();
    final restored = SessionCubit();
    expect(restored.state, c.state);
  });
}
