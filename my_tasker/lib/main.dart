// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'models/models.dart';
import 'providers/providers.dart';
import 'utils/app_theme.dart';
import 'utils/db.dart';
import 'utils/notifications.dart';
import 'screens/dashboard_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/task_screen.dart';
import 'screens/study_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: C.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);

  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(MainCategoryAdapter());
  Hive.registerAdapter(SubCategoryAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(StudySessionAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HistoryEntryAdapter());
  Hive.registerAdapter(StudyPlanAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  await Hive.openBox<UserProfile>(K.boxProfile);
  await Hive.openBox<MainCategory>(K.boxCats);
  await Hive.openBox<SubCategory>(K.boxSubs);
  await Hive.openBox<Task>(K.boxTasks);
  await Hive.openBox<StudySession>(K.boxSessions);
  await Hive.openBox<Habit>(K.boxHabits);
  await Hive.openBox<HistoryEntry>(K.boxHistory);
  await Hive.openBox<StudyPlan>(K.boxPlans);
  await Hive.openBox<AppSettings>(K.boxSettings);

  await NS.init();
  tz.initializeTimeZones();

  runApp(const ProviderScope(child: MyTaskerApp()));
}

class MyTaskerApp extends StatelessWidget {
  const MyTaskerApp({super.key});
  @override
  Widget build(BuildContext context) {
    final setupDone = DB.getSettings().setupDone;
    return MaterialApp(
      title: K.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: setupDone ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home':       (_) => const MainShell(),
      },
    );
  }
}

// ─── Main Navigation Shell ────────────────────────────────────────────────────
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    DashboardScreen(),
    HabitsScreen(),
    TaskScreen(),
    StudyScreen(),
    CategoriesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(tabProvider);
    return Scaffold(
      body: IndexedStack(index: idx, children: _screens),
      bottomNavigationBar: _BottomNav(currentIdx: idx, ref: ref),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIdx;
  final WidgetRef ref;
  const _BottomNav({required this.currentIdx, required this.ref});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: C.surface,
      border: Border(top: BorderSide(color: C.border, width: 1)),
      boxShadow: [BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, -2))],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(Icons.today_outlined,      Icons.today,       'আজ',       0, currentIdx, ref),
            _NavItem(Icons.repeat_outlined,     Icons.repeat,      'অভ্যাস',   1, currentIdx, ref),
            _NavItem(Icons.task_alt_outlined,   Icons.task_alt,    'কাজ',      2, currentIdx, ref),
            _NavItem(Icons.menu_book_outlined,  Icons.menu_book,   'পড়াশোনা', 3, currentIdx, ref),
            _NavItem(Icons.category_outlined,   Icons.category,    'বিষয়',    4, currentIdx, ref),
            _NavItem(Icons.person_outline,      Icons.person,      'প্রোফাইল', 5, currentIdx, ref),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData iconOut, iconFilled;
  final String label;
  final int index, current;
  final WidgetRef ref;
  const _NavItem(this.iconOut, this.iconFilled, this.label,
      this.index, this.current, this.ref);

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => ref.read(tabProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? C.primaryDim : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isActive ? iconFilled : iconOut,
                color: isActive ? C.primary : C.textHint, size: 22),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(
            color: isActive ? C.primary : C.textHint,
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          )),
        ]),
      ),
    );
  }
}
