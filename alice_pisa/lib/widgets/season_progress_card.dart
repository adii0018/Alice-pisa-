import 'package:flutter/material.dart';
import '../models/season.dart';
import '../core/game_state_manager.dart';
import '../utils/app_theme.dart';

class SeasonProgressCard extends StatelessWidget {
  final Season season;
  final double progress;
  final GamePhase currentPhase;

  const SeasonProgressCard({
    super.key,
    required this.season,
    required this.progress,
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Season header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getSeasonColor(season.type.name),
                      ),
                    ),
                    Text(
                      season.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.getSeasonColor(season.type.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSeasonIcon(season.type),
                    color: AppTheme.getSeasonColor(season.type.name),
                    size: 24,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Current phase
            Row(
              children: [
                Icon(
                  _getPhaseIcon(currentPhase),
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'वर्तमान चरण: ${_getPhaseText(currentPhase)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'मौसम की प्रगति',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.textLight.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.getSeasonColor(season.type.name),
                  ),
                  minHeight: 8,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Phase timeline
            _buildPhaseTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseTimeline() {
    final phases = GamePhase.values.where((phase) => phase != GamePhase.setup).toList();
    
    return Row(
      children: phases.asMap().entries.map((entry) {
        final index = entry.key;
        final phase = entry.value;
        final isActive = phase == currentPhase;
        final isCompleted = phase.index < currentPhase.index;
        
        return Expanded(
          child: Row(
            children: [
              // Phase indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppTheme.primaryGreen
                      : isCompleted 
                          ? AppTheme.lightGreen
                          : AppTheme.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isCompleted 
                      ? Icons.check
                      : _getPhaseIcon(phase),
                  color: isActive || isCompleted 
                      ? Colors.white 
                      : AppTheme.textMedium,
                  size: 16,
                ),
              ),
              
              // Connector line (except for last item)
              if (index < phases.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: isCompleted 
                        ? AppTheme.lightGreen
                        : AppTheme.textLight.withOpacity(0.3),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getSeasonIcon(SeasonType seasonType) {
    switch (seasonType) {
      case SeasonType.kharif:
        return Icons.cloud_queue; // Monsoon
      case SeasonType.rabi:
        return Icons.ac_unit; // Winter
      case SeasonType.zaid:
        return Icons.wb_sunny; // Summer
    }
  }

  IconData _getPhaseIcon(GamePhase phase) {
    switch (phase) {
      case GamePhase.setup:
        return Icons.settings;
      case GamePhase.planning:
        return Icons.edit_note;
      case GamePhase.growing:
        return Icons.grass;
      case GamePhase.harvest:
        return Icons.agriculture;
      case GamePhase.reflection:
        return Icons.analytics;
    }
  }

  String _getPhaseText(GamePhase phase) {
    switch (phase) {
      case GamePhase.setup:
        return 'तैयारी';
      case GamePhase.planning:
        return 'योजना';
      case GamePhase.growing:
        return 'बुआई/देखभाल';
      case GamePhase.harvest:
        return 'कटाई';
      case GamePhase.reflection:
        return 'समीक्षा';
    }
  }
}