import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/flashcard.dart';

class FlashcardState extends Equatable {
  const FlashcardState({required this.cards, this.index = 0});

  final List<Flashcard> cards;
  final int index;

  int get total => cards.length;
  bool get isFinished => index >= total;
  Flashcard? get current => isFinished ? null : cards[index];
  double get progress => total == 0 ? 0 : index / total;

  @override
  List<Object?> get props => [cards, index];
}

/// Tracks deck position and ratings. Card flipping stays in widget state.
class FlashcardCubit extends Cubit<FlashcardState> {
  FlashcardCubit(List<Flashcard> cards) : super(FlashcardState(cards: cards));

  void rate(ConfidenceRating rating) {
    if (state.isFinished) return;
    final cards = [...state.cards];
    cards[state.index] = cards[state.index].rated(rating);
    emit(FlashcardState(cards: cards, index: state.index + 1));
  }

  void restart() => emit(
    FlashcardState(
      cards: [
        for (final c in state.cards)
          Flashcard(
            id: c.id,
            question: c.question,
            answer: c.answer,
            explanation: c.explanation,
          ),
      ],
    ),
  );
}
