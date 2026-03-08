import 'package:flutter/material.dart';
import '../models/nutrition_model.dart';

class NutritionController extends ChangeNotifier {
  DailyNutrition _today = DailyNutrition(
    targetCalories: 2000,
    // Datos de ejemplo para ver la UI
    calories: 1240,
    proteins: 68,
    carbs: 142,
    fats: 38,
    meals: [
      MealEntry(
        id: '1',
        foodName: 'Avena con frutas',
        calories: 320,
        proteins: 12,
        carbs: 58,
        fats: 6,
        mealType: MealType.breakfast,
        time: DateTime.now().subtract(const Duration(hours: 4)),
        healthScore: 88,
      ),
      MealEntry(
        id: '2',
        foodName: 'Arroz con pollo',
        calories: 520,
        proteins: 38,
        carbs: 62,
        fats: 14,
        mealType: MealType.lunch,
        time: DateTime.now().subtract(const Duration(hours: 1)),
        healthScore: 72,
      ),
      MealEntry(
        id: '3',
        foodName: 'Manzana roja',
        calories: 52,
        proteins: 0.3,
        carbs: 14,
        fats: 0.2,
        mealType: MealType.snack,
        time: DateTime.now().subtract(const Duration(minutes: 30)),
        healthScore: 95,
      ),
    ],
  );

  DailyNutrition get today => _today;

  void addMeal(MealEntry meal) {
    final updated = DailyNutrition(
      targetCalories: _today.targetCalories,
      calories: _today.calories + meal.calories,
      proteins: _today.proteins + meal.proteins,
      carbs: _today.carbs + meal.carbs,
      fats: _today.fats + meal.fats,
      meals: [..._today.meals, meal],
    );
    _today = updated;
    notifyListeners();
  }

  void removeMeal(String id) {
    final meal = _today.meals.firstWhere((m) => m.id == id);
    final updated = DailyNutrition(
      targetCalories: _today.targetCalories,
      calories: _today.calories - meal.calories,
      proteins: _today.proteins - meal.proteins,
      carbs: _today.carbs - meal.carbs,
      fats: _today.fats - meal.fats,
      meals: _today.meals.where((m) => m.id != id).toList(),
    );
    _today = updated;
    notifyListeners();
  }
}