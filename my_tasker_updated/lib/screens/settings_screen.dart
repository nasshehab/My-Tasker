// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notificationsEnabled;
  late int  _dailyGoalMinutes;
  late String? _geminiKey;
  bool _clearingData = false;

  @override
  void initState() {
    super.initState();
    final s = DB.getSettings();
    _notificationsEnabled = s.notificationsEnabled;
    _dailyGoalMinutes     = s.dailyStudyGoalMinutes;
    _geminiKey            = s.geminiApiKey;
  }

  Future<void> _save() async {
    final s = DB.getSettings()
      ..notificationsEnabled = _notificationsEnabled
      ..dailyStudyGoalMinutes = _dailyGoalMinutes
      ..geminiApiKey = _geminiKey;
    await DB.saveSettings(s);
    final p = DB.getProfile()..dailyGoalMinutes = _dailyGoalMinutes;
    await DB.saveProfile(p);
    ref.read(settingsProvider.notifier).refresh();
    ref.read(profileProvider.notifier).refresh();
  }

  String _fmtGoal(int m) {
    if (m < 60) return '$m মি';
    final h = m ~/ 60, rem = m % 60;
    return rem == 0 ? '$h ঘ' : '$h ঘ $rem মি';
  }

  Future<void> _confirmClearData(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('সব ডেটা মুছবেন?',
            style: TextStyle(color: C.text, fontWeight: FontWeight.w700)),
        content: const Text('সমস্ত কাজ, অভ্যাস, সেশন ও ইতিহাস মুছে যাবে। এটি পূর্বাবস্থায় ফেরানো যাবে না।',
            style: TextStyle(color: C.textSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('বাতিল', style: TextStyle(color: C.textSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('মুছুন', style: TextStyle(color: C.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _clearingData = true);
    try {
      await _clearAllData();
      refreshAll(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('সব ডেটা মুছে ফেলা হয়েছে')));
      }
    } finally {
      if (mounted) setState(() => _clearingData = false);
    }
  }

  Future<void> _clearAllData() async {
    final tasks    = DB.getTasks(includeCompleted: true);
    for (final t in tasks) await DB.deleteTask(t.id);
    final habits   = DB.getHabits(activeOnly: false);
    for (final h in habits) await DB.deleteHabit(h.id);
    final sessions = DB.getSessions();
    for (final s in sessions) await DB.deleteSession(s.id);
    final plans    = DB.getPlans();
    for (final p in plans) await DB.deletePlan(p.id);
    final cats     = DB.getCategories();
    for (final c in cats) await DB.deleteCategory(c.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: C.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('সেটিংস',
            style: TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 17)),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: C.border)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [

          // ── Study Settings ──────────────────────────────────────────────────
          _SectionLabel('পড়াশোনার সেটিং'),
          _SettingCard(children: [
            _TileRow(
              icon: Icons.track_changes_outlined,
              iconColor: C.primary,
              title: 'দৈনিক লক্ষ্যমাত্রা',
              subtitle: 'প্রতিদিন কতক্ষণ পড়তে চান',
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                _StepBtn(Icons.remove_outlined, () async {
                  setState(() => _dailyGoalMinutes = (_dailyGoalMinutes - 15).clamp(15, 720));
                  await _save();
                }),
                const SizedBox(width: 8),
                Text(_fmtGoal(_dailyGoalMinutes),
                    style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(width: 8),
                _StepBtn(Icons.add_outlined, () async {
                  setState(() => _dailyGoalMinutes = (_dailyGoalMinutes + 15).clamp(15, 720));
                  await _save();
                }),
              ]),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Notifications ───────────────────────────────────────────────────
          _SectionLabel('বিজ্ঞপ্তি'),
          _SettingCard(children: [
            _TileRow(
              icon: Icons.notifications_outlined,
              iconColor: C.accent,
              title: 'রিমাইন্ডার বিজ্ঞপ্তি',
              subtitle: 'কাজের সময় মনে করিয়ে দেওয়া',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (v) async {
                  setState(() => _notificationsEnabled = v);
                  await _save();
                },
                activeColor: C.primary,
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // ── App Info ────────────────────────────────────────────────────────
          _SectionLabel('অ্যাপ সম্পর্কে'),
          _SettingCard(children: [
            _TileRow(
              icon: Icons.info_outline,
              iconColor: C.primary,
              title: 'সংস্করণ',
              subtitle: 'মাই ট্যাস্কার',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: C.primaryDim, borderRadius: BorderRadius.circular(8)),
                child: const Text('v1.0.0',
                    style: TextStyle(color: C.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
            const Divider(height: 1, color: C.divider),
            _TileRow(
              icon: Icons.code_outlined,
              iconColor: C.textSub,
              title: 'ডেভেলপার',
              subtitle: 'Nowshad Abrar Shehab',
              trailing: const Icon(Icons.chevron_right, color: C.textHint, size: 18),
            ),
            const Divider(height: 1, color: C.divider),
            _TileRow(
              icon: Icons.history_outlined,
              iconColor: C.textSub,
              title: 'বিল্ড তারিখ',
              subtitle: 'মার্চ ২০২৬',
              trailing: const SizedBox.shrink(),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Data Management ─────────────────────────────────────────────────
          _SectionLabel('ডেটা ব্যবস্থাপনা'),
          _SettingCard(children: [
            _TileRow(
              icon: Icons.delete_sweep_outlined,
              iconColor: C.red,
              title: 'সব ডেটা মুছুন',
              subtitle: 'কাজ, অভ্যাস, সেশন — সব মুছে যাবে',
              trailing: _clearingData
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: C.red, strokeWidth: 2))
                  : GestureDetector(
                      onTap: () => _confirmClearData(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: C.redDim, borderRadius: BorderRadius.circular(8)),
                        child: const Text('মুছুন',
                            style: TextStyle(color: C.red, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
            ),
          ]),
          const SizedBox(height: 28),

          // Footer note
          Center(
            child: Text('মাই ট্যাস্কার | Developer: Nowshad Abrar Shehab',
                style: TextStyle(color: C.textHint, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
    child: Text(label.toUpperCase(),
        style: TextStyle(color: C.textHint, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
  );
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: C.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border)),
    child: Column(children: children),
  );
}

class _TileRow extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, subtitle;
  final Widget trailing;
  const _TileRow({required this.icon, required this.iconColor,
      required this.title, required this.subtitle, required this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: iconColor, size: 19)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(subtitle, style: const TextStyle(color: C.textSub, fontSize: 12)),
      ])),
      const SizedBox(width: 8),
      trailing,
    ]),
  );
}

class _StepBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _StepBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
          color: C.primaryDim, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.primary.withOpacity(0.2))),
      child: Icon(icon, color: C.primary, size: 16),
    ),
  );
}
