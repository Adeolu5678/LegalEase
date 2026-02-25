# Changelog

All notable changes to LegalEase will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-02-25

### Added

#### Export Options (Phase 1.1)
- PDF export for document analyses with professional formatting
- Customizable export options (include summary, red flags, original text)
- Export to Counsel feature for emailing analyses to attorneys
- Pre-formatted cover letter and summary for legal professionals
- Share functionality via system share sheet

#### Legal Dictionary (Phase 1.2)
- Built-in legal terminology reference with 500+ terms
- Category-based organization (contracts, IP, employment, real estate, corporate, general)
- Plain English definitions with usage examples
- In-context term lookup during document analysis
- Related terms linking for exploration
- Favorites feature for quick reference
- Risk level indicators for terms

#### Confidence Scores (Phase 1.3)
- AI confidence ratings for each red flag detection
- Visual confidence bars (High/Medium/Low)
- Confidence badges on red flag cards
- `ConfidenceLevel` enum for standardized confidence levels
- `confidenceScore` field added to `RedFlag` and `RedFlagItem` models

#### Suggested Questions (Phase 1.4)
- AI-generated contextual questions about documents
- Quick-tap questions in chat interface
- Document type-aware question suggestions
- Suggested questions widget in chat screen
- Personalized suggestions based on analysis results

#### Export to Counsel (Phase 1.5)
- Direct email to attorney from analysis screen
- Customizable recipient and message
- Automatic attachment of analysis and original document
- Attorney contact presets for quick access
- Email template preferences

#### Smart Reminders (Phase 2.3)
- Contract deadline tracking and alerts
- Automatic date extraction from documents
- Multiple reminder timing options (day of, 1 day, 3 days, 1 week, 1 month before)
- Push notification support
- Email reminder option
- Smart suggestions for detected important dates
- Reminder types: expiration, renewal, payment, custom

#### Voice Input (Phase 2.5)
- Speech-to-text for chat messages
- Real-time transcription display
- Multi-language support (English, Spanish, French, German, Italian, Portuguese, Japanese, Korean, Chinese)
- Voice commands for quick actions
- Editable transcription before sending
- Auto-send after pause option
- Voice feedback for responses

### Changed
- Enhanced `RedFlag` model with confidence scoring
- Updated `RedFlagItem` to include `confidenceScore` and `ConfidenceLevel`
- Improved `AiProvider` interface with new methods:
  - `detectRedFlagsWithConfidence()`
  - `generateSuggestedQuestions()`
  - `defineLegalTerm()`
- Enhanced chat interface with voice input and suggested questions
- Updated analysis result screen with confidence indicators

### Dependencies Added
- `pdf` package for PDF generation
- `printing` package for PDF preview and sharing
- `flutter_local_notifications` for reminders
- `speech_to_text` for voice input
- `timezone` for reminder scheduling

## [1.1.0] - 2026-02-15

### Added
- Custom persona engine for personalized AI responses
- Premium subscription with RevenueCat integration
- 4-page onboarding flow for new users
- Persona templates (Corporate Counsel, Friendly Advisor, Assertive Advocate, Technical Analyst, Plain English Translator)

### Changed
- Improved document analysis accuracy
- Enhanced UI with semantic color palette
- Better error handling and loading states

### Fixed
- Memory leaks in T&C scanner
- Race conditions in AI provider switching
- PDF rendering issues on older devices

## [1.0.0] - 2026-02-01

### Added
- Deep-scan document analysis with OCR
- Multi-provider AI integration (Gemini, OpenAI, Anthropic)
- Red flag detection with severity levels
- Plain English translation of legal documents
- Document Q&A chat
- On-screen T&C scanner (Android accessibility service)
- iOS keyboard extension for text analysis
- Safari extension for T&C scanning
- Desktop writing assistant (Windows/macOS)
- Firebase authentication (Email, Google, Apple, Anonymous)
- Firestore document storage
- Light/dark theme support
- Multi-platform support (Android, iOS, Web, Windows, macOS)

### Platform-Specific Features
- **Android**: Accessibility service for on-screen T&C detection
- **iOS**: Custom keyboard and Safari extension
- **Desktop**: Real-time writing assistant overlay

---

## Upcoming Features (Roadmap)

### Phase 2.8 - Comments & Notes (Beta)
- Document annotations and highlights
- User notes on specific clauses
- Collaboration features

### Phase 2.4 - Multi-language Support
- Localization for multiple languages
- Translated UI and content
- RTL support

### Phase 2.1 - Advanced Search
- Full-text search across documents
- Advanced filtering and sorting
- Search history

### Phase 2.2 - Document Comparison
- Side-by-side document diff
- Highlighting differences
- Version tracking

### Phase 2.6 - Template Library
- Contract templates
- Legal document templates
- Custom template creation

### Phase 2.7 - Share Analysis
- Public sharing links
- Expiring share links
- Access control

### Phase 3.1 - Cloud Integration
- Google Drive integration
- Dropbox integration
- OneDrive integration
- Direct cloud document import

### Phase 3.2 - Offline Mode
- Local document caching
- Offline analysis queue
- Background sync

### Phase 3.3 - Team Workspaces
- Shared document libraries
- Team collaboration
- Role-based access control
