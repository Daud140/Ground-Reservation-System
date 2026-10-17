# GROUNDZERO FLUTTER APP - COMPLETE CODE EXPLANATION
# VIVA PREPARATION GUIDE - PART 1 of 2
# Every File, Every Line, Every Widget Explained

---

## TABLE OF CONTENTS

1. Project Overview
2. Tech Stack and Dependencies (pubspec.yaml)
3. Project Folder Structure
4. Entry Point - main.dart
5. CORE Layer
   - 5.1 AppColors
   - 5.2 AppStrings
   - 5.3 AppAssets
   - 5.4 Router - AppRouter and RouteNames
   - 5.5 Storage - HiveBoxes and LocalStorageService
   - 5.6 Theme - AppTheme and ThemeProvider
6. DATA Layer
   - 6.1 Demo Data
   - 6.2 Repositories

---

## 1. PROJECT OVERVIEW

GroundZero is a Flutter mobile application for booking sports grounds in Rawalpindi and Islamabad, Pakistan.

### What the app does:
- Authentication: Sign In / Sign Up with email, or one-tap Demo Login
- Browse Grounds: Explore 8 sports venues (Futsal, Football, Cricket, Padel, Tennis, Basketball)
- Book Slots: Select a date and time slot, confirm with QR code ticket
- AI Assistant: Offline GroundBot AI chatbot to find and recommend grounds
- Owner Panel: Ground owners see dashboard, manage bookings, add/edit grounds
- Dark Mode: Full dark/light theme toggle, persisted in Hive
- Favorites: Save favorite grounds locally

### Two User Roles:
- CUSTOMER (Player): Browse -> Search -> View Detail -> Book Slot -> Get Ticket -> Chat with GroundBot
- OWNER: Dashboard Analytics -> View Booking Requests -> Approve/Reject -> Manage Grounds

---

## 2. TECH STACK AND DEPENDENCIES

File: pubspec.yaml

flutter_riverpod: ^3.4.3   - State management
go_router: ^18.0.2          - Navigation / routing
hive: ^2.2.3                - Local database (NoSQL key-value store)
hive_flutter: ^1.1.0        - Hive adapter for Flutter
google_fonts: ^9.0.0        - Plus Jakarta Sans font
fl_chart: ^1.2.0            - Charts in owner dashboard
qr_flutter: ^4.1.0          - QR code generator for booking tickets
shimmer: ^4.0.0             - Shimmer loading effects
intl: ^0.20.3               - Date formatting
uuid: ^4.6.0                - Unique ID generation for bookings

### Why each package:
flutter_riverpod -> Manages app state (auth, theme, data) | Used in: auth_provider, theme_provider
go_router -> Handles screen navigation with URL-like paths | Used in: app_router.dart
hive -> Stores users, grounds, bookings offline (no internet needed) | Used in: local_storage_service.dart
google_fonts -> Beautiful Plus Jakarta Sans font instead of default | Used in: app_theme.dart
fl_chart -> Bar/line charts for owner revenue analytics | Used in: owner_dashboard_screen.dart
qr_flutter -> Generates scannable QR codes for booking passes | Used in: booking_confirmation_screen.dart
shimmer -> Skeleton loading animation while data loads | Used in: customer_home_screen.dart
intl -> Formats dates like "Oct 15, 2026" | Used in: slot_booking_screen.dart
uuid -> Generates unique IDs like GZ-abc123 for bookings | Used in: slot_booking_screen.dart

---

## 3. PROJECT FOLDER STRUCTURE

ground_zero/
- lib/
  - main.dart                         <- App entry point
  - core/
    - constants/
      - app_colors.dart               <- All brand colors
      - app_strings.dart              <- All text strings
      - app_assets.dart               <- Asset image paths
    - router/
      - app_router.dart               <- Navigation setup (GoRouter)
      - route_names.dart              <- Route path strings
    - storage/
      - hive_boxes.dart               <- Hive box name constants
      - local_storage_service.dart    <- Database operations
    - theme/
      - app_theme.dart                <- Light and Dark ThemeData
      - theme_provider.dart           <- Theme toggle state
  - data/
    - demo/
      - demo_data.dart                <- Hardcoded seed data (users, grounds, bookings)
    - repositories/
      - auth_repository.dart          <- Auth operations (sign in, sign up)
      - ground_repository.dart        <- Ground CRUD operations
      - booking_repository.dart       <- Booking CRUD + slot check
      - review_repository.dart        <- Reviews fetch/add
      - ai_repository.dart            <- AI chatbot logic
      - repository_providers.dart     <- Riverpod providers for repos
  - features/
    - auth/
      - models/user_model.dart
      - providers/auth_provider.dart
      - screens/ (onboarding, login, role_selection)
    - customer/
      - models/ (ground_model, review_model)
      - screens/ (home, explore, bookings, detail, profile, main_shell)
    - booking/
      - models/booking_model.dart
      - screens/ (slot_booking, booking_confirmation)
    - ai/
      - models/chat_message_model.dart
      - screens/ai_assistant_screen.dart
    - owner/
      - screens/ (dashboard, booking_requests, ground_management, main_shell)
    - shared/
      - widgets/ (app_logo, google_icon, mini_map_preview, runner_illustration, stadium_illustration)
- assets/
  - images/  <- Ground photos
  - icons/   <- App icons
- pubspec.yaml <- Dependencies

Design Pattern Used: Feature-first Clean Architecture
- core = Framework/Infrastructure
- data = Repositories (data access)
- features = UI Screens + State

---

## 4. ENTRY POINT - main.dart

File: lib/main.dart

CODE:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  runApp(const ProviderScope(child: GroundZeroApp()));
}

### Line by Line:
Line 1 - WidgetsFlutterBinding.ensureInitialized():
  - Must be called FIRST before any async code in main()
  - It connects the Flutter engine to the Dart framework
  - Without this, calling async code before runApp() causes an error

Line 2 - await LocalStorageService.instance.init():
  - Initializes the Hive local database
  - Seeds demo data (users, grounds, bookings) if first run
  - await means we wait for it to complete before starting the app

Line 3 - ProviderScope(...):
  - Required wrapper for Riverpod state management
  - ALL providers must be inside ProviderScope
  - Without this, accessing any provider causes an error

Line 4 - GroundZeroApp():
  - The root widget of the entire app

### GroundZeroApp Widget:
class GroundZeroApp extends ConsumerWidget {
  - ConsumerWidget = Riverpod stateless widget that can call ref.watch()
  
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);   <- Watches dark/light mode
    final router = ref.watch(appRouterProvider);   <- Gets the GoRouter instance
    
    return MaterialApp.router(
      title: 'GroundZero',
      debugShowCheckedModeBanner: false,  <- Hides the red DEBUG banner
      theme: AppTheme.lightTheme,         <- Light theme definition
      darkTheme: AppTheme.darkTheme,      <- Dark theme definition
      themeMode: themeMode,               <- Switches between light/dark
      routerConfig: router,               <- GoRouter handles all navigation
    );
  }
}

MaterialApp.router: Uses GoRouter instead of default Flutter Navigator
themeMode: When ThemeMode.dark uses darkTheme, otherwise lightTheme

---

## 5. CORE LAYER

### 5.1 AppColors - File: lib/core/constants/app_colors.dart

