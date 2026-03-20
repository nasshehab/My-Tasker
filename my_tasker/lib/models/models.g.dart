// lib/models/models.g.dart
// ignore_for_file: type=lint
part of 'models.dart';

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override final int typeId = 0;
  @override
  UserProfile read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return UserProfile(
      name: f[0] as String,
      email: f[1] as String?,
      phone: f[2] as String?,
      photoPath: f[3] as String?,
      createdAt: f[4] as DateTime,
      totalStudyMinutes: f[5] == null ? 0 : f[5] as int,
      currentStreak: f[6] == null ? 0 : f[6] as int,
      longestStreak: f[7] == null ? 0 : f[7] as int,
      lastStudyDate: f[8] as DateTime?,
      dailyGoalMinutes: f[9] == null ? 120 : f[9] as int,
    );
  }
  @override
  void write(BinaryWriter w, UserProfile o) {
    w..writeByte(10)
      ..writeByte(0)..write(o.name)
      ..writeByte(1)..write(o.email)
      ..writeByte(2)..write(o.phone)
      ..writeByte(3)..write(o.photoPath)
      ..writeByte(4)..write(o.createdAt)
      ..writeByte(5)..write(o.totalStudyMinutes)
      ..writeByte(6)..write(o.currentStreak)
      ..writeByte(7)..write(o.longestStreak)
      ..writeByte(8)..write(o.lastStudyDate)
      ..writeByte(9)..write(o.dailyGoalMinutes);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is UserProfileAdapter && typeId == o.typeId;
}

class MainCategoryAdapter extends TypeAdapter<MainCategory> {
  @override final int typeId = 1;
  @override
  MainCategory read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return MainCategory(
      id: f[0] as String, name: f[1] as String,
      colorIndex: f[2] == null ? 0 : f[2] as int,
      createdAt: f[3] as DateTime,
      isArchived: f[4] == null ? false : f[4] as bool,
      iconCode: f[5] == null ? 0xe080 : f[5] as int,
    );
  }
  @override
  void write(BinaryWriter w, MainCategory o) {
    w..writeByte(6)
      ..writeByte(0)..write(o.id)..writeByte(1)..write(o.name)
      ..writeByte(2)..write(o.colorIndex)..writeByte(3)..write(o.createdAt)
      ..writeByte(4)..write(o.isArchived)..writeByte(5)..write(o.iconCode);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is MainCategoryAdapter && typeId == o.typeId;
}

