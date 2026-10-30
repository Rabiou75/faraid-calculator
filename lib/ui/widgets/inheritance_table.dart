import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamic_utils/islamic_utils.dart' as iu;
import '../../data/models/heir.dart';

class InheritanceTable extends StatelessWidget {
  final List<iu.HeirShare> shares;
  final double netEstate;

  const InheritanceTable({
    super.key,
    required this.shares,
    required this.netEstate,
  });

  String _getPluralKey(iu.HeirType type) {
    switch (type) {
      case iu.HeirType.wife: return 'wives';
      case iu.HeirType.husband: return 'husbands';
      case iu.HeirType.son: return 'sons';
      case iu.HeirType.daughter: return 'daughters';
      case iu.HeirType.brotherFull: return 'full_brothers';
      case iu.HeirType.sisterFull: return 'full_sisters';
      case iu.HeirType.brotherPaternal: return 'paternal_brothers';
      case iu.HeirType.sisterPaternal: return 'paternal_sisters';
      case iu.HeirType.brotherUterine: return 'maternal_brothers';
      case iu.HeirType.sisterUterine: return 'maternal_sisters';
      default: return heirTypeLabelKey(type);
    }
  }

  String _getCategoryRule(iu.ShareCategory category) {
    switch (category) {
      case iu.ShareCategory.furudh: return 'rule_fixed';
      case iu.ShareCategory.asabah: return 'rule_residuary';
      case iu.ShareCategory.furudhAndAsabah: return 'rule_fixed_residuary';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeShares = shares.where((s) => !s.isBlocked && s.totalValue > 0).toList();
    final formatter = NumberFormat('#,##0.00', 'en_US');
    
    final colors = [
      Colors.teal.shade600, Colors.blue.shade600, Colors.orange.shade600,
      Colors.purple.shade600, Colors.red.shade600, Colors.green.shade600,
      Colors.brown.shade600, Colors.cyan.shade600,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('col_heir'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
              Expanded(flex: 1, child: Text('col_share'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
              Expanded(flex: 2, child: Text('col_pct'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
              Expanded(flex: 3, child: Text('col_amount'.tr(), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        
        // Data Rows
        ...activeShares.asMap().entries.map((entry) {
          final index = entry.key;
          final share = entry.value;
          final isGroup = share.count > 1;
          final color = colors[index % colors.length];
          final percentage = (share.totalValue / netEstate) * 100;
          final groupName = isGroup ? _getPluralKey(share.heirType).tr() : heirTypeLabelKey(share.heirType).tr();
          final ruleKey = _getCategoryRule(share.category);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  '$groupName ${isGroup ? "(${share.count})" : ""}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (ruleKey.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      ruleKey.tr(),
                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(share.finalShare.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('${percentage.toStringAsFixed(2)}%', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('${formatter.format(share.totalValue)} XAF', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              
              // Individual Rows
              if (isGroup)
                ...List.generate(share.count, (i) {
                  final indFraction = share.finalShare / iu.Fraction(share.count, 1);
                  final indPct = percentage / share.count;
                  
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: Text('${heirTypeLabelKey(share.heirType).tr()} ${i + 1}', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(indFraction.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${indPct.toStringAsFixed(2)}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text('${formatter.format(share.perPersonValue)} XAF', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      if (i < share.count - 1) const Divider(height: 1, thickness: 0.5, color: Colors.black12),
                    ],
                  );
                }),
              const Divider(height: 1, thickness: 1),
            ],
          );
        }),
      ],
    );
  }
}