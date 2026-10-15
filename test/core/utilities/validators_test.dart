import 'package:flutter_test/flutter_test.dart';
import 'package:zing/core/utilities/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts a well-formed address, ignoring surrounding spaces', () {
      expect(Validators.email('ada@example.com'), isNull);
      expect(Validators.email('  ada@example.com  '), isNull);
    });

    for (final bad in [
      '',
      'ada',
      'ada@',
      '@example.com',
      'ada@example',
      'a b@x.com',
    ]) {
      test('rejects "$bad"', () {
        expect(Validators.email(bad), 'Enter a valid email address.');
      });
    }
  });

  group('Validators.name', () {
    test('needs at least two characters after trimming', () {
      expect(Validators.name('Al'), isNull);
      expect(Validators.name(' A '), isNotNull);
      expect(Validators.name(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('needs at least eight characters', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('passwordStrength', () {
    const cases = {
      '': PasswordStrength.empty,
      'abc': PasswordStrength.weak,
      'A1!': PasswordStrength.weak, // short passwords are capped at weak
      'abcdef': PasswordStrength.fair,
      'abcdefgh': PasswordStrength.fair,
      'Abcdefgh': PasswordStrength.fair,
      'Abcdefg1': PasswordStrength.good,
      'Abcdef1!': PasswordStrength.strong,
    };
    cases.forEach((input, expected) {
      test('"$input" is $expected', () {
        expect(passwordStrength(input), expected);
      });
    });

    test('segments match the enum index', () {
      expect(PasswordStrength.empty.segments, 0);
      expect(PasswordStrength.strong.segments, 4);
    });

    test('empty has no message', () {
      expect(PasswordStrength.empty.message, isEmpty);
    });
  });
}
