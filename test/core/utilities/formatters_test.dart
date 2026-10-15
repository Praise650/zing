import 'package:flutter_test/flutter_test.dart';
import 'package:zing/core/utilities/formatters.dart';

void main() {
  group('Formatters.duration', () {
    test('formats seconds as m:ss', () {
      expect(Formatters.duration(0), '0:00');
      expect(Formatters.duration(5), '0:05');
      expect(Formatters.duration(252), '4:12');
      expect(Formatters.duration(3600), '60:00');
    });
  });

  group('Formatters.studyTime', () {
    test('shows minutes only under an hour', () {
      expect(Formatters.studyTime(45), '45m');
      expect(Formatters.studyTime(0), '0m');
    });

    test('shows hours and minutes from one hour up', () {
      expect(Formatters.studyTime(60), '1h 0m');
      expect(Formatters.studyTime(760), '12h 40m');
    });
  });

  group('Formatters.percent', () {
    test('rounds to the nearest whole number', () {
      expect(Formatters.percent(1, 3), 33);
      expect(Formatters.percent(2, 3), 67);
      expect(Formatters.percent(4, 4), 100);
    });

    test('returns 0 instead of dividing by zero', () {
      expect(Formatters.percent(0, 0), 0);
    });
  });

  group('Formatters.greeting', () {
    test('changes at noon and at 6pm', () {
      String at(int h) => Formatters.greeting(DateTime(2026, 10, 15, h));
      expect(at(0), 'Good morning');
      expect(at(11), 'Good morning');
      expect(at(12), 'Good afternoon');
      expect(at(17), 'Good afternoon');
      expect(at(18), 'Good evening');
      expect(at(23), 'Good evening');
    });
  });
}
