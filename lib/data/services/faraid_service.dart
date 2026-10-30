import 'package:islamic_utils/islamic_utils.dart' as iu;
import '../models/calculation_result.dart';
import '../models/heir.dart';
import '../models/inheritance_settings.dart';
import '../models/madhhab.dart';

class FaraidService {
  CalculationResult calculate({
    required double grossEstate,
    required double debts,
    required double funeralCosts,
    required double wasiyyah,
    required bool wasiyyahApproved,
    required String currency,
    required List<Heir> heirs,
    required InheritanceSettings settings,
    required bool deceasedIsMale,
  }) {
    if (grossEstate <= 0) return CalculationResult.error('error_estate');
    if (heirs.isEmpty) return CalculationResult.error('error_no_heirs');

    final baseResult = iu.computeInheritance(
      estate: iu.EstateInput(
        grossValue: grossEstate,
        debts: debts,
        funeralCosts: funeralCosts,
        wasiyyah: wasiyyah,
        wasiyyahApprovedByHeirs: wasiyyahApproved,
        currency: currency,
      ),
      heirs: heirs.map((h) => iu.HeirInput(type: h.type, count: h.count)).toList(),
      deceased: iu.DeceasedInfo(gender: deceasedIsMale ? iu.Gender.male : iu.Gender.female),
    );

    if (!baseResult.isSuccess) {
      return CalculationResult.error('Calculation failed.');
    }

    final result = baseResult.unwrap();
    final shares = result.shares;
    final distributed = shares.fold<double>(0, (acc, s) => acc + s.totalValue);
    final surplus = result.netEstate - distributed;
    String? noteKey;

    if (settings.madhhab == Madhhab.maliki && surplus > 0.01) {
      noteKey = settings.publicTreasuryFunctional ? 'surplus_to_treasury' : 'surplus_redistributed';
    }

    return CalculationResult(
      netEstate: result.netEstate,
      totalDistributed: distributed,
      surplus: surplus,
      shares: shares,
      noteKey: noteKey,
      currency: currency,
      aulApplied: result.summary.aulApplied,
      raddApplied: result.summary.raddApplied,
      specialCase: result.summary.specialCase,
    );
  }
}