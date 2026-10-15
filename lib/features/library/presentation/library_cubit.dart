import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../materials/domain/study_material.dart';

enum LibraryFilter {
  all('All'),
  notes('Notes'),
  pdfs('PDFs'),
  summaries('Summaries'),
  flashcards('Cards');

  const LibraryFilter(this.label);
  final String label;

  bool matches(StudyMaterial m) => switch (this) {
    LibraryFilter.all => true,
    LibraryFilter.notes =>
      m.type == StudyMaterialType.note ||
          m.type == StudyMaterialType.pastedText,
    LibraryFilter.pdfs => m.type == StudyMaterialType.pdf,
    LibraryFilter.summaries => m.hasSummary,
    LibraryFilter.flashcards => m.flashcards.isNotEmpty,
  };
}

class LibraryState extends Equatable {
  const LibraryState({
    required this.materials,
    this.query = '',
    this.filter = LibraryFilter.all,
    this.grid = true,
  });

  final List<StudyMaterial> materials;
  final String query;
  final LibraryFilter filter;
  final bool grid;

  /// Matches titles and summary text, then applies the category filter.
  List<StudyMaterial> get visible {
    final q = query.trim().toLowerCase();
    return materials.where((m) {
      if (!filter.matches(m)) return false;
      if (q.isEmpty) return true;
      return m.title.toLowerCase().contains(q) ||
          (m.summaryText ?? '').toLowerCase().contains(q);
    }).toList();
  }

  LibraryState copyWith({
    List<StudyMaterial>? materials,
    String? query,
    LibraryFilter? filter,
    bool? grid,
  }) => LibraryState(
    materials: materials ?? this.materials,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    grid: grid ?? this.grid,
  );

  @override
  List<Object?> get props => [materials, query, filter, grid];
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(List<StudyMaterial> materials)
    : super(LibraryState(materials: materials));

  /// Keeps the list in sync with the persisted collection.
  void setMaterials(List<StudyMaterial> materials) =>
      emit(state.copyWith(materials: materials));

  void search(String query) => emit(state.copyWith(query: query));
  void setFilter(LibraryFilter filter) => emit(state.copyWith(filter: filter));
  void setGrid(bool grid) => emit(state.copyWith(grid: grid));
}
