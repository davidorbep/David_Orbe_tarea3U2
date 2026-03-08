import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nutrition_controller.dart';
import '../models/nutrition_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final nutrition = context.watch<NutritionController>();
    final today = nutrition.today;
    final name = auth.user?.name ?? 'Usuario';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            backgroundColor: const Color(0xFF2ECC71),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, $name 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const Text('¿Qué vas a comer hoy?',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/profile'),
                      child: CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Tarjeta de calorías ───────────────
                _CaloriesCard(today: today)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 14),

                // ── Macros ────────────────────────────
                _MacrosRow(today: today)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 20),

                // ── Botón escanear ────────────────────
                _ScanButton()
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 20),

                // ── Comidas de hoy ────────────────────
                if (today.meals.isNotEmpty) ...[
                  const Text('Comidas de hoy',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 10),
                  ...today.meals
                      .asMap()
                      .entries
                      .map((e) => _MealTile(meal: e.value)
                          .animate(delay: (300 + e.key * 80).ms)
                          .fadeIn()
                          .slideX(begin: 0.1)),
                ] else
                  _EmptyMeals(),

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

// ── Tarjeta calorías ──────────────────────────────────────────

class _CaloriesCard extends StatelessWidget {
  final DailyNutrition today;
  const _CaloriesCard({required this.today});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Calorías del día',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${today.targetCalories.round()} kcal meta',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CalStat(
                  label: 'Consumidas',
                  value: today.calories.round().toString(),
                  color: const Color(0xFF2ECC71),
                ),
                CircularPercentIndicator(
                  radius: 52,
                  lineWidth: 9,
                  percent: today.caloriesPercent,
                  animation: true,
                  animationDuration: 800,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(today.caloriesPercent * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text('del total',
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                  progressColor: const Color(0xFF2ECC71),
                  backgroundColor: Colors.grey.shade200,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                _CalStat(
                  label: 'Restantes',
                  value: today.remaining.round().toString(),
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CalStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color)),
        Text('kcal',
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// ── Macros ────────────────────────────────────────────────────

class _MacrosRow extends StatelessWidget {
  final DailyNutrition today;
  const _MacrosRow({required this.today});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _MacroCard(
                label: 'Proteínas',
                value: today.proteins,
                color: Colors.blue.shade400,
                icon: '💪')),
        const SizedBox(width: 8),
        Expanded(
            child: _MacroCard(
                label: 'Carbos',
                value: today.carbs,
                color: Colors.orange.shade400,
                icon: '🌾')),
        const SizedBox(width: 8),
        Expanded(
            child: _MacroCard(
                label: 'Grasas',
                value: today.fats,
                color: Colors.purple.shade400,
                icon: '🥑')),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String icon;

  const _MacroCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text('${value.round()}g',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// ── Botón escanear ────────────────────────────────────────────

class _ScanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/scan'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Escanear alimento',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 3),
                  Text(
                      'Apunta la cámara y obtén info nutricional al instante',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white60, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Tile de comida ────────────────────────────────────────────

class _MealTile extends StatelessWidget {
  final MealEntry meal;
  const _MealTile({required this.meal});

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _scoreColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(meal.mealType.emoji,
                style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(meal.foodName,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(
          '${meal.mealType.label} • ${meal.time.hour.toString().padLeft(2, '0')}:${meal.time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${meal.calories.round()} kcal',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 3),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _scoreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${meal.healthScore} pts',
                style: TextStyle(
                    color: _scoreColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, '/nutrition-detail'),
      ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────

class _EmptyMeals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.no_food_rounded, size: 56, color: Colors.grey[350]),
          const SizedBox(height: 12),
          Text('Aún no has registrado nada hoy',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('¡Escanea un alimento para empezar!',
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: const Color(0xFF2ECC71),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded), label: 'Historial'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: 'Perfil'),
      ],
      onTap: (index) {
        if (index == 1) Navigator.pushNamed(context, '/history');
        if (index == 2) Navigator.pushNamed(context, '/profile');
      },
    );
  }
}