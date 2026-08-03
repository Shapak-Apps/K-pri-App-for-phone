sealed class TranslationState {
  const TranslationState();
}

final class IdleState extends TranslationState {
  const IdleState();
}

final class LoadingState extends TranslationState {
  const LoadingState();
}

final class SuccessState extends TranslationState {
  final String text;
  final String? detected;
  const SuccessState(this.text, this.detected);
}

final class ErrorState extends TranslationState {
  final String message;
  const ErrorState(this.message);
}
