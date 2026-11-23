/// Font families declared in pubspec.yaml.
class AppFonts {
  AppFonts._();

  /// UI: headings and numbers.
  static const String prompt = 'Prompt';

  /// UI: body text (variable font, weight set via [AppText]).
  static const String anuphan = 'Anuphan';

  // The PDF report embeds its own fonts (pgvim, Trajan Pro) straight from
  // assets/fonts/, so they are not registered as app fonts and the browser
  // does not download them at startup.
}
