# Quick Start Guide

## Step 1: Initialize Flutter Project (if needed)

If you haven't run `flutter create` yet, you need to generate the platform-specific files. 

**Option A: If the project folder is empty of platform files:**
```powershell
cd calorietrack_flutter
flutter create .
```

**Option B: If you already have a Flutter project, just get dependencies:**
```powershell
cd calorietrack_flutter
flutter pub get
```

## Step 2: Run the App

1. **Make sure you have a device/emulator running:**
   - Start Android Studio
   - Open Device Manager
   - Start an emulator OR connect your phone via USB

2. **Check available devices:**
   ```powershell
   flutter devices
   ```

3. **Run the app:**
   ```powershell
   flutter run
   ```

   Or run on a specific device:
   ```powershell
   flutter run -d <device-id>
   ```

## Step 3: Test the App

1. Tap the **+** button to add a meal
2. Fill in the form (all fields except Notes are required)
3. Save the meal
4. Tap on a meal to view details
5. Use the edit/delete buttons to modify meals

## Troubleshooting

### "No devices found"
- Make sure Android emulator is running OR
- Connect your phone and enable USB debugging

### "Package not found" errors
- Run `flutter pub get` again

### Build errors
- Run `flutter clean` then `flutter pub get`
- Make sure you have the latest Flutter: `flutter upgrade`

## Project Files Created

✅ All Dart source files are ready:
- `lib/main.dart` - App entry point
- `lib/models/meal.dart` - Data model
- `lib/repositories/meal_repository.dart` - Data management
- `lib/screens/` - All 4 screens (Main, Create, Update, Details)
- `lib/widgets/meal_item.dart` - Reusable widget

The app is ready to run! 🚀

