// lib/models/models.dart
import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String? email;
  @HiveField(2) String? phone;
  @HiveField(3) String? photoPath;
  @HiveField(4) DateTime createdAt;
  @HiveField(5) int totalStudyMinutes;
  @HiveField(6) int currentStreak;
  @HiveField(7) int longestStreak;
  @HiveField(8) DateTime? lastStudyDate;
  @HiveField(9) int dailyGoalMinutes;

  UserProfile({
    required this.name,
    this.email,
    this.phone,
    this.photoPath,
    required this.createdAt,
    this.totalStudyMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.dailyGoalMinutes = 120,
  });
}

@HiveType(typeId: 1)
class MainCategory extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) int colorIndex;
  @HiveField(3) DateTime createdAt;
  @HiveField(4) bool isArchived;
  @HiveField(5) int iconCode;

  MainCategory({
    required this.id,
    required this.name,
    this.colorIndex = 0,
    required this.createdAt,
    this.isArchived = false,
    this.iconCode = 0xe080,
  });
}

@HiveType(typeId: 2)
class SubCategory extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String parentId;
  @HiveField(2) String name;
  @HiveField(3) int colorIndex;
  @HiveField(4) int totalMinutes;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) int iconCode;

  SubCategory({
    required this.id,
    required this.parentId,
    required this.name,
    this.colorIndex = 0,
    this.totalMinutes = 0,
    required this.createdAt,
    this.iconCode = 0xe3c9,
  });
}

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)  String id;
  @HiveField(1)  String title;
  @HiveField(2)  String description;
  @HiveField(3)  String? categoryId;
  @HiveField(4)  String? subCategoryId;
  @HiveField(5)  DateTime dueDate;
  @HiveField(6)  DateTime? reminderTime;
  @HiveField(7)  bool isCompleted;
  @HiveField(8)  DateTime createdAt;
  @HiveField(9)  DateTime? completedAt;
  @HiveField(10) int priority;
  @HiveField(11) bool hasReminder;
  @HiveField(12) int? estimatedMinutes;
  @HiveField(13) int notificationId;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.categoryId,
    this.subCategoryId,
    required this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.priority = 1,
    this.hasReminder = false,
    this.estimatedMinutes,
    this.notificationId = 0,
  });
}

@HiveType(typeId: 4)
class StudySession extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String? categoryId;
  @HiveField(2) String? subCategoryId;
  @HiveField(3) String subject;
  @HiveField(4) DateTime startTime;
  @HiveField(5) DateTime endTime;
  @HiveField(6) int durationMinutes;
  @HiveField(7) String notes;
  @HiveField(8) int rating;
  @HiveField(9) DateTime date;

  StudySession({
    required this.id,
    this.categoryId,
    this.subCategoryId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.notes = '',
    this.rating = 3,
    required this.date,
  });
}

@HiveType(typeId: 5)
class Habit extends HiveObject {
  @HiveField(0)  String id;
  @HiveField(1)  String name;
  @HiveField(2)  String description;
  @HiveField(3)  int colorIndex;
  @HiveField(4)  int targetMinutes;
  @HiveField(5)  String frequency;
  @HiveField(6)  Map<String, bool> completionLog;
  @HiveField(7)  Map<String, int> minutesLog;
  @HiveField(8)  DateTime createdAt;
  @HiveField(9)  bool isActive;
  @HiveField(10) int currentStreak;
  @HiveField(11) int longestStreak;
  @HiveField(12) String? categoryId;
  @HiveField(13) int iconCode;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.colorIndex = 0,
    this.targetMinutes = 30,
    this.frequency = 'daily',
    Map<String, bool>? completionLog,
    Map<String, int>? minutesLog,
    required this.createdAt,
    this.isActive = true,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.categoryId,
    this.iconCode = 0xe80c,
  })  : completionLog = completionLog ?? {},
        minutesLog = minutesLog ?? {};
}

@HiveType(typeId: 6)
class HistoryEntry extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String type;
  @HiveField(2) String title;
  @HiveField(3) String description;
  @HiveField(4) DateTime timestamp;
  @HiveField(5) String? referenceId;
  @HiveField(6) int? minutes;
  @HiveField(7) int iconCode;

  HistoryEntry({
    required this.id,
    required this.type,
    required this.title,
    this.description = '',
    required this.timestamp,
    this.referenceId,
    this.minutes,
    this.iconCode = 0xe88f,
  });
}

@HiveType(typeId: 7)
class StudyPlan extends HiveObject {
  @HiveField(0)  String id;
  @HiveField(1)  String title;
  @HiveField(2)  String description;
  @HiveField(3)  DateTime startDate;
  @HiveField(4)  DateTime endDate;
  @HiveField(5)  List<String> taskIds;
  @HiveField(6)  int targetDailyMinutes;
  @HiveField(7)  bool isActive;
  @HiveField(8)  String? categoryId;
  @HiveField(9)  int completedTaskCount;
  @HiveField(10) int colorIndex;

  StudyPlan({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDate,
    required this.endDate,
    List<String>? taskIds,
    this.targetDailyMinutes = 60,
    this.isActive = true,
    this.categoryId,
    this.completedTaskCount = 0,
    this.colorIndex = 0,
  }) : taskIds = taskIds ?? [];
}

@HiveType(typeId: 8)
class AppSettings extends HiveObject {
  @HiveField(0) int dailyStudyGoalMinutes;
  @HiveField(1) bool notificationsEnabled;
  @HiveField(2) String? geminiApiKey;
  @HiveField(3) bool aiEnabled;
  @HiveField(4) bool setupDone;

  AppSettings({
    this.dailyStudyGoalMinutes = 120,
    this.notificationsEnabled = true,
    this.geminiApiKey,
    this.aiEnabled = false,
    this.setupDone = false,
  });
}
