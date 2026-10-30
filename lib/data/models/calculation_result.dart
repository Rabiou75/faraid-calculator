import 'package:islamic_utils/islamic_utils.dart' as iu;

class CalculationResult {
  final double netEstate;
  final double totalDistributed;
  final double surplus;
  final List<iu.HeirShare> shares;
  final String? noteKey;
  final bool succeeded;
  final String? errorMessage;
  
  // New V1.1 fields
  final String currency;
  final bool aulApplied;
  final bool raddApplied;
  final String? specialCase;

  const CalculationResult({
    required this.netEstate,
    required this.totalDistributed,
    required this.surplus,
    required this.shares,
    this.noteKey,
    this.succeeded = true,
    this.errorMessage,
    this.currency = 'XAF',
    this.aulApplied = false,
    this.raddApplied = false,
    this.specialCase,
  });

  factory CalculationResult.error(String message) => CalculationResult(
        netEstate: 0,
        totalDistributed: 0,
        surplus: 0,
        shares: const [],
        succeeded: false,
        errorMessage: message,
      );
}