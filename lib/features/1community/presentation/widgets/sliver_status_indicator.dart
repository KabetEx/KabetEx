import 'package:flutter/material.dart';

class SliverStatusIndicator extends StatelessWidget {
  const SliverStatusIndicator.error({
    super.key,
    required this.message,
    this.onRetry,
  }) : icon = Icons.cloud_off_rounded,
       isError = true;

  const SliverStatusIndicator.empty({super.key, required this.message})
    : icon = Icons.forum_outlined,
      onRetry = null,
      isError = false;

  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[500]),
            const SizedBox(height: 16),
            Text(message, style: theme.textTheme.titleMedium),
            if (isError && onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
