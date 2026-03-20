// lib/utils/db.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'app_theme.dart';

const _uuid = Uuid();

class DB {
  static Box<UserProfile>  get _profiles  => Hive.box(K.boxProfile);
  static Box<MainCategory> get _cats      => Hive.box(K.boxCats);
  static Box<SubCategory>  get _subs      => Hive.box(K.boxSubs);
  static Box<Task>         get _tasks     => Hive.box(K.boxTasks);
  static Box<StudySession> get _sessions  => Hive.box(K.boxSessions);
  static Box<Habit>        get _habits    => Hive.box(K.boxHabits);
  static Box<HistoryEntry> get _history   => Hive.box(K.boxHistory);
  static Box<StudyPlan>    get _plans     => Hive.box(K.boxPlans);
  static Box<AppSettings>  get _settings  => Hive.box(K.boxSettings);

  // ── Settings ───────────────────────────────────────────────────────
  static AppSettings getSettings() {
    if (_settings.isEmpty) {
      final s = AppSettings();
      _settings.put('settings', s);
      return s;
    }
    return _settings.get('settings') ?? AppSettings();
  }
  static Future<void> saveSettings(AppSettings s) =>
      _settings.put('settings', s);

  // ── Profile ────────────────────────────────────────────────────────
  static UserProfile getProfile() {
    return _profiles.get('user') ?? UserProfile(name: 'শিক্ষার্থী', createdAt: DateTime.now());
  }
  static Future<void> saveProfile(UserProfile p) =>
      _profiles.put('user', p);
  static Future<void> ensureProfile() async {
    if (_profiles.get('user') == null) {
      await saveProfile(UserProfile(
        name: 'শিক্ষার্থী',
        createdAt: DateTime.now(),
      ));
    }
  }

  // ── Categories ─────────────────────────────────────────────────────
  static List<MainCategory> getCategories() =>
      _cats.values.where((c) => !c.isArchived).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  static Future<MainCategory> addCategory(
      String name, int colorIndex, int iconCode) async {
    final c = MainCategory(
      id: _uuid.v4(), name: name, colorIndex: colorIndex,
      createdAt: DateTime.now(), iconCode: iconCode,
    );
    await _cats.put(c.id, c);
    return c;
  }

  static Future<void> updateCategory(MainCategory c) => _cats.put(c.id, c);

  static Future<void> deleteCategory(String id) async {
    await _cats.delete(id);
    for (final s in _subs.values.where((s) => s.parentId == id).toList()) {
      await _subs.delete(s.id);
    }
  }

  static MainCategory? getCategoryById(String? id) =>
      id == null ? null : _cats.get(id);

  // alias used by screens
  static MainCategory? getCatById(String? id) => getCategoryById(id);


