import 'package:islamic_utils/islamic_utils.dart' as iu;

String heirTypeLabelKey(iu.HeirType type) => switch (type) {
      iu.HeirType.husband => 'husband',
      iu.HeirType.wife => 'wife',
      iu.HeirType.father => 'father',
      iu.HeirType.mother => 'mother',
      iu.HeirType.grandfatherPaternal => 'grandfather',
      iu.HeirType.grandmotherMaternal => 'grandmother_maternal',
      iu.HeirType.grandmotherPaternal => 'grandmother_paternal',
      iu.HeirType.son => 'son',
      iu.HeirType.daughter => 'daughter',
      iu.HeirType.grandsonSon => 'grandson',
      iu.HeirType.granddaughterSon => 'granddaughter',
      iu.HeirType.brotherFull => 'full_brother',
      iu.HeirType.sisterFull => 'full_sister',
      iu.HeirType.brotherPaternal => 'paternal_brother',
      iu.HeirType.sisterPaternal => 'paternal_sister',
      iu.HeirType.brotherUterine => 'maternal_brother',
      iu.HeirType.sisterUterine => 'maternal_sister',
      iu.HeirType.nephewFull => 'nephew_full',
      iu.HeirType.nephewPaternal => 'nephew_paternal',
      iu.HeirType.uncleFull => 'uncle_full',
      iu.HeirType.unclePaternal => 'uncle_paternal',
      iu.HeirType.cousinFull => 'cousin_full',
      iu.HeirType.cousinPaternal => 'cousin_paternal',
      iu.HeirType.grandchildDaughter => 'grandchild_daughter',
      iu.HeirType.auntMaternal => 'aunt_maternal',
      iu.HeirType.auntPaternal => 'aunt_paternal',
      iu.HeirType.uncleMaternal => 'uncle_maternal',
      iu.HeirType.otherDhawilArham => 'other_dhawil_arham',
    };

class Heir {
  final iu.HeirType type;
  final int count;

  const Heir({required this.type, this.count = 1});

  Heir copyWith({int? count}) => Heir(type: type, count: count ?? this.count);

  String get labelKey => heirTypeLabelKey(type);
}