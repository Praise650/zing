import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/quiz_question.dart';

class QuizState extends Equatable {
  const QuizState({
    required this.questions,
    this.index = 0,
    this.selected,
    this.answered = false,
    this.answers = const [],
    this.finished = false,
  });

  final List<QuizQuestion> questions;
  final int index;
  final int? selected;

  /// True once the current answer is locked in.
  final bool answered;

  /// Selected option per completed question (same order as [questions]).
  final List<int> answers;
  final bool finished;

  QuizQuestion get current => questions[index];
  bool get isLast => index == questions.length - 1;
  bool get currentCorrect => selected == current.correctOptionIndex;

  int get correctCount {
    var n = 0;
    for (var i = 0; i < answers.length; i++) {
      if (answers[i] == questions[i].correctOptionIndex) n++;
    }
    return n;
  }

  int get missedCount => answers.length - correctCount;

  /// Score (%) = correct / total * 100.
  double get scorePercent =>
      questions.isEmpty ? 0 : correctCount / questions.length * 100;

  QuizState copyWith({
    int? index,
    int? Function()? selected,
    bool? answered,
    List<int>? answers,
    bool? finished,
  }) => QuizState(
    questions: questions,
    index: index ?? this.index,
    selected: selected != null ? selected() : this.selected,
    answered: answered ?? this.answered,
    answers: answers ?? this.answers,
    finished: finished ?? this.finished,
  );

  @override
  List<Object?> get props => [
    questions,
    index,
    selected,
    answered,
    answers,
    finished,
  ];
}

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(List<QuizQuestion> questions)
    : super(QuizState(questions: questions));

  /// Ignored once the answer is locked.
  void select(int option) {
    if (state.answered || state.finished) return;
    emit(state.copyWith(selected: () => option));
  }

  /// Locks the current selection.
  void check() {
    if (state.answered || state.selected == null) return;
    emit(
      state.copyWith(
        answered: true,
        answers: [...state.answers, state.selected!],
      ),
    );
  }

  void next() {
    if (!state.answered) return;
    if (state.isLast) {
      emit(state.copyWith(finished: true));
    } else {
      emit(
        state.copyWith(
          index: state.index + 1,
          selected: () => null,
          answered: false,
        ),
      );
    }
  }

  void retake() => emit(QuizState(questions: state.questions));
}
