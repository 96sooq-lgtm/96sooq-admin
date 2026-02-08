import 'package:_96sooq_admin/core/bloc/language/bloc/language_event.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  TranslationBloc()
    : super(TranslationState(languageCode: 'en', isRTL: false)) {
    
    // Logic to load language from local storage
    on<LoadSavedLanguage>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final String? savedLang = prefs.getString('language_code');
      if (savedLang != null) {
        emit(TranslationState(
          languageCode: savedLang,
          isRTL: savedLang == 'ar',
        ));
      }
    });

    on<ChangeLanguage>((event, emit) async {
      // Logic to save language to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', event.languageCode);

      emit(
        TranslationState(
          languageCode: event.languageCode,
          isRTL: event.languageCode == 'ar',
        ),
      );
    });
  }
}