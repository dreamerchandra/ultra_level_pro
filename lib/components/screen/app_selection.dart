import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/device_selection.dart';

class AppSelectionScreen extends ConsumerWidget {
  const AppSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
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
                  ref
                      .read(deviceSelectionProvider.notifier)
                      .selectDevice(UltraLevelDevice.ultraLevelPro);
                  GoRouter.of(context).push('/device');
                },
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'ULTRALEVEL MAX',
                onTap: () {
                  ref
                      .read(deviceSelectionProvider.notifier)
                      .selectDevice(UltraLevelDevice.ultraLevelMax);
                  GoRouter.of(context).push('/device');
                },
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'SMART STARTER',
                onTap: () {
                  ref
                      .read(deviceSelectionProvider.notifier)
                      .selectDevice(UltraLevelDevice.smartStarter);
                  GoRouter.of(context).push('/device');
                },
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'ULTRALEVEL DISPLAY',
                onTap: () {
                  ref
                      .read(deviceSelectionProvider.notifier)
                      .selectDevice(UltraLevelDevice.ultraLevelDisplay);
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
                  fontSize: 18,
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
