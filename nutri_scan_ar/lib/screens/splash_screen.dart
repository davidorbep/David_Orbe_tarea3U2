import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final auth = context.read<AuthController>();
      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                  )
                ],
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  color: Colors.white, size: 56),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            const Text('NutriScan AR',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold))
                .animate(delay: 300.ms)
                .fadeIn()
                .slideY(begin: 0.3),

            const SizedBox(height: 8),

            const Text('Tu nutricionista con IA',
                style: TextStyle(
                    color: Color(0xFF2ECC71), fontSize: 15))
                .animate(delay: 500.ms)
                .fadeIn(),

            const SizedBox(height: 48),

            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF2ECC71).withOpacity(0.7)),
              ),
            ).animate(delay: 700.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}