class SubCategoryAdapter extends TypeAdapter<SubCategory> {
  @override final int typeId = 2;
  @override
  SubCategory read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return SubCategory(
      id: f[0] as String, parentId: f[1] as String, name: f[2] as String,
      colorIndex: f[3] == null ? 0 : f[3] as int,
      totalMinutes: f[4] == null ? 0 : f[4] as int,
      createdAt: f[5] as DateTime,
      iconCode: f[6] == null ? 0xe3c9 : f[6] as int,
    );
  }
  @override
  void write(BinaryWriter w, SubCategory o) {
    w..writeByte(7)
      ..writeByte(0)..write(o.id)..writeByte(1)..write(o.parentId)
      ..writeByte(2)..write(o.name)..writeByte(3)..write(o.colorIndex)
      ..writeByte(4)..write(o.totalMinutes)..writeByte(5)..write(o.createdAt)
      ..writeByte(6)..write(o.iconCode);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is SubCategoryAdapter && typeId == o.typeId;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override final int typeId = 3;
  @override
  Task read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return Task(
      id: f[0] as String, title: f[1] as String,
      description: f[2] == null ? '' : f[2] as String,
      categoryId: f[3] as String?, subCategoryId: f[4] as String?,
      dueDate: f[5] as DateTime, reminderTime: f[6] as DateTime?,
      isCompleted: f[7] == null ? false : f[7] as bool,
      createdAt: f[8] as DateTime, completedAt: f[9] as DateTime?,
      priority: f[10] == null ? 1 : f[10] as int,
      hasReminder: f[11] == null ? false : f[11] as bool,
      estimatedMinutes: f[12] as int?,
      notificationId: f[13] == null ? 0 : f[13] as int,
    );
  }
  @override
  void write(BinaryWriter w, Task o) {
    w..writeByte(14)
      ..writeByte(0)..write(o.id)..writeByte(1)..write(o.title)
      ..writeByte(2)..write(o.description)..writeByte(3)..write(o.categoryId)
      ..writeByte(4)..write(o.subCategoryId)..writeByte(5)..write(o.dueDate)
      ..writeByte(6)..write(o.reminderTime)..writeByte(7)..write(o.isCompleted)
      ..writeByte(8)..write(o.createdAt)..writeByte(9)..write(o.completedAt)
      ..writeByte(10)..write(o.priority)..writeByte(11)..write(o.hasReminder)
      ..writeByte(12)..write(o.estimatedMinutes)..writeByte(13)..write(o.notificationId);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is TaskAdapter && typeId == o.typeId;
}

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override final int typeId = 4;
  @override
  StudySession read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return StudySession(
      id: f[0] as String, categoryId: f[1] as String?,
      subCategoryId: f[2] as String?, subject: f[3] as String,
      startTime: f[4] as DateTime, endTime: f[5] as DateTime,
      durationMinutes: f[6] as int,
      notes: f[7] == null ? '' : f[7] as String,
      rating: f[8] == null ? 3 : f[8] as int,
      date: f[9] as DateTime,
    );
  }
  @override
  void write(BinaryWriter w, StudySession o) {
    w..writeByte(10)
      ..writeByte(0)..write(o.id)..writeByte(1)..write(o.categoryId)
      ..writeByte(2)..write(o.subCategoryId)..writeByte(3)..write(o.subject)
      ..writeByte(4)..write(o.startTime)..writeByte(5)..write(o.endTime)
      ..writeByte(6)..write(o.durationMinutes)..writeByte(7)..write(o.notes)
      ..writeByte(8)..write(o.rating)..writeByte(9)..write(o.date);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is StudySessionAdapter && typeId == o.typeId;
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override final int typeId = 5;
  @override
  Habit read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return Habit(
      id: f[0] as String, name: f[1] as String,
      description: f[2] == null ? '' : f[2] as String,
      colorIndex: f[3] == null ? 0 : f[3] as int,
      targetMinutes: f[4] == null ? 30 : f[4] as int,
      frequency: f[5] == null ? 'daily' : f[5] as String,
      completionLog: (f[6] as Map?)?.cast<String, bool>(),
      minutesLog: (f[7] as Map?)?.cast<String, int>(),
      createdAt: f[8] as DateTime,
      isActive: f[9] == null ? true : f[9] as bool,
      currentStreak: f[10] == null ? 0 : f[10] as int,
      longestStreak: f[11] == null ? 0 : f[11] as int,
      categoryId: f[12] as String?,
      iconCode: f[13] == null ? 0xe80c : f[13] as int,
    );
  }
  @override
  void write(BinaryWriter w, Habit o) {
    w..writeByte(14)
      ..writeByte(0)..write(o.id)..writeByte(1)..write(o.name)
      ..writeByte(2)..write(o.description)..writeByte(3)..write(o.colorIndex)
      ..writeByte(4)..write(o.targetMinutes)..writeByte(5)..write(o.frequency)
      ..writeByte(6)..write(o.completionLog)..writeByte(7)..write(o.minutesLog)
      ..writeByte(8)..write(o.createdAt)..writeByte(9)..write(o.isActive)
      ..writeByte(10)..write(o.currentStreak)..writeByte(11)..write(o.longestStreak)
      ..writeByte(12)..write(o.categoryId)..writeByte(13)..write(o.iconCode);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is HabitAdapter && typeId == o.typeId;
}

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override final int typeId = 6;
  @override
  HistoryEntry read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return HistoryEntry(
      id: f[0] as String, type: f[1] as String, title: f[2] as String,
      description: f[3] == null ? '' : f[3] as String,
      timestamp: f[4] as DateTime, referenceId: f[5] as String?,
      minutes: f[6] as int?,
      iconCode: f[7] == null ? 0xe88f : f[7] as int,
    );
  }
  @override
  void write(BinaryWriter w, HistoryEntry o) {
    w..writeByte(8)
      ..writeByte(0)..write(o.id)..writeByte(1)..write(o.type)
      ..writeByte(2)..write(o.title)..writeByte(3)..write(o.description)
      ..writeByte(4)..write(o.timestamp)..writeByte(5)..write(o.referenceId)
      ..writeByte(6)..write(o.minutes)..writeByte(7)..write(o.iconCode);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is HistoryEntryAdapter && typeId == o.typeId;
}

class StudyPlanAdapter extends TypeAdapter<StudyPlan> {
  @override final int typeId = 7;
  @override
  StudyPlan read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return StudyPlan(
      id: f[0] as String, title: f[1] as String,
      description: f[2] == null ? '' : f[2] as String,
      startDate: f[3] as DateTime, endDate: f[4] as DateTime,
      taskIds: (f[5] as List?)?.cast<String>(),
      targetDailyMinutes: f[6] == null ? 60 : f[6] as int,
      isActive: f[7] == null ? true : f[7] as bool,
      categoryId: f[8] as String?,
      completedTaskCount: f[9] == null ? 0 : f[9] as int,
      colorIndex: f[10] == null ? 0 : f[10] as int,
    );
  }
  @override
  void write(BinaryWriter w, StudyPlan o) {
    w..writeByte(11)
      ..writeByte(0)..write(o.id)..writeByte(1)..write(o.title)
      ..writeByte(2)..write(o.description)..writeByte(3)..write(o.startDate)
      ..writeByte(4)..write(o.endDate)..writeByte(5)..write(o.taskIds)
      ..writeByte(6)..write(o.targetDailyMinutes)..writeByte(7)..write(o.isActive)
      ..writeByte(8)..write(o.categoryId)..writeByte(9)..write(o.completedTaskCount)
      ..writeByte(10)..write(o.colorIndex);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is StudyPlanAdapter && typeId == o.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override final int typeId = 8;
  @override
  AppSettings read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) r.readByte(): r.read()};
    return AppSettings(
      dailyStudyGoalMinutes: f[0] == null ? 120 : f[0] as int,
      notificationsEnabled: f[1] == null ? true : f[1] as bool,
      geminiApiKey: f[2] as String?,
      aiEnabled: f[3] == null ? false : f[3] as bool,
      setupDone: f[4] == null ? false : f[4] as bool,
    );
  }
  @override
  void write(BinaryWriter w, AppSettings o) {
    w..writeByte(5)
      ..writeByte(0)..write(o.dailyStudyGoalMinutes)
      ..writeByte(1)..write(o.notificationsEnabled)
      ..writeByte(2)..write(o.geminiApiKey)
      ..writeByte(3)..write(o.aiEnabled)
      ..writeByte(4)..write(o.setupDone);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => o is AppSettingsAdapter && typeId == o.typeId;
}
