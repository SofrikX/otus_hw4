import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/walk.dart';

class WalkCard extends StatefulWidget {
  const WalkCard({
    required this.walk,
    required this.onJoin,
    required this.onLeave,
    super.key,
  });

  final Walk walk;
  final Future<void> Function() onJoin;
  final Future<void> Function() onLeave;

  @override
  State<WalkCard> createState() => _WalkCardState();
}

class _WalkCardState extends State<WalkCard> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final walk = widget.walk;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.directions_walk),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        walk.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        formatWalkDate(walk.startsAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(walk.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.place_outlined, size: 18),
                  label: Text(walk.place),
                ),
                Chip(
                  avatar: const Icon(Icons.group_outlined, size: 18),
                  label: Text('${walk.participantCount} участников'),
                ),
                Chip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text('Организатор: ${walk.organizerName}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: Key('join-${walk.id}'),
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(walk.isJoined ? Icons.logout : Icons.add),
                label: Text(_buttonLabel(walk)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      if (widget.walk.isJoined) {
        await widget.onLeave();
      } else {
        await widget.onJoin();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _buttonLabel(Walk walk) {
    if (_isSubmitting) {
      return walk.isJoined ? 'Выход...' : 'Присоединение...';
    }

    return walk.isJoined ? 'Выйти' : 'Присоединиться';
  }
}
