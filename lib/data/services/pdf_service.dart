import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:islamic_utils/islamic_utils.dart' as iu;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/app_info.dart';
import '../models/calculation_result.dart';
import '../models/heir.dart';

class PdfService {
  static String _getPluralKey(iu.HeirType type) {
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

  static String _getCategoryRule(iu.ShareCategory category) {
    switch (category) {
      case iu.ShareCategory.furudh: return 'rule_fixed';
      case iu.ShareCategory.asabah: return 'rule_residuary';
      case iu.ShareCategory.furudhAndAsabah: return 'rule_fixed_residuary';
      default: return '';
    }
  }

  static Future<void> exportToPdf(CalculationResult result, List<Heir> inputHeirs, Locale locale, {required double grossEstate, required double debts, required double funeralCosts, required double wasiyyah}) async {
    final pdf = pw.Document();
    final String currency = result.currency;
    final isArabic = locale.languageCode == 'ar';
    final isFrench = locale.languageCode == 'fr';

    pw.Font? arabicFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
      arabicFont = pw.Font.ttf(fontData);
    } catch (e) {
      print('Warning: Could not load Arabic font. $e');
    }

    final textStyle = pw.TextStyle(font: arabicFont, fontSize: 10);
    final boldStyle = textStyle.copyWith(fontWeight: pw.FontWeight.bold);
    final textDirection = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    final colors = [
      PdfColor.fromHex('#00897B'), PdfColor.fromHex('#1E88E5'), PdfColor.fromHex('#FB8C00'),
      PdfColor.fromHex('#8E24AA'), PdfColor.fromHex('#E53935'), PdfColor.fromHex('#43A047'),
      PdfColor.fromHex('#6D4C41'), PdfColor.fromHex('#00ACC1'),
    ];

    final formatter = NumberFormat('#,##0.00', 'en_US');
    final activeShares = result.shares.where((s) => !s.isBlocked && s.totalValue > 0).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: textDirection,
        theme: arabicFont != null ? pw.ThemeData.withFont(base: arabicFont, bold: arabicFont) : null,
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#00897B'), borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(isArabic ? 'نتائج حساب الفرائض' : (isFrench ? 'Résultats du calcul Faraid' : 'Faraid Calculation Results'), style: boldStyle.copyWith(fontSize: 22, color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text(isArabic ? 'إجمالي التركة: ${result.netEstate.toStringAsFixed(2)} $currency' : (isFrench ? 'Valeur totale: ${result.netEstate.toStringAsFixed(2)} $currency' : 'Total Estate: ${result.netEstate.toStringAsFixed(2)} $currency'), style: textStyle.copyWith(color: PdfColors.white)),
                  pw.Text(isArabic ? 'التاريخ: ${DateTime.now().toLocal().toString().split(' ')[0]}' : (isFrench ? 'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}' : 'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}'), style: textStyle.copyWith(fontSize: 9, color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // DEDUCTIONS SUMMARY
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(8), border: pw.Border.all(color: PdfColors.grey300)),
              child: pw.Column(
                children: [
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('gross_estate'.tr(), style: textStyle), pw.Text('${formatter.format(grossEstate)} $currency', style: textStyle)]),
                  if (debts > 0) pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('debts'.tr(), style: textStyle.copyWith(color: PdfColors.red700)), pw.Text('-${formatter.format(debts)} $currency', style: textStyle.copyWith(color: PdfColors.red700))]),
                  if (funeralCosts > 0) pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('funeral_costs'.tr(), style: textStyle.copyWith(color: PdfColors.red700)), pw.Text('-${formatter.format(funeralCosts)} $currency', style: textStyle.copyWith(color: PdfColors.red700))]),
                  if (wasiyyah > 0) pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('wasiyyah'.tr(), style: textStyle.copyWith(color: PdfColors.red700)), pw.Text('-${formatter.format(wasiyyah)} $currency', style: textStyle.copyWith(color: PdfColors.red700))]),
                  pw.Divider(color: PdfColors.grey400),
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('net_estate'.tr(), style: boldStyle), pw.Text('${formatter.format(result.netEstate)} $currency', style: boldStyle)]),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // AWL / RADD NOTES
            if (result.aulApplied) pw.Container(margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(color: PdfColors.amber100, borderRadius: pw.BorderRadius.circular(4)), child: pw.Text('awl_note'.tr(), style: textStyle.copyWith(color: PdfColors.black))),
            if (result.raddApplied) pw.Container(margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(color: PdfColors.blue100, borderRadius: pw.BorderRadius.circular(4)), child: pw.Text('radd_note'.tr(), style: textStyle.copyWith(color: PdfColors.black))),
            if (result.specialCase != null) pw.Container(margin: const pw.EdgeInsets.only(bottom: 8), padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(color: PdfColors.purple100, borderRadius: pw.BorderRadius.circular(4)), child: pw.Text('${'special_case'.tr()}: ${result.specialCase}', style: textStyle.copyWith(color: PdfColors.black))),
            
            pw.SizedBox(height: 16),

            // PIE CHART
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(
                  width: 140, height: 140,
                  child: pw.CustomPaint(
                    size: const PdfPoint(140, 140),
                    painter: (canvas, size) {
                      final centerX = size.x / 2;
                      final centerY = size.y / 2;
                      final radius = size.x / 2 * 0.9;
                      double startAngle = -pi / 2;
                      for (int i = 0; i < activeShares.length; i++) {
                        final share = activeShares[i];
                        final sweepAngle = (share.totalValue / result.netEstate) * 2 * pi;
                        final x1 = centerX + radius * cos(startAngle);
                        final y1 = centerY + radius * sin(startAngle);
                        final x2 = centerX + radius * cos(startAngle + sweepAngle);
                        final y2 = centerY + radius * sin(startAngle + sweepAngle);
                        final largeArcFlag = sweepAngle > pi ? 1 : 0;
                        final svgPath = 'M $centerX $centerY L $x1 $y1 A $radius $radius 0 $largeArcFlag 1 $x2 $y2 Z';
                        canvas.setFillColor(colors[i % colors.length]);
                        canvas.drawShape(svgPath);
                        canvas.fillPath();
                        startAngle += sweepAngle;
                      }
                    },
                  ),
                ),
                pw.SizedBox(width: 32),
                pw.Expanded(
                  child: pw.Wrap(
                    spacing: 12, runSpacing: 8,
                    children: activeShares.asMap().entries.map((entry) {
                      final index = entry.key;
                      final share = entry.value;
                      return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [pw.Container(width: 10, height: 10, decoration: pw.BoxDecoration(color: colors[index % colors.length], shape: pw.BoxShape.circle)), pw.SizedBox(width: 4), pw.Text(heirTypeLabelKey(share.heirType).tr(), style: textStyle)]);
                    }).toList(),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // TABLE HEADERS
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400))),
              child: pw.Row(children: [
                pw.Expanded(flex: 3, child: pw.Text('col_heir'.tr(), style: boldStyle.copyWith(color: PdfColors.grey700))),
                pw.Expanded(flex: 2, child: pw.Text('col_share'.tr(), textAlign: pw.TextAlign.center, style: boldStyle.copyWith(color: PdfColors.grey700))),
                pw.Expanded(flex: 2, child: pw.Text('col_pct'.tr(), textAlign: pw.TextAlign.center, style: boldStyle.copyWith(color: PdfColors.grey700))),
                pw.Expanded(flex: 4, child: pw.Text('col_amount'.tr(), textAlign: pw.TextAlign.right, style: boldStyle.copyWith(color: PdfColors.grey700))),
              ]),
            ),
            
            // TABLE DATA
            ...activeShares.asMap().entries.map((entry) {
              final index = entry.key;
              final share = entry.value;
              final isGroup = share.count > 1;
              final color = colors[index % colors.length];
              final percentage = (share.totalValue / result.netEstate) * 100;
              final groupName = isGroup ? _getPluralKey(share.heirType).tr() : heirTypeLabelKey(share.heirType).tr();
              final ruleKey = _getCategoryRule(share.category);
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                    child: pw.Row(children: [
                      pw.Expanded(flex: 3, child: pw.Row(children: [pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)), pw.SizedBox(width: 6), pw.Text('$groupName ${isGroup ? "(${share.count})" : ""}', style: boldStyle), if (ruleKey.isNotEmpty) ...[pw.SizedBox(width: 4), pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1), decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(2)), child: pw.Text(ruleKey.tr(), style: pw.TextStyle(font: arabicFont, fontSize: 7, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)))]]),),
                      pw.Expanded(flex: 2, child: pw.Text(share.finalShare.toString(), textAlign: pw.TextAlign.center, style: boldStyle)),
                      pw.Expanded(flex: 2, child: pw.Text('${percentage.toStringAsFixed(2)}%', textAlign: pw.TextAlign.center, style: boldStyle.copyWith(color: PdfColors.orange700))),
                      pw.Expanded(flex: 4, child: pw.Text('${formatter.format(share.totalValue)} $currency', textAlign: pw.TextAlign.right, style: boldStyle)),
                    ]),
                  ),
                  if (isGroup) ...List.generate(share.count, (i) {
                    final indFraction = share.finalShare / iu.Fraction(share.count, 1);
                    final indPct = percentage / share.count;
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
                      child: pw.Row(children: [
                        pw.Expanded(flex: 3, child: pw.Padding(padding: const pw.EdgeInsets.only(left: 16), child: pw.Text('${heirTypeLabelKey(share.heirType).tr()} ${i + 1}', style: textStyle.copyWith(color: PdfColors.grey800)))),
                        pw.Expanded(flex: 2, child: pw.Text(indFraction.toString(), textAlign: pw.TextAlign.center, style: textStyle.copyWith(color: PdfColors.grey600))),
                        pw.Expanded(flex: 2, child: pw.Text('${indPct.toStringAsFixed(2)}%', textAlign: pw.TextAlign.center, style: textStyle.copyWith(color: PdfColors.grey600))),
                        pw.Expanded(flex: 4, child: pw.Text('${formatter.format(share.perPersonValue)} $currency', textAlign: pw.TextAlign.right, style: textStyle.copyWith(color: PdfColors.grey800))),
                      ]),
                    );
                  }),
                ],
              );
            }),

            // MARGINAL NOTES
            if (inputHeirs.any((h) => !result.shares.any((s) => s.heirType == h.type && !s.isBlocked))) ...[
              pw.SizedBox(height: 24), pw.Divider(color: PdfColors.grey400), pw.SizedBox(height: 8),
              pw.Text(isArabic ? 'ملاحظات هامشية - القواعد المطبقة' : (isFrench ? 'Notes marginales - Règles appliquées' : 'Marginal Notes - Applied Rules'), style: boldStyle.copyWith(color: PdfColor.fromHex('#E53935'))),
              pw.SizedBox(height: 8),
              ...inputHeirs.where((h) => !result.shares.any((s) => s.heirType == h.type && !s.isBlocked)).map((h) {
                final excludedMsg = isArabic ? 'محجوب من الميراث (حجب)' : (isFrench ? 'est exclu(e) de l\'héritage (Hijab)' : 'is excluded from inheritance (Hijab)');
                return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 4), child: pw.Text('- ${heirTypeLabelKey(h.type).tr()} $excludedMsg', style: textStyle.copyWith(fontSize: 10)));
              }),
            ],

            pw.SizedBox(height: 24),

            // FOOTER WITH PUBLISHER NAME
            pw.Divider(color: PdfColors.grey400),
            pw.Text(
              isArabic ? 'إخلاء مسؤولية: هذا التطبيق أداة حساب. استشر عالماً مؤهلاً للفتوى النهائية.'
                : (isFrench ? 'Avertissement: Cette application est une aide au calcul. Consultez un savant qualifié.' 
                : 'Disclaimer: This app is a calculation aid. Consult a qualified scholar for final rulings.'),
              style: textStyle.copyWith(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '© ${AppInfo.year} ${'publisher'.tr()}: ${AppInfo.publisherName} | v${AppInfo.version}',
              style: textStyle.copyWith(fontSize: 9, color: PdfColor.fromHex('#00897B'), fontWeight: pw.FontWeight.bold),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}