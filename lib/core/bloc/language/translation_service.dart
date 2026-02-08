import 'package:translator/translator.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, String> _cache = {};

  static Future<String> translate(String text, String targetLang) async {
    if (targetLang == 'en' || text.isEmpty) return text;
    
    String cacheKey = "$targetLang:$text";
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      var translation = await _translator.translate(text, to: targetLang);
      _cache[cacheKey] = translation.text;
      return translation.text;
    } catch (e) {
      return text; // Fallback to original text on error
    }
  }
}