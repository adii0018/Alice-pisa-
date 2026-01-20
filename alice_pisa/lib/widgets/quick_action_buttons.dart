import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class QuickActionButtons extends StatelessWidget {
  final VoidCallback onPlanSeason;
  final VoidCallback onViewHistory;
  final VoidCallback onCheckWeather;
  final VoidCallback onEmergencyHelp;

  const QuickActionButtons({
    super.key,
    required this.onPlanSeason,
    required this.onViewHistory,
    required this.onCheckWeather,
    required this.onEmergencyHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'त्वरित कार्य',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // First row of buttons
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.edit_note,
                    label: 'योजना\nबनाएं',
                    color: AppTheme.primaryGreen,
                    onTap: onPlanSeason,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.history,
                    label: 'इतिहास\nदेखें',
                    color: AppTheme.skyBlue,
                    onTap: onViewHistory,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Second row of buttons
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.wb_cloudy,
                    label: 'मौसम\nजांचें',
                    color: AppTheme.sunYellow,
                    onTap: onCheckWeather,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.emergency,
                    label: 'आपातकाल\nसहायता',
                    color: AppTheme.dangerRed,
                    onTap: onEmergencyHelp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}