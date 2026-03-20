// lib/screens/study_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';
import '../utils/pdf_service.dart';
import '../widgets/widgets.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});
  @override ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: AppBar(
      backgroundColor: C.surface, elevation: 0,
      title: const Row(children: [
        AppLogo(size: 26), SizedBox(width: 8),
        Text('পড়াশোনা', style: TextStyle(fontWeight: FontWeight.w700, color: C.text)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: C.primary),
          tooltip: 'নতুন সেশন',
          onPressed: () => _showLogSession(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: C.textSub,
              indicator: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(10)),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [Tab(text: 'সেশন'), Tab(text: 'পরিকল্পনা'), Tab(text: 'অগ্রগতি')],
            ),
          ),
        ]),
      ),
    ),
    body: TabBarView(
      controller: _tabs,
      children: [
        _SessionsTab(ref: ref),
        _PlansTab(ref: ref),
        _ProgressTab(ref: ref),
      ],
    ),
  );

  void _showLogSession(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _LogSessionSheet(ref: ref),
    );
  }
}

// ── Sessions Tab ───────────────────────────────────────────────────────────────
class _SessionsTab extends StatelessWidget {
  final WidgetRef ref;
  const _SessionsTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    if (sessions.isEmpty) {
      return const EmptyView(message: 'কোনো সেশন নেই।\n+ বোতামে চাপুন।', icon: Icons.timer_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: sessions.length,
      itemBuilder: (_, i) {
        final s   = sessions[i];
        final cat = DB.getCatById(s.categoryId);
        final col = cat != null ? C.byIndex(cat.colorIndex) : C.primary;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
          child: Row(children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: col.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
              child: Icon(cat != null
                  ? IconData(cat.iconCode, fontFamily: 'MaterialIcons')
                  : Icons.menu_book_outlined, color: col, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.subject, style: const TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w600)),
              if (cat != null) Text(cat.name, style: const TextStyle(color: C.textSub, fontSize: 12)),
              Text(K.fmtDate(s.date), style: const TextStyle(color: C.textHint, fontSize: 11)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(K.fmtDuration(s.durationMinutes),
                  style: const TextStyle(color: C.primary, fontSize: 16, fontWeight: FontWeight.w700)),
              Row(children: List.generate(5, (j) => Icon(
                j < s.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: C.yellow, size: 13))),
            ]),
          ]),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 40));
      },
    );
  }
}

