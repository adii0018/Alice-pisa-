import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_state_manager.dart';
import '../models/farmer.dart';
import '../models/season.dart';
import '../services/tts_service.dart';
import '../utils/app_theme.dart';

class SeasonPlanningScreen extends StatefulWidget {
  const SeasonPlanningScreen({super.key});

  @override
  State<SeasonPlanningScreen> createState() => _SeasonPlanningScreenState();
}

class _SeasonPlanningScreenState extends State<SeasonPlanningScreen> {
  Crop? selectedCrop;
  double selectedArea = 1.0;
  bool showInsuranceOption = false;
  bool wantInsurance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakIntroduction();
    });
  }

  Future<void> _speakIntroduction() async {
    final gameManager = context.read<GameStateManager>();
    final season = gameManager.currentSeason;
    
    if (season != null) {
      final ttsService = context.read<TTSService>();
      String intro = '${season.displayName} मौसम की योजना बनाने का समय है। ';
      intro += 'कौन सी फसल लगाना चाहते हैं?';
      
      await ttsService.speak(intro, emotion: TTSEmotion.excited);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('मौसम की योजना'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<GameStateManager>(
        builder: (context, gameManager, child) {
          final farmer = gameManager.currentFarmer;
          final season = gameManager.currentSeason;
          
          if (farmer == null || season == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season info card
                _buildSeasonInfoCard(season),
                
                const SizedBox(height: 16),
                
                // Available money card
                _buildAvailableMoneyCard(farmer),
                
                const SizedBox(height: 16),
                
                // Crop selection
                _buildCropSelectionCard(season),
                
                const SizedBox(height: 16),
                
                // Area selection (if crop selected)
                if (selectedCrop != null) ...[
                  _buildAreaSelectionCard(farmer),
                  const SizedBox(height: 16),
                ],
                
                // Cost calculation (if crop and area selected)
                if (selectedCrop != null) ...[
                  _buildCostCalculationCard(farmer),
                  const SizedBox(height: 16),
                ],
                
                // Insurance option (if crop selected)
                if (selectedCrop != null) ...[
                  _buildInsuranceCard(),
                  const SizedBox(height: 16),
                ],
                
                // Action buttons
                if (selectedCrop != null) ...[
                  _buildActionButtons(gameManager, farmer),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeasonInfoCard(Season season) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.getSeasonColor(season.type.name),
              AppTheme.getSeasonColor(season.type.name).withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSeasonIcon(season.type),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          season.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          season.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableMoneyCard(Farmer farmer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'उपलब्ध पैसे',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${farmer.currentMoney.toInt()}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            if (farmer.savings > 0) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'बचत',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMedium,
                    ),
                  ),
                  Text(
                    '₹${farmer.savings.toInt()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCropSelectionCard(Season season) {
    final availableCrops = season.availableCrops;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'फसल चुनें',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...availableCrops.map((crop) => _buildCropOption(crop)),
          ],
        ),
      ),
    );
  }

  Widget _buildCropOption(Crop crop) {
    final isSelected = selectedCrop == crop;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedCrop = crop;
              showInsuranceOption = true;
            });
            
            // Speak crop selection
            context.read<TTSService>().speak(
              '${crop.name} चुना गया। निवेश ₹${crop.investmentCost.toInt()} होगा।',
              emotion: TTSEmotion.neutral,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryGreen
                    : AppTheme.textLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Selection indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryGreen
                          : AppTheme.textLight,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // Crop info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? AppTheme.primaryGreen
                              : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'निवेश: ₹${crop.investmentCost.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMedium,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'अनुमानित लाभ: ₹${crop.expectedProfit.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: crop.expectedProfit > 0 
                                  ? AppTheme.primaryGreen
                                  : AppTheme.dangerRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Risk indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(crop.riskFactor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRiskText(crop.riskFactor),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getRiskColor(crop.riskFactor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAreaSelectionCard(Farmer farmer) {
    final maxArea = farmer.landSize;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'कितना क्षेत्र?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              '${selectedArea.toStringAsFixed(1)} एकड़ (कुल ${maxArea.toStringAsFixed(1)} एकड़ में से)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Slider(
              value: selectedArea,
              min: 0.5,
              max: maxArea,
              divisions: ((maxArea - 0.5) * 2).toInt(),
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                setState(() {
                  selectedArea = value;
                });
              },
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0.5 एकड़', style: TextStyle(fontSize: 12)),
                Text('${maxArea.toStringAsFixed(1)} एकड़', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCalculationCard(Farmer farmer) {
    if (selectedCrop == null) return const SizedBox();
    
    final totalCost = selectedCrop!.investmentCost * selectedArea;
    final expectedIncome = selectedCrop!.expectedYield * selectedCrop!.marketPrice * selectedArea;
    final expectedProfit = expectedIncome - totalCost;
    final canAfford = farmer.currentMoney >= totalCost;
    
    return Card(
      color: canAfford 
          ? AppTheme.lightGreen.withOpacity(0.1)
          : AppTheme.dangerRed.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  canAfford ? Icons.check_circle : Icons.warning,
                  color: canAfford ? AppTheme.primaryGreen : AppTheme.dangerRed,
                ),
                const SizedBox(width: 8),
                Text(
                  'लागत गणना',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? AppTheme.primaryGreen : AppTheme.dangerRed,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildCostRow('कुल निवेश', '₹${totalCost.toInt()}', AppTheme.dangerRed),
            _buildCostRow('अनुमानित आय', '₹${expectedIncome.toInt()}', AppTheme.primaryGreen),
            _buildCostRow('अनुमानित लाभ', '₹${expectedProfit.toInt()}', 
                expectedProfit > 0 ? AppTheme.primaryGreen : AppTheme.dangerRed),
            
            const Divider(),
            
            _buildCostRow('उपलब्ध पैसे', '₹${farmer.currentMoney.toInt()}', AppTheme.textDark),
            _buildCostRow('बचेंगे', '₹${(farmer.currentMoney - totalCost).toInt()}', 
                canAfford ? AppTheme.primaryGreen : AppTheme.dangerRed),
            
            if (!canAfford) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.dangerRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppTheme.dangerRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'पैसे कम हैं। कम क्षेत्र चुनें या कर्ज लें।',
                        style: TextStyle(
                          color: AppTheme.dangerRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'फसल बीमा',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            const Text(
              'प्राकृतिक आपदा से फसल की सुरक्षा के लिए बीमा कराएं।',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Checkbox(
                  value: wantInsurance,
                  onChanged: (value) {
                    setState(() {
                      wantInsurance = value ?? false;
                    });
                  },
                  activeColor: AppTheme.primaryGreen,
                ),
                const Expanded(
                  child: Text(
                    'हां, मैं फसल बीमा कराना चाहता हूं (₹500)',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(GameStateManager gameManager, Farmer farmer) {
    final totalCost = selectedCrop!.investmentCost * selectedArea;
    final insuranceCost = wantInsurance ? 500.0 : 0.0;
    final grandTotal = totalCost + insuranceCost;
    final canAfford = farmer.currentMoney >= grandTotal;
    
    return Column(
      children: [
        if (!canAfford) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLoanOptions(context, grandTotal - farmer.currentMoney),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.credit_card, color: Colors.white),
              label: const Text(
                'कर्ज लें',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canAfford ? () => _confirmPlanting(gameManager) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.agriculture, color: Colors.white),
            label: Text(
              canAfford ? 'बुआई करें (₹${grandTotal.toInt()})' : 'पैसे कम हैं',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmPlanting(GameStateManager gameManager) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पुष्टि करें'),
        content: Text('क्या आप ${selectedCrop!.name} की बुआई करना चाहते हैं?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('हां, करें'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && selectedCrop != null) {
      // Plant the crop
      await gameManager.makeDecision('plant_crop', {
        'crop': selectedCrop!,
        'area': selectedArea,
      });
      
      // Buy insurance if selected
      if (wantInsurance) {
        await gameManager.makeDecision('buy_insurance', {
          'type': 'crop',
        });
      }
      
      // Move to next phase
      await gameManager.nextPhase();
      
      // Speak confirmation
      final ttsService = context.read<TTSService>();
      await ttsService.speak(
        '${selectedCrop!.name} की बुआई हो गई। अब फसल की देखभाल करें।',
        emotion: TTSEmotion.happy,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showLoanOptions(BuildContext context, double neededAmount) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'कर्ज के विकल्प',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Text('आपको ₹${neededAmount.toInt()} की जरूरत है।'),
            const SizedBox(height: 16),
            
            // Loan options will be implemented later
            const Text('कर्ज के विकल्प जल्द आएंगे।'),
            
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('बंद करें'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSeasonIcon(SeasonType seasonType) {
    switch (seasonType) {
      case SeasonType.kharif:
        return Icons.cloud_queue;
      case SeasonType.rabi:
        return Icons.ac_unit;
      case SeasonType.zaid:
        return Icons.wb_sunny;
    }
  }

  Color _getRiskColor(double riskFactor) {
    if (riskFactor < 0.3) return AppTheme.primaryGreen;
    if (riskFactor < 0.5) return AppTheme.sunYellow;
    if (riskFactor < 0.7) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _getRiskText(double riskFactor) {
    if (riskFactor < 0.3) return 'कम जोखिम';
    if (riskFactor < 0.5) return 'मध्यम जोखिम';
    if (riskFactor < 0.7) return 'उच्च जोखिम';
    return 'बहुत जोखिम';
  }
}