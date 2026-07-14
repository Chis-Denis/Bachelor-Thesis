import '../preferences/health_goal.dart';

const Map<HealthGoal, String> goalGuidance = {
  HealthGoal.loseWeight: 'Prefer lower-calorie, high-volume, high-fibre items.',
  HealthGoal.gainMuscle:
      'Prefer high-protein items (at least 30 g) with a calorie surplus.',
  HealthGoal.maintainWeight:
      'Prefer items that fit the remaining macro budget evenly.',
  HealthGoal.improveHealth: 'Prefer whole-food, high-fibre, low-sugar items.',
  HealthGoal.exploreNew:
      'Prefer items and cuisines absent from the recent history.',
};
