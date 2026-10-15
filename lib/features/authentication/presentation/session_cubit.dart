import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SessionState extends Equatable {
  const SessionState({
    this.onboardingSeen = false,
    this.signedIn = false,
    this.name = '',
    this.email = '',
  });

  final bool onboardingSeen;
  final bool signedIn;
  final String name;
  final String email;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  /// Single letter shown in avatars.
  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  SessionState copyWith({
    bool? onboardingSeen,
    bool? signedIn,
    String? name,
    String? email,
  }) => SessionState(
    onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    signedIn: signedIn ?? this.signedIn,
    name: name ?? this.name,
    email: email ?? this.email,
  );

  @override
  List<Object?> get props => [onboardingSeen, signedIn, name, email];
}

/// Local-only account session. There is no backend yet, so any well-formed
/// credentials are accepted.
class SessionCubit extends HydratedCubit<SessionState> {
  SessionCubit() : super(const SessionState());

  void completeOnboarding() {
    if (!state.onboardingSeen) emit(state.copyWith(onboardingSeen: true));
  }

  void signUp({required String name, required String email}) => emit(
    state.copyWith(
      onboardingSeen: true,
      signedIn: true,
      name: name.trim(),
      email: email.trim(),
    ),
  );

  /// Keeps the stored name when signing back in with the same email.
  void signIn({required String email}) {
    final clean = email.trim();
    final sameUser = clean.toLowerCase() == state.email.toLowerCase();
    emit(
      state.copyWith(
        onboardingSeen: true,
        signedIn: true,
        email: clean,
        name: sameUser && state.name.isNotEmpty ? state.name : _nameFrom(clean),
      ),
    );
  }

  void updateProfile({required String name, required String email}) =>
      emit(state.copyWith(name: name.trim(), email: email.trim()));

  void signOut() => emit(state.copyWith(signedIn: false));

  static String _nameFrom(String email) {
    final local = email.split('@').first;
    final words = local
        .split(RegExp(r'[._\-+]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}');
    final name = words.join(' ');
    return name.isEmpty ? 'Student' : name;
  }

  @override
  SessionState? fromJson(Map<String, dynamic> json) => SessionState(
    onboardingSeen: json['onboardingSeen'] as bool? ?? false,
    signedIn: json['signedIn'] as bool? ?? false,
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );

  @override
  Map<String, dynamic> toJson(SessionState state) => {
    'onboardingSeen': state.onboardingSeen,
    'signedIn': state.signedIn,
    'name': state.name,
    'email': state.email,
  };
}
