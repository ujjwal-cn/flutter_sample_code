import 'package:flutter/material.dart';
import 'package:go4sheq/l10n/l10n.dart';
import 'package:go4sheq/util/app_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageBloc with ChangeNotifier {
  Locale _locale = L10n.all[0];

  Locale get locale => _locale;

  int _selectedLanguageIndex = 0;

  int get selectedLanguageIndex => _selectedLanguageIndex;

  LanguageBloc() {
    _loadLanguage();
  }

  void _loadLanguage() {
    SharedPreferences.getInstance().then((prefs) {
      String languageCode = prefs.getString(kPrefsLanguageCode) ?? '';
      if (languageCode.isEmpty) return;

      _locale = Locale(languageCode, '');
      _selectedLanguageIndex = L10n.all.indexOf(_locale);
      notifyListeners();
    });
  }

  changeLanguage({required int languageIndex}) async {
    if (languageIndex == -1) return;

    _locale = L10n.all[languageIndex];
    _selectedLanguageIndex = languageIndex;
    notifyListeners();

    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefsLanguageCode, _locale.toString());
  }
}
