import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/calculation_result.dart';
import '../data/models/heir.dart';
import '../data/models/inheritance_settings.dart';
import '../data/services/faraid_service.dart';
import 'package:islamic_utils/islamic_utils.dart' as iu;

class InheritanceProvider extends ChangeNotifier {
  final FaraidService _service;

  double grossEstate = 0;
  double debts = 0;
  double funeralCosts = 0;
  double wasiyyah = 0;
  bool wasiyyahApproved = false;
  
  String currency = 'XAF';
  bool isDarkMode = false;
  
  bool deceasedIsMale = true;
  final List<Heir> heirs = [];
  InheritanceSettings settings = const InheritanceSettings();
  CalculationResult? result;

  List<Map<String, dynamic>> savedHistory = [];

  InheritanceProvider({FaraidService? service}) : _service = service ?? FaraidService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency') ?? 'XAF';
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    final historyJson = prefs.getString('history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      savedHistory = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    notifyListeners();
  }

  void setCurrency(String v) async {
    currency = v; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', v);
  }

  void toggleDarkMode() async {
    isDarkMode = !isDarkMode; notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void setGrossEstate(double v) { grossEstate = v; notifyListeners(); }
  void setDebts(double v) { debts = v; notifyListeners(); }
  void setFuneralCosts(double v) { funeralCosts = v; notifyListeners(); }
  void setWasiyyah(double v) { wasiyyah = v; notifyListeners(); }
  void setWasiyyahApproved(bool v) { wasiyyahApproved = v; notifyListeners(); }
  void setDeceasedGender(bool isMale) { deceasedIsMale = isMale; notifyListeners(); }

  void addOrUpdateHeir(Heir heir) {
    final idx = heirs.indexWhere((h) => h.type == heir.type);
    if (idx >= 0) { heirs[idx] = heir; } else { heirs.add(heir); }
    notifyListeners();
  }

  void removeHeir(Heir heir) {
    heirs.removeWhere((h) => h.type == heir.type);
    notifyListeners();
  }

  void updateSettings(InheritanceSettings s) { settings = s; notifyListeners(); }

  void calculate() {
    result = _service.calculate(
      grossEstate: grossEstate, debts: debts, funeralCosts: funeralCosts,
      wasiyyah: wasiyyah, wasiyyahApproved: wasiyyahApproved, currency: currency,
      heirs: heirs, settings: settings, deceasedIsMale: deceasedIsMale,
    );
    notifyListeners();
  }

  Future<void> saveCurrentCalculation() async {
    if (result == null || !result!.succeeded) return;
    
    final map = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'grossEstate': grossEstate,
      'debts': debts,
      'funeralCosts': funeralCosts,
      'wasiyyah': wasiyyah,
      'wasiyyahApproved': wasiyyahApproved,
      'currency': currency,
      'deceasedIsMale': deceasedIsMale,
      'heirs': heirs.map((h) => {'type': h.type.name, 'count': h.count}).toList(),
    };

    savedHistory.insert(0, map);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('history', jsonEncode(savedHistory));
    notifyListeners();
  }

  void loadCalculation(Map<String, dynamic> map) {
    grossEstate = (map['grossEstate'] as num).toDouble();
    debts = (map['debts'] as num).toDouble();
    funeralCosts = (map['funeralCosts'] as num).toDouble();
    wasiyyah = (map['wasiyyah'] as num).toDouble();
    wasiyyahApproved = map['wasiyyahApproved'] ?? false;
    currency = map['currency'] ?? 'XAF';
    deceasedIsMale = map['deceasedIsMale'] ?? true;
    
    heirs.clear();
    final rawHeirs = map['heirs'] as List<dynamic>;
    for (var h in rawHeirs) {
      // We need to import islamic_utils to get the HeirType by name
      heirs.add(Heir(type: iu.HeirType.values.byName(h['type']), count: h['count']));
    }
    
    calculate();
  }

  Future<void> deleteHistory(String id) async {
    savedHistory.removeWhere((item) => item['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('history', jsonEncode(savedHistory));
    notifyListeners();
  }

  void reset() {
    grossEstate = 0; debts = 0; funeralCosts = 0; wasiyyah = 0;
    heirs.clear(); result = null; notifyListeners();
  }
}