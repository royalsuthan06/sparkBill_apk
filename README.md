# SparkBill

An offline-first Point of Sale (POS) and billing management system built with Flutter. A single unified codebase that runs natively on **Android**, **iOS**, **Linux**, **Windows**, **macOS**, and **Web** with adaptive UI and optimized performance across all screen sizes.

## Features

- **Cross-Platform** -- Single codebase for Android, iOS, Linux, Windows, macOS, and Web
- **Adaptive UI** -- NavigationRail on desktop/tablet, bottom nav bar on mobile; grid layout for inventory on wide screens
- **Quick Billing** -- SKU search with fuzzy autocomplete, quantity stepper, and instant cart management
- **PDF Invoice Generation** -- Native A4 PDF invoices with branded layout and store metadata
- **Printing** -- Direct print via system spooler on all platforms (browser print dialog on web)
- **Inventory Management** -- Full product CRUD with category filters, price sorting, and price-range filtering
- **Sales Reports** -- Daily, weekly, yesterday, and custom date range analytics with total sales, bill counts, and avg. bill
- **Offline-First** -- 100% local persistence via `SharedPreferences`; no internet required
- **Invoice Reprinting** -- Reprint or void any previous transaction from the reports view

## Supported Platforms

| Platform | Status | Notes |
|---|---|---|
| Android | ✅ | APK build, minSdk from Flutter |
| iOS | ✅ | Xcode project included |
| Linux | ✅ | GTK desktop build |
| Windows | ✅ | CMake desktop build |
| macOS | ✅ | Xcode desktop build |
| Web | ✅ | Chrome/Edge/Firefox, PDF via browser print |

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.12.x / Dart 3.x |
| State Management | Provider |
| PDF Generation | `pdf` + `printing` |
| Persistence | `shared_preferences` |
| Fonts | Google Fonts (Work Sans, JetBrains Mono) |

## Project Structure

```
lib/
├── main.dart                    # App entry, adaptive theme, provider setup
├── data/
│   └── initial_products.dart    # Seed catalog (fireworks inventory)
├── models/
│   ├── bill.dart                # Bill entity (invoice)
│   ├── billed_item.dart         # Line item entity
│   └── product.dart             # Product catalog entity
├── providers/
│   └── pos_provider.dart        # Central state management (cart, inventory, bills)
├── utils/
│   ├── money.dart               # INR currency formatting helpers
│   ├── platform_helper.dart     # Cross-platform detection utilities
│   └── responsive.dart          # Adaptive layout breakpoints and helpers
├── views/
│   ├── billing_view.dart        # POS billing screen with cart
│   ├── home_screen.dart         # Adaptive nav (Rail on desktop, Bar on mobile)
│   ├── inventory_view.dart      # Product catalog with filters, grid on wide screens
│   └── reports_view.dart        # Sales analytics with summary cards
└── widgets/
    ├── add_product_sheet.dart   # Bottom sheet form for adding products
    ├── invoice_dialog.dart      # Receipt preview dialog with PDF generation
    └── stepper_input.dart       # Custom quantity stepper input widget
```

## Getting Started

### Prerequisites

- Flutter SDK 3.12.x or later
- Dart SDK 3.x
- Android Studio / VS Code with Flutter extension

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/sparkbill.git
cd sparkbill

# Install dependencies
flutter pub get

# Run the app (auto-detects connected device)
flutter run

# Run on specific platform
flutter run -d android
flutter run -d chrome
flutter run -d linux
flutter run -d windows
```

### Build

```bash
# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# iOS
flutter build ios --release

# Linux Desktop
flutter build linux --release
# Output: build/linux/x64/release/bundle/sparkbill

# Windows Desktop
flutter build windows --release
# Output: build/windows/x64/runner/Release/sparkbill.exe

# macOS
flutter build macos --release

# Web
flutter build web --release
# Output: build/web/
```

## Architecture

```
Presentation (Views/Widgets)  --  Adaptive layouts per screen size
        │
        │  listen / dispatch
        ▼
State Management (POSProvider - ChangeNotifier)
        │
        │  read / write
        ▼
Storage (SharedPreferences - JSON serialized)
```

- **Models** -- `Product`, `BilledItem`, `Bill` with JSON serialization
- **POSProvider** -- Central `ChangeNotifier` managing cart, inventory, bill history, and sequential invoice numbering (`BL-000001`)
- **Data Persistence** -- All products and bills are serialized to `SharedPreferences` as JSON; seeded from embedded catalog on first launch
- **Responsive Layout** -- `home_screen.dart` uses `NavigationRail` on desktop/tablet (width >= 1024px) and `BottomNavigationBar` on mobile; `inventory_view.dart` switches to grid view on wide screens (width >= 900px)

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
