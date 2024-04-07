import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:holyshitrail/game/characters/character.dart';

class Locale {
  final String localeCode;
  Map? _locales;

  late final Future<bool> ready;

  Locale(this.localeCode) {
    ready = _load();
  }

  Future<bool> _load() async {
    if (_locales != null) return true;
    WidgetsFlutterBinding.ensureInitialized();
    _locales = jsonDecode(
      await rootBundle.loadString("assets/locale/$localeCode.json"),
    );
    return true;
  }

  String getCharacterName(dynamic id) {
    if (id is CharacterId) {
      return _locales!['characters'][id.value]['name'];
    } else {
      return _locales!['characters'][id]['name'];
    }
  }
}
