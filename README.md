# ⚽ Ground Reservation System (Flutter)

A modern, production-grade Flutter application for sports ground, turf, stadium, and court reservations with a sleek and responsive Login & Authentication flow.

---

## 📱 Features

- **🏟️ Modern Sports Ground Themed Design**:
  - Emerald turf green palette, soft shadows, and clean Material 3 design tokens.
  - Responsive design that looks great on mobile, tablet, desktop, and web.

- **🔐 Authentication & Login UI**:
  - **Email & Password Validation**: Real-time form validation with custom error states.
  - **Password Visibility Toggle**: Show/hide password with a single tap.
  - **Remember Me & Forgot Password**: Interactive dialog for password recovery.
  - **One-Tap Demo Credentials**: Quick-fill button (`demo.player@groundres.com`) for testing.
  - **Social Authentication**: Google, Apple, and Phone login options.
  - **Registration Screen (`RegisterScreen`)**: Full Name, Phone, Preferred Sports chip selector (Football, Cricket, Tennis, Badminton, Basketball), and Terms agreement.

- **📅 Interactive Ground Dashboard (`HomeScreen`)**:
  - Browse grounds with sport filters (Football, Cricket, Tennis, Badminton, Basketball).
  - Search grounds by title, location, or sport type.
  - View hourly rates, ratings, reviews, and slot availability.
  - Interactive "Book Slot" bottom sheet to select time slots and confirm reservation.
  - User session display and Sign Out flow.

---

## 📁 Project Structure

```
Ground Reservation System/
├── lib/
│   ├── constants/
│   │   └── app_colors.dart          # Emerald turf green theme, gradients, and tokens
│   ├── screens/
│   │   ├── login_screen.dart        # Main Login Screen with validation & social login
│   │   ├── register_screen.dart     # Sign Up & Sports preference selection
│   │   └── home_screen.dart         # Ground reservation catalog & slot booking
│   ├── widgets/
│   │   ├── custom_button.dart       # Gradient elevated button with loading state
│   │   ├── custom_text_field.dart   # Styled form inputs with focus states
│   │   └── social_login_button.dart # Social login provider buttons
│   └── main.dart                    # App entry point & Material theme configuration
├── test/
│   └── widget_test.dart             # UI smoke tests
├── android/                         # Android native config
├── ios/                             # iOS native config
├── web/                             # Web configuration
├── windows/                         # Windows desktop configuration
├── pubspec.yaml                     # Dependencies & assets configuration
└── README.md
```

---

## 🚀 How to Run

### 1. Check Connected Devices
```bash
flutter devices
```

### 2. Run the App
- **Chrome / Web**:
  ```bash
  flutter run -d chrome
  ```
- **Windows Desktop**:
  ```bash
  flutter run -d windows
  ```
- **Android / iOS Emulator or Device**:
  ```bash
  flutter run
  ```

### 3. Run Tests
```bash
flutter test
```
