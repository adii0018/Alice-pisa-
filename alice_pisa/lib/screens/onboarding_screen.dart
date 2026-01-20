import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/game_state_manager.dart';
import '../services/tts_service.dart';
import '../utils/app_theme.dart';
import 'farmer_dashboard.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Alice Pisa में आपका स्वागत है!',
      subtitle: 'खेती के फैसले सीखें, असली जिंदगी में कामयाब हों',
      description: 'यह एक खेल है जहाम आप किसान बनकर पैसों के फैसले सीखेंगे।',
      icon: Icons.agriculture,
      voiceText: 'Alice Pisa में आपका स्वागत है! यहाम आप खेती के जरिए पैसों के फैसले सीखेंगे।',
    ),
    OnboardingPage(
      title: 'असली किसान की तरह सोचें',
      subtitle: 'हर मौसम में सही फैसले लें',
      description: 'खरीफ, रबी और जायद - तीनों मौसम में अलग-अलग चुनौतियाम होंगी।',
      icon: Icons.wb_sunny,
      voiceText: 'आप असली किसान की तरह हर मौसम में फैसले लेंगे। खरीफ, रबी और जायद मौसम में अलग चुनौतियाम होंगी।',
    ),
    OnboardingPage(
      title: 'गलतियों से सीखें',
      subtitle: 'कोई गेम ओवर नहीं, सिर्फ सीखना',
      description: 'गलत फैसले से परेशानी होगी, लेकिन आप सीखकर बेहतर बनेंगे।',
      icon: Icons.school,
      voiceText: 'यहाम गलतियाम करना ठीक है। गलत फैसले से आप सीखेंगे और बेहतर बनेंगे।',
    ),
    OnboardingPage(
      title: 'अपना परिचय दें',
      subtitle: 'आपका नाम और गाम बताएं',
      description: 'हम आपको आपके नाम से पुकारेंगे और आपके गाम की परिस्थिति समझेंगे।',
      icon: Icons.person,
      voiceText: 'अब अपना नाम और गाम का नाम बताएं। हम आपको आपके नाम से पुकारेंगे।',
      isForm: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speakCurrentPage();
  }

  Future<void> _speakCurrentPage() async {
    final ttsService = context.read<TTSService>();
    await Future.delayed(const Duration(milliseconds: 500));
    await ttsService.speak(_pages[_currentPage].voiceText, emotion: TTSEmotion.excited);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _startGame();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _startGame() async {
    if (_nameController.text.trim().isEmpty || _villageController.text.trim().isEmpty) {
      _showError('कृपया अपना नाम और गाम का नाम भरें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gameManager = context.read<GameStateManager>();
      await gameManager.startNewGame(
        _nameController.text.trim(),
        _villageController.text.trim(),
      );

      final ttsService = context.read<TTSService>();
      await ttsService.speak(
        '${_nameController.text} जी, आपका खेल शुरू हो रहा है!',
        emotion: TTSEmotion.excited,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FarmerDashboard()),
        );
      }
    } catch (e) {
      _showError('खेल शुरू करने में समस्या हुई। कृपया दोबारा कोशिश करें।');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.dangerRed,
      ),
    );
    
    context.read<TTSService>().speak(message, emotion: TTSEmotion.worried);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(_pages.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage 
                            ? AppTheme.primaryGreen 
                            : AppTheme.textLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _speakCurrentPage();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPageContent(page);
                },
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('पीछे'),
                      ),
                    ),
                  
                  if (_currentPage > 0) const SizedBox(width: 16),
                  
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextPage,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_currentPage == _pages.length - 1 ? 'खेल शुरू करें' : 'आगे'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              page.icon,
              size: 50,
              color: AppTheme.primaryGreen,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description or Form
          if (page.isForm) ...[
            _buildForm(),
          ] else ...[
            Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'आपका नाम',
            hintText: 'जैसे: राम कुमार',
            prefixIcon: Icon(Icons.person),
          ),
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _villageController,
          decoration: const InputDecoration(
            labelText: 'गाम का नाम',
            hintText: 'जैसे: रामपुर',
            prefixIcon: Icon(Icons.location_on),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _nextPage(),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'आपकी जानकारी सुरक्षित रहेगी और केवल खेल के लिए इस्तेमाल होगी।',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String voiceText;
  final bool isForm;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.voiceText,
    this.isForm = false,
  });
}