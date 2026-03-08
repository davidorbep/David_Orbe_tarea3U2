import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../controllers/nutrition_controller.dart';
import '../../models/nutrition_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionController>();
    final meals = nutrition.today.meals;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => _showStats(context, nutrition),
          ),
        ],
      ),
      body: meals.isEmpty
          ? _EmptyHistory()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meals.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _DaySummaryCard(nutrition: nutrition);
                final meal = meals[index - 1];
                return _HistoryTile(meal: meal)
                    .animate(delay: (index * 60).ms)
                    .fadeIn()
                    .slideX(begin: 0.1);
              },
            ),
    );
  }

  void _showStats(BuildContext context, NutritionController nutrition) {
    final meals = nutrition.today.meals;
    final avgScore = meals.isEmpty
        ? 0
        : meals.fold(0, (s, m) => s + m.healthScore) ~/ meals.length;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Estadísticas de hoy',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        label: 'Comidas',
                        value: '${meals.length}',
                        icon: Icons.restaurant,
                        color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        label: 'Puntaje prom.',
                        value: '$avgScore',
                        icon: Icons.health_and_safety,
                        color: Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        label: 'Calorías',
                        value:
                            '${nutrition.today.calories.round()} kcal',
                        icon: Icons.local_fire_department,
                        color: Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        label: 'Proteínas',
                        value: '${nutrition.today.proteins.round()}g',
                        icon: Icons.fitness_center,
                        color: Colors.purple)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DaySummaryCard extends StatelessWidget {
  final NutritionController nutrition;
  const _DaySummaryCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final today = nutrition.today;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2ECC71),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Resumen de hoy',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                    label: 'Calorías',
                    value: '${today.calories.round()}'),
                _SummaryItem(
                    label: 'Proteínas',
                    value: '${today.proteins.round()}g'),
                _SummaryItem(
                    label: 'Carbos',
                    value: '${today.carbs.round()}g'),
                _SummaryItem(
                    label: 'Grasas',
                    value: '${today.fats.round()}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MealEntry meal;
  const _HistoryTile({required this.meal});

  Color get _scoreColor {
    if (meal.healthScore >= 75) return Colors.green;
    if (meal.healthScore >= 55) return Colors.lightGreen;
    if (meal.healthScore >= 35) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _scoreColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text(meal.mealType.emoji,
                  style: const TextStyle(fontSize: 22))),
        ),
        title: Text(meal.foodName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${meal.mealType.label} • ${meal.time.hour.toString().padLeft(2, '0')}:${meal.time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${meal.calories.round()} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _scoreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${meal.healthScore} pts',
                  style: TextStyle(
                      color: _scoreColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        onTap: () =>
            Navigator.pushNamed(context, '/nutrition-detail'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label, required this.value,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Sin registros aún',
              style: TextStyle(
                  fontSize: 18, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('Escanea alimentos para verlos aquí',
              style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}