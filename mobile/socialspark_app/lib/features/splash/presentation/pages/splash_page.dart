import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:socialspark_app/core/services/session_store.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = const AssetImage('assets/images/splash.png'); // put any art here
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: bg, fit: BoxFit.cover)),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 320,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Explore now\nto experience the benefits',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: const Color(0xFF20C4B2),
                        ),
                        onPressed: () {
  context.read<SessionStore>().logout(); // resets to unauth
  context.go('/login');
},

                        child: const Text('Get Started'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
