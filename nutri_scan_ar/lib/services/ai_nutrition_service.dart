// Versión simplificada - sin TFLite ni dependencias externas por ahora
import '../models/food_item.dart';

class AINutritionService {
  static final AINutritionService _instance = AINutritionService._internal();
  factory AINutritionService() => _instance;
  AINutritionService._internal();

  Future<void> loadModel() async {
    // Se implementa cuando agreguemos TFLite
  }

  void dispose() {}

  Future<FoodItem?> analyzeImage(dynamic imageFile) async {
    // Retorna datos de prueba por ahora
    return _buildMockFood();
  }

  Future<FoodPrediction?> quickAnalyze(dynamic imageBytes) async {
    return FoodPrediction(label: 'Manzana', confidence: 0.92);
  }

  FoodItem _buildMockFood() {
    return FoodItem(
      id: 'mock_001',
      name: 'Manzana roja',
      nutritionInfo: NutritionInfo(
        calories: 52,
        proteins: 0.3,
        carbs: 14,
        fats: 0.2,
        fiber: 2.4,
        sugar: 10,
        sodium: 1,
        portionSize: '100g',
      ),
      processingLevel: ProcessingLevel.unprocessed,
      healthScore: HealthScore(
        score: 90,
        rating: 'excellent',
        positives: ['Bajo en calorías', 'Buena fuente de fibra', 'Sin sodio'],
        negatives: [],
        recommendation:
            'Excelente elección. Puedes consumirla diariamente sin problema.',
      ),
      alternatives: [],
      confidence: 0.92,
      scannedAt: DateTime.now(),
    );
  }

  static HealthScore calculateHealthScore(
      NutritionInfo nutrition, ProcessingLevel processing) {
    double score = 100;
    final positives = <String>[];
    final negatives = <String>[];

    switch (processing) {
      case ProcessingLevel.ultraProcessed:
        score -= 30;
        negatives.add('Producto ultra procesado');
        break;
      case ProcessingLevel.processedIngredients:
        score -= 15;
        negatives.add('Contiene ingredientes procesados');
        break;
      case ProcessingLevel.minimallyProcessed:
        score -= 5;
        positives.add('Mínimamente procesado');
        break;
      case ProcessingLevel.unprocessed:
        positives.add('Alimento natural sin procesar');
        break;
      default:
        break;
    }

    if (nutrition.sodium > 600) {
      score -= 20;
      negatives.add('Alto en sodio');
    } else if (nutrition.sodium < 140) {
      positives.add('Bajo en sodio');
    }

    if (nutrition.sugar > 12) {
      score -= 15;
      negatives.add('Alto en azúcar');
    } else if (nutrition.sugar < 5) {
      positives.add('Bajo en azúcar');
    }

    if (nutrition.fiber >= 5) {
      score += 5;
      positives.add('Buena fuente de fibra');
    }

    score = score.clamp(0, 100);

    String rating;
    String recommendation;
    if (score >= 75) {
      rating = 'excellent';
      recommendation = 'Excelente elección nutricional.';
    } else if (score >= 55) {
      rating = 'good';
      recommendation = 'Buena opción en moderación.';
    } else if (score >= 35) {
      rating = 'moderate';
      recommendation = 'Consúmelo con moderación.';
    } else {
      rating = 'poor';
      recommendation = 'Limita su consumo.';
    }

    return HealthScore(
      score: score,
      rating: rating,
      positives: positives,
      negatives: negatives,
      recommendation: recommendation,
    );
  }
}

class FoodPrediction {
  final String label;
  final double confidence;
  FoodPrediction({required this.label, required this.confidence});
}