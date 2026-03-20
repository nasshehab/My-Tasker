// lib/screens/task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';
import '../utils/notifications.dart';
import '../widgets/widgets.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});
  @override ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final all     = DB.getTasks(includeCompleted: true);
    final pending = all.where((t) => !t.isCompleted).toList();
    final done    = all.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.surface,
        elevation: 0,
        title: const Row(children: [
          AppLogo(size: 26), SizedBox(width: 8),
          Text('কাজের তালিকা', style: TextStyle(fontWeight: FontWeight.w700, color: C.text)),
        ]),
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
                tabs: [
                  Tab(text: 'বাকি (${K.tobn(pending.length)})'),
                  Tab(text: 'সম্পন্ন (${K.tobn(done.length)})'),
                ],
              ),
            ),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TaskList(tasks: pending, showDone: false, ref: ref),
          _TaskList(tasks: done,    showDone: true,  ref: ref),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: C.primary, foregroundColor: Colors.white,
        onPressed: () => _showAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddTaskSheet(ref: ref),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final bool showDone;
  final WidgetRef ref;
  const _TaskList({required this.tasks, required this.showDone, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyView(
        message: showDone ? 'এখনো কোনো কাজ সম্পন্ন হয়নি' : 'কোনো কাজ নেই\n+ বোতামে চাপুন',
        icon: showDone ? Icons.task_alt : Icons.assignment_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _TaskCard(task: tasks[i], ref: ref)
          .animate().fadeIn(delay: Duration(milliseconds: i * 40)),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task; final WidgetRef ref;
  const _TaskCard({required this.task, required this.ref});

  @override
  Widget build(BuildContext context) {
    final pColors = [C.green, C.yellow, C.red];
    final pc = pColors[task.priority.clamp(0, 2)];

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: C.redDim, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_outline, color: C.red),
      ),
      onDismissed: (_) async {
        await DB.deleteTask(task.id);
        ref.read(tasksProvider.notifier).refresh();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left:   BorderSide(color: pc, width: 4),
            top:    const BorderSide(color: C.border),
            right:  const BorderSide(color: C.border),
            bottom: const BorderSide(color: C.border),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () async {
                if (!task.isCompleted) {
                  await DB.completeTask(task.id);
                  if (task.notificationId != 0) await NS.cancel(task.notificationId);
                  ref.read(tasksProvider.notifier).refresh();
                  ref.read(historyProvider.notifier).refresh();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 2),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? C.green : Colors.transparent,
                  border: Border.all(color: task.isCompleted ? C.green : C.border, width: 2),
                ),
                child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title, style: TextStyle(
                  color: task.isCompleted ? C.textHint : C.text,
                  fontSize: 14, fontWeight: FontWeight.w600,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(task.description, style: const TextStyle(color: C.textSub, fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.schedule_outlined, color: C.textHint, size: 13),
                const SizedBox(width: 4),
                Text(DateFormat('d MMM, h:mm a').format(task.dueDate),
                    style: const TextStyle(color: C.textHint, fontSize: 11)),
                if (task.hasReminder) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.notifications_active_outlined, color: C.primary, size: 13),
                  const SizedBox(width: 2),
                  const Text('রিমাইন্ডার', style: TextStyle(color: C.primary, fontSize: 11)),
                ],
              ]),
            ])),
            const SizedBox(width: 8),
            PriorityBadge(priority: task.priority),
          ]),
        ),
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddTaskSheet({required this.ref});
  @override State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _title = TextEditingController();
  final _desc  = TextEditingController();
  DateTime _due     = DateTime.now().add(const Duration(hours: 1));
  DateTime? _reminder;
  int _priority     = 1;
  bool _hasReminder = false;

  @override
  void dispose() { _title.dispose(); _desc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SheetHandle(),
        const Text('নতুন কাজ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text)),
        const SizedBox(height: 16),
        TextField(controller: _title, autofocus: true,
            style: const TextStyle(color: C.text),
            decoration: const InputDecoration(hintText: 'কাজের শিরোনাম')),
        const SizedBox(height: 10),
        TextField(controller: _desc,
            style: const TextStyle(color: C.text),
            decoration: const InputDecoration(hintText: 'বিবরণ (ঐচ্ছিক)')),
        const SizedBox(height: 14),

        // Priority
        Row(children: [
          const Text('গুরুত্ব:', style: TextStyle(color: C.textSub, fontSize: 13)),
          const SizedBox(width: 12),
          ...[
            ['কম', C.green, 0],
            ['মধ্যম', C.yellow, 1],
            ['জরুরি', C.red, 2],
          ].map((p) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Press(
              onTap: () => setState(() => _priority = p[2] as int),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _priority == p[2] ? (p[1] as Color).withOpacity(0.15) : C.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _priority == p[2] ? p[1] as Color : C.border),
                ),
                child: Text(p[0] as String, style: TextStyle(
                    color: _priority == p[2] ? p[1] as Color : C.textSub,
                    fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          )),
        ]),
        const SizedBox(height: 12),

        // Due date
        Press(
          onTap: () async {
            final d = await showDatePicker(
              context: context, initialDate: _due,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (d == null || !mounted) return;
            final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_due));
            if (t != null) setState(() => _due = DateTime(d.year, d.month, d.day, t.hour, t.minute));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
                color: C.surface2, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.border)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, color: C.primary, size: 18),
              const SizedBox(width: 10),
              Text(DateFormat('EEE, d MMM yyyy  h:mm a').format(_due),
                  style: const TextStyle(color: C.text, fontSize: 13)),
            ]),
          ),
        ),
        const SizedBox(height: 10),

        // Reminder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
              color: C.surface2, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.border)),
          child: Row(children: [
            const Icon(Icons.notifications_outlined, color: C.primary, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Text('রিমাইন্ডার', style: TextStyle(color: C.text, fontSize: 13))),
            Switch(
              value: _hasReminder,
              onChanged: (v) => setState(() {
                _hasReminder = v;
                if (v) _reminder = _due.subtract(const Duration(minutes: 15));
              }),
              activeColor: C.primary,
            ),
          ]),
        ),
        const SizedBox(height: 20),

        PBtn(
          label: 'কাজ যোগ করুন', fullWidth: true,
          onTap: () async {
            if (_title.text.trim().isEmpty) return;
            final nid = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            await DB.addTask(
              title: _title.text.trim(), description: _desc.text.trim(),
              dueDate: _due,
              reminderTime: _hasReminder ? _reminder : null,
              priority: _priority,
              hasReminder: _hasReminder,
              notificationId: _hasReminder ? nid : 0,
            );
            if (_hasReminder && _reminder != null) {
              await NS.schedule(
                id: nid,
                title: 'রিমাইন্ডার: ${_title.text.trim()}',
                body: _desc.text.isNotEmpty ? _desc.text.trim() : 'কাজের সময় হয়েছে',
                when: _reminder!,
              );
            }
            widget.ref.read(tasksProvider.notifier).refresh();
            if (mounted) Navigator.pop(context);
          },
        ),
      ]),
    ),
  );
}
