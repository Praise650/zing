import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation = '',
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List),
    correctOptionIndex: json['correctOptionIndex'] as int,
    explanation: json['explanation'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctOptionIndex': correctOptionIndex,
    'explanation': explanation,
  };

  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  @override
  List<Object?> get props => [id, question, options, correctOptionIndex];
}
