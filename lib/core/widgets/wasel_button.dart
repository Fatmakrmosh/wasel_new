import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaselButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const WaselButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(
              icon,
              color: Colors.black,
            ),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lime,
        foregroundColor: Colors.black,
      ),
    );
  }
}

class WaselSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const WaselSectionTitle({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text(
              'عرض الكل',
              style: TextStyle(
                color: AppColors.lime,
              ),
            ),
          ),
      ],
    );
  }
}