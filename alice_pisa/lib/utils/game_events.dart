import '../models/season.dart';

class GameEvents {
  // Get events specific to each season
  static List<GameEvent> getEventsForSeason(SeasonType season) {
    switch (season) {
      case SeasonType.kharif:
        return _getKharifEvents();
      case SeasonType.rabi:
        return _getRabiEvents();
      case SeasonType.zaid:
        return _getZaidEvents();
    }
  }

  // Kharif season events (Monsoon)
  static List<GameEvent> _getKharifEvents() {
    return [
      GameEvent(
        id: 'kharif_drought',
        title: 'सूखा (Drought)',
        description: 'बारिश कम हुई है। फसल को पानी की जरूरत है।',
        type: EventType.weather,
        probability: 0.3,
        impact: {'yieldModifier': 0.6, 'irrigationCost': 2000},
        choices: [
          EventChoice(
            id: 'buy_water',
            text: 'पानी खरीदें (₹2000)',
            cost: 2000,
            consequences: {'yieldModifier': 0.9, 'stressIncrease': 1},
            voicePrompt: 'पानी खरीदने से फसल बच जाएगी लेकिन पैसे खर्च होंगे',
          ),
          EventChoice(
            id: 'wait_rain',
            text: 'बारिश का इंतजार करें',
            cost: 0,
            consequences: {'yieldModifier': 0.4, 'stressIncrease': 2},
            voicePrompt: 'बारिश का इंतजार करना जोखिम भरा है',
          ),
          EventChoice(
            id: 'sell_early',
            text: 'जल्दी बेच दें',
            cost: 0,
            consequences: {'immediateIncome': 3000, 'yieldModifier': 0.0},
            voicePrompt: 'जल्दी बेचने से कम पैसे मिलेंगे',
          ),
        ],
      ),
      
      GameEvent(
        id: 'kharif_flood',
        title: 'बाढ़ (Flood)',
        description: 'बहुत ज्यादा बारिश से खेत में पानी भर गया है।',
        type: EventType.weather,
        probability: 0.2,
        impact: {'yieldModifier': 0.3, 'drainageCost': 1500},
        choices: [
          EventChoice(
            id: 'drainage',
            text: 'पानी निकालें (₹1500)',
            cost: 1500,
            consequences: {'yieldModifier': 0.7, 'stressIncrease': 1},
            voicePrompt: 'पानी निकालने से फसल बच सकती है',
          ),
          EventChoice(
            id: 'wait_drain',
            text: 'प्राकृतिक रूप से सूखने दें',
            cost: 0,
            consequences: {'yieldModifier': 0.2, 'stressIncrease': 3},
            voicePrompt: 'इंतजार करना खतरनाक हो सकता है',
          ),
        ],
      ),

      GameEvent(
        id: 'kharif_pest_attack',
        title: 'कीट प्रकोप (Pest Attack)',
        description: 'फसल में कीड़े लग गए हैं। तुरंत इलाज जरूरी है।',
        type: EventType.pest,
        probability: 0.4,
        impact: {'yieldModifier': 0.5, 'pesticideCost': 800},
        choices: [
          EventChoice(
            id: 'buy_pesticide',
            text: 'दवाई छिड़कें (₹800)',
            cost: 800,
            consequences: {'yieldModifier': 0.9, 'healthRisk': 0.1},
            voicePrompt: 'दवाई से कीड़े मर जाएंगे लेकिन स्वास्थ्य का ध्यान रखें',
          ),
          EventChoice(
            id: 'organic_solution',
            text: 'घरेलू नुस्खा (₹200)',
            cost: 200,
            consequences: {'yieldModifier': 0.7, 'organicBonus': 500},
            voicePrompt: 'घरेलू नुस्खा सुरक्षित है लेकिन कम प्रभावी',
          ),
          EventChoice(
            id: 'do_nothing',
            text: 'कुछ न करें',
            cost: 0,
            consequences: {'yieldModifier': 0.3, 'stressIncrease': 2},
            voicePrompt: 'कुछ न करने से फसल बर्बाद हो सकती है',
          ),
        ],
      ),

      GameEvent(
        id: 'kharif_medical_emergency',
        title: 'स्वास्थ्य समस्या (Health Emergency)',
        description: 'परिवार में किसी को अचानक इलाज की जरूरत है।',
        type: EventType.health,
        probability: 0.15,
        impact: {'medicalCost': 5000},
        choices: [
          EventChoice(
            id: 'use_savings',
            text: 'बचत से पैसे लें',
            cost: 0,
            consequences: {'savingsDeduction': 5000, 'familyHappiness': 1},
            voicePrompt: 'बचत से इलाज कराना सही है',
          ),
          EventChoice(
            id: 'take_loan',
            text: 'कर्ज लें (₹5000)',
            cost: 0,
            consequences: {'debtIncrease': 6000, 'stressIncrease': 2},
            voicePrompt: 'कर्ज लेना पड़ेगा लेकिन ब्याज भी देना होगा',
          ),
          EventChoice(
            id: 'delay_treatment',
            text: 'इलाज टालें',
            cost: 0,
            consequences: {'familyHappiness': -2, 'futureHealthRisk': 1},
            voicePrompt: 'इलाज टालना खतरनाक हो सकता है',
          ),
        ],
      ),
    ];
  }

