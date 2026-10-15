import '../../features/flashcards/domain/flashcard.dart';
import '../../features/materials/domain/study_material.dart';
import '../../features/quizzes/domain/quiz_question.dart';

/// Deterministic fixtures used until a real backend exists.
abstract final class MockData {
  static final _now = DateTime(2026, 10, 15);

  static const cellBiologyId = 'cell-biology';

  static const flashcards = <Flashcard>[
    Flashcard(
      id: 'f1',
      question:
          'What is the final electron acceptor in the electron transport chain?',
      answer: 'Oxygen',
      explanation:
          'Oxygen accepts electrons and combines with hydrogen to form water.',
    ),
    Flashcard(
      id: 'f2',
      question: 'Where does glycolysis take place?',
      answer: 'Cytoplasm',
      explanation: 'Glycolysis does not need oxygen or mitochondria.',
    ),
    Flashcard(
      id: 'f3',
      question: 'Roughly how much ATP does one glucose molecule yield?',
      answer: 'About 30 ATP',
      explanation: 'Most of it is produced by the electron transport chain.',
    ),
    Flashcard(
      id: 'f4',
      question: 'Which molecule is produced at the end of glycolysis?',
      answer: 'Pyruvate',
      explanation: 'Each glucose yields two pyruvate molecules.',
    ),
  ];

  static const questions = <QuizQuestion>[
    QuizQuestion(
      id: 'q1',
      question: 'Where does glycolysis take place in the cell?',
      options: ['Mitochondria', 'Cytoplasm', 'Nucleus', 'Golgi apparatus'],
      correctOptionIndex: 1,
      explanation:
          'Glycolysis happens in the cytoplasm. It does not need oxygen or mitochondria.',
    ),
    QuizQuestion(
      id: 'q2',
      question: 'Which molecule is the final electron acceptor?',
      options: ['Carbon dioxide', 'Oxygen', 'Water', 'Glucose'],
      correctOptionIndex: 1,
      explanation:
          'Oxygen accepts electrons at the end of the chain and forms water.',
    ),
    QuizQuestion(
      id: 'q3',
      question: 'Where does the Krebs cycle occur?',
      options: [
        'Mitochondrial matrix',
        'Cytoplasm',
        'Ribosome',
        'Cell membrane',
      ],
      correctOptionIndex: 0,
      explanation: 'The Krebs cycle runs in the mitochondrial matrix.',
    ),
  ];

  static final materials = <StudyMaterial>[
    StudyMaterial(
      id: cellBiologyId,
      title: 'Cell Biology · Chapter 4',
      type: StudyMaterialType.pdf,
      createdAt: DateTime(2026, 10, 12),
      lastAccessed: _now,
      status: ProcessingStatus.ready,
      meta: 'PDF · 18 pages · Added Oct 12',
      summaryText:
          'Mitochondria convert nutrients into ATP through cellular respiration. '
          'The process has three stages and takes place across the inner membrane.',
      keyConcepts: const ['Glycolysis', 'Krebs cycle', 'Electron transport'],
      takeaways: const [
        'One glucose molecule yields about 30 ATP.',
        'Oxygen is the final electron acceptor.',
        'Glycolysis occurs in the cytoplasm.',
      ],
      flashcards: flashcards,
      questions: questions,
    ),
    StudyMaterial(
      id: 'organic-chem',
      title: 'Organic Chemistry Notes',
      type: StudyMaterialType.pdf,
      createdAt: _now,
      lastAccessed: _now,
      status: ProcessingStatus.ready,
      meta: '12 pages · Today',
      summaryText: 'Functional groups determine how organic molecules react.',
      keyConcepts: const ['Alkanes', 'Alcohols', 'Esters'],
      takeaways: const ['Carbon forms four bonds.'],
      flashcards: flashcards,
      questions: questions,
    ),
    StudyMaterial(
      id: 'python-basics',
      title: 'Python Basics',
      type: StudyMaterialType.note,
      createdAt: DateTime(2026, 10, 9),
      lastAccessed: DateTime(2026, 10, 9),
      status: ProcessingStatus.ready,
      meta: '8 notes · Oct 9',
      summaryText:
          'Variables, loops and functions are the building blocks of Python.',
      flashcards: flashcards,
      questions: questions,
    ),
    StudyMaterial(
      id: 'calculus-limits',
      title: 'Calculus Limits',
      type: StudyMaterialType.note,
      createdAt: DateTime(2026, 10, 7),
      lastAccessed: DateTime(2026, 10, 7),
      status: ProcessingStatus.ready,
      meta: '40 cards · Oct 7',
      summaryText: 'A limit describes the value a function approaches.',
      flashcards: flashcards,
    ),
    StudyMaterial(
      id: 'aws-cert',
      title: 'AWS Cert Guide',
      type: StudyMaterialType.pdf,
      createdAt: DateTime(2026, 10, 3),
      lastAccessed: DateTime(2026, 10, 3),
      status: ProcessingStatus.ready,
      meta: '86 pages · Oct 3',
      summaryText: 'Core AWS services: compute, storage, networking and IAM.',
    ),
    StudyMaterial(
      id: 'roman-history',
      title: 'Roman History',
      type: StudyMaterialType.pastedText,
      createdAt: DateTime(2026, 9, 28),
      lastAccessed: DateTime(2026, 9, 28),
      status: ProcessingStatus.ready,
      meta: '5 notes · Sep 28',
      summaryText: 'From the Republic to the Empire.',
    ),
  ];

  static StudyMaterial byId(String id) =>
      materials.firstWhere((m) => m.id == id, orElse: () => materials.first);

  /// Minutes studied Monday to Sunday.
  static const weeklyMinutes = <int>[35, 50, 20, 60, 45, 90, 30];
}
