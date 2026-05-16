# 🪐 Orbit: Premium Password Manager

<div align="center">
  <h3>Secure, Beautiful, and Seamless Digital Vault</h3>
  <p>A high-fidelity Flutter application engineered to protect your credentials with uncompromising security and stunning aesthetics.</p>
</div>

---

## ✨ Key Features

### 🛡️ Master Password Security
- **Single Master Key:** Secure your entire digital life with one robust master password.
- **Change & Verification:** Easily change your master password anytime with built-in confirmation workflows.
- **Always-Rounded Inputs:** Clean, permanently rounded input fields (28px radius) with premium subtle borders.

### 🔑 Secure Vault & Organization
- **Comprehensive Storage:** Store account titles, usernames/emails/employee codes, passwords, website URLs, and custom notes.
- **Interactive Details Modal & Full Editing:** Tapping any password card instantly summons a beautifully structured modal presenting full account info with one-tap copy actions. Modify account titles, usernames, employee codes, passwords, and categories anytime via the dedicated Edit Entry screen.
- **Custom Categories:** Organize credentials into categories (`Social`, `Work`, `Finance`, `Entertainment`, `General`, `Other`). Add, edit, or delete categories dynamically.
- **Password Obscuring & Favorites:** Easily toggle password visibility or star frequent accounts for rapid access.

### ⚡ Smart Password Generator
- **Real-Time Strength Indicator:** Visual strength gauge (Weak, Fair, Strong, Unbreakable) updates live as you type or generate passwords.
- **Custom Parameters:** Instantly generate passwords of any length with custom character inclusions (uppercase, digits, special symbols).

### 🌓 Adaptive Theming & Appearance
- **Global Light & Dark Modes:** Fully adaptive UI components, cards, surfaces, and shadows that transition flawlessly between light and dark mode.
- **50 Curated Accent Colors:** Personalize the app's entire color palette instantly. Search through exactly 50 premium shades (from *Royal Blue* to *Neon Purple*).

### 🌊 Seamless Curved Navigation Bar
- **Physically Merged Aesthetics:** Custom bezier curve painter (`cubicTo`) creates a zero-gap, continuous material "dip" where the active icon perfectly docks.
- **Zero Latency Transitions:** Responsive, snappy page sliding and animated pop-up bouncy icons (`Curves.easeInOutBack`).

### 💾 Data Management & Automatic Scheduling
- **JSON Backup & Restore:** Export your entire vault and custom categories to a securely formatted `.json` backup file on your device.
- **Strict Duplicate Checking:** When importing an Orbit backup file, identical passwords (same title, website, and password) are automatically skipped to prevent vault clutter, while new passwords or updated entries are seamlessly merged.
- **Automatic Backup Scheduling & History:** Configure your vault to backup automatically (*Daily*, *Weekly*, *Monthly*). View historical automated backups directly inside the app, and instantly restore or export any past backup file.
- **Local Persistence:** All credentials are automatically encrypted and persisted in device local storage for immediate access.

### 🔒 Advanced Native Security & Biometrics
- **Hardware-Enforced Biometrics:** Seamless fingerprint/FaceID integration (`local_auth`) utilizing Android's secure `BiometricPrompt` KeyStore subsystem. Requires native `FlutterFragmentActivity` inheritance to ensure strict verification against system-enrolled credentials only. Prompts automatically upon app launch with manual on-demand unlock and master password fallback.
- **Screenshot & Leak Protection:** Enforces native Android `FLAG_SECURE` window parameters. Actively blocks taking screenshots or screen recording while inside your vault, and blacks out the app's preview thumbnail in the OS Recent Apps switcher to prevent credential leakage.

### ⚡ OS Autofill Integration
- **System-Wide Autofill Registration:** Fully registered as a native Android system Autofill provider (`OrbitAutofillService` declared in `AndroidManifest.xml` with `BIND_AUTOFILL_SERVICE` permissions). Appears natively inside Android OS Settings -> Passwords & Accounts -> Autofill service list alongside Google Password Manager.
- **In-App Testing & Simulation:** Dedicated configuration screen (`AutofillConfigScreen`) guides users through system enablement and provides an interactive testing sandbox to simulate OS autofill prompts.

---


## 🛠️ Technology Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev/) (Dart 3.x)
- **State Management:** `Provider` (`AuthProvider`, `VaultProvider`, `ThemeProvider`)
- **Typography:** `Google Fonts` (*Outfit*)
- **File System:** `file_picker` & `dart:io` for cross-platform JSON data management
- **Design System:** Material 3 & Custom Glassmorphism / Gradient Surfaces

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10+)
- Android Studio / VS Code / Windows build tools

### Installation & Running Locally

1. **Clone the repository / navigate to project directory:**
   ```bash
   cd orbit
   ```

2. **Get all Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Run the application in release mode for maximum fluidity:**
   ```bash
   flutter run --release
   ```

---

<div align="center">
  <p>Crafted with premium visual excellence and robust data integrity.</p>
</div>
