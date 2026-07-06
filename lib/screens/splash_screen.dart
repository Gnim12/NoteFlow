import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/loading_dots.dart';
import '../widgets/splash_background.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: .75,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: -.05,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _logoController.forward();

    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        _textController.forward();
      },
    );

    Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashBackground(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              /// Halo lumineux
              Stack(
                alignment: Alignment.center,
                children: [

                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (_, __) {
                      return Container(
                        width:
                            180 +
                                (_logoController.value *
                                    30),
                        height:
                            180 +
                                (_logoController.value *
                                    30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                              .withOpacity(.08),
                        ),
                      );
                    },
                  ),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedBuilder(
                        animation:
                            _rotationAnimation,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle:
                                _rotationAnimation
                                    .value *
                                pi,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 125,
                          height: 125,
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(.14),
                            shape:
                                BoxShape.circle,
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(
                                      .20),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              24,
                            ),
                            child: Image.asset(
                              "assets/icons/logo.png",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SlideTransition(
                position: _slideAnimation,
                child: const Text(
                  "NoteFlow",
                  style: TextStyle(
                    fontSize: 34,
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SlideTransition(
                position: _slideAnimation,
                child: Text(
                  "Capturez vos idées,\norganisez votre quotidien",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white
                        .withOpacity(.92),
                  ),
                ),
              ),

              const SizedBox(height: 45),

              const LoadingDots(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 18),
          child: Text(
            "Version 1.0.0",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white.withOpacity(.75),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}