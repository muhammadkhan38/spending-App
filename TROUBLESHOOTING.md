# Troubleshooting Guide

## DDS (Dart Development Service) Error Fix

### Problem
```
RemoteDebuggerExecutionContext: Timed out finding an execution context after 100 ms.
AppInspector: Error calling Runtime.evaluate
DartDevelopmentServiceException: Failed to start Dart Development Service
```

### Solutions (In Order of Recommendation)

#### Solution 1: Run with --no-dds Flag (Quick Fix)
```powershell
flutter run --no-dds
```
This disables the Dart Development Service and should allow the app to run.

#### Solution 2: Clean and Rebuild
```powershell
flutter clean
flutter pub get
flutter run
```

#### Solution 3: Use VS Code Launch Configuration
1. Press `F5` or click "Run > Start Debugging"
2. Select "Flutter (Windows)" from the dropdown
3. This uses the launch.json configuration with optimized settings

#### Solution 4: Kill All Dart/Flutter Processes
```powershell
# Kill all Flutter processes
taskkill /F /IM flutter.exe
taskkill /F /IM dart.exe

# Then try running again
flutter run
```

#### Solution 5: Restart VS Code
Sometimes VS Code's Dart/Flutter extension needs a restart:
1. Close all VS Code windows
2. Reopen VS Code
3. Run the app again

#### Solution 6: Update Flutter and Dart Tools
```powershell
flutter upgrade
flutter pub upgrade
dart pub global activate devtools
```

#### Solution 7: Clear Flutter Cache
```powershell
# Clear build cache
flutter clean
rd /s /q %LOCALAPPDATA%\Pub\Cache
flutter pub get
```

#### Solution 8: Run on Specific Device
```powershell
# For Windows Desktop
flutter run -d windows

# For Chrome
flutter run -d chrome

# For Edge
flutter run -d edge
```

### Prevention Tips

1. **Use Launch Configurations**: The `.vscode/launch.json` file is now set up with optimized configurations

2. **Choose Stable Channels**: Avoid Flutter dev/beta channels if not needed
   ```powershell
   flutter channel stable
   flutter upgrade
   ```

3. **Close Unused Apps**: Sometimes having multiple debugging sessions causes issues

4. **Regular Cleanup**: Run `flutter clean` periodically

5. **Update Dependencies**: Keep packages up to date
   ```powershell
   flutter pub upgrade
   ```

### Common Causes

- **Port Conflicts**: Another app using the DDS port
- **Stale Processes**: Previous Flutter instances not properly closed
- **VS Code Extension Issues**: Dart/Flutter extension needs restart
- **Network Issues**: Firewall blocking local connections
- **Corrupted Cache**: Build artifacts causing conflicts

### Recommended Running Method

For this project, use:
```powershell
flutter run -d windows --no-dds
```

Or use the VS Code debugger with F5 (it's now configured with the fix).

### Testing the Fix

1. Stop all running Flutter processes
2. Run: `flutter clean`
3. Run: `flutter run --no-dds`
4. Select Windows (1) when prompted
5. App should launch successfully

### VS Code Debugging

Now you can use F5 to debug with these options:
- **Flutter (Windows)** - Runs on Windows with --no-dds
- **Flutter (Chrome)** - Runs in Chrome browser
- **Flutter (Debug)** - Standard debug mode
- **Flutter (Release)** - Release mode for testing performance

### Still Having Issues?

If the problem persists:

1. **Check Firewall**: Ensure Flutter can make local connections
2. **Antivirus**: Temporarily disable to test
3. **Administrator**: Try running VS Code as administrator
4. **Reinstall**: As a last resort, reinstall Flutter

```powershell
# Check Flutter doctor
flutter doctor -v

# This will show any configuration issues
```

### Additional Commands

```powershell
# See all connected devices
flutter devices

# Run with verbose logging
flutter run -v

# Run in release mode (no debugging)
flutter run --release

# Hot reload shortcut
# Press 'r' in the terminal while app is running

# Hot restart
# Press 'R' in the terminal while app is running
```

---

**Quick Reference:**
- Problem? → `flutter clean` → `flutter run --no-dds`
- Still issues? → Restart VS Code
- Need debugging? → Use F5 with "Flutter (Windows)" config

**Current Setup:**
- Flutter 3.35.6 (Stable)
- Dart 3.9.2
- Platform: Windows 10.0.26200.6899
- Launch configs: ✅ Configured in .vscode/launch.json
