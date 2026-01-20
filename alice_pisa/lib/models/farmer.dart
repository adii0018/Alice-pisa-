class Farmer {
  final String id;
  final String name;
  final String village;
  
  // Financial State
  double currentMoney;
  double savings;
  double debt;
  
  // Assets
  double landSize; // in acres
  List<Crop> crops;
  bool hasInsurance;
  
  // Emotional State
  StressLevel stressLevel;
  double happiness;
  
  // Game Progress
  int currentSeason;
  int totalSeasons;
  List<SeasonResult> seasonHistory;

  Farmer({
    required this.id,
    required this.name,
    required this.village,
    this.currentMoney = 5000.0,
    this.savings = 0.0,
    this.debt = 0.0,
    this.landSize = 2.0,
    this.crops = const [],
    this.hasInsurance = false,
    this.stressLevel = StressLevel.calm,
    this.happiness = 0.7,
    this.currentSeason = 0,
    this.totalSeasons = 0,
    this.seasonHistory = const [],
  });

  // Calculate total wealth
  double get totalWealth => currentMoney + savings - debt;
  
  // Check if farmer is in financial stress
  bool get isInStress => debt > (currentMoney + savings) * 0.8;
  
  // Get current financial health score (0-1)
  double get financialHealth {
    if (totalWealth <= 0) return 0.0;
    if (debt == 0 && savings > currentMoney) return 1.0;
    
    double debtRatio = debt / (currentMoney + savings + 1);
    double savingsRatio = savings / (currentMoney + 1);
    
    return (1 - debtRatio + savingsRatio) / 2;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'village': village,
      'currentMoney': currentMoney,
      'savings': savings,
      'debt': debt,
      'landSize': landSize,
      'hasInsurance': hasInsurance,
      'stressLevel': stressLevel.index,
      'happiness': happiness,
      'currentSeason': currentSeason,
      'totalSeasons': totalSeasons,
    };
  }

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      name: json['name'],
      village: json['village'],
      currentMoney: json['currentMoney']?.toDouble() ?? 0.0,
      savings: json['savings']?.toDouble() ?? 0.0,
      debt: json['debt']?.toDouble() ?? 0.0,
      landSize: json['landSize']?.toDouble() ?? 2.0,
      hasInsurance: json['hasInsurance'] ?? false,
      stressLevel: StressLevel.values[json['stressLevel'] ?? 0],
      happiness: json['happiness']?.toDouble() ?? 0.7,
      currentSeason: json['currentSeason'] ?? 0,
      totalSeasons: json['totalSeasons'] ?? 0,
    );
  }
}

class Crop {
  final String name;
  final double investmentCost;
  final double expectedYield;
  final double marketPrice;
  final double riskFactor; // 0-1, higher = more risky
  
  Crop({
    required this.name,
    required this.investmentCost,
    required this.expectedYield,
    required this.marketPrice,
    required this.riskFactor,
  });
  
  double get expectedProfit => (expectedYield * marketPrice) - investmentCost;
}

enum StressLevel {
  calm,      // Green - All good
  worried,   // Yellow - Some concerns
  stressed,  // Orange - Financial pressure
  desperate  // Red - Crisis mode
}

class SeasonResult {
  final int seasonNumber;
  final String seasonType;
  final double income;
  final double expenses;
  final double profit;
  final List<String> events;
  final List<String> decisions;
  
  SeasonResult({
    required this.seasonNumber,
    required this.seasonType,
    required this.income,
    required this.expenses,
    required this.profit,
    required this.events,
    required this.decisions,
  });
}