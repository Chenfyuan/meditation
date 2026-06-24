class UserStats {
  final int streakDays;
  final int totalMinutes;
  final int totalSessions;
  final int weeklyCompleted;
  final List<int> weeklyMinutes;

  const UserStats({
    this.streakDays = 12,
    this.totalMinutes = 320,
    this.totalSessions = 28,
    this.weeklyCompleted = 5,
    this.weeklyMinutes = const [14, 20, 10, 25, 18, 30, 8],
  });
}
