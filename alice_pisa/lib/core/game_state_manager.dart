import 'package:flutter/foundation.dart';
import '../models/farmer.dart';
import '../models/season.dart';
import '../services/local_storage_service.dart';
import '../utils/game_events.dart';

class GameStateManager extends ChangeNotifier {
  Farmer? _currentFarmer;
  Season? _currentSeason;
  GamePhase _currentPhase = GamePhase.setup;
  List<GameEvent> _activeEvents = [];
  
  // Game progress tracking
  double _seasonProgress = 0.0;
  Map<String, dynamic> _gameStats = {};
  
  // Getters
  Farmer? get currentFarmer => _currentFarmer;
  Season? get currentSeason => _currentSeason;
  GamePhase get currentPhase => _currentPhase;
  List<GameEvent> get activeEvents => _activeEvents;
  double get seasonProgress => _seasonProgress;
  Map<String, dynamic> get gameStats => _gameStats;
  
  // Initialize new game
  Future<void> startNewGame(String farmerName, String village) async {
    _currentFarmer = Farmer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: farmerName,
      village: village,
    );
    
    // Start with Kharif season
    _currentSeason = Season(
      type: SeasonType.kharif,
      year: 1,
      availableCrops: Season.getCropsForSeason(SeasonType.kharif),
      possibleEvents: GameEvents.getEventsForSeason(SeasonType.kharif),
      weather: WeatherCondition.good,
    );
    
    _currentPhase = GamePhase.planning;
    _seasonProgress = 0.0;
    
