// lib/screens/dashboard_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selDate       = ref.watch(selectedDateProvider);
    final tasks         = DB.getTasksForDate(selDate);
    final habits        = ref.watch(habitsProvider);
    final profile       = ref.watch(profileProvider);
    final isOnline      = ref.watch(connectivityProvider).value ?? false;
    final todaySessions = DB.getSessions(date: DateTime.now());
    final todayMin      = todaySessions.fold(0, (s, e) => s + e.durationMinutes);
    final goal          = profile.dailyGoalMinutes;
    final pct           = goal > 0 ? (todayMin / goal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          _buildAppBar(context, profile, isOnline),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              children: [
                const SizedBox(height: 12),
                WeekStrip(selected: selDate,
                    onSelect: (d) => ref.read(selectedDateProvider.notifier).state = d),
                const SizedBox(height: 14),

                // Goal card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.auto_stories, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('আজকের পড়াশোনার লক্ষ্য',
                          style: TextStyle(color: Colors.white70, fontSize: 13))),
                      Text('${(pct * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${K.fmtDuration(todayMin)} / ${K.fmtDuration(goal)} পড়া হয়েছে',
                        style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ]),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 14),

                // Stats
                Row(children: [
                  Expanded(child: StatTile(label: 'আজ পড়া',
                      value: K.fmtDuration(todayMin), icon: Icons.timer_outlined, color: C.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(
                      label: 'বাকি কাজ',
                      value: K.tobn(tasks.where((t) => !t.isCompleted).length),
                      icon: Icons.checklist_outlined, color: C.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(
                      label: 'ধারাবাহিক',
                      value: '${K.tobn(profile.currentStreak)} দিন',
                      icon: Icons.local_fire_department, color: C.yellow)),
                ]).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 18),

                // Tasks
                SHead(title: 'আজকের কাজ', action: 'সব দেখুন',
                    onAction: () => ref.read(tabProvider.notifier).state = 2),
                if (tasks.isEmpty)
                  const EmptyView(message: 'আজকের জন্য কোনো কাজ নেই', icon: Icons.task_outlined)
                else
                  ...tasks.take(4).map((t) => _TaskRow(task: t, ref: ref)
                      .animate().fadeIn(delay: 50.ms)),
                const SizedBox(height: 18),

                // Habits
                SHead(title: 'আজকের অভ্যাস', action: 'সব দেখুন',
                    onAction: () => ref.read(tabProvider.notifier).state = 1),
                if (habits.isEmpty)
                  const EmptyView(message: 'কোনো অভ্যাস যোগ করা হয়নি', icon: Icons.repeat_outlined)
                else
                  ...habits.take(5).map((h) => _HabitRow(habit: h, date: selDate, ref: ref)
                      .animate().fadeIn(delay: 50.ms)),

                // AI card
                if (isOnline) ...[
                  const SizedBox(height: 18),
                  SCard(
                    color: C.primaryDim,
                    border: Border.all(color: C.primary.withOpacity(0.25)),
                    child: const Row(children: [
                      Icon(Icons.auto_awesome, color: C.primary, size: 22),
                      SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('AI পড়াশোনা সহায়ক',
                            style: TextStyle(color: C.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('ইন্টারনেট সংযোগ আছে — AI সুবিধা ব্যবহার করুন',
                            style: TextStyle(color: C.textSub, fontSize: 12)),
                      ])),
                      Icon(Icons.chevron_right, color: C.primary),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: C.primary, foregroundColor: Colors.white,
        onPressed: () => _showQuickAdd(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserProfile profile, bool isOnline) {
    return Column(children: [
      Container(
        color: C.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(children: [
          const AppLogo(size: 30, showText: true),
          const Spacer(),
          profile.photoPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(profile.photoPath!),
                      width: 36, height: 36, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _AvatarDefault()))
              : const _AvatarDefault(),
        ]),
      ),
      if (!isOnline) const OfflineBanner(),
      const Divider(height: 1, color: C.border),
    ]);
  }

  void _showQuickAdd(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SheetHandle(),
          const Text('দ্রুত যোগ করুন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.text)),
          const SizedBox(height: 16),
          _QuickTile(Icons.add_task, 'নতুন কাজ', C.primary, () {
            Navigator.pop(context);
            ref.read(tabProvider.notifier).state = 2;
          }),
          const SizedBox(height: 8),
          _QuickTile(Icons.timer_outlined, 'পড়াশোনার সেশন', C.accent, () {
            Navigator.pop(context);
            ref.read(tabProvider.notifier).state = 3;
          }),
          const SizedBox(height: 8),
          _QuickTile(Icons.loop, 'নতুন অভ্যাস', C.green, () {
            Navigator.pop(context);
            ref.read(tabProvider.notifier).state = 1;
          }),
        ]),
      ),
    );
  }
}

class _AvatarDefault extends StatelessWidget {
  const _AvatarDefault();
  @override
  Widget build(BuildContext context) => const CircleAvatar(
      radius: 18, backgroundColor: C.primaryDim,
      child: Icon(Icons.person, color: C.primary, size: 20));
}

class _QuickTile extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickTile(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Press(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22), const SizedBox(width: 14),
        Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _TaskRow extends ConsumerWidget {
  final Task task; final WidgetRef ref;
  const _TaskRow({required this.task, required this.ref});
  @override
  Widget build(BuildContext context, WidgetRef r) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        GestureDetector(
          onTap: () async {
            if (!task.isCompleted) {
              await DB.completeTask(task.id);
              ref.read(tasksProvider.notifier).refresh();
              ref.read(historyProvider.notifier).refresh();
            }
          },
          child: AnimatedContainer(
            duration: 200.ms,
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted ? C.green : Colors.transparent,
              border: Border.all(color: task.isCompleted ? C.green : C.border, width: 2),
            ),
            child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.title, style: TextStyle(
            color: task.isCompleted ? C.textHint : C.text, fontSize: 14, fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          )),
          if (task.description.isNotEmpty)
            Text(task.description, style: const TextStyle(color: C.textSub, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 8),
        PriorityBadge(priority: task.priority),
      ]),
    ),
  );
}

class _HabitRow extends StatelessWidget {
  final Habit habit; final DateTime date; final WidgetRef ref;
  const _HabitRow({required this.habit, required this.date, required this.ref});
  @override
  Widget build(BuildContext context) {
    final key  = K.dateKey(date);
    final done = habit.completionLog[key] ?? false;
    final col  = C.byIndex(habit.colorIndex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(IconData(habit.iconCode, fontFamily: 'MaterialIcons'), color: col, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.name, style: const TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w500)),
            Text('${K.tobn(habit.currentStreak)} দিনের ধারাবাহিকতা',
                style: const TextStyle(color: C.textSub, fontSize: 12)),
          ])),
          GestureDetector(
            onTap: () async {
              await DB.toggleHabit(habit.id, date);
              ref.read(habitsProvider.notifier).refresh();
            },
            child: AnimatedContainer(
              duration: 200.ms,
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? C.green : C.surface2,
                border: Border.all(color: done ? C.green : C.border, width: 1.5),
              ),
              child: done ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
          ),
        ]),
      ),
    );
  }
}
