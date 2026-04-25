class OnboardingState {
  final double? weight;
  final double? height;
  final int? age;
  final String? activityLevel;
  final String gender;
  final String? userGoal;
  final int estimatedCalories;

  const OnboardingState({
    this.weight,
    this.height,
    this.age,
    this.activityLevel,
    this.gender = 'Male',
    this.userGoal,
    this.estimatedCalories = 0,
  });

  OnboardingState copyWith({
    double? weight,
    double? height,
    int? age,
    String? activityLevel,
    String? gender,
    String? userGoal,
    int? estimatedCalories,
  }) {
    return OnboardingState(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      gender: gender ?? this.gender,
      userGoal: userGoal ?? this.userGoal,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
    );
  }
}
