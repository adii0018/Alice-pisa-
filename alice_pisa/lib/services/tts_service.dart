import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    _flutterTts = FlutterTts();
    
    // Configure TTS for Hindi/English mix
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setSpeechRate(0.8); // Slightly slower for clarity
    await _flutterTts.setVolume(0.9);
    await _flutterTts.setPitch(1.0);
    
    _isInitialized = true;
  }

  // Speak text with emotion
  Future<void> speak(String text, {TTSEmotion emotion = TTSEmotion.neutral}) async {
    if (!_isInitialized) await init();
    
    // Adjust speech parameters based on emotion
    switch (emotion) {
      case TTSEmotion.happy:
        await _flutterTts.setSpeechRate(0.9);
        await _flutterTts.setPitch(1.1);
        break;
      case TTSEmotion.worried:
        await _flutterTts.setSpeechRate(0.7);
        await _flutterTts.setPitch(0.9);
        break;
      case TTSEmotion.stressed:
        await _flutterTts.setSpeechRate(0.6);
        await _flutterTts.setPitch(0.8);
        break;
      case TTSEmotion.excited:
        await _flutterTts.setSpeechRate(1.0);
        await _flutterTts.setPitch(1.2);
        break;
      case TTSEmotion.neutral:
      default:
        await _flutterTts.setSpeechRate(0.8);
        await _flutterTts.setPitch(1.0);
        break;
    }
    
    await _flutterTts.speak(text);
  }

  // Speak financial guidance
  Future<void> speakGuidance(String guidance, bool isPositive) async {
    TTSEmotion emotion = isPositive ? TTSEmotion.happy : TTSEmotion.worried;
    await speak(guidance, emotion: emotion);
  }

  // Speak season introduction
  Future<void> speakSeasonIntro(String seasonName, String description) async {
    String intro = "$seasonName का मौसम शुरू हो गया है। $description";
    await speak(intro, emotion: TTSEmotion.excited);
  }

  // Speak financial status
  Future<void> speakFinancialStatus(double money, double debt, bool isGood) async {
    String status = "आपके पास ₹${money.toInt()} हैं";
    if (debt > 0) {
      status += " और ₹${debt.toInt()} का कर्ज है";
    }
    
    TTSEmotion emotion = isGood ? TTSEmotion.happy : TTSEmotion.worried;
    await speak(status, emotion: emotion);
  }

  // Speak event notification
  Future<void> speakEvent(String eventTitle, String eventDescription) async {
    String notification = "ध्यान दें! $eventTitle। $eventDescription";
    await speak(notification, emotion: TTSEmotion.worried);
  }

  // Speak decision consequences
  Future<void> speakConsequence(String consequence, bool isPositive) async {
    String prefix = isPositive ? "बहुत अच्छा! " : "सावधान! ";
    await speak(prefix + consequence, emotion: isPositive ? TTSEmotion.happy : TTSEmotion.stressed);
  }

  // Stop speaking
  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }

  // Pause speaking
  Future<void> pause() async {
    if (_isInitialized) {
      await _flutterTts.pause();
    }
  }

  // Check if TTS is available
  Future<bool> isLanguageAvailable(String language) async {
    if (!_isInitialized) await init();
    
    List<dynamic> languages = await _flutterTts.getLanguages;
    return languages.contains(language);
  }

  // Get available voices
  Future<List<dynamic>> getVoices() async {
    if (!_isInitialized) await init();
    return await _flutterTts.getVoices;
  }
}

enum TTSEmotion {
  neutral,
  happy,
  worried,
  stressed,
  excited,
}