    await _saveGameState();
    notifyListeners();
  }
  
  // Load existing game
  Future<void> loadGame() async {
    final savedData = await LocalStorageService.instance.getGameData();
    if (savedData != null) {
      _currentFarmer = Farmer.fromJson(savedData['farmer']);
      // Load season and other state...
      notifyListeners();
    }
  }
  
  // Make a financial decision
  Future<void> makeDecision(String decisionId, Map<String, dynamic> params) async {
    if (_currentFarmer == null) return;
    
    switch (decisionId) {
      case 'plant_crop':
        await _plantCrop(params['crop'], params['area']);
        break;
      case 'take_loan':
        await _takeLoan(params['amount'], params['source']);
        break;
      case 'buy_insurance':
        await _buyInsurance(params['type']);
        break;
      case 'save_money':
        await _saveMoney(params['amount']);
        break;
      case 'spend_money':
        await _spendMoney(params['amount'], params['category']);
        break;
    }
    
    await _saveGameState();
    notifyListeners();
  }
  
  // Plant a crop
  Future<void> _plantCrop(Crop crop, double area) async {
    if (_currentFarmer == null) return;
    
    double totalCost = crop.investmentCost * area;
    
    if (_currentFarmer!.currentMoney >= totalCost) {
      _currentFarmer!.currentMoney -= totalCost;
      _currentFarmer!.crops.add(crop);
      
      // Update stress based on financial situation
      _updateStressLevel();
    }
  }
  
  // Take a loan
  Future<void> _takeLoan(double amount, String source) async {
    if (_currentFarmer == null) return;
    
    double interestRate = _getLoanInterestRate(source);
    double totalDebt = amount * (1 + interestRate);
    
    _currentFarmer!.currentMoney += amount;
    _currentFarmer!.debt += totalDebt;
    
    _updateStressLevel();
  }
  
  // Buy insurance
  Future<void> _buyInsurance(String type) async {
    if (_currentFarmer == null) return;
    
    double cost = _getInsuranceCost(type);
    
    if (_currentFarmer!.currentMoney >= cost) {
      _currentFarmer!.currentMoney -= cost;
      _currentFarmer!.hasInsurance = true;
      
      // Insurance reduces stress
      if (_currentFarmer!.stressLevel.index > 0) {
        _currentFarmer!.stressLevel = StressLevel.values[_currentFarmer!.stressLevel.index - 1];
      }
    }
  }
  
  // Save money
  Future<void> _saveMoney(double amount) async {
    if (_currentFarmer == null) return;
    
    if (_currentFarmer!.currentMoney >= amount) {
      _currentFarmer!.currentMoney -= amount;
      _currentFarmer!.savings += amount;
      
      // Saving reduces stress
      _updateStressLevel();
    }
  }
  
  // Spend money
  Future<void> _spendMoney(double amount, String category) async {
    if (_currentFarmer == null) return;
    
    if (_currentFarmer!.currentMoney >= amount) {
      _currentFarmer!.currentMoney -= amount;
      
      // Different categories have different stress impacts
      if (category == 'luxury') {
        // Luxury spending increases stress if money is tight
        if (_currentFarmer!.currentMoney < _currentFarmer!.debt * 0.5) {
          _increaseStress();
        }
      }
    }
  }
  
  // Progress to next phase
  Future<void> nextPhase() async {
    switch (_currentPhase) {
      case GamePhase.setup:
        _currentPhase = GamePhase.planning;
        break;
      case GamePhase.planning:
        _currentPhase = GamePhase.growing;
        await _triggerRandomEvents();
        break;
      case GamePhase.growing:
        _currentPhase = GamePhase.harvest;
        await _calculateHarvest();
        break;
      case GamePhase.harvest:
        _currentPhase = GamePhase.reflection;
        await _calculateSeasonResults();
        break;
      case GamePhase.reflection:
        await _nextSeason();
        break;
    }
    
    _seasonProgress = (_currentPhase.index / GamePhase.values.length);
    await _saveGameState();
    notifyListeners();
  }
  
  // Trigger random events during growing phase
  Future<void> _triggerRandomEvents() async {
    if (_currentSeason == null) return;
    
    for (var event in _currentSeason!.possibleEvents) {
      if (_shouldTriggerEvent(event)) {
        _activeEvents.add(event);
      }
    }
  }
  
  // Calculate harvest results
  Future<void> _calculateHarvest() async {
    if (_currentFarmer == null) return;
    
    double totalIncome = 0;
    
    for (var crop in _currentFarmer!.crops) {
      double yield = crop.expectedYield;
      
      // Apply weather and event modifiers
      yield *= _getWeatherModifier();
      yield *= _getEventModifier();
      
      double income = yield * crop.marketPrice;
      totalIncome += income;
    }
    
    _currentFarmer!.currentMoney += totalIncome;
    _updateStressLevel();
  }
  
  // Calculate season results and prepare for next season
  Future<void> _calculateSeasonResults() async {
    if (_currentFarmer == null) return;
    
    // Record season results
    _currentFarmer!.totalSeasons++;
    
    // Update happiness based on financial performance
    _updateHappiness();
  }
  
  // Move to next season
  Future<void> _nextSeason() async {
    if (_currentSeason == null) return;
    
    SeasonType nextSeasonType;
    int nextYear = _currentSeason!.year;
    
    switch (_currentSeason!.type) {
      case SeasonType.kharif:
        nextSeasonType = SeasonType.rabi;
        break;
      case SeasonType.rabi:
        nextSeasonType = SeasonType.zaid;
        break;
      case SeasonType.zaid:
        nextSeasonType = SeasonType.kharif;
        nextYear++;
        break;
    }
    
    _currentSeason = Season(
      type: nextSeasonType,
      year: nextYear,
      availableCrops: Season.getCropsForSeason(nextSeasonType),
      possibleEvents: GameEvents.getEventsForSeason(nextSeasonType),
      weather: WeatherCondition.good,
    );
    
    _currentPhase = GamePhase.planning;
    _seasonProgress = 0.0;
    _activeEvents.clear();
    _currentFarmer!.crops.clear();
  }
  
  // Helper methods
  void _updateStressLevel() {
    if (_currentFarmer == null) return;
    
    double financialHealth = _currentFarmer!.financialHealth;
    
    if (financialHealth > 0.8) {
      _currentFarmer!.stressLevel = StressLevel.calm;
    } else if (financialHealth > 0.6) {
      _currentFarmer!.stressLevel = StressLevel.worried;
    } else if (financialHealth > 0.3) {
      _currentFarmer!.stressLevel = StressLevel.stressed;
    } else {
      _currentFarmer!.stressLevel = StressLevel.desperate;
    }
  }
  
  void _increaseStress() {
    if (_currentFarmer == null) return;
    
    int currentIndex = _currentFarmer!.stressLevel.index;
    if (currentIndex < StressLevel.values.length - 1) {
      _currentFarmer!.stressLevel = StressLevel.values[currentIndex + 1];
    }
  }
  
  void _updateHappiness() {
    if (_currentFarmer == null) return;
    
    double financialHealth = _currentFarmer!.financialHealth;
    _currentFarmer!.happiness = financialHealth;
  }
  
  double _getLoanInterestRate(String source) {
    switch (source) {
      case 'bank':
        return 0.12; // 12% annual
      case 'moneylender':
        return 0.36; // 36% annual
      case 'shg':
        return 0.08; // 8% annual
      default:
        return 0.15;
    }
  }
  
  double _getInsuranceCost(String type) {
    switch (type) {
      case 'crop':
        return 500;
      case 'health':
        return 1200;
      case 'life':
        return 800;
      default:
        return 500;
    }
  }
  
  bool _shouldTriggerEvent(GameEvent event) {
    return (DateTime.now().millisecond / 1000) < event.probability;
  }
  
  double _getWeatherModifier() {
    if (_currentSeason == null) return 1.0;
    
    switch (_currentSeason!.weather) {
      case WeatherCondition.excellent:
        return 1.2;
      case WeatherCondition.good:
        return 1.0;
      case WeatherCondition.average:
        return 0.8;
      case WeatherCondition.poor:
        return 0.6;
      case WeatherCondition.disaster:
        return 0.2;
    }
  }
  
  double _getEventModifier() {
    double modifier = 1.0;
    
    for (var event in _activeEvents) {
      if (event.impact.containsKey('yieldModifier')) {
        modifier *= event.impact['yieldModifier'];
      }
    }
    
    return modifier;
  }
  
  Future<void> _saveGameState() async {
    if (_currentFarmer != null) {
      await LocalStorageService.instance.saveGameData({
        'farmer': _currentFarmer!.toJson(),
        'currentPhase': _currentPhase.index,
        'seasonProgress': _seasonProgress,
      });
    }
  }
}

enum GamePhase {
  setup,      // Initial farmer setup
  planning,   // Crop selection, financial planning
  growing,    // Events occur, decisions needed
  harvest,    // Results calculated
  reflection  // Season summary, learning
}