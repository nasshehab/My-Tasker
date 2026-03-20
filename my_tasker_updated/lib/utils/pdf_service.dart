// lib/utils/pdf_service.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import '../utils/db.dart';
import '../utils/app_theme.dart';

class PdfService {
  static Future<void> generateMonthlyReport(int year, int month) async {
    final sessions = DB.getSessionsForMonth(year, month);
    final tasks = DB.getTasks(includeCompleted: true)
        .where((t) =>
            t.createdAt.year == year &&
            t.createdAt.month == month)
        .toList();
    final habits = DB.getHabits();
    final categories = DB.getCategories();
    final profile = DB.getProfile();

    final totalMin = sessions.fold(0, (s, e) => s + e.durationMinutes);
    final completedTasks = tasks.where((t) => t.isCompleted).length;

    final pdf = pw.Document();

    // Category map
    final catMap = {for (final c in categories) c.id: c};

    // Habit completion this month
    final habitRows = <Map<String, dynamic>>[];
    for (final h in habits) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      int done = 0;
      for (int d = 1; d <= daysInMonth; d++) {
        final key = K.dateKey(DateTime(year, month, d));
        if (h.completionLog[key] == true) done++;
      }
      habitRows.add({
        'name': h.name,
        'done': done,
        'total': daysInMonth,
        'pct': daysInMonth > 0 ? (done / daysInMonth * 100).round() : 0,
      });
    }

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('D64E6F'),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('মাই ট্যাস্কার',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('মাসিক রিপোর্ট - ${K.monthName(month)} $year',
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 14)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(profile.name,
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),

        // Summary cards row
        pw.Row(children: [
          _statCard('মোট পড়াশোনা', K.fmtDuration(totalMin), PdfColor.fromHex('D64E6F')),
          pw.SizedBox(width: 12),
          _statCard('সেশন সংখ্যা', '${sessions.length}', PdfColor.fromHex('2D9E5A')),
          pw.SizedBox(width: 12),
          _statCard('কাজ সম্পন্ন', '$completedTasks/${tasks.length}', PdfColor.fromHex('2563EB')),
          pw.SizedBox(width: 12),
          _statCard('অভ্যাস', '${habits.length} টি', PdfColor.fromHex('7C3AED')),
        ]),
        pw.SizedBox(height: 24),

        // Study sessions table
        if (sessions.isNotEmpty) ...[
          _sectionTitle('পড়াশোনার সেশন'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('E8E2DC'), width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              _tableHeader(['বিষয়', 'বিভাগ', 'তারিখ', 'সময়']),
              ...sessions.map((s) => _tableRow([
                s.subject,
                catMap[s.categoryId]?.name ?? '-',
                K.fmtDate(s.date),
                K.fmtDuration(s.durationMinutes),
              ])),
            ],
          ),
          pw.SizedBox(height: 24),
        ],

        // Tasks table
        if (tasks.isNotEmpty) ...[
          _sectionTitle('কাজের তালিকা'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('E8E2DC'), width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              _tableHeader(['শিরোনাম', 'নির্ধারিত তারিখ', 'অবস্থা']),
              ...tasks.map((t) => _tableRow([
                t.title,
                K.fmtDate(t.dueDate),
                t.isCompleted ? 'সম্পন্ন' : 'বাকি',
              ])),
            ],
          ),
          pw.SizedBox(height: 24),
        ],

        // Habits table
        if (habitRows.isNotEmpty) ...[
          _sectionTitle('অভ্যাস ট্র্যাকিং'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('E8E2DC'), width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              _tableHeader(['অভ্যাস', 'সম্পন্ন', 'মোট দিন', 'শতাংশ']),
              ...habitRows.map((h) => _tableRow([
                h['name'].toString(),
                '${h['done']}',
                '${h['total']}',
                '${h['pct']}%',
              ])),
            ],
          ),
          pw.SizedBox(height: 24),
        ],

        // Footer
        pw.Divider(color: PdfColor.fromHex('E8E2DC')),
        pw.SizedBox(height: 8),
        pw.Text(
          'মাই ট্যাস্কার অ্যাপ | Developer: Nowshad Abrar Shehab',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ));

    // Save and share
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'স্টাডি_রিপোর্ট_${K.monthName(month)}_$year.pdf',
    );
  }

  static pw.Widget _statCard(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(value,
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(label,
                  style: const pw.TextStyle(
                      color: PdfColors.white, fontSize: 9)),
            ],
          ),
        ),
      );

  static pw.Widget _sectionTitle(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(t,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('1A1A1A'))),
  );

  static pw.TableRow _tableHeader(List<String> cols) => pw.TableRow(
    decoration: pw.BoxDecoration(color: PdfColor.fromHex('F4F0EC')),
    children: cols.map((c) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(c,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
    )).toList(),
  );

  static pw.TableRow _tableRow(List<String> cols) => pw.TableRow(
    children: cols.map((c) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(c, style: const pw.TextStyle(fontSize: 10)),
    )).toList(),
  );
}
