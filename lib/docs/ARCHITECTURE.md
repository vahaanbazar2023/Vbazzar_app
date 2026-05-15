# Flutter Project Architecture & Folder Structure

> This document describes the complete architecture and folder conventions used in this Flutter project. Use it as a blueprint to replicate the same structure in a new project.

---

## Tech Stack

| Concern | Package |
|---|---|
| State Management | `get` (GetX) |
| Routing | GetX `GetMaterialApp` + named routes |
| Dependency Injection | GetX Bindings |
| Networking | `dio` |
| Local Storage | `get_storage` |
| Secure Storage | `flutter_secure_storage` |
| Responsive UI | `flutter_screenutil` |
| SVG Support | `flutter_svg` |
| Push Notifications | `firebase_messaging` + `flutter_local_notifications` |
| Localization | Flutter ARB (`flutter_localizations` + `intl`) |
| OTP Input | `pinput` |
| Phone Input | `intl_phone_field` |
| Image Zoom | `photo_view` |

---

## Top-Level Folder Structure

```
project_root/
├── android/
├── ios/
├── assets/
│   ├── fonts/
│   └── images/
│       ├── png/
│       └── svg/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── core/
│   ├── features/
│   ├── l10n/
│   ├── routes/
│   └── theme/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── l10n.yaml
```

---

## `lib/` Detailed Structure

### Entry Point — `main.dart`

```dart
void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Bootstrap.initialize();
      runApp(const MyApp());
    },
    (error, stack) => Bootstrap.handleRuntimeError(error, stack),
  );
}
```

- Wraps everything in `runZonedGuarded` for global error capture.
- Calls `Bootstrap.initialize()` before `runApp`.

---

### `lib/app/`

The root application widget and global app-level wiring.

```
app/
├── app.dart            # Root widget (GetMaterialApp + ScreenUtilInit)
├── app_binding.dart    # Global GetX bindings registered at startup
├── app_lifecycle.dart  # Handles app foreground/background lifecycle
├── app_router.dart     # Delegates to AppPages for route resolution
└── app_theme.dart      # Thin wrapper around ThemeConfig
```

**`app.dart`** — `VahaanApp` (or `MyApp`):

- Wraps in `ScreenUtilInit` with design size `375 × 812`.
- Uses `GetMaterialApp` with named routes, localization delegates, and `initialBinding`.
- Design size must match the Figma frame width/height.

---

### `lib/bootstrap/`

One-time app startup sequence, run before `runApp`.

```
bootstrap/
├── bootstrap.dart        # Orchestrates init steps in order
└── app_initializer.dart  # Individual init helpers (Firebase, etc.)
```

**Init order inside `Bootstrap.initialize()`:**
1. Error handling setup (`FlutterError.onError`, platform dispatcher)
2. System UI (status bar style, orientation lock)
3. Core services (storage, logger)
4. Environment configuration
5. App services (notifications, Firebase)

---

### `lib/config/`

Environment-specific configuration.

```
config/
├── env.dart          # Abstract `Env` interface / active env selector
├── dev_env.dart      # Dev API base URL, keys
├── staging_env.dart  # Staging values
└── prod_env.dart     # Production values
```

Switch the active environment in `env.dart`. All network code reads from `Env`.

---

### `lib/routes/`

Centralized routing registry.

```
routes/
├── app_routes.dart   # Route name constants (static const Strings)
└── app_pages.dart    # GetPage list (maps route → screen + binding)
```

**Convention:**

```dart
// app_routes.dart
class AppRoutes {
  static const splash = '/splash';
  static const home   = '/home';
}

// app_pages.dart
GetPage(
  name: AppRoutes.home,
  page: () => const HomeScreen(),
  binding: HomeBinding(),
  transition: Transition.rightToLeft,
)
```

---

### `lib/theme/`

Global theming separated from app wiring.

```
theme/
├── theme_config.dart   # ThemeData lightTheme / darkTheme
├── text_styles.dart    # App-wide TextStyle constants
└── app_fonts.dart      # Font family name constants
```

---

### `lib/l10n/`

ARB localization files consumed by the Flutter toolchain.

```
l10n/
├── app_en.arb
├── app_hi.arb
└── app_te.arb
```

`l10n.yaml` at project root points the generator here. Generated code goes to `.dart_tool/flutter_gen/`.

---

## `lib/core/`

Shared, feature-agnostic code. Nothing here imports from `features/`.

```
core/
├── constants/
├── design_system/
├── error/
├── extensions/
├── localization/
├── models/
├── network/
├── services/
├── storage/
└── utils/
```

### `core/constants/`

```
constants/
├── app_colors.dart   # All color tokens (hex values as Color)
├── app_sizes.dart    # Numeric size constants
├── app_assets.dart   # Asset path strings
└── app_strings.dart  # Static string constants (non-localized)
```

### `core/design_system/`

Atomic Design hierarchy for UI components.

