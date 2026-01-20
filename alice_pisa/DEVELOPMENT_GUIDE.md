# Alice Pisa - Development Guide

## Project Overview
Alice Pisa is a gamified financial literacy app focused on behavior-driven learning through consequence-based gameplay. The farmer persona prototype demonstrates the core game mechanics.

## Architecture

### Core Components

1. **Game State Management** (`lib/core/game_state_manager.dart`)
   - Manages farmer state, seasons, and game progression
   - Handles decision-making and consequence calculation
   - Tracks financial health and stress levels

2. **Models** (`lib/models/`)
   - `farmer.dart`: Farmer entity with financial state
   - `season.dart`: Season types, crops, and events

3. **Services** (`lib/services/`)
   - `tts_service.dart`: Voice guidance with emotional context
   - `local_storage_service.dart`: Offline data persistence

4. **Screens** (`lib/screens/`)
   - `splash_screen.dart`: App initialization
   - `onboarding_screen.dart`: User setup and introduction
   - `farmer_dashboard.dart`: Main game interface
   - `season_planning_screen.dart`: Crop selection and planning

5. **Widgets** (`lib/widgets/`)
   - `financial_status_card.dart`: Real-time financial display
   - `season_progress_card.dart`: Game progression tracking
   - `stress_indicator.dart`: Emotional feedback system
   - `quick_action_buttons.dart`: Navigation shortcuts

## Key Features Implemented

### ✅ Behavior-Driven Learning
- **Decision → Outcome → Emotion → Reflection** loop
- Real-time stress indicators based on financial decisions
- Consequence-based feedback without "game over"

### ✅ Farmer Persona Simulation
- Seasonal income patterns (Kharif, Rabi, Zaid)
- Realistic crop economics with risk factors
- Weather and market event system

### ✅ Emotional Feedback System
- Visual stress indicators (calm → worried → stressed → desperate)
- Voice prompts with emotional context
- Color-coded financial health display

### ✅ Offline-First Architecture
- Local SQLite database for game state
- SharedPreferences for settings
- Works without internet connection

### ✅ Voice-First Interface
- Hindi/English TTS integration
- Contextual voice guidance
- Emotional speech modulation

### ✅ Rural-Friendly Design
- Large touch targets (48dp minimum)
- High contrast colors
- Icon-driven navigation
- Minimal text dependency

## Game Flow

```
1. Splash Screen → Initialize services
2. Onboarding → Farmer setup (name, village)
3. Dashboard → Season overview, financial status
4. Planning → Crop selection, area planning
5. Growing → Events and decisions
6. Harvest → Results calculation
7. Reflection → Learning summary
8. Next Season → Cycle continues
```

## Financial Mechanics

### Income Simulation
- Seasonal patterns (80% at harvest, 20% ongoing)
- Crop-specific yields and market prices
- Weather and event modifiers

### Expense Categories
- Essential: Seeds, fertilizer, family needs
- Optional: Insurance, better inputs
- Emergency: Medical, repairs

### Stress Calculation
```dart
double financialHealth = (totalWealth - debt) / (income + savings + 1)
StressLevel = f(financialHealth, debt_ratio, savings_ratio)
```

## Event System

### Event Types
- **Weather**: Drought, flood, cold wave, heat wave
- **Market**: Price crashes, price booms
- **Health**: Medical emergencies
- **Social**: Festivals, celebrations
- **Government**: Subsidies, policy changes
- **Pest**: Crop diseases, pest attacks

### Event Structure
```dart
GameEvent {
  String title, description;
  EventType type;
  double probability;
  Map<String, dynamic> impact;
  List<EventChoice> choices;
}
```

## Next Development Steps

### Phase 2: Enhanced Gameplay
- [ ] Complete event handling system
- [ ] Loan and credit mechanics
- [ ] Insurance claim processing
- [ ] Market price fluctuations
- [ ] Weather prediction system

### Phase 3: Learning Analytics
- [ ] Decision tracking and analysis
- [ ] Learning progress measurement
- [ ] Personalized tips and guidance
- [ ] Behavioral pattern recognition

### Phase 4: Additional Personas
- [ ] Woman persona (household budgeting)
- [ ] Student persona (pocket money management)
- [ ] Young Adult persona (salary and investments)

### Phase 5: Social Features
- [ ] Community challenges
- [ ] Peer comparison (anonymous)
- [ ] Success story sharing
- [ ] Mentor system

## Technical Improvements

### Performance
- [ ] Image optimization for low-end devices
- [ ] Lazy loading for large datasets
- [ ] Background processing for calculations

### Accessibility
- [ ] Screen reader support
- [ ] High contrast mode
- [ ] Font size adjustment
- [ ] Voice command integration

### Localization
- [ ] Regional language support
- [ ] Local crop varieties
- [ ] Regional economic contexts
- [ ] Cultural adaptation

## Testing Strategy

### Unit Tests
- Game state management logic
- Financial calculation accuracy
- Event probability systems

### Integration Tests
- Database operations
- TTS service integration
- Screen navigation flows

### User Testing
- Rural user feedback sessions
- Accessibility testing
- Performance on low-end devices

## Deployment Considerations

### Minimum Requirements
- Android 6.0+ (API 23)
- 2GB RAM
- 100MB storage
- Optional: Internet for cloud sync

### Distribution
- Google Play Store
- APK sideloading for rural areas
- Offline installer packages

### Analytics
- Decision tracking (anonymized)
- Learning outcome measurement
- Performance monitoring
- Crash reporting

## Contributing

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names in English
- Comment complex business logic
- UI text in Hindi/local language

### Git Workflow
- Feature branches for new functionality
- Pull requests for code review
- Semantic versioning for releases

### Documentation
- Update this guide for major changes
- Document new game mechanics
- Maintain API documentation
- User guide in local language

## Resources

### Design Assets
- Icons: Material Design + custom rural icons
- Colors: Earth-tone palette for rural context
- Fonts: Poppins for readability
- Sounds: Natural, non-intrusive audio cues

### Data Sources
- Crop prices: Government agricultural databases
- Weather patterns: Meteorological data
- Economic indicators: Rural development statistics

### Research References
- Behavioral economics principles
- Gamification best practices
- Rural UX design guidelines
- Financial literacy research