// ── Plans Tab ──────────────────────────────────────────────────────────────────
class _PlansTab extends StatelessWidget {
  final WidgetRef ref;
  const _PlansTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: PBtn(label: 'নতুন পরিকল্পনা তৈরি করুন', icon: Icons.add, fullWidth: true,
            onTap: () => _showCreatePlan(context, ref)),
      ),
      Expanded(
        child: plans.isEmpty
            ? const EmptyView(message: 'কোনো পরিকল্পনা নেই।', icon: Icons.list_alt_outlined)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: plans.length,
                itemBuilder: (_, i) => _PlanCard(plan: plans[i], ref: ref)
                    .animate().fadeIn(delay: Duration(milliseconds: i * 50)),
              ),
      ),
    ]);
  }

  void _showCreatePlan(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CreatePlanSheet(ref: ref),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final StudyPlan plan; final WidgetRef ref;
  const _PlanCard({required this.plan, required this.ref});

  @override
  Widget build(BuildContext context) {
    final col  = C.byIndex(plan.colorIndex);
    final days = plan.endDate.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col.withOpacity(0.4), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(plan.title,
              style: const TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w700))),
          Press(
            onTap: () async { await DB.deletePlan(plan.id); ref.read(plansProvider.notifier).refresh(); },
            child: Icon(Icons.delete_outline, color: C.red.withOpacity(0.6), size: 20),
          ),
        ]),
        if (plan.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(plan.description, style: const TextStyle(color: C.textSub, fontSize: 12)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.today_outlined, size: 14, color: C.textHint),
          const SizedBox(width: 4),
          Text('${K.fmtDate(plan.startDate)} — ${K.fmtDate(plan.endDate)}',
              style: const TextStyle(color: C.textHint, fontSize: 11)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.timer_outlined, size: 14, color: C.textHint),
          const SizedBox(width: 4),
          Text('দৈনিক লক্ষ্য: ${K.fmtDuration(plan.targetDailyMinutes)}',
              style: const TextStyle(color: C.textSub, fontSize: 12)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: days > 0 ? C.primaryDim : C.redDim,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(days > 0 ? '${K.tobn(days)} দিন বাকি' : 'শেষ',
                style: TextStyle(color: days > 0 ? C.primary : C.red, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }
}

// ── Progress Tab ───────────────────────────────────────────────────────────────
class _ProgressTab extends StatefulWidget {
  final WidgetRef ref;
  const _ProgressTab({required this.ref});
  @override State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  bool _downloading = false;
  int _selMonth = DateTime.now().month;
  int _selYear  = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final profile    = DB.getProfile();
    final catMinutes = DB.getCatMinutes();
    final cats       = DB.getCats();
    final total      = catMinutes.values.fold(0, (s, v) => s + v);
    final monthData  = DB.getMonthlyMinutes(_selYear, _selMonth);
    final daysInMonth = DateTime(_selYear, _selMonth + 1, 0).day;
    final maxVal     = monthData.values.isEmpty ? 60 : monthData.values.reduce((a, b) => a > b ? a : b);
    const months     = ['জানু','ফেব্রু','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টে','অক্টো','নভে','ডিসে'];
    const monthsFull = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Summary cards
        Row(children: [
          Expanded(child: StatTile(label: 'মোট পড়া',
              value: K.fmtDuration(profile.totalStudyMinutes),
              icon: Icons.timer_outlined, color: C.primary)),
          const SizedBox(width: 12),
          Expanded(child: StatTile(label: 'সর্বোচ্চ ধারাবাহিকতা',
              value: '${K.tobn(profile.longestStreak)} দিন',
              icon: Icons.local_fire_department, color: C.accent)),
        ]),
        const SizedBox(height: 20),

        // Pie chart
        const SHead(title: 'বিষয় অনুযায়ী সময়'),
        if (catMinutes.isEmpty || total == 0)
          Container(
            height: 120,
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
            child: const EmptyView(message: 'সেশন লগ করলে চার্ট দেখা যাবে', icon: Icons.pie_chart_outline),
          )
        else
          SCard(child: Column(children: [
            SizedBox(height: 180, child: PieChart(PieChartData(
              sections: cats.where((c) => (catMinutes[c.id] ?? 0) > 0).map((c) {
                final min = catMinutes[c.id] ?? 0;
                final pct = min / total * 100;
                return PieChartSectionData(
                  value: min.toDouble(), color: C.byIndex(c.colorIndex),
                  title: '${pct.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  radius: 65,
                );
              }).toList(),
              centerSpaceRadius: 40, sectionsSpace: 3,
            ))),
            const SizedBox(height: 12),
            ...cats.where((c) => (catMinutes[c.id] ?? 0) > 0).map((c) {
              final min = catMinutes[c.id] ?? 0;
              final pct = (min / total * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 10, height: 10,
                      decoration: BoxDecoration(color: C.byIndex(c.colorIndex), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(c.name, style: const TextStyle(color: C.text, fontSize: 13))),
                  Text('$pct% | ${K.fmtDuration(min)}', style: const TextStyle(color: C.textSub, fontSize: 12)),
                ]),
              );
            }),
          ])),
        const SizedBox(height: 20),

        // Monthly bar chart
        Row(children: [
          const Expanded(child: Text('মাসিক বিশ্লেষণ',
              style: TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: C.primary),
            onPressed: () => setState(() {
              _selMonth--; if (_selMonth < 1) { _selMonth = 12; _selYear--; }
            }),
          ),
          Text('${months[_selMonth - 1]} ${K.tobn(_selYear)}',
              style: const TextStyle(color: C.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: C.primary),
            onPressed: () => setState(() {
              _selMonth++; if (_selMonth > 12) { _selMonth = 1; _selYear++; }
            }),
          ),
        ]),
        SCard(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              gridData: FlGridData(
                show: true, drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: C.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, interval: 5,
                  getTitlesWidget: (v, _) {
                    final day = v.toInt() + 1;
                    if (day % 5 != 0) return const SizedBox.shrink();
                    return Text(K.tobn(day), style: const TextStyle(color: C.textHint, fontSize: 9));
                  },
                )),
              ),
              barGroups: List.generate(daysInMonth, (i) {
                final d   = DateTime(_selYear, _selMonth, i + 1);
                final min = monthData[K.dateKey(d)] ?? 0;
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: min.toDouble(),
                    color: min > 0 ? C.primary : C.border,
                    width: 6, borderRadius: BorderRadius.circular(3),
                  ),
                ]);
              }),
              maxY: (maxVal * 1.3).toDouble(),
            )),
          ),
        ),
        const SizedBox(height: 20),

        // PDF download card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: C.primaryDim,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.primary.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.picture_as_pdf, color: C.primary, size: 22),
              SizedBox(width: 10),
              Text('মাসিক রিপোর্ট ডাউনলোড', style: TextStyle(color: C.primary, fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            const Text('সেশন, কাজ ও অভ্যাসের সম্পূর্ণ মাসিক প্রতিবেদন PDF আকারে ডাউনলোড করুন।',
                style: TextStyle(color: C.textSub, fontSize: 12)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selMonth,
                    dropdownColor: C.surface,
                    style: const TextStyle(color: C.text, fontSize: 13),
                    items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(monthsFull[i]))),
                    onChanged: (v) { if (v != null) setState(() => _selMonth = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              _downloading
                  ? const SizedBox(width: 44, height: 44,
                      child: CircularProgressIndicator(color: C.primary, strokeWidth: 2))
                  : PBtn(
                      label: 'ডাউনলোড', icon: Icons.download,
                      onTap: () async {
                        setState(() => _downloading = true);
                        try {
                          await PdfService.generateMonthlyReport(_selYear, _selMonth);
                        } catch (e) {
                          debugPrint('PDF error: $e');
                        } finally {
                          if (mounted) setState(() => _downloading = false);
                        }
                      },
                    ),
            ]),
          ]),
        ),
      ],
    );
  }
}

