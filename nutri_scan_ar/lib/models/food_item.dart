// lib/models/food_item.dart

class FoodItem {
  final String id;
  final String name;
  final String? imageUrl;
  final NutritionInfo nutritionInfo;
  final ProcessingLevel processingLevel;
  final HealthScore healthScore;
  final List<String> alternatives;
  final String? barcode;
  final double? confidence; // Confianza del modelo de IA (0-1)
  final DateTime scannedAt;

  FoodItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.nutritionInfo,
    required this.processingLevel,
    required this.healthScore,
    this.alternatives = const [],
    this.barcode,
    this.confidence,
    required this.scannedAt,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Alimento desconocido',
      imageUrl: json['image_url'],
      nutritionInfo: NutritionInfo.fromJson(json['nutrition'] ?? {}),
      processingLevel: ProcessingLevel.fromString(json['processing_level'] ?? 'unknown'),
      healthScore: HealthScore.fromJson(json['health_score'] ?? {}),
      alternatives: List<String>.from(json['alternatives'] ?? []),
      barcode: json['barcode'],
      confidence: json['confidence']?.toDouble(),
      scannedAt: json['scanned_at'] != null
          ? DateTime.parse(json['scanned_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'nutrition': nutritionInfo.toJson(),
      'processing_level': processingLevel.value,
      'health_score': healthScore.toJson(),
      'alternatives': alternatives,
      'barcode': barcode,
      'confidence': confidence,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    NutritionInfo? nutritionInfo,
    ProcessingLevel? processingLevel,
    HealthScore? healthScore,
    List<String>? alternatives,
    String? barcode,
    double? confidence,
    DateTime? scannedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      processingLevel: processingLevel ?? this.processingLevel,
      healthScore: healthScore ?? this.healthScore,
      alternatives: alternatives ?? this.alternatives,
      barcode: barcode ?? this.barcode,
      confidence: confidence ?? this.confidence,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NutritionInfo
// ─────────────────────────────────────────────────────────────
class NutritionInfo {
  final double calories;
  final double proteins;    // gramos
  final double carbs;       // gramos
  final double fats;        // gramos
  final double fiber;       // gramos
  final double sugar;       // gramos
  final double sodium;      // miligramos
  final double? saturatedFats;
  final double? transFats;
  final double? cholesterol;
  final double? vitaminsScore; // 0-100
  final double? mineralsScore; // 0-100
  final String portionSize;   // ej: "100g", "1 taza"

  NutritionInfo({
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.saturatedFats,
    this.transFats,
    this.cholesterol,
    this.vitaminsScore,
    this.mineralsScore,
    this.portionSize = '100g',
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] ?? 0).toDouble(),
      proteins: (json['proteins'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
      saturatedFats: json['saturated_fats']?.toDouble(),
      transFats: json['trans_fats']?.toDouble(),
      cholesterol: json['cholesterol']?.toDouble(),
      vitaminsScore: json['vitamins_score']?.toDouble(),
      mineralsScore: json['minerals_score']?.toDouble(),
      portionSize: json['portion_size'] ?? '100g',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'saturated_fats': saturatedFats,
      'trans_fats': transFats,
      'cholesterol': cholesterol,
      'vitamins_score': vitaminsScore,
      'minerals_score': mineralsScore,
      'portion_size': portionSize,
    };
  }

  /// Calcula el porcentaje de cada macronutriente respecto a las calorías totales
  double get proteinCalories => proteins * 4;
  double get carbCalories => carbs * 4;
  double get fatCalories => fats * 9;

  double get proteinPercent => calories > 0 ? (proteinCalories / calories) * 100 : 0;
  double get carbPercent => calories > 0 ? (carbCalories / calories) * 100 : 0;
  double get fatPercent => calories > 0 ? (fatCalories / calories) * 100 : 0;
}

// ─────────────────────────────────────────────────────────────
// ProcessingLevel (basado en clasificación NOVA)
// ─────────────────────────────────────────────────────────────
enum ProcessingLevel {
  unprocessed('unprocessed', 'Sin procesar', 1),
  minimallyProcessed('minimally_processed', 'Mínimamente procesado', 2),
  processedIngredients('processed_ingredients', 'Ingredientes procesados', 3),
  ultraProcessed('ultra_processed', 'Ultra procesado', 4),
  unknown('unknown', 'Desconocido', 0);

  final String value;
  final String label;
  final int novaGroup;

  const ProcessingLevel(this.value, this.label, this.novaGroup);

  static ProcessingLevel fromString(String value) {
    return ProcessingLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProcessingLevel.unknown,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HealthScore
// ─────────────────────────────────────────────────────────────
class HealthScore {
  final double score;           // 0-100
  final String rating;          // 'excellent', 'good', 'moderate', 'poor'
  final List<String> positives;
  final List<String> negatives;
  final String recommendation;

  HealthScore({
    required this.score,
    required this.rating,
    this.positives = const [],
    this.negatives = const [],
    this.recommendation = '',
  });

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    return HealthScore(
      score: (json['score'] ?? 50).toDouble(),
      rating: json['rating'] ?? 'moderate',
      positives: List<String>.from(json['positives'] ?? []),
      negatives: List<String>.from(json['negatives'] ?? []),
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'rating': rating,
      'positives': positives,
      'negatives': negatives,
      'recommendation': recommendation,
    };
  }

  String get emoji {
    switch (rating) {
      case 'excellent': return '🟢';
      case 'good': return '🟡';
      case 'moderate': return '🟠';
      case 'poor': return '🔴';
      default: return '⚪';
    }
  }
}