  // Rabi season events (Winter)
  static List<GameEvent> _getRabiEvents() {
    return [
      GameEvent(
        id: 'rabi_cold_wave',
        title: 'शीत लहर (Cold Wave)',
        description: 'अचानक ठंड बढ़ गई है। फसल को बचाना जरूरी है।',
        type: EventType.weather,
        probability: 0.25,
        impact: {'yieldModifier': 0.7, 'protectionCost': 1000},
        choices: [
          EventChoice(
            id: 'cover_crops',
            text: 'फसल ढकें (₹1000)',
            cost: 1000,
            consequences: {'yieldModifier': 0.95},
            voicePrompt: 'फसल ढकने से ठंड से बचाव होगा',
          ),
          EventChoice(
            id: 'light_fires',
            text: 'आग जलाएं (₹300)',
            cost: 300,
            consequences: {'yieldModifier': 0.8, 'fireRisk': 0.1},
            voicePrompt: 'आग जलाना सस्ता है लेकिन सावधानी बरतें',
          ),
          EventChoice(
            id: 'do_nothing_cold',
            text: 'कुछ न करें',
            cost: 0,
            consequences: {'yieldModifier': 0.5, 'stressIncrease': 2},
            voicePrompt: 'ठंड से फसल को नुकसान हो सकता है',
          ),
        ],
      ),

      GameEvent(
        id: 'rabi_market_crash',
        title: 'बाजार गिरावट (Market Crash)',
        description: 'गेहूं के भाव अचानक गिर गए हैं।',
        type: EventType.market,
        probability: 0.2,
        impact: {'priceModifier': 0.6},
        choices: [
          EventChoice(
            id: 'sell_immediately',
            text: 'तुरंत बेच दें',
            cost: 0,
            consequences: {'priceModifier': 0.6, 'immediateIncome': 1},
            voicePrompt: 'तुरंत बेचने से कम पैसे मिलेंगे',
          ),
          EventChoice(
            id: 'store_grain',
            text: 'अनाज रखें (₹500)',
            cost: 500,
            consequences: {'storageCost': 500, 'futureBonus': 0.3},
            voicePrompt: 'रखने से बाद में अच्छे दाम मिल सकते हैं',
          ),
          EventChoice(
            id: 'find_buyer',
            text: 'बेहतर खरीदार ढूंढें',
            cost: 0,
            consequences: {'priceModifier': 0.8, 'timeDelay': 1},
            voicePrompt: 'अच्छे खरीदार ढूंढने में समय लगेगा',
          ),
        ],
      ),

      GameEvent(
        id: 'rabi_festival_expense',
        title: 'त्योहार खर्च (Festival Expenses)',
        description: 'होली का त्योहार आ रहा है। परिवार खुशी मनाना चाहता है।',
        type: EventType.social,
        probability: 0.8,
        impact: {'festivalCost': 2000},
        choices: [
          EventChoice(
            id: 'celebrate_big',
            text: 'धूमधाम से मनाएं (₹2000)',
            cost: 2000,
            consequences: {'familyHappiness': 2, 'socialStatus': 1},
            voicePrompt: 'त्योहार मनाने से खुशी मिलेगी',
          ),
          EventChoice(
            id: 'celebrate_simple',
            text: 'सादा मनाएं (₹500)',
            cost: 500,
            consequences: {'familyHappiness': 1, 'moneySaved': 1500},
            voicePrompt: 'सादा मनाने से पैसे बचेंगे',
          ),
          EventChoice(
            id: 'skip_festival',
            text: 'त्योहार न मनाएं',
            cost: 0,
            consequences: {'familyHappiness': -2, 'socialStatus': -1},
            voicePrompt: 'त्योहार न मनाने से परिवार दुखी होगा',
          ),
        ],
      ),
    ];
  }

