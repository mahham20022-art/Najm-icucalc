import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/patient.dart';
import '../services/storage.dart';
import '../services/analytics.dart';

/// Root app state. Holds the patient, all input values (per-screen), score
/// selections, notes, and the currently-selected tab. Persists to
/// SharedPreferences with a short debounce.
class AppState extends ChangeNotifier {
  AppState(this._storage) {
    _load();
  }

  final Storage _storage;
  Timer? _saveTimer;

  Patient _patient = Patient.empty;
  Map<String, String> _inputs = {};
  Map<String, Map<int, num>> _scores = {}; // key -> item index -> value
  String _notes = '';
  int _tab = 0;
  String _drugCat = 'all';
  String _drugQuery = '';

  Patient get patient => _patient;
  Map<String, String> get inputs => _inputs;
  Map<String, Map<int, num>> get scores => _scores;
  String get notes => _notes;
  int get tab => _tab;
  String get drugCat => _drugCat;
  String get drugQuery => _drugQuery;

  double? input(String k) => double.tryParse(_inputs[k] ?? '');
  String inputStr(String k) => _inputs[k] ?? '';

  void _load() {
    final praw = _storage.patientRaw();
    if (praw != null && praw.isNotEmpty) {
      try { _patient = Patient.fromRaw(praw); } catch (_) {}
    }
    try {
      final m = jsonDecode(_storage.inputsRaw()) as Map<String, dynamic>;
      _inputs = m.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    } catch (_) {}
    try {
      final m = jsonDecode(_storage.scoresRaw()) as Map<String, dynamic>;
      _scores = m.map((k, v) {
        final inner = (v as Map<String, dynamic>).map(
          (ik, iv) => MapEntry(int.parse(ik), (iv as num)),
        );
        return MapEntry(k, inner);
      });
    } catch (_) {}
    _notes = _storage.notes();
    _tab = _storage.tab();
    _drugCat = _storage.drugCat();
    _drugQuery = _storage.drugQuery();
    notifyListeners();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), _save);
  }

  Future<void> _save() async {
    await _storage.setPatientRaw(_patient.toRaw());
    await _storage.setInputsRaw(jsonEncode(_inputs));
    final scoresJson = _scores.map(
      (k, v) => MapEntry(k, v.map((ik, iv) => MapEntry(ik.toString(), iv))),
    );
    await _storage.setScoresRaw(jsonEncode(scoresJson));
    await _storage.setNotes(_notes);
    await _storage.setTab(_tab);
    await _storage.setDrugCat(_drugCat);
    await _storage.setDrugQuery(_drugQuery);
  }

  void updatePatient(Patient Function(Patient) mut) {
    _patient = mut(_patient);
    notifyListeners();
    _scheduleSave();
  }

  void clearPatient() {
    _patient = Patient.empty;
    notifyListeners();
    _scheduleSave();
    Analytics.event('patient_cleared');
  }

  void setInput(String key, String value) {
    if (_inputs[key] == value) return;
    _inputs[key] = value;
    notifyListeners();
    _scheduleSave();
  }

  void setScore(String key, int itemIndex, num value) {
    (_scores[key] ??= <int, num>{})[itemIndex] = value;
    notifyListeners();
    _scheduleSave();
  }

  void setNotes(String v) {
    _notes = v;
    notifyListeners();
    _scheduleSave();
  }

  void setTab(int i) {
    if (_tab == i) return;
    _tab = i;
    notifyListeners();
    _scheduleSave();
    Analytics.screen(_tabName(i));
  }

  void setDrugCat(String c) {
    _drugCat = c;
    notifyListeners();
    _scheduleSave();
  }

  void setDrugQuery(String q) {
    _drugQuery = q;
    notifyListeners();
    _scheduleSave();
  }

  static String _tabName(int i) => const [
    'infusions','hemo','vent','abg','lytes','renal','scores','notes',
  ][i.clamp(0, 7)];

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
