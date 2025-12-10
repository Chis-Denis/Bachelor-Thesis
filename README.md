# CalorieTrack Flutter

A non-native mobile application for tracking meals and calories, built with Flutter.

## Features

- ✅ Create, Read, Update, Delete (CRUD) operations for meals
- ✅ Meal tracking with calories, protein, carbs, and fat
- ✅ Material Design 3 UI
- ✅ Real-time updates using Streams
- ✅ Form validation
- ✅ Navigation between screens

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── meal.dart            # Meal data model
├── repositories/
│   └── meal_repository.dart # Data repository (similar to ViewModel pattern)
├── screens/
│   ├── main_screen.dart     # Main list screen
│   ├── create_meal_screen.dart
│   ├── update_meal_screen.dart
│   └── meal_details_screen.dart
└── widgets/
    └── meal_item.dart       # Reusable meal list item widget
```

## Getting Started

### Prerequisites

- Flutter SDK installed (see FLUTTER_SETUP_GUIDE.md)
- Android Studio or VS Code with Flutter extensions
- Android emulator or physical device

### Installation

1. Navigate to the project directory:
   ```powershell
   cd calorietrack_flutter
   ```

2. Get dependencies:
   ```powershell
   flutter pub get
   ```

3. Run the app:
   ```powershell
   flutter run
   ```

## How to Use

1. **View Meals**: The main screen shows all your meals in a list
2. **Add Meal**: Tap the floating action button (+) to add a new meal
3. **View Details**: Tap on any meal to see full details
4. **Edit Meal**: Tap the edit icon on any meal item
5. **Delete Meal**: Tap the delete icon and confirm deletion

## Architecture

This app follows a similar architecture to the native Kotlin version:

- **Model**: `Meal` class represents the data structure
- **Repository**: `MealRepository` manages data (singleton pattern, similar to the Kotlin object)
- **Screens**: Each screen corresponds to an Activity in the native app
- **Streams**: Used for reactive updates (similar to LiveData in Android)

## Differences from Native App

- Uses Flutter's Material Design 3 instead of Material Components
- Uses Streams instead of LiveData for reactive programming
- Navigation uses Navigator instead of Intents
- Form validation is built into Flutter's TextFormField

## Next Steps (Future Enhancements)

- Add local database persistence (SQLite with sqflite)
- Add server synchronization
- Add offline support
- Add date filtering
- Add weekly/monthly summaries

