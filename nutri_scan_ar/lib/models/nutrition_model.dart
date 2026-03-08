class DailyNutrition {
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double targetCalories;
  final List<MealEntry> meals;

  DailyNutrition({
    this.calories = 0,
    this.proteins = 0,
    this.carbs = 0,
    this.fats = 0,
    this.targetCalories = 2000,
    this.meals = const [],
  });

  double get caloriesPercent =>
      (calories / targetCalories).clamp(0.0, 1.0);
  double get remaining =>
      (targetCalories - calories).clamp(0.0, double.infinity);
}

class MealEntry {
  final String id;
  final String foodName;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final MealType mealType;
  final DateTime time;
  final int healthScore;

  MealEntry({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.mealType,
    required this.time,
    required this.healthScore,
  });
}

enum MealType {
  breakfast('Desayuno', '🌅'),
  lunch('Almuerzo', '🍽️'),
  dinner('Cena', '🌙'),
  snack('Merienda', '🍎');

  final String label;
  final String emoji;
  const MealType(this.label, this.emoji);
}