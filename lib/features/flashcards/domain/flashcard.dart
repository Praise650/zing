import 'package:equatable/equatable.dart';

enum ConfidenceRating { again, hard, good, easy }

class Flashcard extends Equatable {
  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.explanation,
    this.lastRating,
  });

  final String id;
  final String question;
  final String answer;
  final String? explanation;
  final ConfidenceRating? lastRating;

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'] as String,
    question: json['question'] as String,
    answer: json['answer'] as String,
    explanation: json['explanation'] as String?,
    lastRating: ConfidenceRating.values.asNameMap()[json['lastRating']],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'explanation': explanation,
    'lastRating': lastRating?.name,
  };

  Flashcard rated(ConfidenceRating rating) => Flashcard(
    id: id,
    question: question,
    answer: answer,
    explanation: explanation,
    lastRating: rating,
  );

  @override
  List<Object?> get props => [id, question, answer, explanation, lastRating];
}
