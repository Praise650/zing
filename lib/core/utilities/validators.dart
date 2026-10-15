/// Pure form validation helpers.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns an error message, or null when [value] is a valid email.
  static String? email(String value) =>
      _email.hasMatch(value.trim()) ? null : 'Enter a valid email address.';

  static String? name(String value) =>
      value.trim().length >= 2 ? null : 'Enter your full name.';

  static String? password(String value) =>
      value.length >= 8 ? null : 'Use at least 8 characters.';
}

enum PasswordStrength { empty, weak, fair, good, strong }

extension PasswordStrengthX on PasswordStrength {
  /// Number of filled meter segments (0 to 4).
  int get segments => index;

  String get message => switch (this) {
    PasswordStrength.empty => '',
    PasswordStrength.weak => 'Weak. Use 8+ characters with a number.',
    PasswordStrength.fair => 'Fair. Use 8+ characters with a number.',
    PasswordStrength.good => 'Good. Add a symbol to make it stronger.',
    PasswordStrength.strong => 'Strong password.',
  };
}

PasswordStrength passwordStrength(String value) {
  if (value.isEmpty) return PasswordStrength.empty;
  var score = 0;
  if (value.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) {
    score++;
  }
  if (RegExp(r'\d').hasMatch(value)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
  if (value.length < 6) {
    score = score.clamp(0, 1);
  }
  return switch (score) {
    0 || 1 => value.length < 6 ? PasswordStrength.weak : PasswordStrength.fair,
    2 => PasswordStrength.fair,
    3 => PasswordStrength.good,
    _ => PasswordStrength.strong,
  };
}
