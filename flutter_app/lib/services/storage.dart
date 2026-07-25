import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences with a single JSON blob per key.
class Storage {
  static const _patientKey  = 'najm.patient';
  static const _inputsKey   = 'najm.inputs';
  static const _scoresKey   = 'najm.scores';
  static const _notesKey    = 'najm.notes';
  static const _tabKey      = 'najm.tab';
  static const _drugCatKey  = 'najm.drug.cat';
  static const _drugQKey    = 'najm.drug.q';
  static const _abxClassKey = 'najm.abx.class';
  static const _abxQKey     = 'najm.abx.q';

  static const _allKeys = [
    _patientKey, _inputsKey, _scoresKey, _notesKey, _tabKey,
    _drugCatKey, _drugQKey, _abxClassKey, _abxQKey,
  ];

  final SharedPreferences _p;
  Storage(this._p);

  static Future<Storage> open() async {
    final p = await SharedPreferences.getInstance();
    return Storage(p);
  }

  String? patientRaw() => _p.getString(_patientKey);
  Future<void> setPatientRaw(String s) => _p.setString(_patientKey, s);

  String inputsRaw() => _p.getString(_inputsKey) ?? '{}';
  Future<void> setInputsRaw(String s) => _p.setString(_inputsKey, s);

  String scoresRaw() => _p.getString(_scoresKey) ?? '{}';
  Future<void> setScoresRaw(String s) => _p.setString(_scoresKey, s);

  String notes() => _p.getString(_notesKey) ?? '';
  Future<void> setNotes(String s) => _p.setString(_notesKey, s);

  int tab() => _p.getInt(_tabKey) ?? 0;
  Future<void> setTab(int i) => _p.setInt(_tabKey, i);

  String drugCat() => _p.getString(_drugCatKey) ?? 'all';
  Future<void> setDrugCat(String s) => _p.setString(_drugCatKey, s);

  String drugQuery() => _p.getString(_drugQKey) ?? '';
  Future<void> setDrugQuery(String s) => _p.setString(_drugQKey, s);

  String abxClass() => _p.getString(_abxClassKey) ?? 'all';
  Future<void> setAbxClass(String s) => _p.setString(_abxClassKey, s);

  String abxQuery() => _p.getString(_abxQKey) ?? '';
  Future<void> setAbxQuery(String s) => _p.setString(_abxQKey, s);

  Future<void> wipeAll() async {
    for (final k in _allKeys) {
      await _p.remove(k);
    }
  }
}