This class holds ALL colors used in the app.
class AppColors {
  AppColors._(); <- Private constructor - cannot create an instance (utility class)

Brand Colors:
  emerald        = #10B981 -> Primary buttons, active icons, highlights
  emeraldDark    = #059669 -> Darker shade for pressed states
  emeraldLight   = #34D399 -> Light accent
  emeraldContainer = #D1FAE5 -> Background of selected chips/cards
  navy           = #0F172A -> Text, dark background, logo text
  navyLight      = #1E293B -> Dark surface cards
  lime           = #A3E635 -> Accent color in dark mode secondary

Background Colors:
  backgroundLight = #F8FAFC -> Scaffold background in light mode
  surfaceLight    = #FFFFFF -> Cards, input fields
  surfaceSecondaryLight = #F1F5F9 -> Input fill, secondary containers
  backgroundDark  = #0B1120 -> Scaffold in dark mode
  surfaceDark     = #0F172A -> Cards in dark mode

Semantic Status Colors:
  success = #10B981 -> Confirmed booking (green)
  warning = #F59E0B -> Pending booking (yellow/amber)
  error   = #EF4444 -> Rejected/error (red)
  info    = #3B82F6 -> Completed/info (blue)

Gradients (used in BoxDecoration gradient: property):
  emeraldGradient      -> Green to Dark Green (logo, buttons)
  limeEmeraldGradient  -> Yellow-Green to Green (accent cards)
  navyGradient         -> Deep Navy to Light Navy (dark cards)
  darkCardGradient     -> Light Navy to Deep Navy (dark card backgrounds)

VIVA TIP: If sir says "change the primary color to blue":
  Change: static const Color emerald = Color(0xFF10B981);
  To:     static const Color emerald = Color(0xFF3B82F6);
  Result: The ENTIRE app updates because everything references AppColors.emerald!

---

### 5.2 AppStrings - File: lib/core/constants/app_strings.dart

All text labels in one place. Change a label here -> updates everywhere.

static const String appName = 'GroundZero';
static const String appTagline = 'Book Your Arena in Seconds';
static const String currency = 'PKR';
static const String currencyPrefix = 'PKR ';
static const String aiAssistantName = 'GroundBot AI';
static const String aiTagline = 'Your Smart Sports Concierge';

Navigation labels: navHome, navSearch, navBookings, navDashboard, navGrounds, navRequests

Auth strings: welcomeBack, signInSubtitle, createAccount, demoCustomerLogin, demoOwnerLogin

---

### 5.3 AppAssets - File: lib/core/constants/app_assets.dart

Path strings for ground images stored in assets/images/ folder.

static const String groundFutsalRawal     = 'assets/images/ground_futsal_rawal.jpg';
static const String groundFootballMargalla = 'assets/images/ground_football_margalla.jpg';
static const String groundPadelIslamabad  = 'assets/images/ground_padel_islamabad.jpg';
static const String groundCricketAyub     = 'assets/images/ground_cricket_ayub.jpg';
static const String groundCentaurusFutsal = 'assets/images/ground_centaurus_futsal.jpg';
static const String groundTennisCapital   = 'assets/images/ground_tennis_capital.jpg';
static const String groundChaklalaTurf    = 'assets/images/ground_chaklala_turf.jpg';
static const String groundBasketballBahria= 'assets/images/ground_basketball_bahria.jpg';

These are referenced in demo_data.dart when creating GroundModel objects.
All paths must also be declared in pubspec.yaml under flutter -> assets.

---

### 5.4 Router - AppRouter and RouteNames

File: lib/core/router/route_names.dart

URL-like path constants:
static const String splash        = '/';
static const String onboarding    = '/onboarding';
static const String login         = '/login';
static const String roleSelection = '/role-selection';
static const String customerRoot  = '/customer';
static const String groundDetails = '/customer/ground/:id';    <- :id is a dynamic parameter
static const String slotBooking   = '/customer/book/:id';
static const String confirmationTicket = '/customer/ticket/:bookingId';
static const String aiAssistant   = '/customer/ai-assistant';
static const String ownerRoot     = '/owner';

File: lib/core/router/app_router.dart

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);  <- Reacts when auth state changes
  return GoRouter(
    initialLocation: AppRoutes.splash,        <- Start at '/'
    redirect: (context, state) { ... },        <- Route guard
    routes: [ ... ],                           <- All screen routes
  );
});

THE REDIRECT FUNCTION (Route Guard):
This function runs before EVERY navigation. It decides whether to allow or redirect:

Logic:
1. If user NOT logged in AND trying private page -> redirect to '/login'
2. If user IS logged in AND currently on '/' (splash) -> redirect to '/customer' or '/owner'
3. Otherwise -> return null (allow navigation to proceed normally)

ROUTE DEFINITIONS:
Each GoRoute maps a URL path to a Widget (Screen):

Path '/'                           -> OnboardingScreen()
Path '/onboarding'                 -> OnboardingScreen()
Path '/login'                      -> LoginScreen()
Path '/role-selection'             -> RoleSelectionScreen()
Path '/customer'                   -> CustomerMainShell()
Path '/customer/ground/:id'        -> GroundDetailScreen(groundId: id)
Path '/customer/book/:id'          -> SlotBookingScreen(groundId: id)
Path '/customer/ticket/:bookingId' -> BookingConfirmationScreen(bookingId, bookingExtra)
Path '/customer/ai-assistant'      -> AiAssistantScreen()
Path '/owner'                      -> OwnerMainShell()

NAVIGATION COMMANDS:
context.go('/customer')            -> Replace entire stack (no back button)
context.push('/customer/ground/ground_1') -> Push on stack (back button works)
context.pop()                      -> Go back to previous screen

DYNAMIC PARAMETERS:
// In router:
GoRoute(path: '/customer/ground/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'] ?? 'ground_1';
    return GroundDetailScreen(groundId: id);
  })

// When navigating:
context.push('/customer/ground/${ground.id}');

PASSING EXTRA DATA:
// Sender:
context.push('/customer/ticket/${booking.id}', extra: booking);

// Receiver in router:
final bookingExtra = state.extra as BookingModel?;

VIVA TIP: "How to add a new screen?"
Step 1: Add route string to route_names.dart
Step 2: Add GoRoute() in app_router.dart
Step 3: Create the screen .dart file
Step 4: Navigate with context.go() or context.push()

---

### 5.5 Storage - HiveBoxes and LocalStorageService

File: lib/core/storage/hive_boxes.dart

Box names (think of them as "table names" in a database):
static const String usersBox     = 'groundzero_users';
static const String groundsBox   = 'groundzero_grounds';
static const String bookingsBox  = 'groundzero_bookings';
static const String reviewsBox   = 'groundzero_reviews';
static const String settingsBox  = 'groundzero_settings';
static const String favoritesBox = 'groundzero_favorites';

File: lib/core/storage/local_storage_service.dart

SINGLETON PATTERN - only ONE instance exists throughout the app:
static final LocalStorageService instance = LocalStorageService._();
This means: LocalStorageService.instance is always the same object.

init() METHOD:
1. Calls Hive.initFlutter() - sets up Hive for Flutter (finds the storage path)
2. Opens all 6 boxes in parallel using Future.wait([...])
3. Checks 'is_seeded_v1' flag in settingsBox
4. If flag is false -> calls seedDemoData() to populate initial data
5. Sets flag to true so it won't seed again