  // ── Sub-Categories ─────────────────────────────────────────────────
  static List<SubCategory> getSubCategories(String parentId) =>
      _subs.values.where((s) => s.parentId == parentId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  static List<SubCategory> getAllSubs() => _subs.values.toList();

  static Future<SubCategory> addSubCategory(
      String parentId, String name, int colorIndex, int iconCode) async {
    final s = SubCategory(
      id: _uuid.v4(), parentId: parentId, name: name,
      colorIndex: colorIndex, createdAt: DateTime.now(), iconCode: iconCode,
    );
    await _subs.put(s.id, s);
    return s;
  }

  static Future<void> deleteSubCategory(String id) => _subs.delete(id);

  // ── Tasks ──────────────────────────────────────────────────────────
  static List<Task> getTasks({bool includeCompleted = false}) {
    final list = _tasks.values.toList();
    if (!includeCompleted) {
      return list.where((t) => !t.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    return list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Task> getTasksForDate(DateTime date) {
    final d = K.dateKey(date);
    return _tasks.values
        .where((t) => K.dateKey(t.dueDate) == d)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static Future<Task> addTask({
    required String title,
    String description = '',
    String? categoryId,
    String? subCategoryId,
    required DateTime dueDate,
    DateTime? reminderTime,
    int priority = 1,
    bool hasReminder = false,
    int? estimatedMinutes,
    int notificationId = 0,
  }) async {
    final t = Task(
      id: _uuid.v4(), title: title, description: description,
      categoryId: categoryId, subCategoryId: subCategoryId,
      dueDate: dueDate, reminderTime: reminderTime,
      createdAt: DateTime.now(), priority: priority,
      hasReminder: hasReminder, estimatedMinutes: estimatedMinutes,
      notificationId: notificationId,
    );
    await _tasks.put(t.id, t);
    return t;
  }

  static Future<void> completeTask(String id) async {
    final t = _tasks.get(id);
    if (t == null) return;
    t.isCompleted = true;
    t.completedAt = DateTime.now();
    await t.save();
    await _addHistory(
      type: 'task_complete', title: 'কাজ সম্পন্ন: ${t.title}',
      referenceId: id, iconCode: 0xe876,
    );
  }

  static Future<void> deleteTask(String id) => _tasks.delete(id);

  // tasks completed in a given month (for PDF report)
  static List<Task> getCompletedTasksForMonth(int year, int month) {
    return _tasks.values.where((t) =>
        t.isCompleted &&
        t.completedAt != null &&
        t.completedAt!.year == year &&
        t.completedAt!.month == month).toList();
  }

  // ── Study Sessions ─────────────────────────────────────────────────
  static List<StudySession> getSessions({DateTime? date, String? catId}) {
    var list = _sessions.values.toList();
    if (date != null) {
      final d = K.dateKey(date);
      list = list.where((s) => K.dateKey(s.date) == d).toList();
    }
    if (catId != null) {
      list = list.where((s) => s.categoryId == catId).toList();
    }
    return list..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static List<StudySession> getSessionsForMonth(int year, int month) =>
      _sessions.values
          .where((s) => s.date.year == year && s.date.month == month)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  static Future<StudySession> addSession({
    String? categoryId, String? subCategoryId,
    required String subject,
    DateTime? startTime, DateTime? endTime,
    required int durationMinutes,
    String notes = '', int rating = 3,
  }) async {
    final now = DateTime.now();
    final s = StudySession(
      id: _uuid.v4(), categoryId: categoryId, subCategoryId: subCategoryId,
      subject: subject,
      startTime: startTime ?? now.subtract(Duration(minutes: durationMinutes)),
      endTime: endTime ?? now,
      durationMinutes: durationMinutes, notes: notes, rating: rating,
      date: now,
    );
    await _sessions.put(s.id, s);
    final p = getProfile();
    p.totalStudyMinutes += durationMinutes;
    final today = K.dateKey(now);
    if (p.lastStudyDate == null || K.dateKey(p.lastStudyDate!) != today) {
      p.currentStreak++;
      if (p.currentStreak > p.longestStreak) p.longestStreak = p.currentStreak;
      p.lastStudyDate = now;
    }
    await p.save();
    if (subCategoryId != null) {
      final sub = _subs.get(subCategoryId);
      if (sub != null) { sub.totalMinutes += durationMinutes; await sub.save(); }
    }
    await _addHistory(
      type: 'study', title: 'পড়াশোনা: $subject',
      description: K.fmtDuration(durationMinutes),
      referenceId: s.id, minutes: durationMinutes, iconCode: 0xe80c,
    );
    return s;
  }

  static Future<void> deleteSession(String id) => _sessions.delete(id);

  // Chart data
  static Map<String, int> getMonthlyMinutes(int year, int month) {
    final result = <String, int>{};
    for (final s in _sessions.values
        .where((s) => s.date.year == year && s.date.month == month)) {
      final key = K.dateKey(s.date);
      result[key] = (result[key] ?? 0) + s.durationMinutes;
    }
    return result;
  }

  // aliases for screen compatibility
  static List<MainCategory> getCats() => getCategories();
  static List<SubCategory> getSubCats(String parentId) => getSubCategories(parentId);
  static Map<String, int> getCatMinutes() => getCategoryMinutes();
  static Future<SubCategory> addSubCat(String parentId, String name, int colorIndex) =>
      addSubCategory(parentId, name, colorIndex, 0xe080);
  static Future<void> deleteSubCat(String id) => deleteSubCategory(id);
  static Future<MainCategory> addCat(String name, int colorIndex, int iconCode) =>
      addCategory(name, colorIndex, iconCode);
  static Future<void> deleteCat(String id) => deleteCategory(id);

  static Map<String, int> getCategoryMinutes() {
    final result = <String, int>{};
    for (final s in _sessions.values) {
      if (s.categoryId != null) {
        result[s.categoryId!] = (result[s.categoryId!] ?? 0) + s.durationMinutes;
      }
    }
    return result;
  }

  // ── Habits ─────────────────────────────────────────────────────────
  static List<Habit> getHabits({bool activeOnly = true}) {
    final list = activeOnly
        ? _habits.values.where((h) => h.isActive).toList()
        : _habits.values.toList();
    return list..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  static Future<Habit> addHabit({
    required String name, String description = '',
    int colorIndex = 0, int targetMinutes = 30,
    String? categoryId, int iconCode = 0xe80c,
  }) async {
    final h = Habit(
      id: _uuid.v4(), name: name, description: description,
      colorIndex: colorIndex, targetMinutes: targetMinutes,
      createdAt: DateTime.now(), categoryId: categoryId, iconCode: iconCode,
    );
    await _habits.put(h.id, h);
    return h;
  }

  static Future<void> toggleHabit(String id, DateTime date) async {
    final h = _habits.get(id);
    if (h == null) return;
    final key = K.dateKey(date);
    h.completionLog[key] = !(h.completionLog[key] ?? false);
    _recalcStreak(h);
    await h.save();
    if (h.completionLog[key] == true) {
      await _addHistory(
        type: 'habit', title: 'অভ্যাস সম্পন্ন: ${h.name}',
        referenceId: id, iconCode: h.iconCode,
      );
    }
  }

  static void _recalcStreak(Habit h) {
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = today.subtract(Duration(days: i));
      if (h.completionLog[K.dateKey(d)] == true) {
        streak++;
      } else {
        break;
      }
    }
    h.currentStreak = streak;
    if (streak > h.longestStreak) h.longestStreak = streak;
  }

  static Future<void> deleteHabit(String id) => _habits.delete(id);

  // ── History ────────────────────────────────────────────────────────
  static List<HistoryEntry> getHistory({int limit = 200}) {
    final list = _history.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list.take(limit).toList();
  }

  static Future<void> _addHistory({
    required String type, required String title,
    String description = '', String? referenceId,
    int? minutes, int iconCode = 0xe88f,
  }) async {
    final e = HistoryEntry(
      id: _uuid.v4(), type: type, title: title, description: description,
      timestamp: DateTime.now(), referenceId: referenceId,
      minutes: minutes, iconCode: iconCode,
    );
    await _history.put(e.id, e);
  }

  // ── Study Plans ────────────────────────────────────────────────────
  static List<StudyPlan> getPlans({bool activeOnly = false}) {
    final list = activeOnly
        ? _plans.values.where((p) => p.isActive).toList()
        : _plans.values.toList();
    return list..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  static Future<StudyPlan> addPlan({
    required String title, String description = '',
    required DateTime startDate, required DateTime endDate,
    int targetDailyMinutes = 60, String? categoryId, int colorIndex = 0,
  }) async {
    final p = StudyPlan(
      id: _uuid.v4(), title: title, description: description,
      startDate: startDate, endDate: endDate,
      targetDailyMinutes: targetDailyMinutes,
      categoryId: categoryId, colorIndex: colorIndex,
    );
    await _plans.put(p.id, p);
    return p;
  }

  static Future<void> deletePlan(String id) => _plans.delete(id);
}
