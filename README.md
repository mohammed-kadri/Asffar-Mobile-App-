# Travel & Agency Booking App

A comprehensive Flutter application for managing travel packages, visa services, and real-time communication between travelers and travel agencies. Built with Firebase backend and multi-language support.

## Overview

This application provides a platform for travelers to discover and book travel packages, visa services, and other travel-related services offered by agencies. It features real-time messaging, payment verification, subscription management, and detailed post analytics.

## Features

### For Travelers
- Browse available trips and services
- View detailed post information with images, pricing, and itineraries
- Real-time messaging with agencies
- Booking management
- Multi-language support (English, Arabic, French)
- Internet connection detection

### For Agencies
- Create and manage travel posts and service listings
- View trip statistics and analytics
- Real-time messaging with travelers
- Agency profile management
- Post editing and deletion capabilities

### General Features
- Firebase Authentication (Email/Password)
- Cloud Firestore database integration
- Firebase Storage for image uploads
- Responsive UI design
- Localization (L10n) for multiple languages
- State management with Provider
- Image cropping and picking

## Project Structure

```
lib/
├── controllers/           # Business logic controllers
├── models/               # Data models
├── providers/            # Provider state management
├── services/             # Business services
│   ├── auth_service.dart
│   ├── chat_service.dart
│   └── ...
├── theme/                # App theming
│   └── app_theme.dart
├── views/
│   └── screens/
│       ├── agency/       # Agency-specific screens
│       │   ├── agency_navbar.dart
│       │   ├── agency_profile.dart
│       │   ├── home.dart
│       │   ├── messages.dart
│       │   ├── post_details.dart
│       │   ├── statistics.dart
│       │   ├── add_post.dart
│       │   └── submit_documents.dart
│       └── shared/       # Shared screens
│           └── chat_screen.dart
├── app_localizations.dart # Localization support
├── firebase_options.dart  # Firebase configuration
└── main.dart             # App entry point

l10n/                      # Localization files
├── ar.json               # Arabic translations
├── en.json               # English translations
└── fr.json               # French translations

android/                   # Android-specific configuration
ios/                       # iOS-specific configuration
functions/                 # Firebase Cloud Functions
```

## Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter**: 3.0.5 or higher
- **Dart**: 3.0.5 or higher
- **Android SDK**: API level 21 or higher
- **Xcode**: 13 or higher (for iOS development)
- **Firebase CLI**: For Firebase deployment

## Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd untitled3
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Localization Files
```bash
flutter gen-l10n
```

### 4. Build the Project
```bash
flutter pub get
flutter build apk    # For Android
flutter build ios    # For iOS
```

## Configuration

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project

2. **Configure Firebase for Flutter**
   ```bash
   flutterfire configure
   ```

3. **Authentication Rules**
   - Enable Email/Password authentication in Firebase Console

4. **Firestore Database Setup**
   - Create collections: `trips`, `services`, `users`, `chats`
   - Apply security rules from `firestore.rules`

5. **Storage Setup**
   - Apply security rules from `storage.rules`

### Environment Configuration

Update `lib/firebase_options.dart` with your Firebase credentials for:
- Android
- iOS

### Localization Configuration

Localization files are in `l10n/`:
- `ar.json` - Arabic translations
- `en.json` - English translations
- `fr.json` - French translations

To add new translations:
1. Add entries to all JSON files in `l10n/`
2. Run: `flutter gen-l10n`
3. Use `AppLocalizations.of(context)!.translate('key')`

## Usage

### Running the App

```bash
flutter run
```

### Specific Device/Emulator

```bash
flutter run -d <device-id>
```

### Production Build

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Key Technologies & Dependencies

- **Framework**: Flutter
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Messaging**: Real-time chat with Firestore
- **UI Components**:
  - Google Navigation Bar
  - Iconsax icons
  - Image Cropper & Picker
  - Flutter SpinKit
- **Utilities**:
  - Intl (Date formatting)
  - Shared Preferences
  - Internet Connection Checker
  - HTTP client

## Firestore Collections Schema

### users
```json
{
  "uid": "string",
  "type": "traveler | agency",
  "email": "string",
  "name": "string",
  "profileImage": "string"
}
```

### trips
```json
{
  "postId": "string",
  "agencyId": "string",
  "agencyName": "string",
  "destination": "string",
  "departDate": "Timestamp",
  "returnDate": "Timestamp",
  "duration": "number",
  "price": "number",
  "places": "array",
  "hotelName": "string",
  "subscribers": "number",
  "availablePlaces": "number",
  "mainImageUrl": "string",
  "description": "string",
  "family": "boolean"
}
```

### services
```json
{
  "postId": "string",
  "agencyId": "string",
  "agencyName": "string",
  "type": "string",
  "country": "string",
  "visaType": "string",
  "price": "number",
  "mainImageUrl": "string",
  "description": "string"
}
```

### chats
```json
{
  "chatId": "string",
  "participants": ["travelerId", "agencyId"],
  "lastMessage": "string",
  "lastMessageTime": "Timestamp",
  "messages": "subcollection"
}
```
