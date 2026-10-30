import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/calculation_result.dart';
import '../data/models/heir.dart';
import '../data/models/inheritance_settings.dart';
import '../data/services/faraid_service.dart';

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

  InheritanceProvider({FaraidService? service}) : _service = service ?? FaraidService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency') ?? 'XAF';
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void setCurrency(String v) async {
    currency = v; 
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', v);
  }

  void toggleDarkMode() async {
    isDarkMode = !isDarkMode;
    notifyListeners();
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
      grossEstate: grossEstate,
      debts: debts,
      funeralCosts: funeralCosts,
      wasiyyah: wasiyyah,
      wasiyyahApproved: wasiyyahApproved,
      currency: currency,
      heirs: heirs,
      settings: settings,
      deceasedIsMale: deceasedIsMale,
    );
    notifyListeners();
  }

  void reset() {
    grossEstate = 0; debts = 0; funeralCosts = 0; wasiyyah = 0;
    heirs.clear(); result = null; notifyListeners();
  }
}