```
design_system/
├── design_system.dart          # Barrel export for the entire DS
├── QUICK_START.dart            # Code examples for quick reference
├── tokens/                     # Design tokens
│   ├── app_spacing.dart
│   ├── app_radius.dart
│   └── app_sizes.dart
├── typography/
│   ├── app_text_styles.dart    # TextStyle definitions
│   └── app_text.dart          # AppText widget
├── atoms/                      # Smallest indivisible widgets
│   ├── app_text.dart
│   ├── app_icon.dart
│   ├── app_svg_icon.dart
│   ├── app_divider.dart
│   └── gradient_text.dart
├── molecules/                  # Atoms composed together
│   ├── custom_input_field.dart
│   ├── custom_dropdown_field.dart
│   ├── custom_phone_input_field.dart
│   ├── custom_autocomplete_field.dart
│   ├── app_textfield.dart
│   ├── primary_button.dart
│   ├── gradient_button.dart
│   ├── search_bar.dart
│   ├── timer_badge.dart
│   └── custom_snackbar.dart
├── organisms/                  # Full UI sections
│   ├── app_card.dart
│   ├── app_bottom_nav_bar.dart
│   ├── login_form.dart
│   ├── product_tile.dart
│   ├── network_image_carousel.dart
│   └── zoomable_image_viewer.dart
├── templates/                  # Screen-level layout shells
│   ├── app_scaffold.dart
│   ├── app_layout.dart
│   ├── auth_layout.dart
│   └── dashboard_layout.dart
├── buttons/
│   └── primary_button.dart
├── inputs/
│   └── custom_textfield.dart
├── feedback/
│   └── error_widget.dart
├── loaders/
│   └── loading_widget.dart
└── examples/
    └── design_system_example.dart
```

**Atomic Design Rules:**
- `atoms` — no children widgets from DS; pure Flutter primtives only.
- `molecules` — compose atoms; no feature-specific logic.
- `organisms` — compose molecules; may accept callbacks but no controller refs.
- `templates` — layout shells used by feature screens (Scaffold wrappers).

### `core/network/`

```
network/
├── network_service.dart        # GetxService wrapping Dio; GET/POST/PUT/DELETE methods
├── network_info.dart           # Connectivity check helper
├── api_constants.dart          # Base URL, timeouts, API key
├── client/
│   └── dio_client.dart         # Raw Dio instance factory
├── endpoints/
│   └── api_endpoints.dart      # All path strings (e.g. '/api/v1/...')
└── interceptors/
    ├── auth_interceptor.dart   # Attaches Bearer token from secure storage
    ├── logging_interceptor.dart
    └── retry_interceptor.dart
```

`NetworkService` is a `GetxService` registered in `AppBinding` as permanent. Feature data sources call `NetworkService.to`.

### `core/storage/`

```
storage/
├── storage_keys.dart           # All key name constants
├── local_storage_service.dart  # GetStorage wrapper (non-sensitive data)
└── secure_storage_service.dart # flutter_secure_storage wrapper (tokens)
```

### `core/services/`

```
services/
├── logger_service.dart         # Singleton logger (debug/info/error)
├── analytics_service.dart      # Analytics event tracking
├── connectivity_service.dart   # Reactive connectivity stream
├── fcm_service.dart            # Firebase Cloud Messaging setup
├── notification_service.dart   # Local notification scheduling
└── location_service.dart       # GPS / location fetching
```

### `core/error/`

```
error/
├── failure.dart            # Sealed/abstract Failure types
├── app_exceptions.dart     # Custom exception classes
└── error_handler.dart      # Maps DioException → Failure
```

### `core/utils/`

```
utils/
├── validators.dart         # Form field validators
├── formatters.dart         # Date, currency, etc.
├── input_formatters.dart   # TextInputFormatter implementations
├── debouncer.dart          # Debounce utility class
└── extensions.dart         # Misc Dart extensions
```

### `core/extensions/`

```
extensions/
└── context_extensions.dart   # BuildContext extensions (theme, size, l10n)
```

### `core/localization/`

```
localization/
├── translations.dart         # GetX Translations map (if using GetX i18n)
├── locale_keys.dart          # Key constants for ARB keys
└── supported_locales.dart    # List<Locale> supported
```

### `core/models/`

```
models/
└── location_models.dart    # Shared data models used across features
```

---

## `lib/features/`

Each feature is a self-contained vertical slice.

```
features/
├── splash/
├── introduction/
├── language/
├── auth/
├── main_shell/
├── home/
├── profile/
├── search/
├── sell/
├── categories/
├── auction/
├── subscription/
└── wishlist/
```

### Feature Folder Convention

Every feature follows this internal layout:

```
feature_name/
├── feature_binding.dart       # GetX Binding (registers controllers)
├── controllers/
│   └── feature_controller.dart   # GetxController; holds state + business logic
├── data/
│   └── feature_data_source.dart  # Makes HTTP calls via NetworkService
├── models/
│   ├── request_model.dart
│   └── response_model.dart
├── repositories/
│   └── feature_repository.dart   # Mediates between controller and data source
└── views/
    ├── feature_screen.dart        # Main screen widget (Obx / GetBuilder)
    └── widgets/                   # Screen-local widgets (not in DS)
```

