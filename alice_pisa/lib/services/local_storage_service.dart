import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static LocalStorageService get instance => _instance;
  LocalStorageService._internal();

  Database? _database;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'alice_pisa.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Game state table
        await db.execute('''
          CREATE TABLE game_state (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farmer_data TEXT NOT NULL,
            season_data TEXT,
            phase INTEGER NOT NULL,
            progress REAL NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Season history table
        await db.execute('''
          CREATE TABLE season_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farmer_id TEXT NOT NULL,
            season_number INTEGER NOT NULL,
            season_type TEXT NOT NULL,
            income REAL NOT NULL,
            expenses REAL NOT NULL,
            profit REAL NOT NULL,
            events TEXT,
            decisions TEXT,
            created_at INTEGER NOT NULL
          )
        ''');

        // Decision tracking table
        await db.execute('''
          CREATE TABLE decisions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farmer_id TEXT NOT NULL,
            decision_type TEXT NOT NULL,
            decision_data TEXT NOT NULL,
            outcome TEXT,
            timestamp INTEGER NOT NULL
          )
        ''');

        // Learning analytics table
        await db.execute('''
          CREATE TABLE learning_analytics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farmer_id TEXT NOT NULL,
            concept TEXT NOT NULL,
            attempts INTEGER DEFAULT 1,
            success_rate REAL DEFAULT 0.0,
            last_attempt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Save game state
  Future<void> saveGameData(Map<String, dynamic> gameData) async {
    if (_database == null) return;

    await _database!.insert(
      'game_state',
      {
        'farmer_data': jsonEncode(gameData['farmer']),
        'season_data': gameData['season'] != null ? jsonEncode(gameData['season']) : null,
        'phase': gameData['currentPhase'] ?? 0,
        'progress': gameData['seasonProgress'] ?? 0.0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Load latest game state
  Future<Map<String, dynamic>?> getGameData() async {
    if (_database == null) return null;

    final List<Map<String, dynamic>> maps = await _database!.query(
      'game_state',
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final data = maps.first;
      return {
        'farmer': jsonDecode(data['farmer_data']),
        'season': data['season_data'] != null ? jsonDecode(data['season_data']) : null,
        'currentPhase': data['phase'],
        'seasonProgress': data['progress'],
      };
    }

    return null;
  }

  // Save season result
  Future<void> saveSeasonResult(Map<String, dynamic> seasonResult) async {
    if (_database == null) return;

    await _database!.insert('season_history', {
      'farmer_id': seasonResult['farmerId'],
      'season_number': seasonResult['seasonNumber'],
      'season_type': seasonResult['seasonType'],
      'income': seasonResult['income'],
      'expenses': seasonResult['expenses'],
      'profit': seasonResult['profit'],
      'events': jsonEncode(seasonResult['events'] ?? []),
      'decisions': jsonEncode(seasonResult['decisions'] ?? []),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get season history
  Future<List<Map<String, dynamic>>> getSeasonHistory(String farmerId) async {
    if (_database == null) return [];

    return await _database!.query(
      'season_history',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'season_number ASC',
    );
  }

  // Track decision
  Future<void> trackDecision(String farmerId, String decisionType, 
      Map<String, dynamic> decisionData, [String? outcome]) async {
    if (_database == null) return;

    await _database!.insert('decisions', {
      'farmer_id': farmerId,
      'decision_type': decisionType,
      'decision_data': jsonEncode(decisionData),
      'outcome': outcome,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get decision history
  Future<List<Map<String, dynamic>>> getDecisionHistory(String farmerId) async {
    if (_database == null) return [];

    return await _database!.query(
      'decisions',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'timestamp DESC',
    );
  }

  // Update learning analytics
  Future<void> updateLearningAnalytics(String farmerId, String concept, bool success) async {
    if (_database == null) return;

    // Check if record exists
    final existing = await _database!.query(
      'learning_analytics',
      where: 'farmer_id = ? AND concept = ?',
      whereArgs: [farmerId, concept],
    );

    if (existing.isNotEmpty) {
      // Update existing record
      final record = existing.first;
      int attempts = record['attempts'] as int;
      double successRate = record['success_rate'] as double;
      
      attempts++;
      if (success) {
        successRate = ((successRate * (attempts - 1)) + 1) / attempts;
      } else {
        successRate = (successRate * (attempts - 1)) / attempts;
      }

      await _database!.update(
        'learning_analytics',
        {
          'attempts': attempts,
          'success_rate': successRate,
          'last_attempt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'farmer_id = ? AND concept = ?',
        whereArgs: [farmerId, concept],
      );
    } else {
      // Create new record
      await _database!.insert('learning_analytics', {
        'farmer_id': farmerId,
        'concept': concept,
        'attempts': 1,
        'success_rate': success ? 1.0 : 0.0,
        'last_attempt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Get learning analytics
  Future<List<Map<String, dynamic>>> getLearningAnalytics(String farmerId) async {
    if (_database == null) return [];

    return await _database!.query(
      'learning_analytics',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'last_attempt DESC',
    );
  }

  // Shared preferences helpers
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  bool? getBool(String key) => _prefs?.getBool(key);
  String? getString(String key) => _prefs?.getString(key);
  int? getInt(String key) => _prefs?.getInt(key);
  double? getDouble(String key) => _prefs?.getDouble(key);

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs?.clear();
    if (_database != null) {
      await _database!.delete('game_state');
      await _database!.delete('season_history');
      await _database!.delete('decisions');
      await _database!.delete('learning_analytics');
    }
  }

  // Export game data for backup
  Future<Map<String, dynamic>> exportGameData(String farmerId) async {
    return {
      'gameState': await getGameData(),
      'seasonHistory': await getSeasonHistory(farmerId),
      'decisionHistory': await getDecisionHistory(farmerId),
      'learningAnalytics': await getLearningAnalytics(farmerId),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}