enum SeasonType {
  kharif,  // Monsoon season (June-October)
  rabi,    // Winter season (November-April)  
  zaid     // Summer season (April-June)
}

class Season {
  final SeasonType type;
  final int year;
  final List<Crop> availableCrops;
  final List<GameEvent> possibleEvents;
  final WeatherCondition weather;
  
  Season({
    required this.type,
    required this.year,
    required this.availableCrops,
    required this.possibleEvents,
    required this.weather,
  });
  
  String get displayName {
    switch (type) {
      case SeasonType.kharif:
        return 'खरीफ़ (Kharif)';
      case SeasonType.rabi:
        return 'रबी (Rabi)';
      case SeasonType.zaid:
        return 'जायद (Zaid)';
    }
  }
  
  String get description {
    switch (type) {
      case SeasonType.kharif:
        return 'मानसून का मौसम - धान, मक्का, कपास';
      case SeasonType.rabi:
        return 'सर्दी का मौसम - गेहूं, जौ, मटर';
      case SeasonType.zaid:
        return 'गर्मी का मौसम - तरबूज, खीरा, चारा';
    }
  }
  
  // Get season-specific crops
  static List<Crop> getCropsForSeason(SeasonType season) {
    switch (season) {
      case SeasonType.kharif:
        return [
          Crop(name: 'धान (Rice)', investmentCost: 8000, expectedYield: 25, marketPrice: 1800, riskFactor: 0.3),
          Crop(name: 'मक्का (Maize)', investmentCost: 6000, expectedYield: 30, marketPrice: 1500, riskFactor: 0.4),
          Crop(name: 'कपास (Cotton)', investmentCost: 12000, expectedYield: 8, marketPrice: 5500, riskFactor: 0.6),
        ];
      case SeasonType.rabi:
        return [
          Crop(name: 'गेहूं (Wheat)', investmentCost: 10000, expectedYield: 35, marketPrice: 2000, riskFactor: 0.2),
          Crop(name: 'जौ (Barley)', investmentCost: 7000, expectedYield: 28, marketPrice: 1600, riskFactor: 0.3),
          Crop(name: 'मटर (Peas)', investmentCost: 5000, expectedYield: 15, marketPrice: 4000, riskFactor: 0.5),
        ];
      case SeasonType.zaid:
        return [
          Crop(name: 'तरबूज (Watermelon)', investmentCost: 4000, expectedYield: 200, marketPrice: 15, riskFactor: 0.7),
          Crop(name: 'खीरा (Cucumber)', investmentCost: 3000, expectedYield: 100, marketPrice: 25, riskFactor: 0.6),
          Crop(name: 'चारा (Fodder)', investmentCost: 2000, expectedYield: 50, marketPrice: 30, riskFactor: 0.2),
        ];
    }
  }
}

enum WeatherCondition {
  excellent,  // Perfect conditions
  good,       // Normal conditions
  average,    // Some challenges
  poor,       // Difficult conditions
  disaster    // Crop failure risk
}

class GameEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final double probability; // 0-1
  final Map<String, dynamic> impact;
  final List<EventChoice> choices;
  
  GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.probability,
    required this.impact,
    required this.choices,
  });
}

enum EventType {
  weather,     // Drought, flood, hail
  market,      // Price crash, price boom
  health,      // Medical emergency
  social,      // Wedding, festival
  government,  // Subsidy, loan waiver
  pest,        // Crop disease, pest attack
}

class EventChoice {
  final String id;
  final String text;
  final double cost;
  final Map<String, dynamic> consequences;
  final String voicePrompt;
  
  EventChoice({
    required this.id,
    required this.text,
    required this.cost,
    required this.consequences,
    required this.voicePrompt,
  });
}