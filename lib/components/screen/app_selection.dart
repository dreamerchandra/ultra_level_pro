import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSelectionScreen extends StatelessWidget {
  const AppSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xF2F5FAFF),
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFeatureCard(
                'ULTRALEVEL PRO',
                onTap: () {
                  GoRouter.of(context).push('/device');
                },
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'ULTRALEVEL MAX',
                onTap: () {
                  GoRouter.of(context).push('/device');
                },
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'SMART STARTER',
                onTap: () {
                  GoRouter.of(context).push('/device');
                },
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'ULTRALEVEL DISPLAY',
                onTap: () {
                  GoRouter.of(context).push('/device');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, {Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Image.asset(
                'asserts/image/${title.replaceAll(' ', '_')}.png',
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
