import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_state_manager.dart';
import '../models/farmer.dart';
import '../models/season.dart';
import '../services/tts_service.dart';
import '../utils/app_theme.dart';
import '../widgets/financial_status_card.dart';
import '../widgets/season_progress_card.dart';
import '../widgets/stress_indicator.dart';
import '../widgets/quick_action_buttons.dart';
import 'season_planning_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakWelcome();
    });
  }

  Future<void> _speakWelcome() async {
    final gameManager = context.read<GameStateManager>();
    final farmer = gameManager.currentFarmer;
    final season = gameManager.currentSeason;
    
    if (farmer != null && season != null) {
      final ttsService = context.read<TTSService>();
      
      String welcome = '${farmer.name} जी, नमस्ते! ';
      welcome += '${season.displayName} मौसम में आपका स्वागत है। ';
      
      // Add financial status
      if (farmer.currentMoney > 10000) {
        welcome += 'आपकी आर्थिक स्थिति अच्छी है।';
      } else if (farmer.debt > farmer.currentMoney) {
        welcome += 'आपको पैसों का ध्यान रखना होगा।';
      } else {
        welcome += 'सावधानी से फैसले लें।';
      }
      
      await ttsService.speak(welcome, emotion: TTSEmotion.happy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Consumer<GameStateManager>(
        builder: (context, gameManager, child) {
          final farmer = gameManager.currentFarmer;
          final season = gameManager.currentSeason;
          
          if (farmer == null || season == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // App Bar with farmer info
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.getSeasonColor(season.type.name),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    farmer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.getSeasonColor(season.type.name),
                          AppTheme.getSeasonColor(season.type.name).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  farmer.village,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              season.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              season.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  // Stress indicator in app bar
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: StressIndicator(
                      stressLevel: farmer.stressLevel,
                      size: 24,
                    ),
                  ),
                ],
              ),

              // Dashboard content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Financial status
                    FinancialStatusCard(farmer: farmer),
                    
                    const SizedBox(height: 16),
                    
                    // Season progress
                    SeasonProgressCard(
                      season: season,
                      progress: gameManager.seasonProgress,
                      currentPhase: gameManager.currentPhase,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick actions
                    QuickActionButtons(
                      onPlanSeason: () => _navigateToPlanning(context),
                      onViewHistory: () => _showSeasonHistory(context),
                      onCheckWeather: () => _showWeatherInfo(context),
                      onEmergencyHelp: () => _showEmergencyOptions(context),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Current crops (if any)
                    if (farmer.crops.isNotEmpty) ...[
                      _buildCurrentCropsCard(farmer.crops),
                      const SizedBox(height: 16),
                    ],
                    
                    // Active events (if any)
                    if (gameManager.activeEvents.isNotEmpty) ...[
                      _buildActiveEventsCard(gameManager.activeEvents),
                      const SizedBox(height: 16),
                    ],
                    
                    // Tips and guidance
                    _buildTipsCard(farmer, season),
                    
                    const SizedBox(height: 100), // Bottom padding
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      
      // Floating action button for main action
      floatingActionButton: Consumer<GameStateManager>(
        builder: (context, gameManager, child) {
          return FloatingActionButton.extended(
            onPressed: () => _handleMainAction(context, gameManager),
            backgroundColor: AppTheme.primaryGreen,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: Text(
              _getMainActionText(gameManager.currentPhase),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentCropsCard(List<Crop> crops) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grass, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'मौजूदा फसलें',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...crops.map((crop) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(crop.name),
                  Text(
                    '₹${crop.expectedProfit.toInt()}',
                    style: TextStyle(
                      color: crop.expectedProfit > 0 
                          ? AppTheme.primaryGreen 
                          : AppTheme.dangerRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveEventsCard(List<GameEvent> events) {
    return Card(
      color: AppTheme.warningOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: AppTheme.warningOrange),
                const SizedBox(width: 8),
                Text(
                  'तत्काल ध्यान दें!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...events.map((event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• ${event.title}: ${event.description}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _handleEvents(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningOrange,
              ),
              child: const Text('फैसला लें', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(Farmer farmer, Season season) {
    List<String> tips = _getTipsForFarmer(farmer, season);
    
    return Card(
      color: AppTheme.lightGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'सुझाव',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<String> _getTipsForFarmer(Farmer farmer, Season season) {
    List<String> tips = [];
    
    // Financial tips
    if (farmer.debt > farmer.currentMoney * 0.5) {
      tips.add('कर्ज कम करने की कोशिश करें');
    }
    
    if (farmer.savings < farmer.currentMoney * 0.2) {
      tips.add('आपातकाल के लिए पैसे बचाएं');
    }
    
    if (!farmer.hasInsurance) {
      tips.add('फसल बीमा कराना फायदेमंद हो सकता है');
    }
    
    // Season-specific tips
    switch (season.type) {
      case SeasonType.kharif:
        tips.add('मानसून पर निर्भर न रहें, सिंचाई की व्यवस्था करें');
        break;
      case SeasonType.rabi:
        tips.add('ठंड से फसल को बचाने की तैयारी करें');
        break;
      case SeasonType.zaid:
        tips.add('पानी की कमी हो सकती है, पहले से तैयारी करें');
        break;
    }
    
    return tips.take(3).toList(); // Show max 3 tips
  }

  String _getMainActionText(GamePhase phase) {
    switch (phase) {
      case GamePhase.setup:
        return 'शुरू करें';
      case GamePhase.planning:
        return 'योजना बनाएं';
      case GamePhase.growing:
        return 'फसल देखें';
      case GamePhase.harvest:
        return 'फसल काटें';
      case GamePhase.reflection:
        return 'परिणाम देखें';
    }
  }

  void _handleMainAction(BuildContext context, GameStateManager gameManager) {
    switch (gameManager.currentPhase) {
      case GamePhase.planning:
        _navigateToPlanning(context);
        break;
      case GamePhase.growing:
        _handleEvents(context);
        break;
      case GamePhase.harvest:
        gameManager.nextPhase();
        break;
      case GamePhase.reflection:
        gameManager.nextPhase();
        break;
      default:
        gameManager.nextPhase();
        break;
    }
  }

  void _navigateToPlanning(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SeasonPlanningScreen()),
    );
  }

  void _handleEvents(BuildContext context) {
    // TODO: Navigate to events handling screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('घटनाओं का पन्ना जल्द आएगा')),
    );
  }

  void _showSeasonHistory(BuildContext context) {
    // TODO: Show season history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('इतिहास देखने का विकल्प जल्द आएगा')),
    );
  }

  void _showWeatherInfo(BuildContext context) {
    // TODO: Show weather information
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('मौसम की जानकारी जल्द आएगी')),
    );
  }

  void _showEmergencyOptions(BuildContext context) {
    // TODO: Show emergency help options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('आपातकालीन सहायता जल्द आएगी')),
    );
  }
}