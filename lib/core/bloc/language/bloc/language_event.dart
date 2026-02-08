abstract class TranslationEvent {}

class ChangeLanguage extends TranslationEvent {
  final String languageCode;
  ChangeLanguage(this.languageCode);
}

class LoadSavedLanguage extends TranslationEvent {}
