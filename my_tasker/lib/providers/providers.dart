// lib/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import '../utils/db.dart';

// ── Connectivity ──────────────────────────────────────────────────────────────
final connectivityProvider = StreamProvider<bool>((ref) =>
    Connectivity().onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none)));

// ── Profile ───────────────────────────────────────────────────────────────────
final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) =>
        ProfileNotifier());

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(DB.getProfile());
  void refresh() => state = DB.getProfile();
  Future<void> save(UserProfile p) async {
    await DB.saveProfile(p);
    state = p;
  }
}

// ── Settings ──────────────────────────────────────────────────────────────────
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) =>
        SettingsNotifier());

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(DB.getSettings());
  Future<void> save(AppSettings s) async {
    await DB.saveSettings(s);
    state = s;
  }
  void refresh() => state = DB.getSettings();
}

// ── Tasks ─────────────────────────────────────────────────────────────────────
final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<Task>>((ref) =>
        TasksNotifier());

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super(DB.getTasks());
  void refresh() => state = DB.getTasks();
  void refreshAll() => state = DB.getTasks(includeCompleted: true);
}

// ── Habits ────────────────────────────────────────────────────────────────────
final habitsProvider =
    StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) =>
        HabitsNotifier());

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier() : super(DB.getHabits());
  void refresh() => state = DB.getHabits();
}

// ── Categories ────────────────────────────────────────────────────────────────
final catsProvider =
    StateNotifierProvider<CatsNotifier, List<MainCategory>>((ref) =>
        CatsNotifier());

class CatsNotifier extends StateNotifier<List<MainCategory>> {
  CatsNotifier() : super(DB.getCategories());
  void refresh() => state = DB.getCategories();
}

// ── Sessions ──────────────────────────────────────────────────────────────────
final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<StudySession>>((ref) =>
        SessionsNotifier());

class SessionsNotifier extends StateNotifier<List<StudySession>> {
  SessionsNotifier() : super(DB.getSessions());
  void refresh() => state = DB.getSessions();
}

// ── History ───────────────────────────────────────────────────────────────────
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) =>
        HistoryNotifier());

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  HistoryNotifier() : super(DB.getHistory());
  void refresh() => state = DB.getHistory();
}

// ── Plans ─────────────────────────────────────────────────────────────────────
final plansProvider =
    StateNotifierProvider<PlansNotifier, List<StudyPlan>>((ref) =>
        PlansNotifier());

class PlansNotifier extends StateNotifier<List<StudyPlan>> {
  PlansNotifier() : super(DB.getPlans());
  void refresh() => state = DB.getPlans();
}

// ── UI State ──────────────────────────────────────────────────────────────────
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final tabIndexProvider = StateProvider<int>((ref) => 0);
// alias
final tabProvider = tabIndexProvider;

// ── Refresh all ───────────────────────────────────────────────────────────────
void refreshAll(WidgetRef ref) {
  ref.read(tasksProvider.notifier).refresh();
  ref.read(habitsProvider.notifier).refresh();
  ref.read(catsProvider.notifier).refresh();
  ref.read(sessionsProvider.notifier).refresh();
  ref.read(historyProvider.notifier).refresh();
  ref.read(plansProvider.notifier).refresh();
  ref.read(profileProvider.notifier).refresh();
}