seedDemoData() METHOD:
1. Clears all existing records from users, grounds, bookings, reviews boxes
2. Loops through DemoData.users -> saves each as JSON string
3. Loops through DemoData.grounds -> saves each as JSON string
4. Loops through DemoData.bookings -> saves each as JSON string
5. Loops through DemoData.reviews -> saves each as JSON string
6. Marks is_seeded_v1 = true

HOW DATA IS STORED IN HIVE:
await usersBox.put(user.id, jsonEncode(user.toJson()));
- Key: user.id (e.g., "owner_1")
- Value: JSON string (e.g., '{"id":"owner_1","name":"Tariq Mehmood",...}')

WHY JSON STRING? Hive cannot store complex Dart objects without TypeAdapters.
Using jsonEncode/jsonDecode is simpler for mid-term demos.

Auth Session Management Methods:
getCurrentUser() -> Reads 'current_session_user' from settingsBox, deserializes JSON
saveCurrentUser(user) -> Writes JSON to settingsBox['current_session_user']
clearSession() -> Deletes 'current_session_user' key (logout)

Favorites Management Methods:
getFavoriteGroundIds() -> Returns all keys in favoritesBox as List<String>
isFavorite(groundId) -> Checks if groundId key exists in favoritesBox
toggleFavorite(groundId) -> Adds key if not present, deletes key if present

resetDemoData() METHOD:
- Clears favorites
- Calls seedDemoData() again (resets to original state)
- Used by "Reset Demo Data" button in profile screen

---

### 5.6 Theme - AppTheme and ThemeProvider

File: lib/core/theme/app_theme.dart

AppTheme provides TWO complete Material 3 themes.

CONSTANTS:
static const double cardRadius   = 20.0;  <- All card corners rounded 20px
static const double buttonRadius = 16.0;  <- Button border radius
static const double inputRadius  = 14.0;  <- TextField border radius

SHADOW GETTERS:
softShadowLight  -> Subtle 2-layer shadow for cards in light mode
softShadowDark   -> Black shadow for dark mode
floatingShadowLight -> Stronger shadow for floating elements like bottom nav

