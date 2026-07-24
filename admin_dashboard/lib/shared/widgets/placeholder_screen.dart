import 'package:flutter/material.dart';

/// Every nav-reachable section gets a real route and a real destination
/// in `AdminShell` from day one, per this build's "shell first, then
/// deepen" scope — most of the 9 sections just render this until a
/// later pass gives them real Firestore-backed screens, rather than a
/// dead nav entry with nowhere to go.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_outlined, size: 40, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              description ?? 'Not built yet — coming in a later pass.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
