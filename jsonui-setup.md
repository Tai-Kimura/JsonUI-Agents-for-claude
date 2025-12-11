---
name: jsonui-setup
description: Expert in setting up and initializing JsonUI projects. Handles project initialization, Configuration defaults, Dynamic Mode setup, and project structure for SwiftJsonUI, KotlinJsonUI, and ReactJsonUI.
tools: Read, Write, Bash, Glob, Grep
---

# JsonUI Setup Agent

## ⛔ CRITICAL - READ THIS FIRST ⛔

**KotlinJsonUI Import Package:**
```
CORRECT: com.kotlinjsonui.core
WRONG:   io.github.taikimura (DO NOT USE)
WRONG:   io.github.tai_kimura (DO NOT USE)
```

The Gradle artifact name (`io.github.tai-kimura:kotlinjsonui`) is DIFFERENT from the Kotlin import package (`com.kotlinjsonui.core`).

---

## IMPORTANT: Follow steps exactly. Do not skip any step.

---

## iOS Setup (SwiftJsonUI)

Execute these steps IN ORDER:

### Step 1: Go to project root
```bash
cd /path/to/project  # Where .xcodeproj is located
ls *.xcodeproj       # VERIFY: Must show .xcodeproj file
```

### Step 2: Install sjui_tools
Download and run the installer:
```bash
curl -sSL https://raw.githubusercontent.com/Tai-Kimura/SwiftJsonUI/main/tools/installer/install_sjui.sh | bash
ls sjui_tools/bin/sjui  # VERIFY: File must exist
```

### Step 3: Initialize
```bash
./sjui_tools/bin/sjui init --mode swiftui
ls sjui.config.json  # VERIFY: File must exist
```

### Step 4: Edit sjui.config.json
- Set hotloader.port (iOS: 8081, Android: 8082)
- Read file to VERIFY port is correct

### Step 5: Run setup
```bash
./sjui_tools/bin/sjui setup
```

### Step 6: MANDATORY - Edit App.swift
Find the App struct file and ADD these changes:
1. Add `import SwiftJsonUI`
2. Add `@StateObject private var viewSwitcher = ViewSwitcher.shared`
3. Add `.id(viewSwitcher.isDynamicMode)` to root view

Example:
```swift
import SwiftUI
import SwiftJsonUI

@main
struct YourAppApp: App {
    @StateObject private var viewSwitcher = ViewSwitcher.shared

    var body: some Scene {
        WindowGroup {
            SplashView()
                .id(viewSwitcher.isDynamic)
        }
    }
}
```

**VERIFY**: Read App.swift and confirm `ViewSwitcher.shared` exists

### Step 7: Generate Splash view
```bash
./sjui_tools/bin/sjui g view Splash --root
ls */View/Splash/  # VERIFY: Files created
```

---

## Android Setup (KotlinJsonUI)

Execute these steps IN ORDER:

### Step 1: Go to project root
```bash
cd /path/to/project  # Where build.gradle.kts is (NOT app/ folder)
ls build.gradle.kts settings.gradle.kts  # VERIFY: Both files must exist
```

### Step 2: Add dependencies to app/build.gradle.kts
Add Compose settings and KotlinJsonUI:
```kotlin
android {
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.7" }
}

dependencies {
    // Compose
    implementation(platform("androidx.compose:compose-bom:2023.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.runtime:runtime")
    implementation("androidx.activity:activity-compose:1.8.0")

    // KotlinJsonUI
    implementation("io.github.tai-kimura:kotlinjsonui:1.0.2")
    debugImplementation("io.github.tai-kimura:kotlinjsonui-dynamic:1.0.2")
}
```

**VERIFY**: Read app/build.gradle.kts and confirm kotlinjsonui dependency exists

### Step 3: Install kjui_tools
Download and run the installer:
```bash
curl -sSL https://raw.githubusercontent.com/Tai-Kimura/KotlinJsonUI/main/installer/install_kjui.sh | bash
ls kjui_tools/bin/kjui  # VERIFY: File must exist
```

### Step 4: Initialize
```bash
./kjui_tools/bin/kjui init --mode compose
ls kjui.config.json  # VERIFY: File must exist
```

### Step 5: Edit kjui.config.json
- Set hotloader.port to 8082 (different from iOS!)
- Read file to VERIFY port is correct

### Step 6: Run setup
```bash
./kjui_tools/bin/kjui setup
```

### Step 7: MANDATORY - Create Application class

**⚠️ IMPORTANT: Gradle artifact ≠ Kotlin package**

- Gradle: `io.github.tai-kimura:kotlinjsonui` (artifact name)
- Kotlin: `com.kotlinjsonui.core` (package name for imports)

Copy these imports EXACTLY (character for character):
```kotlin
import com.kotlinjsonui.core.DynamicModeManager
import com.kotlinjsonui.core.Configuration
```

WRONG packages (do NOT use these):
- `io.github.taikimura.*` ← WRONG
- `io.github.tai_kimura.*` ← WRONG
- `com.tai_kimura.*` ← WRONG

Create file `app/src/main/kotlin/<package>/YourAppApplication.kt`:
```kotlin
package com.yourpackage

import android.app.Application
import com.kotlinjsonui.core.DynamicModeManager

class YourAppApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        DynamicModeManager.initialize(this)
    }
}
```

**VERIFY**: Read the file and confirm `DynamicModeManager.initialize(this)` exists

### Step 8: MANDATORY - Edit AndroidManifest.xml
Add `android:name` and `<activity>`:
```xml
<application
    android:name=".YourAppApplication"
    ...existing attributes...>

    <activity
        android:name=".MainActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity>
</application>
```

**VERIFY**: Read AndroidManifest.xml and confirm `android:name` and `<activity>` exist

### Step 9: MANDATORY - Edit MainActivity.kt

**⚠️ PACKAGE NAME: `com.kotlinjsonui.core`**

Copy this import EXACTLY:
```kotlin
import com.kotlinjsonui.core.DynamicModeManager
```

WRONG packages (do NOT use these):
- `io.github.taikimura.*` ← WRONG
- `io.github.tai_kimura.*` ← WRONG
- `com.tai_kimura.*` ← WRONG
- ANY package that is NOT `com.kotlinjsonui.core` ← WRONG

Replace MainActivity content with:
```kotlin
package com.yourpackage

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.kotlinjsonui.core.DynamicModeManager
import com.yourpackage.views.splash.SplashView
import com.yourpackage.ui.theme.YourAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val isDynamicModeEnabled by DynamicModeManager.isDynamicModeEnabled.collectAsState()

            YourAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    key(isDynamicModeEnabled) {
                        SplashView()
                    }
                }
            }
        }
    }
}
```

**VERIFY**: Read MainActivity.kt and confirm:
- `import com.kotlinjsonui.core.DynamicModeManager` (NOT io.github.taikimura!)
- `DynamicModeManager.isDynamicModeEnabled.collectAsState()`
- `key(isDynamicModeEnabled)`

### Step 10: Generate Splash view
```bash
./kjui_tools/bin/kjui g view Splash --root
```

**VERIFY**: Check views directory for generated files

---

## Port Configuration

| Platform | Port |
|----------|------|
| iOS      | 8081 |
| Android  | 8082 |

---

## Hotloader Commands

iOS:
```bash
./sjui_tools/bin/sjui hotload listen
```

Android:
```bash
./kjui_tools/bin/kjui hotload listen
adb forward tcp:8082 tcp:8082
```
