import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_utils/islamic_utils.dart' as iu;
import '../models/calculation_result.dart';
import '../models/heir.dart';
import 'csv_saver.dart' if (dart.library.js_interop) 'csv_saver_web.dart';

class CsvService {
  static String _convertToCsv(List<List<dynamic>> rows) {
    StringBuffer buffer = StringBuffer();
    for (var row in rows) {
      buffer.writeln(row.map((cell) {
        String cellStr = cell.toString();
        if (cellStr.contains(',') || cellStr.contains('"') || cellStr.contains('\n')) {
          cellStr = '"${cellStr.replaceAll('"', '""')}"';
        }
        return cellStr;
      }).join(','));
    }
    return buffer.toString();
  }

  static void exportToCsv(CalculationResult result) {
    List<List<dynamic>> rows = [];
    
    rows.add([
      'heir'.tr(), 
      'share_fraction'.tr(), 
      'col_pct'.tr(), 
      'col_amount'.tr() + ' (${result.currency})'
    ]);

    final activeShares = result.shares.where((s) => !s.isBlocked && s.totalValue > 0);
    
    for (var share in activeShares) {
      final pct = (share.totalValue / result.netEstate) * 100;
      // Group Row
      rows.add([
        '${heirTypeLabelKey(share.heirType).tr()} (${share.count})',
        share.finalShare.toString(),
        '${pct.toStringAsFixed(2)}%',
        share.totalValue.toStringAsFixed(2)
      ]);
      
      // Individual Rows
      if (share.count > 1) {
        for (int i = 0; i < share.count; i++) {
          // FIX: Use iu.Fraction to prevent the math crash!
          final indFrac = share.finalShare / iu.Fraction(share.count, 1);
          final indPct = pct / share.count;
          rows.add([
            '  ${heirTypeLabelKey(share.heirType).tr()} ${i + 1}',
            indFrac.toString(),
            '${indPct.toStringAsFixed(2)}%',
            share.perPersonValue.toStringAsFixed(2)
          ]);
        }
      }
    }

    String csvData = _convertToCsv(rows);
    final bytes = utf8.encode(csvData);
    String filename = 'Faraid_Calculation_${DateTime.now().millisecondsSinceEpoch}.csv';
    
    saveCsv(filename, bytes);
  }
}