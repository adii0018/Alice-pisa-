import 'package:flutter/material.dart';
import '../models/farmer.dart';
import '../utils/app_theme.dart';

class StressIndicator extends StatefulWidget {
  final StressLevel stressLevel;
  final double size;
  final bool showLabel;
  final VoidCallback? onTap;

  const StressIndicator({
    super.key,
    required this.stressLevel,
    this.size = 32,
    this.showLabel = false,
    this.onTap,
  });

  @override
  State<StressIndicator> createState() => _StressIndicatorState();
}

class _StressIndicatorState extends State<StressIndicator>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Animate for high stress levels
    if (widget.stressLevel.index >= 2) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.stressLevel != widget.stressLevel) {
      if (widget.stressLevel.index >= 2) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.stressLevel.index >= 2 ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: AppTheme.getStressColor(widget.stressLevel.index),
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getStressColor(widget.stressLevel.index).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getStressIcon(widget.stressLevel),
                    color: Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              );
            },
          ),
          
          if (widget.showLabel) ...[
            const SizedBox(height: 4),
            Text(
              _getStressText(widget.stressLevel),
              style: TextStyle(
                fontSize: widget.size * 0.3,
                fontWeight: FontWeight.w600,
                color: AppTheme.getStressColor(widget.stressLevel.index),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStressIcon(StressLevel stressLevel) {
    switch (stressLevel) {
      case StressLevel.calm:
        return Icons.sentiment_very_satisfied;
      case StressLevel.worried:
        return Icons.sentiment_neutral;
      case StressLevel.stressed:
        return Icons.sentiment_dissatisfied;
      case StressLevel.desperate:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  String _getStressText(StressLevel stressLevel) {
    switch (stressLevel) {
      case StressLevel.calm:
        return 'शांत';
      case StressLevel.worried:
        return 'चिंतित';
      case StressLevel.stressed:
        return 'तनावग्रस्त';
      case StressLevel.desperate:
        return 'परेशान';
    }
  }
}

// Stress level explanation widget
class StressLevelExplanation extends StatelessWidget {
  final StressLevel stressLevel;

  const StressLevelExplanation({
    super.key,
    required this.stressLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getStressColor(stressLevel.index).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getStressColor(stressLevel.index).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StressIndicator(
                stressLevel: stressLevel,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _getStressTitle(stressLevel),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getStressColor(stressLevel.index),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStressDescription(stressLevel),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _getStressAdvice(stressLevel),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getStressTitle(StressLevel stressLevel) {
    switch (stressLevel) {
      case StressLevel.calm:
        return 'आप शांत हैं';
      case StressLevel.worried:
        return 'आप चिंतित हैं';
      case StressLevel.stressed:
        return 'आप तनाव में हैं';
      case StressLevel.desperate:
        return 'आप बहुत परेशान हैं';
    }
  }

  String _getStressDescription(StressLevel stressLevel) {
    switch (stressLevel) {
      case StressLevel.calm:
        return 'आपकी आर्थिक स्थिति अच्छी है। आप सही फैसले ले रहे हैं।';
      case StressLevel.worried:
        return 'कुछ आर्थिक चिंताएं हैं। सावधानी से फैसले लें।';
      case StressLevel.stressed:
        return 'आर्थिक दबाव बढ़ रहा है। तुरंत कार्रवाई की जरूरत है।';
      case StressLevel.desperate:
        return 'गंभीर आर्थिक संकट है। आपातकालीन कदम उठाने होंगे।';
    }
  }

  String _getStressAdvice(StressLevel stressLevel) {
    switch (stressLevel) {
      case StressLevel.calm:
        return 'बचत करते रहें और भविष्य की योजना बनाएं।';
      case StressLevel.worried:
        return 'खर्च कम करें और आपातकालीन फंड बनाएं।';
      case StressLevel.stressed:
        return 'कर्ज कम करने पर ध्यान दें और अनावश्यक खर्च बंद करें।';
      case StressLevel.desperate:
        return 'तुरंत सहायता लें और आपातकालीन योजना बनाएं।';
    }
  }
}