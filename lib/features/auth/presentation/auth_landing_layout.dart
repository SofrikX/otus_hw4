import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/glass_card.dart';

class AuthLandingLayout extends StatelessWidget {
  const AuthLandingLayout({
    required this.form,
    required this.formTitle,
    required this.formSubtitle,
    super.key,
  });

  final Widget form;
  final String formTitle;
  final String formSubtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 920;
              final content = isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: _AuthHero(compact: constraints.maxWidth < 960),
                        ),
                        const SizedBox(width: 32),
                        Flexible(
                          flex: 0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: _FormPanel(this),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _FormPanel(this),
                        const SizedBox(height: 24),
                        const _AuthHero(compact: true),
                      ],
                    );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.all(isWide ? 32 : 0),
                    child: content,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel(this.layout);

  final AuthLandingLayout layout;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.gradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.pets, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PetConnect',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            layout.formTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            layout.formSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          layout.form,
        ],
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(compact ? 22 : 34),
      borderRadius: AppRadius.xl,
      opacity: 0.48,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -28,
            child: Text(
              '🐾',
              style: TextStyle(fontSize: compact ? 96 : 150),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _FeatureChip(icon: Icons.verified_user, label: 'Безопасно'),
                  _FeatureChip(icon: Icons.auto_awesome, label: 'Современно'),
                  _FeatureChip(icon: Icons.diversity_1, label: 'Для всех'),
                ],
              ),
              SizedBox(height: compact ? 28 : 48),
              Text(
                'Сообщество\nдля вас и ваших питомцев',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                    ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  'Делитесь моментами, создавайте профили питомцев и находите прогулки рядом.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                height: compact ? 132 : 220,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.heroGradient,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Center(
                  child: Text(
                    compact ? '🐶  🐱' : '🐶   🐱   🐕',
                    style: TextStyle(fontSize: compact ? 52 : 86),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.secondary),
      label: Text(label),
      side: const BorderSide(color: AppColors.glassBorder),
      backgroundColor: AppColors.surfaceHigh.withValues(alpha: 0.68),
    );
  }
}