**Data Flow:**

```
View (screen)
  └─► Controller (GetxController)
        └─► Repository
              └─► DataSource
                    └─► NetworkService (Dio)
```

**Binding resolves the dependency graph at route push time:**

```dart
class FeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeatureController());
  }
}
```

### Example — `auth` feature

```
auth/
├── auth_binding.dart
├── controllers/
│   └── auth_controller.dart
├── data/
│   └── auth_data_source.dart
├── models/
│   ├── login_request.dart
│   ├── login_response.dart
│   ├── otp_response.dart
│   ├── otp_verify_models.dart
│   └── complete_profile_models.dart
├── repositories/
│   └── auth_repository.dart
└── views/
    ├── login_with_otp.dart
    ├── verify_otp.dart
    └── complete_profile_screen.dart
```

### Example — `main_shell` feature

The bottom navigation host. Contains a controller that tracks the selected tab index.

```
main_shell/
├── bindings/
│   └── main_shell_binding.dart
├── controllers/
│   └── main_shell_controller.dart
├── views/
│   └── main_shell_screen.dart       # IndexedStack or PageView
└── widgets/
    └── (bottom-nav specific widgets)
```

---

## Global Bindings (`app_binding.dart`)

Services that must live for the entire app lifetime are registered here:

```dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NetworkService>(NetworkService(), permanent: true);
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<LoggerService>(LoggerService.instance, permanent: true);
  }
}
```

---

## Naming Conventions

| File type | Convention | Example |
|---|---|---|
| Screens | `snake_case_screen.dart` | `login_with_otp.dart` |
| Controllers | `snake_case_controller.dart` | `auth_controller.dart` |
| Repositories | `snake_case_repository.dart` | `auth_repository.dart` |
| Data sources | `snake_case_data_source.dart` | `auth_data_source.dart` |
| Bindings | `snake_case_binding.dart` | `auth_binding.dart` |
| Models | `snake_case_models.dart` | `otp_verify_models.dart` |
| Routes | `AppRoutes.camelCase` | `AppRoutes.verifyOtp` |
| Colors | `AppColors.camelCase` | `AppColors.primary` |
| TextStyles | `AppTextStyles.camelCase` | `AppTextStyles.bodyMedium` |

---

## Responsive Sizing

All sizes use `flutter_screenutil`:

- **Design frame:** `375 × 812` (iPhone 14 logical pixels)
- Width values → `.w` (e.g. `16.w`)
- Height values → `.h`
- Font sizes → `.sp`
- Border radii → `.r`

Never use raw `double` literals for layout values.

---

## State Management Pattern (GetX)

- **Reactive state:** `final isLoading = false.obs;` — use `.obs` for primitives, `Rxn<T>` for nullable objects.
- **UI consumption:** wrap with `Obx(() => ...)` for reactive rebuilds.
- **Non-reactive state:** use `GetBuilder<Controller>` for batch updates.
- **Controller lifecycle:** controllers are created by bindings on route push and auto-deleted on route pop unless `permanent: true`.

---

## Error Handling

- `Failure` (abstract) subclasses represent domain errors.
- `ErrorHandler` maps `DioException` → `Failure`.
- Controllers catch repository exceptions, set an observable error state, and drive UI snackbars via `CustomSnackbar.showError(...)`.

---

## Localization

- Source of truth: `lib/l10n/app_en.arb` (and other locale ARBs).
- Run `flutter gen-l10n` (or `flutter pub run intl_utils:generate`) to regenerate.
- Access strings via `AppLocalizations.of(context)!.keyName` or the context extension.
- Supported locales: English (`en`), Hindi (`hi`), Telugu (`te`).

---

## Assets Convention

```
assets/
├── fonts/
│   ├── Moul/
│   ├── Montserrat/
│   └── Plus_Jakarta_Sans/
└── images/
    ├── png/    ← raster images
    └── svg/    ← vector icons & illustrations
```

Reference paths via `AppAssets.someImage` constants defined in `core/constants/app_assets.dart`.

---

## Adding a New Feature — Checklist

1. Create `lib/features/<feature_name>/` folder.
2. Add `<feature_name>_binding.dart`.
3. Add `controllers/<feature_name>_controller.dart` (extends `GetxController`).
4. Add `data/<feature_name>_data_source.dart` (calls `NetworkService`).
5. Add `repositories/<feature_name>_repository.dart`.
6. Add `models/` for request/response DTOs.
7. Add `views/<feature_name>_screen.dart`.
8. Register route in `lib/routes/app_routes.dart` (constant) and `lib/routes/app_pages.dart` (GetPage).
9. If needed, add any reusable DS components to `core/design_system/molecules/` or `organisms/`.
