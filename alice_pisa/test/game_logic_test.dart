import 'package:flutter_test/flutter_test.dart';
import 'package:alice_pisa/models/farmer.dart';
import 'package:alice_pisa/models/season.dart';

void main() {
  group('Alice Pisa Game Logic Tests', () {
    
    test('Farmer financial health calculation', () {
      // Test case 1: Healthy farmer
      final healthyFarmer = Farmer(
        id: 'test1',
        name: 'Test Farmer',
        village: 'Test Village',
        currentMoney: 10000,
        savings: 5000,
        debt: 2000,
      );
      
      expect(healthyFarmer.totalWealth, equals(13000)); // 10000 + 5000 - 2000
      expect(healthyFarmer.financialHealth, greaterThan(0.5));
      expect(healthyFarmer.isInStress, isFalse);
      
      // Test case 2: Stressed farmer
      final stressedFarmer = Farmer(
        id: 'test2',
        name: 'Stressed Farmer',
        village: 'Test Village',
        currentMoney: 1000,
        savings: 500,
        debt: 5000,
      );
      
      expect(stressedFarmer.totalWealth, equals(-3500)); // 1000 + 500 - 5000
      expect(stressedFarmer.isInStress, isTrue);
      expect(stressedFarmer.stressLevel, equals(StressLevel.desperate));
    });
    
    test('Crop profitability calculation', () {
      final riceCrop = Crop(
        name: 'Rice',
        investmentCost: 8000,
        expectedYield: 25,
        marketPrice: 1800,
        riskFactor: 0.3,
      );
      
      // Expected profit = (25 * 1800) - 8000 = 45000 - 8000 = 37000
      expect(riceCrop.expectedProfit, equals(37000));
    });
    
    test('Season crop availability', () {
      final kharifCrops = Season.getCropsForSeason(SeasonType.kharif);
      final rabiCrops = Season.getCropsForSeason(SeasonType.rabi);
      final zaidCrops = Season.getCropsForSeason(SeasonType.zaid);
      
      expect(kharifCrops.length, greaterThan(0));
      expect(rabiCrops.length, greaterThan(0));
      expect(zaidCrops.length, greaterThan(0));
      
      // Check if rice is available in Kharif season
      expect(kharifCrops.any((crop) => crop.name.contains('धान')), isTrue);
      
      // Check if wheat is available in Rabi season
      expect(rabiCrops.any((crop) => crop.name.contains('गेहूं')), isTrue);
    });
    
    test('Farmer JSON serialization', () {
      final originalFarmer = Farmer(
        id: 'test123',
        name: 'JSON Test',
        village: 'Test Village',
        currentMoney: 15000,
        savings: 3000,
        debt: 1000,
        landSize: 2.5,
        hasInsurance: true,
        stressLevel: StressLevel.calm,
        happiness: 0.8,
      );
      
      // Convert to JSON and back
      final json = originalFarmer.toJson();
      final deserializedFarmer = Farmer.fromJson(json);
      
      expect(deserializedFarmer.id, equals(originalFarmer.id));
      expect(deserializedFarmer.name, equals(originalFarmer.name));
      expect(deserializedFarmer.village, equals(originalFarmer.village));
      expect(deserializedFarmer.currentMoney, equals(originalFarmer.currentMoney));
      expect(deserializedFarmer.savings, equals(originalFarmer.savings));
      expect(deserializedFarmer.debt, equals(originalFarmer.debt));
      expect(deserializedFarmer.hasInsurance, equals(originalFarmer.hasInsurance));
      expect(deserializedFarmer.stressLevel, equals(originalFarmer.stressLevel));
    });
    
    test('Stress level progression', () {
      final farmer = Farmer(
        id: 'stress_test',
        name: 'Stress Test',
        village: 'Test Village',
        currentMoney: 5000,
        savings: 1000,
        debt: 0,
      );
      
      // Initially should be calm
      expect(farmer.stressLevel, equals(StressLevel.calm));
      
      // Add debt to increase stress
      farmer.debt = 8000; // High debt relative to assets
      
      // Financial health should decrease
      expect(farmer.financialHealth, lessThan(0.5));
      expect(farmer.isInStress, isTrue);
    });
  });
}