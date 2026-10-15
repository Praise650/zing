# Zing — AI-Powered Study Companion

> *"Snap your notes. Spark your brain."*

**Zing** is a modern, polished, AI-powered learning application designed for Flutter (iOS and Android). It helps students and self-learners instantly transform raw study materials—notes, PDFs, and pasted text—into structured summaries, active-recall flashcards, interactive quizzes, and measurable learning progress.

---

## Table of Contents
1. [Brand Identity & Core Concept](#brand-identity--core-concept)
2. [Project Setup & Installation](#project-setup--installation)
3. [Directory Structure](#directory-structure)
4. [Part 1: UI/UX & Design System Brief](#part-1-uiux--design-system-brief)
5. [Part 2: Technical Logic & Architecture Brief](#part-2-technical-logic--architecture-brief)
6. [Implementation Stages](#implementation-stages)
7. [Quality & Acceptance Criteria](#quality--acceptance-criteria)

---

## Brand Identity & Core Concept

The name **Zing** represents an instant electric response in the brain—a snap of the fingers that jolts curiosity, ignites focus, and transforms complex information into active mental energy.

* **Tagline:** *Snap your notes. Spark your brain.*
* **Visual Personality:** Clean, intelligent, high-energy yet calm, highly legible, and free from administrative clutter.
* **Target Audience:** University/secondary students, self-taught tech learners, and certification candidates.

---

## Project Setup & Installation

### Prerequisites
* **Flutter SDK:** $\ge 3.19.0$
* **Dart SDK:** $\ge 3.3.0$
* iOS Simulator / Android Emulator or physical test device

### Getting Started

```bash
# Clone the repository
git clone https://github.com/your-org/zing-app.git

# Navigate into the project folder
cd zing-app

# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Launch the application
flutter run
```

---

## Directory Structure

Zing uses a feature-oriented, domain-separated architecture designed for scalability and maintainability:

```text
lib/
├── app/
│   ├── app.dart              # MaterialApp configuration & theme setup
│   ├── router.dart           # GoRouter route definitions & ShellRoute tabs
│   └── theme/
│       ├── app_colors.dart   # Brand and semantic color definitions
│       ├── app_radius.dart   # Corner radii design tokens
│       ├── app_spacing.dart  # Spacing scale tokens (Base 4)
│       ├── app_theme.dart    # Light & Dark ThemeData builders
│       └── app_typography.dart # Inter typography scale
├── core/
│   ├── constants/            # Global constants & key definitions
│   ├── extensions/           # BuildContext & String utility extensions
│   ├── utilities/            # Calculation helpers & formatters
│   └── widgets/              # Reusable design system UI components
├── features/
│   ├── authentication/       # Sign in, Sign up, Forgot password
│   ├── flashcards/           # Flip animation, card queue, confidence rating
│   ├── home/                 # Dashboard, streak bar, study recommendations
│   ├── library/              # Material collection, search & multi-filter
│   ├── materials/            # Import pipeline (PDF, text), upload mock engine
│   ├── onboarding/           # Value proposition carousel & welcome flow
│   ├── profile/              # User settings, goals, theme toggles
│   ├── progress/             # Analytics dashboard, weekly charts, badges
│   ├── quizzes/              # Multiple-choice quiz engine & score screens
│   └── summaries/            # Reading-focused AI summary viewer
└── main.dart                 # Application entrypoint
```

---

## Part 1: UI/UX & Design System Brief

### 1. Visual Direction & Design Tokens
Built on **Material 3 foundations** with a distinct consumer-learning product identity.

#### Color Tokens
* **Primary Brand:** `#6257E8` (Primary), `#4539B5` (Primary Dark), `#F0EEFF` (Primary Surface)
* **Secondary:** `#8B7CF6`
* **Surfaces & Backgrounds:** `#F8F9FC` (App Background), `#FFFFFF` (Surface), `#191B2A` (Primary Text), `#6D7285` (Secondary Text), `#E6E8F0` (Border)
* **Feedback & Status:**
  * **Success & Streaks:** `#159A72` (Success), `#E8F8F1` (Surface)
  * **Warning & Reminders:** `#E9A23B` (Warning), `#FFF5E5` (Surface)
  * **Error:** `#D94A55` (Error), `#FFF0F1` (Surface)
  * **Information:** `#3978D4`

#### Typography (Inter Font Family)
* **Display Headings:** $28\text{pt}$ / Bold / Line Height $1.2$
* **Screen Titles:** $22\text{pt}$ / SemiBold / Line Height $1.25$
* **Section Headings:** $18\text{pt}$ / SemiBold / Line Height $1.3$
* **Card Titles / Subtitles:** $16\text{pt}$ / Medium / Line Height $1.35$
* **Body Text:** $14\text{pt}$ / Regular / Line Height $1.5$ (Optimized for comfortable long-form summary reading)
* **Captions & Metadata:** $12\text{pt}$ / Medium / Line Height $1.4$
* **Buttons & Labels:** $14\text{pt}$ / SemiBold / Tracking $0.2\text{px}$

#### Spacing & Layout Scale (Base 4)
* **Tokens:** `4`, `8`, `12`, `16`, `20`, `24`, `32`, `40`, `48` (pixels)
* **Constants:** Screen horizontal padding = `16px` or `20px`, Card padding = `16px`, Component gap = `12px`.

#### Shape & Elevation
* **Chips / Controls:** $8\text{px}$ radius
* **Text Inputs / Buttons:** $12\text{px}$ radius
* **Standard Cards:** $16\text{px}$ radius with subtle $1\text{px}$ border (`#E6E8F0`) and minimal soft elevation.
* **Bottom Sheets / Dialogs:** $24\text{px}$ top radius.

---

### 2. Required Screens & UX Flows

1. **Onboarding:**
   * Value proposition showcase ("Snap your notes into instant study decks").
   * Quick CTA: *Get Started* or *Sign In*.
2. **Authentication:**
   * Sign-In and Registration forms with password visibility toggles, form validation, and inline feedback.
3. **Home Dashboard:**
   * Personalized greeting & profile shortcut.
   * Active study streak widget (amber accent).
   * Prominent **+ Add Study Material** primary action.
   * "Continue Studying" card and quick AI triggers (*Summarize*, *Flashcards*, *Quiz*).
4. **Add Study Material:**
   * Import sources: PDF/Document upload, raw text paste, photo/scan note placeholder.
   * Interactive status states: *Selecting File* $\rightarrow$ *Uploading ($0-100\%$) * $\rightarrow$ *Processing AI* $\rightarrow$ *Ready / Error*.
5. **Material Details & AI Summary:**
   * Material title, file type metadata, and preview.
   * Summary tab displaying key concepts, bulleted takeaways, and actionable revision notes.
6. **Flashcards (Active Recall Engine):**
   * Smooth flip animation (Front: Question / Back: Answer).
   * Progress counter ($N$ of $M$ cards).
   * Confidence rating bar (*Again*, *Hard*, *Good*, *Easy*).
7. **Quiz Session:**
   * Question counter and progress bar.
   * Radio/card answer selection with instant selected states.
   * Completion screen displaying total score, review breakdown, and retry option.
8. **Library:**
   * Search bar with category filters (*All*, *Notes*, *PDFs*, *Summaries*, *Flashcards*).
   * Material card grid/list with document type icons.
9. **Progress & Analytics:**
   * Study time counters, flashcards reviewed, quiz averages, and active streak.
   * Weekly study activity chart visualization.
10. **Profile & Settings:**
    * Preferences, daily study goals, notification triggers, theme switchers (Light/Dark mode), and logout.

---

## Part 2: Technical Logic & Architecture Brief

### 1. Data Layer & Entities

```dart
enum MaterialType { pdf, note, pastedText, scan }
enum ProcessingStatus { idle, uploading, processing, ready, failed }
enum ConfidenceRating { again, hard, good, easy }

class StudyMaterial {
  final String id;
  final String title;
  final MaterialType type;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final ProcessingStatus status;
  final String? summaryText;
  final List<Flashcard>? flashcards;
  final List<QuizQuestion>? questions;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.lastAccessed,
    this.status = ProcessingStatus.idle,
    this.summaryText,
    this.flashcards,
    this.questions,
  });
}

class Flashcard {
  final String id;
  final String question;
  final String answer;
  ConfidenceRating? lastRating;

  Flashcard({required this.id, required this.question, required this.answer, this.lastRating});
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  int? selectedOptionIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.selectedOptionIndex,
  });
}
```

---

### 2. Business Logic & State Rules

1. **Simulated AI Processing Pipeline:**
   * Upload progress updates over $1.5\text{s}$ using `Stream` or `Future.delayed`.
   * AI processing takes $3.0\text{s}$, transitioning `ProcessingStatus` from `uploading` $\rightarrow$ `processing` $\rightarrow$ `ready`.
2. **Flashcard Review Engine:**
   * Tracks deck position (`currentIndex` / `totalCards`).
   * Card flipping operates on local widget state to prevent full-screen rebuilds.
   * Submitting a rating (`ConfidenceRating`) advances the queue and updates the global `UserProgress` model.
3. **Quiz Calculation Engine:**
   * Answer locking: Once an answer option is clicked, the selection is locked for that question to prevent accidental resubmission.
   * Score formula:
     $$\text{Score (\%)} = \left( \frac{\text{Number of Correct Answers}}{\text{Total Questions}} \right) \times 100$$
4. **Library Search & Filtering:**
   * Query filter matches against material titles and summary text keywords.
   * Functional category filter:
     `materials.where((item) => selectedFilter == Filter.all || item.type == selectedFilter.type)`

---

## Implementation Stages

* **Stage 1: Design Tokens & Base Components** — Implement `AppColors`, `AppTypography`, `AppTheme`, and reusable core widgets (`ZingButton`, `ZingTextField`, `ZingCard`).
* **Stage 2: Shell & Core Navigation** — Build `GoRouter` shell route with bottom navigation, Onboarding, Authentication, and Home Dashboard screens.
* **Stage 3: Import Pipeline & AI Summaries** — Build document import flow, simulated AI delay state machine, and reading-focused summary viewer.
* **Stage 4: Flashcards & Quiz Engine** — Implement flip animations, confidence scoring queue, interactive multiple-choice quiz logic, and completion screens.
* **Stage 5: Library, Progress & Profile** — Build searchable material repository, weekly chart visualization, and settings tab.
* **Stage 6: Dark Mode & Refinements** — Verify dark theme token mapping, safe area handling, keyboard interaction, and run `flutter analyze`.

---

## Quality & Acceptance Criteria

* ✅ Zero hardcoded magic numbers or raw hex colors inside feature screens.
* ✅ All mock user interactions (card flips, quiz selection, filter switching, file uploads) function seamlessly.
* ✅ Smooth light and dark mode switching supported globally.
* ✅ Responsive across common Android and iOS phone viewport sizes without text clipping or overflow errors.
* ✅ Clean codebase passing `flutter analyze` without errors.