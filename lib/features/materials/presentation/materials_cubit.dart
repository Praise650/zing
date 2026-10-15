import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../domain/study_material.dart';

class MaterialsState extends Equatable {
  const MaterialsState(this.materials);

  final List<StudyMaterial> materials;

  @override
  List<Object?> get props => [materials];
}

/// The user's material collection, persisted on device.
class MaterialsCubit extends HydratedCubit<MaterialsState> {
  /// [seed] is what a fresh install starts with.
  MaterialsCubit({List<StudyMaterial> seed = const []})
    : super(MaterialsState(seed));

  /// Newest first.
  void add(StudyMaterial material) =>
      emit(MaterialsState([material, ...state.materials]));

  StudyMaterial? find(String id) {
    for (final m in state.materials) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  MaterialsState? fromJson(Map<String, dynamic> json) => MaterialsState([
    for (final e in json['materials'] as List)
      StudyMaterial.fromJson(Map<String, dynamic>.from(e as Map)),
  ]);

  @override
  Map<String, dynamic> toJson(MaterialsState state) => {
    'materials': [for (final m in state.materials) m.toJson()],
  };
}
