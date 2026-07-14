enum HealthGoal {
  loseWeight,
  gainMuscle,
  maintainWeight,
  improveHealth,
  exploreNew;

  String get label => switch (this) {
        HealthGoal.loseWeight => 'Lose weight',
        HealthGoal.gainMuscle => 'Gain muscle',
        HealthGoal.maintainWeight => 'Maintain weight',
        HealthGoal.improveHealth => 'Improve health',
        HealthGoal.exploreNew => 'Discover new foods',
      };

  String get description => switch (this) {
        HealthGoal.loseWeight => 'Reduce calorie intake',
        HealthGoal.gainMuscle => 'High protein, calorie surplus',
        HealthGoal.maintainWeight => 'Balance intake and activity',
        HealthGoal.improveHealth => 'Focus on nutrition quality',
        HealthGoal.exploreNew => "Try cuisines and dishes you haven't had",
      };
}
