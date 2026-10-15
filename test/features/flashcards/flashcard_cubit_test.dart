import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zing/features/flashcards/domain/flashcard.dart';
import 'package:zing/features/flashcards/presentation/flashcard_cubit.dart';

const _cards = [
  Flashcard(id: '1', question: 'Q1', answer: 'A1'),
  Flashcard(id: '2', question: 'Q2', answer: 'A2'),
];

void main() {
  test('starts at the first card with no progress', () {
    final s = FlashcardCubit(_cards).state;
    expect(s.current?.id, '1');
    expect(s.progress, 0);
    expect(s.isFinished, isFalse);
  });

  blocTest<FlashcardCubit, FlashcardState>(
    'rate stores the rating and moves to the next card',
    build: () => FlashcardCubit(_cards),
    act: (c) => c.rate(ConfidenceRating.good),
    verify: (c) {
      expect(c.state.index, 1);
      expect(c.state.cards.first.lastRating, ConfidenceRating.good);
      expect(c.state.progress, 0.5);
    },
  );

  test(
    'rating the last card finishes the deck and further ratings are ignored',
    () {
      final c = FlashcardCubit(_cards)
        ..rate(ConfidenceRating.easy)
        ..rate(ConfidenceRating.again);
      expect(c.state.isFinished, isTrue);
      expect(c.state.current, isNull);
      final finished = c.state;
      c.rate(ConfidenceRating.hard);
      expect(c.state, finished);
    },
  );

  test('restart clears ratings and returns to the first card', () {
    final c = FlashcardCubit(_cards)
      ..rate(ConfidenceRating.easy)
      ..restart();
    expect(c.state.index, 0);
    expect(c.state.cards.every((card) => card.lastRating == null), isTrue);
  });

  test('empty deck is finished with zero progress', () {
    final s = FlashcardCubit(const []).state;
    expect(s.isFinished, isTrue);
    expect(s.progress, 0);
  });
}