LIGHT THEME - AppTheme.lightTheme:
- useMaterial3: true -> Uses Material Design 3
- fontFamily: Plus Jakarta Sans (via Google Fonts)
- colorScheme:
    primary = emerald (#10B981) -> Used by ElevatedButton, progress indicators, etc.
    secondary = navy (#0F172A)
    error = red (#EF4444)
    surface = white (#FFFFFF)
    scaffoldBackground = #F8FAFC
- textTheme: All text styles (displayLarge, headlineLarge, bodyMedium, etc.)
- appBarTheme: Transparent, no elevation
- cardTheme: 20px radius, no elevation, 1px border
- inputDecorationTheme: Emerald focus border, 14px radius
- elevatedButtonTheme: Emerald background, 52px minimum height, 16px radius
- chipTheme: Pill shape (100px radius), emerald when selected
- dividerTheme: 1px thick

DARK THEME - AppTheme.darkTheme:
- Same structure as light theme
- Colors switched: dark backgrounds, light text, lime as secondary accent

File: lib/core/theme/theme_provider.dart

class ThemeNotifier extends Notifier<ThemeMode> {
  ThemeMode build() {
    // On startup, read isDarkMode from Hive settingsBox
    final isDark = box.get('isDarkMode', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
  
  void toggleTheme() {
    // Switch between light and dark
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    box.put('isDarkMode', newMode == ThemeMode.dark);  // Save to Hive
  }
  
  void setTheme(ThemeMode mode) {
    state = mode;
    box.put('isDarkMode', mode == ThemeMode.dark);  // Save to Hive
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

ThemeMode values:
- ThemeMode.light -> Uses AppTheme.lightTheme
- ThemeMode.dark  -> Uses AppTheme.darkTheme
- ThemeMode.system -> Follows phone setting (not used in this app)

Theme choice is PERSISTED IN HIVE so it survives app restarts.

VIVA TIP: "How does dark mode work?"
1. ThemeNotifier reads isDarkMode from Hive on startup
2. main.dart watches themeProvider -> passes themeMode to MaterialApp.router
3. When profile toggle is tapped -> themeProvider.notifier.toggleTheme()
4. This updates state -> MaterialApp rebuilds with new theme
5. New choice is saved to Hive automatically

---

## 6. DATA LAYER

### 6.1 Demo Data - File: lib/data/demo/demo_data.dart

Contains all hardcoded seed data for offline/mid-term version. 680 lines total.

USERS (5 total):
ID: owner_1    | Name: Tariq Mehmood | Email: owner@groundzero.pk          | Role: owner
ID: owner_2    | Name: Hamza Malik   | Email: hamza.owner@groundzero.pk    | Role: owner
ID: customer_1 | Name: Bilal Ahmed   | Email: customer@groundzero.pk       | Role: customer
ID: customer_2 | Name: Usman Khan    | Email: usman@groundzero.pk          | Role: customer
ID: customer_3 | Name: Saad Ali      | Email: saad@groundzero.pk           | Role: customer

GROUNDS (8 total):
ground_1 | Rawal Sports Arena   | Futsal     | F-7 Markaz, Islamabad         | PKR 3,500/hr
ground_2 | Margalla Turf Club   | Football   | E-11/4, Islamabad             | PKR 5,500/hr
ground_3 | Capital Padel Club   | Padel      | F-10, Islamabad               | PKR 4,200/hr
ground_4 | Ayub Cricket Ground  | Cricket    | Ayub Park, Rawalpindi         | PKR 6,000/hr
ground_5 | Centaurus Futsal     | Futsal     | Blue Area, Islamabad          | PKR 4,000/hr
ground_6 | Capital Tennis Courts| Tennis     | F-7, Islamabad                | PKR 2,800/hr
ground_7 | Chaklala Turf        | Football   | Chaklala, Rawalpindi          | PKR 3,200/hr
ground_8 | Bahria Basketball    | Basketball | Bahria Town, Rawalpindi       | PKR 2,500/hr

BOOKINGS: Pre-seeded with various statuses (pending, confirmed, completed, cancelled)
REVIEWS: Pre-seeded with star ratings and customer comments for each ground

---

### 6.2 Repositories and Repository Providers

#### THE REPOSITORY PATTERN:
Each repository has TWO versions:
1. Abstract class (interface) -> defines WHAT operations exist (contract)
2. MockXxxRepository -> uses Hive locally for offline demo
3. (Future) FirebaseXxxRepository -> would call Firestore/Firebase APIs

File: lib/data/repositories/repository_providers.dart

PROVIDERS:
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(); // <- Swap this ONE LINE for Firebase later
});

final groundRepositoryProvider   = Provider<GroundRepository>((ref) => MockGroundRepository());
final bookingRepositoryProvider  = Provider<BookingRepository>((ref) => MockBookingRepository());
final reviewRepositoryProvider   = Provider<ReviewRepository>((ref) => MockReviewRepository());
final aiRepositoryProvider       = Provider<AiRepository>((ref) => MockAiRepository());

SWITCHING TO FIREBASE (for final term):
Just change MockAuthRepository() to FirebaseAuthRepository()
Nothing else needs to change because the abstract class contract is the same!

AUTH REPOSITORY METHODS:
getCurrentUser()                                       -> Gets stored session user from Hive
signIn(email, password)                                -> Searches Hive for matching email
signUp(name, email, phone, password, role)             -> Creates new user, saves to Hive
signOut()                                              -> Clears session from Hive
quickDemoLogin(role)                                   -> Sets predefined demo user as session

NOTE: Password is NOT verified in the mock (any password works as long as email exists).
In real Firebase, firebase_auth handles password hashing and verification.

GROUND REPOSITORY METHODS:
getAllGrounds()                                         -> Returns all grounds from groundsBox
getGroundsByOwner(ownerId)                             -> Filters by owner
getGroundById(id)                                      -> Gets single ground
addGround(ground)                                      -> Creates new ground
updateGround(ground)                                   -> Updates existing ground
deleteGround(id)                                       -> Removes ground from storage
searchGrounds(query, sportType, maxPrice, minRating)   -> Multi-criteria filtering

SEARCH LOGIC (4 filters combined with AND logic):
1. Text query: ground.name.contains(q) OR ground.location.contains(q)
2. Sport type: ground.sportType == targetSportType
3. Max price: ground.pricePerHour <= maxPrice
4. Min rating: ground.rating >= minRating
All filters must pass for a ground to appear in results.

BOOKING REPOSITORY METHODS:
getAllBookings()                                        -> All bookings, sorted newest first
getBookingsForCustomer(customerId)                     -> Customer booking history
getBookingsForOwner(ownerId)                           -> Owner incoming requests
getBookingsForGroundAndDate(groundId, date)            -> Slots taken on specific date
isSlotAvailable(groundId, date, timeSlot)              -> Returns true if slot is free
createBooking(booking)                                 -> Validates then saves
updateBookingStatus(bookingId, newStatus)              -> Change status (confirm/reject)
cancelBooking(bookingId)                               -> Sets status to cancelled

DOUBLE BOOKING PREVENTION:
createBooking() works like this:
1. Calls isSlotAvailable(groundId, date, timeSlot)
2. isSlotAvailable checks ALL bookings for that ground+date
3. If ANY existing booking with status PENDING or CONFIRMED has same timeSlot -> returns false
4. If false -> throws Exception("Double-booking prevented: This slot is already reserved.")
5. The UI catches this exception and shows a red SnackBar to the user
6. If true -> saves the new booking to Hive

REVIEW REPOSITORY METHODS:
getReviewsForGround(groundId) -> Fetches all reviews for a ground, sorted newest first
addReview(review)             -> Saves new review to Hive reviewsBox

AI REPOSITORY - File: lib/data/repositories/ai_repository.dart

Abstract class AiRepository has 4 methods:
1. sendChatMessage(userMessage, allGrounds) -> Chatbot conversation
2. summarizeReviews(ground, reviews) -> Pros/cons summary
3. generateGroundDescription(name, sportType, location, facilities) -> Description text
4. generateOwnerInsights(bookings, grounds) -> Business recommendations

MockAiRepository uses KEYWORD MATCHING (not real NLP):

sendChatMessage() flow:
Step 1 - Detect sport from keywords:
  "futsal" or "football" -> SportType.futsal / SportType.football
  "cricket" -> SportType.cricket
  "padel" -> SportType.padel
  "tennis" -> SportType.tennis
  "basketball" -> SportType.basketball

Step 2 - Extract budget using Regex:
  Pattern: r'(?:under|below|less than|<|budget|around)\s*(\d{3,5})'
  Matches: "under 4000", "< 3500", "budget 3000", "around 2500"
  Extracts the number as a double

Step 3 - Detect location:
  isIslamabad = message contains "islamabad" OR "f-7" OR "e-11" OR "f-10" OR "blue area"
  isRawalpindi = message contains "rawalpindi" OR "pindi" OR "ayub" OR "chaklala" OR "bahria"

Step 4 - Filter grounds:
  allGrounds.where((g) {
    if sportType specified and g.sportType != targetSport -> exclude
    if budget specified and g.pricePerHour > budget -> exclude
    if islamabad and g.location doesnt contain islamabad -> exclude
    if rawalpindi and g.location doesnt contain rawalpindi -> exclude
    return true (include)
  })

Step 5 - Return ChatMessageModel with:
  - Reply text explaining what was found
  - groundIds of matched grounds (shown as cards in chat)
  - suggestionChips for quick replies

TO ADD REAL GEMINI AI:
Create GeminiCloudAiRepository implements AiRepository
Call: POST https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
Change repository_providers.dart: return GeminiCloudAiRepository();



# GROUNDZERO FLUTTER APP â€” VIVA PREPARATION GUIDE (PART 2)
### Features, Screens, Widgets, State Management, APIs, and Viva Defense Q&A

---

## 7. FEATURES LAYER â€” AUTHENTICATION

### 7.1 UserModel â€” File: `lib/features/auth/models/user_model.dart`

#### Enums:
```dart
enum UserRole { customer, owner }
```
- `customer`: Regular player who books arenas, searches grounds, and chats with GroundBot AI.
- `owner`: Facility manager who owns sports grounds, manages bookings, and tracks revenue.
- Getter `displayName`: Returns `"Customer"` or `"Ground Owner"`.

#### Class Fields:
- `id` (String): Unique user ID (e.g., `'customer_1'`, `'owner_1'`).
- `name` (String): User's full name (e.g., `'Bilal Ahmed'`, `'Tariq Mehmood'`).
- `email` (String): Login email address.
- `phone` (String): Contact phone number formatted with Pakistan code (`+92 321 9876543`).
- `role` (UserRole): Role assigned to the user.
- `avatarUrl` (String?): Optional profile picture URL.

#### Getters:
```dart
bool get isCustomer => role == UserRole.customer;
bool get isOwner => role == UserRole.owner;
```

#### Serialization & Immutability:
- `toJson()`: Serializes `UserModel` to `Map<String, dynamic>` for Hive NoSQL storage.
- `fromJson(Map<String, dynamic> json)`: Factory constructor deserializing stored JSON maps back to `UserModel`.
- `copyWith(...)`: Returns a new cloned instance with modified fields, preserving immutable state management required by Riverpod.

---

### 7.2 AuthProvider â€” File: `lib/features/auth/providers/auth_provider.dart`

#### `AuthState` Class:
```dart
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
}
```
- `user == null` indicates an unauthenticated guest.
- `isLoading`: Used across the UI to show circular spinners and disable action buttons.
- `errorMessage`: Captured upon failed sign-in/sign-up and rendered via `SnackBar`.

#### `AuthNotifier` Class (`extends Notifier<AuthState>`):
1. `build()`:
   - Sets initial state: `AuthState(isLoading: false)`.
   - Dispatches a microtask (`Future.microtask(...)`) to invoke `checkCurrentUser()`. This checks Hive storage asynchronously without blocking the initial widget tree build.
2. `checkCurrentUser()`:
   - Reads `LocalStorageService.instance.getCurrentUser()`.
   - If a valid session is found, populates `state = state.copyWith(user: user)`.
3. `signIn(String email, String password)`:
   - Sets `isLoading = true`.
   - Calls `authRepository.signIn(email, password)`.
   - Saves session into Hive; updates state; navigates role-specifically.
4. `signUp(String name, String email, String phone, String password, UserRole role)`:
   - Registers new user into Hive; automatically starts active session.
5. `quickDemoLogin(UserRole role)`:
   - Bypasses password entry and loads pre-seeded credentials (`customer_1` or `owner_1`) for one-tap viva demonstrations.
6. `signOut()`:
   - Deletes active session key from Hive; resets `AuthState` to default.

---

### 7.3 OnboardingScreen â€” File: `lib/features/auth/screens/onboarding_screen.dart`

- **Purpose**: App launch introduction highlighting core features.
- **Widgets Used**: `Scaffold`, `SafeArea`, `Column`, `Row`, `GestureDetector`, `AnimatedContainer`, `ElevatedButton`, `TextButton`, `RichText`.
- **Top Bar**: `GroundZeroLogo` paired with a "Skip" `TextButton` navigating directly to `/login`.
- **Hero Graphic**: Embeds `RunnerIllustrationWidget`, rendered via `CustomPainter`.
- **Feature Pills**: An interactive row with animated selection highlighting "Instant Turf Booking" and "AI Arena Concierge".
- **Call-to-Action**: Emerald `ElevatedButton` redirecting to `/role-selection` or `/login`.

---

### 7.4 LoginScreen â€” File: `lib/features/auth/screens/login_screen.dart`

- **Type**: `ConsumerStatefulWidget` (interacts with `authProvider` while keeping local controller states).
- **Controllers**:
  - `_emailController`: Defaults to `'customer@groundzero.pk'`.
  - `_passwordController`: Defaults to `'123456'`.
  - `_nameController`, `_phoneController`: Active when switching to "Sign Up" mode.
- **State Flags**:
  - `_isLoginTab`: Toggles between Login and Registration views.
  - `_obscurePassword`: Toggles password masking.
  - `_selectedRole`: Selects `UserRole.customer` or `UserRole.owner` during Sign Up.
- **Header**: Gradient Container (`#064E3B` to `#059669`) with `GroundZeroLogo` and "PK Edition" pill tag.
- **Tab Switcher**: Custom animated sliding toggle ("Sign In" vs "Create Account").
- **Quick Demo Access**:
  - Contains two dedicated buttons: **Demo Customer** and **Demo Owner**.
  - Invokes `ref.read(authProvider.notifier).quickDemoLogin(role)`.

---

### 7.5 RoleSelectionScreen â€” File: `lib/features/auth/screens/role_selection_screen.dart`

- Allows users to explicitly choose between:
  1. **Player / Customer Mode**: Displays `RunnerIllustrationWidget` with bullet points: instant confirmation, split bills, verified arenas.
  2. **Ground Owner Mode**: Displays `StadiumIllustrationWidget` with bullet points: real-time slot calendar, double-booking prevention, revenue analytics.

---

## 8. FEATURES LAYER â€” CUSTOMER

### 8.1 GroundModel & ReviewModel

#### `GroundModel` (`lib/features/customer/models/ground_model.dart`):
- `id`: Unique identifier (e.g., `'ground_1'`).
- `ownerId`: Foreign key mapping to ground owner's `UserModel.id`.
- `name`: Venue title (e.g., `'Rawal Sports Arena'`).
- `sportType`: `SportType` enum (`futsal`, `football`, `cricket`, `padel`, `tennis`, `basketball`).
- `location`: Short address (e.g., `'F-7 Markaz, Islamabad'`).
- `address`: Detailed street address for map pinpointing.
- `pricePerHour`: Hourly rental cost in PKR (e.g., `3500.0`).
- `rating`: Float rating (e.g., `4.9`).
- `reviewsCount`: Total count of submitted reviews.
- `openTime` / `closeTime`: Operating window (e.g., `'07:00'` to `'02:00'`).
- `facilities`: List of amenity tags (`'FIFA Grade Turf'`, `'LED Floodlights'`, `'Changing Rooms'`, `'Valet Parking'`).
- `images`: List of asset/network image paths.
- `isActive`: Boolean enabling owners to temporarily disable bookings for maintenance.

#### `ReviewModel` (`lib/features/customer/models/review_model.dart`):
- `id`, `groundId`, `customerId`, `customerName`, `rating`, `comment`, `createdAt`.

---

### 8.2 CustomerMainShell â€” File: `lib/features/customer/screens/customer_main_shell.dart`

- **Navigation Pattern**: Bottom Navigation Shell utilizing `IndexedStack`.
- **Why `IndexedStack`?**:
  - Maintains state and scroll positions of all 5 tabs simultaneously without re-triggering network or storage calls when switching tabs.
- **Tabs (5 items)**:
  - Tab 0: `CustomerHomeScreen` (Browse grounds, categories, search, featured turf)
  - Tab 1: `CustomerExploreScreen` (Advanced filtering, search, multi-sport discovery)
  - Tab 2: `CustomerBookingsScreen` (Upcoming, completed, and cancelled tickets)
  - Tab 3: `AiAssistantScreen` (GroundBot AI sports concierge)
  - Tab 4: `CustomerProfileScreen` (User info, dark mode toggle, data reset, logout)

---

### 8.3 CustomerHomeScreen â€” File: `lib/features/customer/screens/customer_home_screen.dart`

- **Structure**: `CustomScrollView` with sliver components for fluid 60fps scrolling.
- **Top Sliver Bar**:
  - Custom `GroundZeroLogo`.
  - Location Selector (`Islamabad, PK` / `Rawalpindi, PK`) with bottom-sheet picker.
  - Notification icon with unread indicator badge.
  - User avatar with initial badge linking to profile tab.
- **Search & Filter Bar**:
  - Real-time search query listener filtering venue names and sectors.
  - Filter icon launching bottom sheet modal (price slider, rating filter).
- **Horizontal Sport Categories**:
  - Scrollable row of chips (`All`, `Futsal`, `Cricket`, `Padel`, `Football`, `Tennis`, `Basketball`).
  - Active chip is highlighted in emerald green.
- **Featured Arena Card**:
  - Highlights top-rated venue (`Rawal Sports Arena`) with gradient overlay, pricing tag, and "Book Slot" quick action.
- **Grounds Grid/List**:
  - Displays loaded grounds matching active category and search filter.
  - Each card shows: photo, verified badge, sport chip, rating, price per hour, location, and favorite toggle heart button.
- **AI Concierge Banner**:
  - Prompts users to chat with GroundBot AI.

---

### 8.4 CustomerBookingsScreen â€” File: `lib/features/customer/screens/customer_bookings_screen.dart`

- **Tabs**:
  1. Upcoming (Pending & Confirmed bookings)
  2. Completed (Finished bookings)
  3. Cancelled (Rejected or cancelled bookings)
- **Booking Card Elements**:
  - Ground Name, Sport type icon, Date, and Time Slot.
  - Booking Reference Code (e.g., `GZ-789254`).
  - Status Badge with dynamic colors:
    - `Pending`: Amber / Yellow badge (`#F59E0B`)
    - `Confirmed`: Emerald Green badge (`#10B981`)
    - `Rejected`: Crimson Red badge (`#EF4444`)
    - `Completed`: Blue badge (`#3B82F6`)
  - "View Pass" button opening the digital QR ticket screen (`/customer/ticket/:bookingId`).

---

### 8.5 GroundDetailScreen â€” File: `lib/features/customer/screens/ground_detail_screen.dart`

- **Hero Image Header**: Dynamic ground photo with back button and favorite heart icon.
- **Venue Metadata**:
  - Sport badge, pricing (`PKR 3,500 / hr`), rating stars, and opening hours.
- **Facilities Wrap**:
  - Chip tags for floodlights, turf grade, parking, changing rooms, cafeteria.
- **Mini Map Preview**:
  - Integrates `MiniMapPreviewWidget` rendering schematic vector map with venue pin and "Directions" action.
- **AI Review Insights**:
  - Summarizes customer sentiment into pros and cons via `aiRepository.summarizeReviews()`.
- **Customer Reviews List**:
  - Ratings and verified feedback cards.
- **Sticky Bottom Action**:
  - Fixed "Book Arena Slot" button redirecting to `/customer/book/:id`.

---

## 9. FEATURES LAYER â€” BOOKING SYSTEM

### 9.1 BookingModel â€” File: `lib/features/booking/models/booking_model.dart`

```dart
enum BookingStatus { pending, confirmed, rejected, completed, cancelled }
```

#### Fields:
- `id`: Booking identifier (e.g., `'GZ-8F29A103'`).
- `groundId`: ID of the booked arena.
- `groundName`: Denormalized venue name for fast display.
- `groundLocation`: Sector and city.
- `sportType`: Sport type enum.
- `customerId`: User ID of player.
- `customerName`, `customerPhone`: Contact details.
- `ownerId`: Venue owner ID receiving booking fees.
- `date`: Selected date formatted as `'YYYY-MM-DD'`.
- `timeSlot`: Time interval (e.g., `'18:00 - 19:00'`).
- `totalPrice`: Total calculated price (Hourly Rate x Slot Duration).
- `status`: Current status enum (`pending`, `confirmed`, etc.).
- `paymentMethod`: `'EasyPaisa'`, `'JazzCash'`, `'Bank Transfer'`, or `'Cash on Ground'`.
- `qrCodeData`: Pipe-delimited string payload: `'GZ-8F29A103|ground_1|customer_1|2026-10-15|18:00-19:00'`.
- `createdAt`: Timestamp.

---

### 9.2 SlotBookingScreen â€” File: `lib/features/booking/screens/slot_booking_screen.dart`

#### Three-Step Booking Flow:
1. **Date Picker Strip**:
   - Horizontal scrollable list showing dates for the next 14 days.
   - Formatted via `intl` package: Day of week (`"Thu"`), Date (`"15"`), Month (`"Oct"`).
2. **Dynamic Slot Grid**:
   - Computes 1-hour slots based on arena's `openTime` and `closeTime`.
   - Queries `bookingRepository.getBookingsForGroundAndDate(groundId, selectedDate)` to identify occupied slots.
   - **Slot States**:
     - `Available`: Emerald border, selectable.
     - `Selected`: Solid emerald background, white text.
     - `Booked / Unavailable`: Greyed out, disabled click, strikethrough text.
3. **Payment Method Selector**:
   - `ChoiceChip` selection: EasyPaisa, JazzCash, 1Link Bank Transfer, Cash on Ground.
4. **Checkout & Double-Booking Prevention**:
   - Validates selection.
   - Invokes `bookingRepository.createBooking(booking)`.
   - If slot was reserved simultaneously, throws conflict exception and alerts user via SnackBar.
   - On success, routes to `/customer/ticket/:bookingId`.

---

### 9.3 BookingConfirmationScreen â€” File: `lib/features/booking/screens/booking_confirmation_screen.dart`

- **Confirmation Animation**: Success tick with emerald glow.
- **Physical Ticket Aesthetics**:
  - Perforated visual styling with dashed borders.
  - Summary of arena, date, slot time, customer details, and total paid.
- **QR Code Verification**:
  - Utilizes `qr_flutter` widget:
    ```dart
    QrImageView(
      data: booking.qrCodeData,
      version: QrVersions.auto,
      size: 200.0,
    )
    ```
  - Ground staff can scan this pass to verify entry instantly.
- **Action Buttons**: "View My Bookings" and "Return to Home".

---

## 10. FEATURES LAYER â€” AI ASSISTANT

### 10.1 ChatMessageModel & AI Engine

#### `ChatMessageModel` (`lib/features/ai/models/chat_message_model.dart`):
- `id`: Message identifier.
- `text`: Message string.
- `isUser`: Boolean distinguishing user from GroundBot AI.
- `timestamp`: Message time.
- `groundIds`: Recommended ground IDs attached to the response.
- `suggestionChips`: Quick-reply prompt strings.

#### Keyword NLP Matching Engine (`lib/data/repositories/ai_repository.dart`):
1. **Sport Detection**: Matches tokens (`futsal`, `football`, `cricket`, `padel`, `tennis`, `basketball`).
2. **Budget Extraction**: Uses Regular Expression:
   ```dart
   RegExp(r'(?:under|below|less than|<|budget|around)\s*(\d{3,5})')
   ```
   Extracts numerical values (e.g., "grounds under 4000" -> `4000.0`).
3. **Location Matching**: Identifies Rawalpindi sectors (`Ayub Park`, `Chaklala`, `Bahria Town`) and Islamabad sectors (`F-7`, `E-11`, `F-10`, `Blue Area`).
4. **Ground Filtering**: Filters all catalog grounds matching sport, budget ceiling, and sector.
5. **UI Rendering**: Returns conversational text response alongside interactive horizontal cards of matching venues and quick-action chips.

---

## 11. FEATURES LAYER â€” OWNER PANEL

### 11.1 OwnerMainShell â€” File: `lib/features/owner/screens/owner_main_shell.dart`

- 4-Tab Bottom Navigation for Arena Owners:
  - Tab 0: `OwnerDashboardScreen` (Analytics, charts, revenue, occupancy)
  - Tab 1: `OwnerBookingRequestsScreen` (Incoming customer bookings, approve/reject)
  - Tab 2: `OwnerGroundManagementScreen` (List, edit, add grounds, toggle active state)
  - Tab 3: `CustomerProfileScreen` (Profile, switch theme, logout)

---

### 11.2 OwnerDashboardScreen â€” File: `lib/features/owner/screens/owner_dashboard_screen.dart`

- **Metric Cards (4x)**:
  - Total Revenue (Sum of confirmed bookings in PKR)
  - Total Bookings count
  - Pending Requests requiring approval
  - Active Ground listings
- **Revenue Analytics Bar Chart**:
  - Implemented using `fl_chart` package (`BarChart`).
  - Displays revenue across the last 7 days (Mon-Sun).
  - Y-axis shows PKR earnings; bars rendered in emerald green.
- **Arena Occupancy Indicator**:
  - Percentage metric: `(Booked Slots / Total Daily Slots) * 100`.
- **AI Business Insights**:
  - Generates actionable advice (e.g., "Weekend 8 PM - 11 PM slots have 95% occupancy. Consider introducing peak-hour pricing").
- **Recent Activity Feed**:
  - Shows the 5 most recent customer reservations.

---

### 11.3 OwnerBookingRequestsScreen â€” File: `lib/features/owner/screens/owner_booking_requests_screen.dart`

- Fetches all booking orders for the logged-in owner's grounds.
- For `Pending` bookings, provides two interactive actions:
  - **Confirm / Approve**: Calls `bookingRepo.updateBookingStatus(id, BookingStatus.confirmed)`.
  - **Reject / Cancel**: Calls `bookingRepo.updateBookingStatus(id, BookingStatus.rejected)`.
- Updates status in Hive storage immediately and refreshes UI.

---

### 11.4 OwnerGroundManagementScreen â€” File: `lib/features/owner/screens/owner_ground_management_screen.dart`

- Displays cards for all grounds owned by the user.
- **Active / Inactive Toggle**:
  - `Switch` widget allows owners to temporarily take grounds offline for turf maintenance.
- **Edit Ground**: Opens bottom modal sheet to modify price per hour, open/close hours, facilities.
- **Add Ground (FAB)**:
  - Floating Action Button launches form with validation:
  - Generates new UUID (`ground_${Uuid().v4()}`), stores in Hive, and refreshes screen.
- **Delete Ground**:
  - Shows confirmation dialog before removing record from Hive.

---

## 12. SHARED WIDGETS & CUSTOM PAINTERS

1. **`GroundZeroLogo`** (`lib/features/shared/widgets/app_logo.dart`):
   - Scalable vector logo: rounded gradient square with sports ball icon and dual-colored typography (`GROUND` in Navy, `ZERO` in Emerald).
2. **`MiniMapPreviewWidget`** (`lib/features/shared/widgets/mini_map_preview.dart`):
   - Standalone offline map simulation built using Flutter's `CustomPainter` API (`Canvas`, `Path`, `Paint`).
   - Renders roads, green park spaces, highway curves, and venue pin without external API charges or Google Maps API key requirements.
3. **`GoogleLogoWidget`** (`lib/features/shared/widgets/google_icon.dart`):
   - Precision vector drawing of Google's 4-color "G" emblem using quadratic bezier curves on Canvas.
4. **`RunnerIllustrationWidget` & `StadiumIllustrationWidget`**:
   - Clean vector drawings of a running player and sports stadium used in onboarding and role selection cards.

---

## 13. UI WIDGETS & API ATTACHMENT MAP

| Category | Flutter Widgets Used | File Location | Attached Data / Service |
| :--- | :--- | :--- | :--- |
| **Authentication** | `TextField`, `ElevatedButton`, `ChoiceChip`, `AnimatedContainer` | `lib/features/auth/screens/login_screen.dart` | `authProvider`, `MockAuthRepository` -> Hive `usersBox` |
| **Navigation** | `IndexedStack`, `GestureDetector`, `SafeArea`, `AnimatedContainer` | `customer_main_shell.dart`, `owner_main_shell.dart` | `appRouterProvider`, `GoRouter` |
| **Catalog & Search** | `CustomScrollView`, `SliverToBoxAdapter`, `ListView`, `TextField` | `customer_home_screen.dart`, `customer_explore_screen.dart` | `groundRepositoryProvider` -> Hive `groundsBox` |
| **Slot Booking** | `GridView`, `ChoiceChip`, `ElevatedButton` | `lib/features/booking/screens/slot_booking_screen.dart` | `bookingRepositoryProvider` -> checks slot collision in Hive |
| **Digital Ticket** | `QrImageView` (`qr_flutter`), `ClipRRect`, `Card` | `booking_confirmation_screen.dart` | `qrCodeData` string encoded with UUID payload |
| **AI Concierge** | `ListView.builder`, `TextField`, `IconButton`, `Chip` | `lib/features/ai/screens/ai_assistant_screen.dart` | `aiRepositoryProvider` -> Keyword & Regex Parser |
| **Owner Dashboard** | `BarChart` (`fl_chart`), `LinearProgressIndicator`, `Card` | `owner_dashboard_screen.dart` | Calculates revenue & occupancy from `bookingRepository` |
| **Ground Admin** | `Switch`, `FloatingActionButton`, `showModalBottomSheet` | `owner_ground_management_screen.dart` | CRUD methods in `groundRepositoryProvider` |
| **Theme Toggle** | `Switch`, `ListTile` | `customer_profile_screen.dart` | `themeProvider` -> Hive `settingsBox['isDarkMode']` |

---

## 14. VIVA DEFENSE & RAPID CODE MODIFICATION CHEAT SHEET

### Q1: "If I tell you to change the primary brand color to Blue right now, where and how will you do it?"
**Answer**:
1. Open `lib/core/constants/app_colors.dart`.
2. Locate line:
   ```dart
   static const Color emerald = Color(0xFF10B981);
   ```
3. Change to:
   ```dart
   static const Color emerald = Color(0xFF2563EB); // Royal Blue
   ```
4. Save and Hot Reload (`r`). Because all buttons, badges, chips, and icons reference `AppColors.emerald`, the entire app reflects the new color instantly.

---

### Q2: "Where are the APIs attached? Is this connected to a backend?"
**Answer**:
"Sir, the app is engineered using the **Repository Pattern** with Clean Architecture.
Currently, the repositories (`MockAuthRepository`, `MockGroundRepository`, `MockBookingRepository`) interact with **Hive Local NoSQL Storage** on the device filesystem.
In `lib/data/repositories/repository_providers.dart`:
```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());
```
To attach a live REST API or Firebase backend, we simply create a `FirebaseAuthRepository implements AuthRepository` with HTTP/Firebase SDK calls, and swap that single line in `repository_providers.dart`. The UI layer does not need a single line of modification because it only knows the abstract `AuthRepository` interface."

---

### Q3: "How do you prevent two customers from booking the same slot at the same time?"
**Answer**:
"In `lib/data/repositories/booking_repository.dart`, the `createBooking()` method performs atomic slot validation before saving:
```dart
final available = await isSlotAvailable(booking.groundId, booking.date, booking.timeSlot);
if (!available) {
  throw Exception('Double-booking prevented: This slot is already reserved.');
}
```
`isSlotAvailable()` checks all existing bookings for that `groundId` and `date`. If any booking already has status `pending` or `confirmed` with the identical `timeSlot`, it rejects the reservation and the UI displays an alert SnackBar."

---

### Q4: "Where is the QR code generated, and what data is inside it?"
**Answer**:
"The QR code is generated in `lib/features/booking/screens/booking_confirmation_screen.dart` using the `qr_flutter` package widget `QrImageView`.
The data payload is constructed in `SlotBookingScreen`:
`"GZ-8F29A103|ground_1|customer_1|2026-10-15|18:00-19:00"`
Ground management staff at the facility gate scan this QR code to verify the booking ID, customer ID, arena, date, and allotted hour."

---

### Q5: "How does Dark Mode work and how does it persist after restarting the app?"
**Answer**:
"We manage dark mode through Riverpod's `themeProvider` in `lib/core/theme/theme_provider.dart`:
- When the user toggles the switch in `CustomerProfileScreen`, it calls `ref.read(themeProvider.notifier).toggleTheme()`.
- The notifier updates state and writes `box.put('isDarkMode', isDark)` into Hive's `settingsBox`.
- When the app is re-opened, `ThemeNotifier.build()` reads `box.get('isDarkMode')` and passes `ThemeMode.dark` or `ThemeMode.light` to `MaterialApp.router` in `main.dart`."

---

### Q6: "How does the AI Assistant work without an internet connection?"
**Answer**:
"In `lib/data/repositories/ai_repository.dart`, `MockAiRepository.sendChatMessage()` runs an offline natural language parsing pipeline:
1. It analyzes user input for sports keywords (`futsal`, `cricket`, `padel`, etc.).
2. It parses budget numbers via regular expression (`r'(?:under|budget)\s*(\d{3,5})'`).
3. It detects location mentions (`Islamabad`, `Rawalpindi`, `F-7`, `Ayub Park`).
4. It filters the local ground database and returns custom text alongside visual venue recommendation cards."

---

### Q7: "How would you add a new sport type (e.g., Badminton)?"
**Answer**:
1. Open `lib/features/customer/models/ground_model.dart`.
2. Add `badminton` to `enum SportType { football, cricket, futsal, padel, tennis, basketball, badminton }`.
3. In `displayName` getter, add: `case SportType.badminton: return 'Badminton';`.
4. In `iconName` getter, add: `case SportType.badminton: return 'sports_tennis';`.
5. Hot reload â€” Badminton immediately appears in filter chips, ground creation forms, and search screens.

---

### Q8: "Where is the owner revenue chart implemented?"
**Answer**:
"In `lib/features/owner/screens/owner_dashboard_screen.dart` using the `fl_chart` package. It aggregates confirmed booking totals for the past 7 days, maps them into `BarChartGroupData`, and renders a responsive bar chart with PKR values on the Y-axis and day abbreviations on the X-axis."

---

## 15. PROJECT FILE DIRECTORY CHEAT SHEET

```
ground_zero/
â”œâ”€â”€ pubspec.yaml                             <- Dependencies (riverpod, go_router, hive, fl_chart, qr_flutter)
â”œâ”€â”€ lib/
â”‚   â”œâ”€â”€ main.dart                            <- runApp(), ProviderScope, LocalStorageService init
â”‚   â”œâ”€â”€ core/
â”‚   â”‚   â”œâ”€â”€ constants/
â”‚   â”‚   â”‚   â”œâ”€â”€ app_colors.dart              <- Brand color palette (emerald, navy, lime)
â”‚   â”‚   â”‚   â”œâ”€â”€ app_strings.dart             <- App text strings & labels
â”‚   â”‚   â”‚   â””â”€â”€ app_assets.dart              <- Local image asset paths
â”‚   â”‚   â”œâ”€â”€ router/
â”‚   â”‚   â”‚   â”œâ”€â”€ app_router.dart              <- GoRouter routing configuration & auth guards
â”‚   â”‚   â”‚   â””â”€â”€ route_names.dart             <- Route path string constants
â”‚   â”‚   â”œâ”€â”€ storage/
â”‚   â”‚   â”‚   â”œâ”€â”€ hive_boxes.dart              <- Hive box name constants
â”‚   â”‚   â”‚   â””â”€â”€ local_storage_service.dart   <- Hive DB initialization & demo seeding
â”‚   â”‚   â””â”€â”€ theme/
â”‚   â”‚       â”œâ”€â”€ app_theme.dart               <- Light & Dark ThemeData (Material 3)
â”‚   â”‚       â””â”€â”€ theme_provider.dart          <- Riverpod ThemeMode state management
â”‚   â”œâ”€â”€ data/
â”‚   â”‚   â”œâ”€â”€ demo/
â”‚   â”‚   â”‚   â””â”€â”€ demo_data.dart               <- Seed data (5 users, 8 grounds, bookings, reviews)
â”‚   â”‚   â””â”€â”€ repositories/
â”‚   â”‚       â”œâ”€â”€ auth_repository.dart         <- Auth sign in / sign up / demo login
â”‚   â”‚       â”œâ”€â”€ ground_repository.dart       <- Ground catalog CRUD & multi-criteria search
â”‚   â”‚       â”œâ”€â”€ booking_repository.dart      <- Booking creation, slot checking & approval
â”‚   â”‚       â”œâ”€â”€ review_repository.dart       <- Review fetch & submission
â”‚   â”‚       â”œâ”€â”€ ai_repository.dart           <- Keyword NLP chatbot & review summarizer
â”‚   â”‚       â””â”€â”€ repository_providers.dart    <- Riverpod providers for all repositories
â”‚   â””â”€â”€ features/
â”‚       â”œâ”€â”€ auth/
â”‚       â”‚   â”œâ”€â”€ models/user_model.dart       <- UserModel & UserRole enum
â”‚       â”‚   â”œâ”€â”€ providers/auth_provider.dart <- AuthNotifier & AuthState
â”‚       â”‚   â””â”€â”€ screens/
â”‚       â”‚       â”œâ”€â”€ onboarding_screen.dart   <- Introductory screen
â”‚       â”‚       â”œâ”€â”€ login_screen.dart        <- Sign In / Sign Up / Demo quick logins
â”‚       â”‚       â””â”€â”€ role_selection_screen.dart<- Choose Customer vs Owner mode
â”‚       â”œâ”€â”€ customer/
â”‚       â”‚   â”œâ”€â”€ models/
â”‚       â”‚   â”‚   â”œâ”€â”€ ground_model.dart        <- GroundModel & SportType enum
â”‚       â”‚   â”‚   â””â”€â”€ review_model.dart        <- ReviewModel
â”‚       â”‚   â””â”€â”€ screens/
â”‚       â”‚       â”œâ”€â”€ customer_main_shell.dart <- 5-tab IndexedStack shell
â”‚       â”‚       â”œâ”€â”€ customer_home_screen.dart<- Discovery home & sport chips
â”‚       â”‚       â”œâ”€â”€ customer_explore_screen.dart<- Advanced filter search
â”‚       â”‚       â”œâ”€â”€ customer_bookings_screen.dart<- My match passes (Upcoming/Past)
â”‚       â”‚       â”œâ”€â”€ ground_detail_screen.dart<- Ground details, map, AI summary
â”‚       â”‚       â””â”€â”€ customer_profile_screen.dart<- Profile, dark mode toggle, logout
â”‚       â”œâ”€â”€ booking/
â”‚       â”‚   â”œâ”€â”€ models/booking_model.dart    <- BookingModel & BookingStatus enum
â”‚       â”‚   â””â”€â”€ screens/
â”‚       â”‚       â”œâ”€â”€ slot_booking_screen.dart <- Date picker, slot grid, payment
â”‚       â”‚       â””â”€â”€ booking_confirmation_screen.dart<- Digital QR ticket pass
â”‚       â”œâ”€â”€ ai/
â”‚       â”‚   â”œâ”€â”€ models/chat_message_model.dart<- ChatMessageModel
â”‚       â”‚   â””â”€â”€ screens/ai_assistant_screen.dart<- GroundBot AI chat interface
â”‚       â”œâ”€â”€ owner/
â”‚       â”‚   â””â”€â”€ screens/
â”‚       â”‚       â”œâ”€â”€ owner_main_shell.dart    <- 4-tab Owner shell
â”‚       â”‚       â”œâ”€â”€ owner_dashboard_screen.dart<- Analytics & fl_chart revenue
â”‚       â”‚       â”œâ”€â”€ owner_booking_requests_screen.dart<- Booking requests approval
â”‚       â”‚       â””â”€â”€ owner_ground_management_screen.dart<- Add/Edit/Toggle grounds
â”‚       â””â”€â”€ shared/
â”‚           â””â”€â”€ widgets/
â”‚               â”œâ”€â”€ app_logo.dart            <- GroundZero vector logo
â”‚               â”œâ”€â”€ google_icon.dart         <- Custom Google G painter
â”‚               â”œâ”€â”€ mini_map_preview.dart    <- Custom vector arena map painter
â”‚               â”œâ”€â”€ runner_illustration.dart <- Vector running athlete
â”‚               â””â”€â”€ stadium_illustration.dart<- Vector stadium painter
```

