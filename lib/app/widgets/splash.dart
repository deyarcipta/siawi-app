import 'dart:async';
import 'package:flutter/material.dart';
import 'package:siawi_app/app/modules/home/widget/version_checker.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controller untuk progres loading
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  int _currentPercentage = 1;

  // Controller untuk animasi logo entrance (kemunculan)
  late AnimationController _logoEntranceController;
  late Animation<double> _logoScaleIn;
  late Animation<double> _logoFadeIn;

  // Controller untuk animasi logo pulse & floating (efek bernafas & melayang)
  late AnimationController _logoPulseController;
  late Animation<double> _logoFloating;
  late Animation<double> _logoGlow;
  late Animation<double> _logoBreathScale;

  @override
  void initState() {
    super.initState();

    // 1. ANIMASI ENTRANCE LOGO (Muncul membesar dengan efek spring/elastic)
    _logoEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScaleIn = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntranceController,
        curve: Curves.easeOut,
      ),
    );

    // 2. ANIMASI BREATHING & FLOATING LOGO (Melayang & berdenyut secara halus)
    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFloating = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(
        parent: _logoPulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _logoGlow = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(
        parent: _logoPulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _logoBreathScale = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(
        parent: _logoPulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 3. ANIMASI SIMULASI LOADING PROGRESS 1 - 100%
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _currentPercentage = _progressAnimation.value.toInt().clamp(1, 100);
          });
        }
      });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted && widget.onFinished != null) {
            widget.onFinished!();
          }
        });
      }
    });

    // Jalankan entrance lalu loop breathing & progress
    _logoEntranceController.forward().then((_) {
      if (mounted) {
        _logoPulseController.repeat(reverse: true);
      }
    });
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _logoEntranceController.dispose();
    _logoPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. LATAR BELAKANG GRADIEN DEEP INDIGO & ROYAL BLUE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B112C), // Deep midnight indigo
                  Color(0xFF131C42), // Royal indigo
                  Color(0xFF0E1533),
                  Color(0xFF070A14), // Near black
                ],
                stops: [0.0, 0.45, 0.8, 1.0],
              ),
            ),
          ),

          // 2. MODERN TECH GRID PATTERN (POLA JARING GEOMETRIS PRESISI)
          Positioned.fill(
            child: CustomPaint(
              painter: _TechGridPatternPainter(),
            ),
          ),

          // 3. SUBTLE AMBIENT RADIAL GLOW BERDENYUT DI BELAKANG EMBLEM LOGO
          Positioned(
            top: MediaQuery.of(context).size.height * 0.17,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_logoEntranceController, _logoPulseController]),
                builder: (context, child) {
                  final glowOpacity = (_logoFadeIn.value * _logoGlow.value).clamp(0.0, 1.0);
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF4F46E5).withValues(alpha: glowOpacity),
                          const Color(0xFF38BDF8).withValues(alpha: glowOpacity * 0.5),
                          Colors.transparent,
                        ],
                        radius: 0.65,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. KONTEN UTAMA SPLASH SCREEN
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // EMBLEM LOGO DENGAN ANIMASI SCALE-IN, FLOATING, & BREATHING GLOW
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoEntranceController, _logoPulseController]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _logoFloating.value),
                        child: Transform.scale(
                          scale: _logoScaleIn.value * _logoBreathScale.value,
                          child: Opacity(
                            opacity: _logoFadeIn.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(34),
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: 0.16 + (_logoGlow.value * 0.14),
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5).withValues(
                                      alpha: _logoGlow.value,
                                    ),
                                    blurRadius: 36,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF38BDF8).withValues(
                                      alpha: _logoGlow.value * 0.45,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/logo/logo-splash.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // BADGE PILL "SMK WISATA INDONESIA"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "SMK WISATA INDONESIA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // JUDUL: SISTEM INFORMASI AKADEMIK (DENGAN AKSEN CYAN-BLUE)
                  const Text(
                    "SISTEM INFORMASI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "AKADE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: "MIK",
                          style: TextStyle(
                            color: Color(0xFF38BDF8), // Cyan-blue accent
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SUB-TEKS
                  const Text(
                    "Portal Terpadu Siswa, Guru & Manajemen",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 4),

                  // INDIKATOR LOADING & PROGRESS DINAMIS (1 - 100%)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF38BDF8),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Memuat data akademik...",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "$_currentPercentage%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 4.5,
                          width: double.infinity,
                          color: Colors.white.withValues(alpha: 0.12),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_currentPercentage / 100.0).clamp(0.01, 1.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF38BDF8),
                                    Color(0xFF6366F1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // INFORMASI VERSI, AKREDITASI & LEGALITAS RESMI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "VERSI ${VersionChecker.appVersion}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        "  •  ",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF10B981),
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'TERAKREDITASI "A"',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "© SMK Wisata Indonesia Jakarta. Hak Cipta Dilindungi.",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter untuk menggambar pola jaring geometris presisi (tech grid pattern)
class _TechGridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 34.0;
    final paintLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Garis vertikal
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintLine);
    }

    // Garis horizontal
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintLine);
    }

    // Titik pertemuan grid (grid intersection dots)
    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paintDot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
