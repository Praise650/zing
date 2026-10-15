import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/quizzes/domain/quiz_question.dart';
import 'package:zing/features/quizzes/presentation/quiz_cubit.dart';

const _questions = [
  QuizQuestion(
    id: 'a',
    question: 'A?',
    options: ['x', 'y'],
    correctOptionIndex: 0,
  ),
  QuizQuestion(
    id: 'b',
    question: 'B?',
    options: ['x', 'y'],
    correctOptionIndex: 1,
  ),
];

void main() {
  QuizCubit build() => QuizCubit(_questions);

  test('starts on the first question, unanswered', () {
    final s = build().state;
    expect(s.index, 0);
    expect(s.selected, isNull);
    expect(s.answered, isFalse);
    expect(s.finished, isFalse);
  });

  blocTest<QuizCubit, QuizState>(
    'select stores the chosen option',
    build: build,
    act: (c) => c.select(1),
    expect: () => [const QuizState(questions: _questions, selected: 1)],
  );

  blocTest<QuizCubit, QuizState>(
    'check without a selection does nothing',
    build: build,
    act: (c) => c.check(),
    expect: () => <QuizState>[],
  );

  blocTest<QuizCubit, QuizState>(
    'check locks the answer and records it',
    build: build,
    act: (c) => c
      ..select(0)
      ..check(),
    skip: 1,
    expect: () => [
      const QuizState(
        questions: _questions,
        selected: 0,
        answered: true,
        answers: [0],
      ),
    ],
  );

  blocTest<QuizCubit, QuizState>(
    'select is ignored after the answer is locked',
    build: build,
    act: (c) => c
      ..select(0)
      ..check()
      ..select(1),
    verify: (c) => expect(c.state.selected, 0),
  );

  blocTest<QuizCubit, QuizState>(
    'next before checking does nothing',
    build: build,
    act: (c) => c
      ..select(0)
      ..next(),
    verify: (c) => expect(c.state.index, 0),
  );

  blocTest<QuizCubit, QuizState>(
    'next advances and clears the selection',
    build: build,
    act: (c) => c
      ..select(0)
      ..check()
      ..next(),
    verify: (c) {
      expect(c.state.index, 1);
      expect(c.state.selected, isNull);
      expect(c.state.answered, isFalse);
      expect(c.state.answers, [0]);
    },
  );

  group('full run', () {
    test('scores correct and missed answers and finishes after the last', () {
      final c = build()
        ..select(0)
        ..check()
        ..next()
        ..select(0) // wrong: correct is 1
        ..check();
      expect(c.state.isLast, isTrue);
      expect(c.state.currentCorrect, isFalse);
      c.next();
      expect(c.state.finished, isTrue);
      expect(c.state.correctCount, 1);
      expect(c.state.missedCount, 1);
      expect(c.state.scorePercent, 50);
    });

    test('retake resets everything', () {
      final c = build()
        ..select(0)
        ..check()
        ..retake();
      expect(c.state, const QuizState(questions: _questions));
    });
  });

  test('scorePercent is 0 for an empty quiz', () {
    expect(QuizCubit(const []).state.scorePercent, 0);
  });
}
