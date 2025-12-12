# Flutter App - Error Fixes Guide

## 🔴 Issues Found

Based on the error messages, here are the issues to fix:

---

## 1. Missing `firebase_options.dart`

**Error:** `The system cannot find the file specified`

**Fix:** Create `lib/firebase_options.dart`

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForWeb',
    appId: '1:123456789:web:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    authDomain: 'exportsafe-ai.firebaseapp.com',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForAndroid',
    appId: '1:123456789:android:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForIOS',
    appId: '1:123456789:ios:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForMacOS',
    appId: '1:123456789:macos:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForWindows',
    appId: '1:123456789:windows:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'exportsafe-ai',
    databaseURL: 'https://exportsafe-ai.firebaseio.com',
    storageBucket: 'exportsafe-ai.appspot.com',
  );
}
```

---

## 2. String Interpolation Errors

**Error:** `String starting with ' must end with '`

**Issue:** Incomplete string interpolation in print statements

**Files to fix:**
- `lib/data/services/auth_service.dart`
- `lib/presentation/screens/dashboard/dashboard_screen.dart`
- `lib/presentation/screens/audit/upload_screen.dart`
- `lib/presentation/screens/audit/report_screen.dart`

**Example fix:**
```dart
// ❌ Wrong
print('Google Sign-In Error: \');

// ✅ Correct
print('Google Sign-In Error: ${error.toString()}');
```

---

## 3. Missing Imports

**Error:** `Undefined name 'DefaultFirebaseOptions'`

**Fix:** Add to `lib/main.dart`
```dart
import 'firebase_options.dart';
```

---

## 4. File Type Issues

**Error:** `The argument type 'XFile' can't be assigned to the parameter type 'File'`

**Issue:** Using `XFile` from `file_picker` instead of `File` from `dart:io`

**Fix in `lib/presentation/screens/audit/upload_screen.dart`:**
```dart
// ❌ Wrong
import 'package:file_picker/file_picker.dart';
File file = xFile; // XFile is not File

// ✅ Correct
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Convert XFile to File
File file = File(xFile.path);
```

---

## 5. Google Sign-In Issues

**Error:** `Couldn't find constructor 'GoogleSignIn'`

**Fix in `lib/data/services/auth_service.dart`:**
```dart
// ❌ Wrong
final GoogleSignIn _googleSignIn = GoogleSignIn();

// ✅ Correct
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);
```

---

## 6. Missing Method Definitions

**Error:** `The method 'signIn' isn't defined for the type`

**Fix:** Ensure all methods are properly defined in service classes

---

## 7. Theme Issues

**Error:** `The argument type 'CardTheme' can't be assigned to the parameter type`

**Fix in `lib/core/theme/app_theme.dart`:**
```dart
// ✅ Correct approach
ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
    ),
    // Don't use deprecated CardTheme
    cardColor: Colors.white,
  );
}
```

---

## Quick Fix Steps

### Step 1: Create firebase_options.dart
Copy the code above and create the file

### Step 2: Fix String Interpolation
Search for incomplete print statements and fix them:
```
print('...: \');  →  print('...: ${error}');
```

### Step 3: Fix Imports
Add missing imports to all files:
```dart
import 'dart:io';
import 'firebase_options.dart';
```

### Step 4: Fix File Types
Convert XFile to File where needed:
```dart
File file = File(xFile.path);
```

### Step 5: Fix Google Sign-In
Update GoogleSignIn initialization:
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);
```

### Step 6: Run Flutter Clean
```bash
flutter clean
flutter pub get
flutter run
```

---

## Common Patterns to Fix

### Pattern 1: String Interpolation
```dart
// ❌ Wrong
print('Error: \');

// ✅ Correct
print('Error: ${error.toString()}');
```

### Pattern 2: File Handling
```dart
// ❌ Wrong
void setFile(XFile file) { }

// ✅ Correct
void setFile(File file) { }
// Or convert: File file = File(xFile.path);
```

### Pattern 3: Missing Semicolons
```dart
// ❌ Wrong
context.go('/report/\')

// ✅ Correct
context.go('/report/');
```

### Pattern 4: Missing Closing Quotes
```dart
// ❌ Wrong
throw Exception('Error: \');

// ✅ Correct
throw Exception('Error: ${error.toString()}');
```

---

## Testing After Fixes

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run with verbose output
flutter run -v

# Run on specific device
flutter run -d chrome
```

---

## Expected Result

After fixing all errors, you should see:
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Application finished.
```

---

## Summary of Changes

| File | Issue | Fix |
|------|-------|-----|
| `lib/firebase_options.dart` | Missing file | Create with Firebase config |
| `lib/main.dart` | Missing import | Add `import 'firebase_options.dart'` |
| `lib/data/services/auth_service.dart` | String interpolation | Fix print statements |
| `lib/presentation/screens/dashboard/dashboard_screen.dart` | String interpolation | Fix print statements |
| `lib/presentation/screens/audit/upload_screen.dart` | File type mismatch | Convert XFile to File |
| `lib/presentation/screens/audit/report_screen.dart` | String interpolation | Fix print statements |
| `lib/core/theme/app_theme.dart` | Theme issues | Remove deprecated CardTheme |

---

**After applying these fixes, the Flutter app should compile successfully!** ✅