// ── Add session sheet ──────────────────────────────────────────────────────────
class _LogSessionSheet extends StatefulWidget {
  final WidgetRef ref;
  const _LogSessionSheet({required this.ref});
  @override State<_LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends State<_LogSessionSheet> {
  final _subject = TextEditingController();
  final _notes   = TextEditingController();
  int _dur = 30, _rating = 4;
  String? _catId;

  @override
  void dispose() { _subject.dispose(); _notes.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cats = DB.getCats();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SheetHandle(),
          const Text('পড়াশোনার সেশন লগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text)),
          const SizedBox(height: 16),
          TextField(controller: _subject, autofocus: true,
              style: const TextStyle(color: C.text),
              decoration: const InputDecoration(hintText: 'বিষয় / টপিক')),
          const SizedBox(height: 10),
          if (cats.isNotEmpty)
            DropdownButtonFormField<String?>(
              value: _catId, dropdownColor: C.surface,
              style: const TextStyle(color: C.text),
              decoration: const InputDecoration(hintText: 'বিষয়ের ক্যাটাগরি (ঐচ্ছিক)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('কোনো ক্যাটাগরি নেই')),
                ...cats.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() => _catId = v),
            ),
          const SizedBox(height: 10),
          Row(children: [
            const Text('সময়কাল:', style: TextStyle(color: C.textSub, fontSize: 13)),
            const Spacer(),
            IconButton(
                onPressed: () => setState(() => _dur = (_dur - 5).clamp(5, 600)),
                icon: const Icon(Icons.remove_circle_outline, color: C.textSub)),
            Text('${K.tobn(_dur)} মি', style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 15)),
            IconButton(
                onPressed: () => setState(() => _dur = (_dur + 5).clamp(5, 600)),
                icon: const Icon(Icons.add_circle_outline, color: C.primary)),
          ]),
          Row(children: [
            const Text('রেটিং:', style: TextStyle(color: C.textSub, fontSize: 13)),
            const SizedBox(width: 12),
            ...List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Icon(i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: C.yellow, size: 28),
            )),
          ]),
          const SizedBox(height: 10),
          TextField(controller: _notes,
              style: const TextStyle(color: C.text),
              decoration: const InputDecoration(hintText: 'নোট (ঐচ্ছিক)')),
          const SizedBox(height: 20),
          PBtn(
            label: 'সেশন সেভ করুন', fullWidth: true,
            onTap: () async {
              if (_subject.text.trim().isEmpty) return;
              await DB.addSession(
                subject: _subject.text.trim(), categoryId: _catId,
                durationMinutes: _dur, notes: _notes.text.trim(), rating: _rating,
              );
              widget.ref.read(sessionsProvider.notifier).refresh();
              widget.ref.read(profileProvider.notifier).refresh();
              widget.ref.read(historyProvider.notifier).refresh();
              if (mounted) Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }
}

class _CreatePlanSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreatePlanSheet({required this.ref});
  @override State<_CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<_CreatePlanSheet> {
  final _title = TextEditingController();
  final _desc  = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end   = DateTime.now().add(const Duration(days: 30));
  int _target = 60, _color = 0;

  @override
  void dispose() { _title.dispose(); _desc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHandle(),
      const Text('নতুন পরিকল্পনা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text)),
      const SizedBox(height: 16),
      TextField(controller: _title, autofocus: true,
          style: const TextStyle(color: C.text),
          decoration: const InputDecoration(hintText: 'পরিকল্পনার নাম')),
      const SizedBox(height: 10),
      TextField(controller: _desc,
          style: const TextStyle(color: C.text),
          decoration: const InputDecoration(hintText: 'বিবরণ (ঐচ্ছিক)')),
      const SizedBox(height: 14),
      Row(children: [
        const Text('দৈনিক লক্ষ্য:', style: TextStyle(color: C.textSub, fontSize: 13)),
        const Spacer(),
        IconButton(
            onPressed: () => setState(() => _target = (_target - 15).clamp(15, 480)),
            icon: const Icon(Icons.remove_circle_outline, color: C.textSub)),
        Text('${K.tobn(_target)} মি', style: const TextStyle(color: C.text, fontWeight: FontWeight.w700)),
        IconButton(
            onPressed: () => setState(() => _target = (_target + 15).clamp(15, 480)),
            icon: const Icon(Icons.add_circle_outline, color: C.primary)),
      ]),
      const SizedBox(height: 12),
      const Text('রঙ:', style: TextStyle(color: C.textSub, fontSize: 13)),
      const SizedBox(height: 8),
      ColorPicker(selected: _color, onSelect: (i) => setState(() => _color = i)),
      const SizedBox(height: 20),
      PBtn(
        label: 'পরিকল্পনা তৈরি করুন', fullWidth: true,
        onTap: () async {
          if (_title.text.trim().isEmpty) return;
          await DB.addPlan(
            title: _title.text.trim(), description: _desc.text.trim(),
            startDate: _start, endDate: _end, targetDailyMinutes: _target, colorIndex: _color,
          );
          widget.ref.read(plansProvider.notifier).refresh();
          if (mounted) Navigator.pop(context);
        },
      ),
    ]),
  );
}