  // Zaid season events (Summer)
  static List<GameEvent> _getZaidEvents() {
    return [
      GameEvent(
        id: 'zaid_water_shortage',
        title: 'पानी की कमी (Water Shortage)',
        description: 'गर्मी में पानी की भारी कमी है। ट्यूबवेल सूख गया है।',
        type: EventType.weather,
        probability: 0.6,
        impact: {'yieldModifier': 0.3, 'waterCost': 3000},
        choices: [
          EventChoice(
            id: 'buy_water_tanker',
            text: 'पानी का टैंकर (₹3000)',
            cost: 3000,
            consequences: {'yieldModifier': 0.8, 'stressIncrease': 2},
            voicePrompt: 'टैंकर महंगा है लेकिन फसल बच जाएगी',
          ),
          EventChoice(
            id: 'drill_deeper',
            text: 'गहरा बोरवेल (₹8000)',
            cost: 8000,
            consequences: {'yieldModifier': 1.0, 'futureWaterSecurity': 1},
            voicePrompt: 'गहरा बोरवेल महंगा है लेकिन भविष्य के लिए अच्छा',
          ),
          EventChoice(
            id: 'abandon_crop',
            text: 'फसल छोड़ दें',
            cost: 0,
            consequences: {'yieldModifier': 0.0, 'stressIncrease': 3},
            voicePrompt: 'फसल छोड़ने से सारा निवेश बर्बाद हो जाएगा',
          ),
        ],
      ),

      GameEvent(
        id: 'zaid_electricity_problem',
        title: 'बिजली की समस्या (Power Problem)',
        description: 'मोटर चलाने के लिए बिजली नहीं आ रही।',
        type: EventType.government,
        probability: 0.7,
        impact: {'yieldModifier': 0.6, 'dieselCost': 1500},
        choices: [
          EventChoice(
            id: 'use_diesel',
            text: 'डीजल जेनरेटर (₹1500)',
            cost: 1500,
            consequences: {'yieldModifier': 0.9, 'pollutionIncrease': 1},
            voicePrompt: 'डीजल से मोटर चलेगी लेकिन महंगा है',
          ),
          EventChoice(
            id: 'solar_pump',
            text: 'सोलर पंप (₹25000)',
            cost: 25000,
            consequences: {'yieldModifier': 1.0, 'futureElectricitySavings': 1},
            voicePrompt: 'सोलर पंप महंगा है लेकिन लंबे समय के लिए फायदेमंद',
          ),
          EventChoice(
            id: 'wait_electricity',
            text: 'बिजली का इंतजार करें',
            cost: 0,
            consequences: {'yieldModifier': 0.4, 'stressIncrease': 2},
            voicePrompt: 'बिजली का इंतजार करना जोखिम भरा है',
          ),
        ],
      ),

      GameEvent(
        id: 'zaid_heat_wave',
        title: 'लू (Heat Wave)',
        description: 'भयंकर गर्मी से फसल मुरझा रही है।',
        type: EventType.weather,
        probability: 0.4,
        impact: {'yieldModifier': 0.5, 'shadeCost': 800},
        choices: [
          EventChoice(
            id: 'shade_nets',
            text: 'छाया जाल (₹800)',
            cost: 800,
            consequences: {'yieldModifier': 0.85, 'futureHeatProtection': 1},
            voicePrompt: 'छाया जाल से फसल को गर्मी से बचाव होगा',
          ),
          EventChoice(
            id: 'extra_watering',
            text: 'ज्यादा पानी दें (₹400)',
            cost: 400,
            consequences: {'yieldModifier': 0.7, 'waterWaste': 1},
            voicePrompt: 'ज्यादा पानी देने से राहत मिलेगी',
          ),
          EventChoice(
            id: 'harvest_early',
            text: 'जल्दी काट लें',
            cost: 0,
            consequences: {'yieldModifier': 0.6, 'qualityReduction': 1},
            voicePrompt: 'जल्दी काटने से गुणवत्ता कम हो जाएगी',
          ),
        ],
      ),
    ];
  }

  // Get random event based on probability
  static GameEvent? getRandomEvent(List<GameEvent> possibleEvents) {
    for (var event in possibleEvents) {
      double random = DateTime.now().millisecond / 1000.0;
      if (random < event.probability) {
        return event;
      }
    }
    return null;
  }

  // Get events by type
  static List<GameEvent> getEventsByType(EventType type, SeasonType season) {
    List<GameEvent> allEvents = getEventsForSeason(season);
    return allEvents.where((event) => event.type == type).toList();
  }

  // Get high probability events (tutorial/learning focused)
  static List<GameEvent> getTutorialEvents(SeasonType season) {
    List<GameEvent> allEvents = getEventsForSeason(season);
    return allEvents.where((event) => event.probability > 0.5).toList();
  }
}