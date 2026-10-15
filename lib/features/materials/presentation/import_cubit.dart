import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/mock_data.dart';
import '../domain/study_material.dart';

class ImportState extends Equatable {
  const ImportState({
    this.status = ProcessingStatus.idle,
    this.fileName,
    this.progress = 0,
    this.errorMessage,
    this.material,
  });

  final ProcessingStatus status;
  final String? fileName;

  /// Upload progress, 0.0 to 1.0.
  final double progress;
  final String? errorMessage;

  /// The material created once [status] is [ProcessingStatus.ready].
  final StudyMaterial? material;

  @override
  List<Object?> get props => [
    status,
    fileName,
    progress,
    errorMessage,
    material,
  ];
}

/// Simulated import pipeline: upload (1.5s) -> processing (3s) -> ready.
class ImportCubit extends Cubit<ImportState> {
  ImportCubit({
    this.uploadDuration = const Duration(milliseconds: 1500),
    this.processingDuration = const Duration(seconds: 3),
    this.tick = const Duration(milliseconds: 50),
    this.onImported,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const ImportState());

  /// Called with the finished material, e.g. to add it to the library.
  final void Function(StudyMaterial material)? onImported;
  final DateTime Function() _now;

  final Duration uploadDuration;
  final Duration processingDuration;
  final Duration tick;
  Timer? _timer;

  bool _failNext = false;
  StudyMaterialType _type = StudyMaterialType.pdf;
  String? _text;

  /// Makes the next run end in a failure (demo of the error state).
  void failNextRun() => _failNext = true;

  /// Repeats the last [start] call, e.g. after a failure.
  void retry() => start(state.fileName ?? 'file.pdf', type: _type, text: _text);

  void start(
    String fileName, {
    StudyMaterialType type = StudyMaterialType.pdf,
    String? text,
  }) {
    _timer?.cancel();
    _type = type;
    _text = text;
    final fail = _failNext;
    _failNext = false;
    emit(
      ImportState(
        status: ProcessingStatus.uploading,
        fileName: fileName,
        progress: 0,
      ),
    );
    final steps = (uploadDuration.inMicroseconds / tick.inMicroseconds).ceil();
    var step = 0;
    _timer = Timer.periodic(tick, (t) {
      step++;
      if (step < steps) {
        emit(
          ImportState(
            status: ProcessingStatus.uploading,
            fileName: fileName,
            progress: step / steps,
          ),
        );
        return;
      }
      t.cancel();
      emit(
        ImportState(
          status: ProcessingStatus.processing,
          fileName: fileName,
          progress: 1,
        ),
      );
      _timer = Timer(processingDuration, () {
        if (fail) {
          emit(
            ImportState(
              status: ProcessingStatus.failed,
              fileName: fileName,
              errorMessage:
                  'The PDF is password protected. Remove the password and try again.',
            ),
          );
          return;
        }
        final material = _buildMaterial(fileName, type, text);
        onImported?.call(material);
        emit(
          ImportState(
            status: ProcessingStatus.ready,
            fileName: fileName,
            progress: 1,
            material: material,
          ),
        );
      });
    });
  }

  /// Stand-in for the AI step: derives a title and summary locally and reuses
  /// the sample flashcards and questions.
  StudyMaterial _buildMaterial(
    String fileName,
    StudyMaterialType type,
    String? text,
  ) {
    final now = _now();
    final pasted = type == StudyMaterialType.pastedText;
    final body = (text ?? '').trim();
    final title = pasted && body.isNotEmpty
        ? _truncate(body.split('\n').first, 40)
        : fileName
              .replaceFirst(RegExp(r'\.[A-Za-z0-9]+$'), '')
              .replaceAll(RegExp(r'[_\-]+'), ' ');
    return StudyMaterial(
      id: 'import-${now.microsecondsSinceEpoch}',
      title: title,
      type: type,
      createdAt: now,
      lastAccessed: now,
      status: ProcessingStatus.ready,
      meta: '${pasted ? 'Pasted text' : 'PDF'} · Added today',
      summaryText: pasted && body.isNotEmpty
          ? _truncate(body, 240)
          : 'Summary of $title, generated from your upload.',
      flashcards: MockData.flashcards,
      questions: MockData.questions,
    );
  }

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max).trimRight()}…';

  void cancel() {
    _timer?.cancel();
    emit(const ImportState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
