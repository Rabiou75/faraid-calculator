import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.teal),
          const SizedBox(width: 8),
          Text('help'.tr()),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _helpSection(
                context,
                icon: Icons.account_balance_wallet,
                title: 'gross_estate'.tr(),
                description: 'help_estate'.tr(),
              ),
              const SizedBox(height: 16),
              _helpSection(
                context,
                icon: Icons.group_add,
                title: 'add_heir'.tr(),
                description: 'help_heirs'.tr(),
              ),
              const SizedBox(height: 16),
              _helpSection(
                context,
                icon: Icons.table_chart,
                title: 'results'.tr(),
                description: 'help_results'.tr(),
              ),
              const SizedBox(height: 16),
              _helpSection(
                context,
                icon: Icons.gavel,
                title: 'madhhab'.tr(),
                description: 'help_fiqh'.tr(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _helpSection(BuildContext context, {required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}