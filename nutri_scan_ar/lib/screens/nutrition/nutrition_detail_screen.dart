import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../models/nutrition_model.dart';

class NutritionDetailScreen extends StatelessWidget {
  const NutritionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo — luego vendrán del escaneo real
    final meal = MealEntry(
      id: 'demo',
      foodName: 'Manzana roja',
      calories: 52,
      proteins: 0.3,
      carbs: 14,
      fats: 0.2,
      mealType: MealType.snack,
      time: DateTime.now(),
      healthScore: 95,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF2ECC71),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(meal.foodName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '${meal.calories.round()}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text('kcal por 100g',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Puntaje de salud ──────────────────
                _HealthScoreCard(score: meal.healthScore)
                    .animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 14),

                // ── Macronutrientes ───────────────────
                _MacrosCard(meal: meal)
                    .animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 14),

                // ── Otros nutrientes ──────────────────
                _OtherNutrientsCard()
                    .animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 14),

                // ── Alternativas ──────────────────────
                _AlternativesCard()
                    .animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF2ECC71),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar al diario',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  final int score;
  const _HealthScoreCard({required this.score});

  Color get _color {
    if (score >= 75) return Colors.green;
    if (score >= 55) return Colors.lightGreen;
    if (score >= 35) return Colors.orange;
    return Colors.red;
  }

  String get _rating {
    if (score >= 75) return 'Excelente';
    if (score >= 55) return 'Bueno';
    if (score >= 35) return 'Moderado';
    return 'Pobre';
  }

  String get _recommendation {
    if (score >= 75) return 'Excelente elección. Puedes incluirlo regularmente en tu dieta.';
    if (score >= 55) return 'Buena opción dentro de una dieta balanceada.';
    if (score >= 35) return 'Consúmelo con moderación.';
    return 'Limita su consumo y busca alternativas más nutritivas.';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Impacto en la salud',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _color.withOpacity(0.4)),
                  ),
                  child: Text(_rating,
                      style: TextStyle(
                          color: _color, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 12,
              percent: score / 100,
              progressColor: _color,
              backgroundColor: Colors.grey.shade200,
              barRadius: const Radius.circular(6),
              animation: true,
              animationDuration: 800,
              trailing: Text('$score/100',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: _color)),
            ),
            const SizedBox(height: 14),
            Text(_recommendation,
                style: TextStyle(
                    color: Colors.grey[700], height: 1.4)),
            const SizedBox(height: 12),
            _BulletPoint(text: 'Bajo en calorías', isPositive: true),
            _BulletPoint(text: 'Buena fuente de fibra', isPositive: true),
            _BulletPoint(text: 'Sin sodio añadido', isPositive: true),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final bool isPositive;
  const _BulletPoint({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.cancel,
            color: isPositive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _MacrosCard extends StatelessWidget {
  final MealEntry meal;
  const _MacrosCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Macronutrientes',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Por porción: 100g',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            _MacroBar(label: 'Proteínas', value: meal.proteins,
                max: 50, color: Colors.blue.shade400, unit: 'g'),
            const SizedBox(height: 12),
            _MacroBar(label: 'Carbohidratos', value: meal.carbs,
                max: 300, color: Colors.orange.shade400, unit: 'g'),
            const SizedBox(height: 12),
            _MacroBar(label: 'Grasas', value: meal.fats,
                max: 65, color: Colors.purple.shade400, unit: 'g'),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;
  final String unit;

  const _MacroBar({
    required this.label, required this.value,
    required this.max, required this.color, required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${value.toStringAsFixed(1)}$unit',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 8,
          percent: (value / max).clamp(0.0, 1.0),
          progressColor: color,
          backgroundColor: color.withOpacity(0.15),
          barRadius: const Radius.circular(4),
          animation: true,
          animationDuration: 600,
        ),
      ],
    );
  }
}

class _OtherNutrientsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nutrients = [
      {'label': 'Azúcares', 'value': '10.4g', 'warn': false},
      {'label': 'Fibra', 'value': '2.4g', 'warn': false},
      {'label': 'Sodio', 'value': '1mg', 'warn': false},
      {'label': 'Colesterol', 'value': '0mg', 'warn': false},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Otros nutrientes',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...nutrients.map((n) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(
                          n['warn'] as bool
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          color: n['warn'] as bool
                              ? Colors.orange
                              : Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(n['label'] as String),
                      ]),
                      Text(n['value'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _AlternativesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alternatives = [
      'Pera', 'Durazno', 'Fresas', 'Arándanos'
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tips_and_updates_rounded,
                    color: Color(0xFF2ECC71)),
                SizedBox(width: 8),
                Text('Alternativas saludables',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: alternatives
                  .map((a) => Chip(
                        label: Text(a,
                            style: const TextStyle(fontSize: 13)),
                        backgroundColor:
                            const Color(0xFF2ECC71).withOpacity(0.1),
                        side: const BorderSide(
                            color: Color(0xFF2ECC71), width: 0.5),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}