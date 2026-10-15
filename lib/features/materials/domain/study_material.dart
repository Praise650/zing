import 'package:equatable/equatable.dart';

import '../../flashcards/domain/flashcard.dart';
import '../../quizzes/domain/quiz_question.dart';

enum StudyMaterialType { pdf, note, pastedText, scan }

enum ProcessingStatus { idle, uploading, processing, ready, failed }

class StudyMaterial extends Equatable {
  const StudyMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.lastAccessed,
    this.status = ProcessingStatus.idle,
    this.meta = '',
    this.summaryText,
    this.keyConcepts = const [],
    this.takeaways = const [],
    this.flashcards = const [],
    this.questions = const [],
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) => [
      for (final e in (json[key] as List? ?? const []))
        parse(Map<String, dynamic>.from(e as Map)),
    ];
    return StudyMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      type: StudyMaterialType.values.byName(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      status: ProcessingStatus.values.byName(json['status'] as String),
      meta: json['meta'] as String? ?? '',
      summaryText: json['summaryText'] as String?,
      keyConcepts: List<String>.from(json['keyConcepts'] as List? ?? const []),
      takeaways: List<String>.from(json['takeaways'] as List? ?? const []),
      flashcards: list('flashcards', Flashcard.fromJson),
      questions: list('questions', QuizQuestion.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'lastAccessed': lastAccessed.toIso8601String(),
    'status': status.name,
    'meta': meta,
    'summaryText': summaryText,
    'keyConcepts': keyConcepts,
    'takeaways': takeaways,
    'flashcards': [for (final f in flashcards) f.toJson()],
    'questions': [for (final q in questions) q.toJson()],
  };

  final String id;
  final String title;
  final StudyMaterialType type;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final ProcessingStatus status;

  /// Short descriptor shown on cards, e.g. "12 pages · Today".
  final String meta;
  final String? summaryText;
  final List<String> keyConcepts;
  final List<String> takeaways;
  final List<Flashcard> flashcards;
  final List<QuizQuestion> questions;

  bool get hasSummary => summaryText != null && summaryText!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    createdAt,
    lastAccessed,
    status,
    meta,
    summaryText,
  ];
}
