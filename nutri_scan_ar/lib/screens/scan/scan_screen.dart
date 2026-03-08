import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/nutrition_controller.dart';
import '../../models/nutrition_model.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isAnalyzing = false;
  bool _flashOn = false;
  late AnimationController _scanAnim;
  late Animation<double> _scanLine;

  @override
  void initState() {
    super.initState();
    _initScanAnimation();
    _initCamera();
  }

  void _initScanAnimation() {
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scanAnim, curve: Curves.easeInOut));
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (!_isCameraReady || _isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isAnalyzing = false);
      _showResult();
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _isAnalyzing = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _showResult();
      }
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;
    _flashOn = !_flashOn;
    await _cameraController!
        .setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  void _showResult() {
    final meal = MealEntry(
      id: DateTime.now().toString(),
      foodName: 'Manzana roja',
      calories: 52,
      proteins: 0.3,
      carbs: 14,
      fats: 0.2,
      mealType: MealType.snack,
      time: DateTime.now(),
      healthScore: 95,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(
        meal: meal,
        onSave: () {
          context.read<NutritionController>().addMeal(meal);
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Guardado en tu diario'),
              backgroundColor: Color(0xFF2ECC71),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Cámara ────────────────────────────────
          if (_isCameraReady)
            CameraPreview(_cameraController!)
          else
            const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF2ECC71)),
            ),

          // ── Marco AR ──────────────────────────────
          if (_isCameraReady) _buildARFrame(),

          // ── Top bar ───────────────────────────────
          _buildTopBar(),

          // ── Controles ─────────────────────────────
          _buildControls(),

          // ── Analizando overlay ────────────────────
          if (_isAnalyzing) _buildAnalyzingOverlay(),
        ],
      ),
    );
  }

  Widget _buildARFrame() {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth * 0.72;
      final top = (constraints.maxHeight - size) / 2 - 30;
      final left = (constraints.maxWidth - size) / 2;

      return Stack(children: [
        // Oscurecer fondo
        Positioned.fill(
          child: CustomPaint(
            painter: _DimPainter(
              rect: Rect.fromLTWH(left, top, size, size),
            ),
          ),
        ),
        // Marco animado
        Positioned(
          left: left,
          top: top,
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _scanLine,
            builder: (_, __) => CustomPaint(
              painter: _FramePainter(progress: _scanLine.value),
            ),
          ),
        ),
        // Texto guía
        Positioned(
          top: top + size + 16,
          left: 0,
          right: 0,
          child: const Text(
            'Centra el alimento dentro del marco',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ]);
    });
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleBtn(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.view_in_ar, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Modo AR',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _CircleBtn(
            icon: _flashOn ? Icons.flash_on : Icons.flash_off,
            onTap: _toggleFlash,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CircleBtn(
            icon: Icons.photo_library_rounded,
            onTap: _pickFromGallery,
            size: 52,
          ),
          GestureDetector(
            onTap: _capture,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 34),
            ),
          ),
          _CircleBtn(
            icon: Icons.info_outline,
            onTap: () {},
            size: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: Color(0xFF2ECC71)),
            const SizedBox(height: 20),
            const Text('Analizando con IA...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Identificando alimento',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ── Botón circular ────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleBtn(
      {required this.icon, required this.onTap, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    );
  }
}

// ── Painter: Sombra alrededor del marco ───────────────────────

class _DimPainter extends CustomPainter {
  final Rect rect;
  _DimPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.rect != rect;
}

// ── Painter: Marco con línea de escaneo ───────────────────────

class _FramePainter extends CustomPainter {
  final double progress;
  _FramePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF2ECC71);
    const corner = 28.0;
    const r = 20.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Esquinas
    void drawCorner(double x, double y, double sx, double sy) {
      canvas.drawLine(
          Offset(x, y + sy * corner), Offset(x, y + sy * r), paint);
      canvas.drawArc(
        Rect.fromLTWH(
            x - (sx < 0 ? r * 2 : 0), y - (sy < 0 ? r * 2 : 0), r * 2, r * 2),
        sx < 0
            ? (sy < 0 ? 0 : 3.14159 / 2)
            : (sy < 0 ? 3.14159 * 1.5 : 3.14159),
        3.14159 / 2,
        false,
        paint,
      );
      canvas.drawLine(
          Offset(x + sx * r, y), Offset(x + sx * corner, y), paint);
    }

    drawCorner(0, 0, 1, 1);
    drawCorner(size.width, 0, -1, 1);
    drawCorner(0, size.height, 1, -1);
    drawCorner(size.width, size.height, -1, -1);

    // Línea de escaneo
    final y = size.height * progress;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y, size.width, 2))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.progress != progress;
}

// ── Resultado del escaneo ─────────────────────────────────────

class _ResultSheet extends StatelessWidget {
  final MealEntry meal;
  final VoidCallback onSave;

  const _ResultSheet({required this.meal, required this.onSave});

  Color get _scoreColor {
    if (meal.healthScore >= 75) return Colors.green;
    if (meal.healthScore >= 55) return Colors.lightGreen;
    if (meal.healthScore >= 35) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.foodName,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.eco, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text('Alimento natural · Sin procesar',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12)),
                    ]),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _scoreColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: _scoreColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${meal.healthScore}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _scoreColor)),
                    Text('/100',
                        style: TextStyle(
                            fontSize: 9, color: _scoreColor)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Macros rápidos
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientBadge(
                    label: 'Calorías',
                    value: '${meal.calories.round()}',
                    unit: 'kcal',
                    color: Colors.orange),
                _NutrientBadge(
                    label: 'Proteínas',
                    value: '${meal.proteins.toStringAsFixed(1)}',
                    unit: 'g',
                    color: Colors.blue),
                _NutrientBadge(
                    label: 'Carbos',
                    value: '${meal.carbs.round()}',
                    unit: 'g',
                    color: Colors.amber),
                _NutrientBadge(
                    label: 'Grasas',
                    value: '${meal.fats.toStringAsFixed(1)}',
                    unit: 'g',
                    color: Colors.purple),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(
                      context, '/nutrition-detail'),
                  child: const Text('Ver detalle'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
        begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

class _NutrientBadge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutrientBadge({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            TextSpan(
                text: unit,
                style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7))),
          ]),
        ),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}