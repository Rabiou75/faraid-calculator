import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamic_utils/islamic_utils.dart' as iu;
import 'package:provider/provider.dart';

import '../../data/models/heir.dart';
import '../../data/models/madhhab.dart';
import '../../data/services/pdf_service.dart';
import '../../providers/inheritance_provider.dart';
import '../widgets/inheritance_pie_chart.dart';
import '../widgets/inheritance_table.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InheritanceProvider>();
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () => provider.reset(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (code) {
              if (code == 'en') context.setLocale(const Locale('en'));
              if (code == 'fr') context.setLocale(const Locale('fr'));
              if (code == 'ar') context.setLocale(const Locale('ar'));
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'fr', child: Text('Francais')),
              PopupMenuItem(value: 'ar', child: Text('\u0639\u0644\u0631\u0628\u064A\u0629')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('welcome'.tr(), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text('home_subtitle'.tr()),
            const SizedBox(height: 32),

            // --- ESTATE INPUTS ---
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'gross_estate'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.account_balance_wallet),
                suffixText: 'XAF',
              ),
              onChanged: (v) => provider.setGrossEstate(double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'debts'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.money_off),
                      suffixText: 'XAF',
                    ),
                    onChanged: (v) => provider.setDebts(double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'funeral_costs'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.local_florist),
                      suffixText: 'XAF',
                    ),
                    onChanged: (v) => provider.setFuneralCosts(double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'wasiyyah'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.handshake),
                suffixText: 'XAF',
              ),
              onChanged: (v) => provider.setWasiyyah(double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 8),
            // Display Net Estate dynamically
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${'net_estate'.tr()}: ${formatter.format((provider.grossEstate - provider.debts - provider.funeralCosts - provider.wasiyyah).clamp(0, double.infinity))} XAF',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 24),

            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text('male'.tr()), icon: const Icon(Icons.male)),
                ButtonSegment(value: false, label: Text('female'.tr()), icon: const Icon(Icons.female)),
              ],
              selected: {provider.deceasedIsMale},
              onSelectionChanged: (s) => provider.setDeceasedGender(s.first),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<Madhhab>(
              value: provider.settings.madhhab,
              decoration: InputDecoration(
                labelText: 'madhhab'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.menu_book),
              ),
              items: Madhhab.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.key.tr())))
                  .toList(),
              onChanged: (m) {
                if (m == null) return;
                provider.updateSettings(provider.settings.copyWith(madhhab: m));
              },
            ),
            if (provider.settings.madhhab == Madhhab.maliki) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('public_treasury_status'.tr()),
                subtitle: Text(provider.settings.publicTreasuryFunctional
                    ? 'public_treasury_functional'.tr()
                    : 'public_treasury_absent'.tr()),
                value: provider.settings.publicTreasuryFunctional,
                onChanged: (v) => provider.updateSettings(provider.settings.copyWith(publicTreasuryFunctional: v)),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('add_heir'.tr(), style: Theme.of(context).textTheme.titleLarge),
                if (provider.heirs.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear'),
                    onPressed: () => provider.reset(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.heirs.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('no_heirs'.tr(), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              )
            else
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: provider.heirs.map((h) {
                    return ListTile(
                      title: Text(h.labelKey.tr(), style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: h.count > 1 ? () => provider.addOrUpdateHeir(h.copyWith(count: h.count - 1)) : null,
                          ),
                          Text('${h.count}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => provider.addOrUpdateHeir(h.copyWith(count: h.count + 1)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => provider.removeHeir(h),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _heirChip(context, provider, iu.HeirType.husband),
                _heirChip(context, provider, iu.HeirType.wife),
                _heirChip(context, provider, iu.HeirType.father),
                _heirChip(context, provider, iu.HeirType.mother),
                _heirChip(context, provider, iu.HeirType.son),
                _heirChip(context, provider, iu.HeirType.daughter),
                _heirChip(context, provider, iu.HeirType.grandfatherPaternal),
                _heirChip(context, provider, iu.HeirType.grandmotherMaternal),
                _heirChip(context, provider, iu.HeirType.grandmotherPaternal),
                _heirChip(context, provider, iu.HeirType.brotherFull),
                _heirChip(context, provider, iu.HeirType.sisterFull),
                _heirChip(context, provider, iu.HeirType.brotherPaternal),
                _heirChip(context, provider, iu.HeirType.sisterPaternal),
                _heirChip(context, provider, iu.HeirType.brotherUterine),
                _heirChip(context, provider, iu.HeirType.sisterUterine),
              ],
            ),
            const SizedBox(height: 40),

            FilledButton.icon(
              icon: const Icon(Icons.calculate),
              label: Text('calculate'.tr()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => provider.calculate(),
            ),
            const SizedBox(height: 24),

            if (provider.result != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: provider.result!.succeeded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('results'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const Divider(),
                            
                            // NET ESTATE SUMMARY
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('gross_estate'.tr(), style: const TextStyle(fontSize: 13)),
                                      Text('${formatter.format(provider.grossEstate)} XAF', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  if (provider.debts > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('debts'.tr(), style: const TextStyle(fontSize: 13, color: Colors.red)),
                                        Text('-${formatter.format(provider.debts)} XAF', style: const TextStyle(fontSize: 13, color: Colors.red)),
                                      ],
                                    ),
                                  if (provider.funeralCosts > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('funeral_costs'.tr(), style: const TextStyle(fontSize: 13, color: Colors.red)),
                                        Text('-${formatter.format(provider.funeralCosts)} XAF', style: const TextStyle(fontSize: 13, color: Colors.red)),
                                      ],
                                    ),
                                  if (provider.wasiyyah > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('wasiyyah'.tr(), style: const TextStyle(fontSize: 13, color: Colors.red)),
                                        Text('-${formatter.format(provider.wasiyyah)} XAF', style: const TextStyle(fontSize: 13, color: Colors.red)),
                                      ],
                                    ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('net_estate'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('${formatter.format(provider.result!.netEstate)} XAF', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            InheritancePieChart(shares: provider.result!.shares),
                            const SizedBox(height: 16),
                            
                            InheritanceTable(
                              shares: provider.result!.shares,
                              netEstate: provider.result!.netEstate,
                            ),

                            // MARGINAL NOTES
                            Builder(builder: (context) {
                              final blockedHeirs = provider.heirs.where((h) {
                                return !provider.result!.shares.any((s) => s.heirType == h.type && !s.isBlocked);
                              }).toList();
                              
                              if (blockedHeirs.isEmpty) return const SizedBox();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text('marginal_notes'.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error, letterSpacing: 1.2)),
                                  const SizedBox(height: 8),
                                  ...blockedHeirs.map((h) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('\u2022 ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Expanded(child: Text('${h.labelKey.tr()} ${'is_excluded'.tr()}', style: const TextStyle(fontSize: 13))),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),

                            if (provider.result!.noteKey != null)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(provider.result!.noteKey!.tr(), style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                                    ),
                                  ],
                                ),
                              ),
                              
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Export PDF Report'),
                                onPressed: () => PdfService.exportToPdf(
                                  provider.result!, 
                                  provider.heirs, 
                                  context.locale,
                                  grossEstate: provider.grossEstate,
                                  debts: provider.debts,
                                  funeralCosts: provider.funeralCosts,
                                  wasiyyah: provider.wasiyyah,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(provider.result!.errorMessage?.tr() ?? 'Error', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 32),
            Text('disclaimer'.tr(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _heirChip(BuildContext context, InheritanceProvider provider, iu.HeirType type) {
    final isAdded = provider.heirs.any((h) => h.type == type);
    return FilterChip(
      label: Text(heirTypeLabelKey(type).tr()),
      selected: isAdded,
      onSelected: isAdded ? null : (bool selected) {
        if (selected) provider.addOrUpdateHeir(Heir(type: type, count: 1));
      },
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(color: isAdded ? Theme.of(context).colorScheme.onPrimary : null),
    );
  }
}