import 'madhhab.dart';

class InheritanceSettings {
  final Madhhab madhhab;
  final bool publicTreasuryFunctional;

  const InheritanceSettings({
    this.madhhab = Madhhab.general,
    this.publicTreasuryFunctional = true,
  });

  InheritanceSettings copyWith({
    Madhhab? madhhab,
    bool? publicTreasuryFunctional,
  }) =>
      InheritanceSettings(
        madhhab: madhhab ?? this.madhhab,
        publicTreasuryFunctional:
            publicTreasuryFunctional ?? this.publicTreasuryFunctional,
      );
}