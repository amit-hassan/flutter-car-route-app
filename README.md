# 🚗 Flutter Car Route Application

**Interactive mobile application to select two points on a map and instantly view the optimal car route with distance and estimated time.**  
This project is built following **production-level coding standards** with **GetX modular architecture, GetX state management, and comprehensive testing**.

## 📌 Features Implemented

### **Core Features**
- ✅ **Interactive Map Interface**
  - Pan, zoom, and view real-time location.
  - Google Maps integration with smooth camera animations.
- ✅ **Point-and-Select Functionality**
  - Tap once to select **origin**, tap again to select **destination**.
  - Origin and Destination markers with **reverse geocoded addresses**.
- ✅ **Real-time Route Display**
  - Fetches and displays **optimal car route** using Google Directions API.
  - Shows **distance & estimated travel time**.
 
  ## 🔐 API Key Security

This application integrates with **Google Maps SDK** and **Google Directions API** for route planning.

### How API Keys are Handled
- API keys are **not hardcoded** in the public repository.
- Keys are **stored securely** using:
  - **Local environment variables** for development (Android Studio Env Config)
  - **AndroidManifest placeholders** for debug builds (Local.properties file in Android folder)
- The **debug APK** includes a **development key** to demonstrate full functionality.

> ⚠️ For production deployment, API keys should be restricted to your app’s SHA-1 and package name to prevent unauthorized usage.


### **Bonus Features**
- ✅ **Robust State Management**
  - **GetX** used for reactive UI and clean state management.
  - Handles GPS, permissions, internet status, and map interactions efficiently.
- ✅ **Offline & Error Handling**
  - Shows **red banner** when offline.
  - Handles **GPS disabled**, **permission denied**, and **no route found** gracefully.
- ✅ **Production-Level Code**
  - Modular folder structure.
  - Separation of concerns (Services, Controllers, Views).
  - **Unit & Integration Tests** included.
- ✅ **User-Friendly UX**
  - Floating instruction card:
    - `"Tap to select origin"` → `"Tap to select destination"`
    - Displays **origin & destination names** once selected.
  - bottom card showing **distance and duration**.
  - Floating action buttons for:
    - **Recenter map**
    - **Clear route**

---

## Project Structure

```
flutter_car_route_app/
└─ 
  lib/
   └─ app/
     ├─ data/
     │   ├─ helpers/
     │   │   ├─ connectivity_helper.dart      # Monitors network connectivity
     │   │   ├─ helpers.dart                  # Common utility functions
     │   │   ├─ permission_helper.dart        # Location permission handling
     │   │   └─ toast_helper.dart             # Toast/notification utilities
     │   │
     │   ├─ models/
     │   │   ├─ models.dart                   # General models
     │   │   └─ route_model.dart              # Car route & polyline model
     │   │
     │   └─ services/
     │       ├─ location_service.dart         # Handles GPS & location updates
     │       ├─ map_service.dart              # Manages map markers & styles
     │       ├─ network_service.dart          # Dio client & API communication
     │       ├─ route_service.dart            # Fetches directions & polyline
     │       └─ services.dart                 # Service exports
     │
     ├─ modules/
     │   └─ home/
     │       ├─ home_binding.dart             # GetX DI setup for Home module
     │       ├─ home_controller.dart          # Business logic & state mgmt
     │       └─ home_view.dart                # UI & map interactions
     │
     ├─ routes/
     │   ├─ app_pages.dart                    # Page configurations
     │   └─ app_routes.dart                   # Named routes for navigation
     │
     ├─ shared/
     │   ├─ constants/
     │   │   ├─ api_keys.dart                 # API keys for external services
     │   │   ├─ app_strings.dart              # Centralized app strings
     │   │   ├─ constants.dart                # Global constants
     │   │   └─ map_styles.dart               # Google Map style JSON
     │   │
     │   └─ widgets/
     │       ├─ error_message.dart            # Reusable error message widget
     │       ├─ info_card.dart                # UI card for route & tips
     │       └─ widgets.dart                  # Widget exports
     │
     └─ main.dart                             # Application entry point
```

> ✅ This follows **GetX Modular Architecture** with `View`, `Controller`, `Services`, and `Helpers`.

---

## ✨ Features

### Core Map & Routing Features
- **Interactive Map Interface**: Dynamic map supporting pan, zoom, and tap gestures for location selection.
- **Point-and-Select Functionality**: Precise on-map selection for origin and destination points.
- **Real-time Route Calculation**: Fetches and displays the optimal car route using the Google Directions API.
- **Dynamic Polyline Rendering**: Visually draws the calculated path on the map.
- **Route Information Display**: Shows key metrics like estimated distance and travel time.
- **Custom Map Markers**: Unique, asset-based icons for origin and destination.
- **Live Location Awareness**: Fetches and centers on the user's current GPS position on demand.

### Architecture & State Management (GetX)
- **Dependency Injection**: Decoupled and testable architecture using `GetX Bindings` for all services.
- **Reactive State Management**: Efficiently updates specific UI components using reactive variables (`.obs`) and boolean flags for state.
- **Service-Oriented Architecture**: Business logic is cleanly separated into modular, single-responsibility services (Location, Routing, Map, etc.).
- **SOLID Principles**: Code is structured following professional standards like the Single Responsibility and Dependency Inversion principles.

### UI/UX & Theming
- **Modern, Layered UI**: Professional, "Google Map-like" interface with floating panels and non-intrusive overlays on the map.
- **State-Driven UI Components**: UI components appear and change based on the controller's state.
- **Light/Dark Mode Theming**: Complete theme support with custom JSON-based map styles for dark modes.
- **Optimized Widget Builds**: `Obx` is used efficiently on small, specific widgets to prevent unnecessary rebuilds of heavy components like the map.

### Robustness & Error Handling
- **Graceful Permission Handling**: A dedicated flow to check for location permissions, guiding the user to app settings.
- **GPS Service Check**: Detects if the device's GPS is enabled and provides clear user prompts.
- **Offline Awareness**: Monitors internet connectivity and provides clear, non-blocking feedback to the user.
- **Integrated Error Display**: Shows permission and network errors cleanly within the UI.
- **Lifecycle-Aware Checks**: Automatically re-checks permissions when the user returns to the app from settings.

---

## ⚙️ Setup & Installation

1. **Clone Repository**
   ```bash
   git clone [https://github.com/<your-username>/car_route_app.git](https://github.com/amit-hassan/flutter-car-route-app)
   cd car_route_app

## 🛠 Technology Stack

### **Core Technologies**
| Technology       | Version      | Purpose                     |
|-----------------|-------------|-----------------------------|
| **Flutter**      | >=3.19.0     | Cross-platform UI framework |
| **Dart**         | >=3.3.4      | Programming language        |
| **GetX**         | ^4.7.2       | State management & DI       |
| **Google Maps**  | ^2.2.5      | Interactive maps & routing  |

### **Network & Data**
| Technology               | Version       | Purpose                           |
|--------------------------|--------------|-----------------------------------|
| **Dio**                  | ^5.8.0+1       | HTTP client for API requests      |
| **Geolocator**           | ^12.0.0     | Get current location              |
| **Geocoding**            | ^4.0.0       | Reverse geocoding for addresses   |
| **flutter_polyline_points** | ^2.1.0   | Decode route polylines            |
| **Connectivity Plus**    | ^6.1.4       | Internet connectivity checks      |

### **Development Tools**
| Technology               | Version       | Purpose                            |
|--------------------------|--------------|------------------------------------|
| **flutter_lints**        | ^3.0.0       | Code linting and best practices    |
| **mockito**              | ^5.4.2       | Unit testing with mocks            |
| **integration_test**     | latest        | Integration and E2E testing        |


### Test Structure
```
test/
├── unit/           # Unit tests 
└── integration/    # Integration tests
```
### Environment Setup

1. **Flutter Doctor**: Ensure Flutter is properly installed
   ```bash
   flutter doctor
   ```

2. **IDE Setup**: Configure your IDE with Flutter extensions
   - **Android Studio**: Flutter plugin

3. **Platform Setup**: Configure platform-specific settings
   - **Android**: Update `android/app/build.gradle`
   - **iOS**: Update `ios/Runner/Info.plist`
  
### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget/home_view_test.dart

# Run with coverage
flutter test --coverage
```
### Code Style
- Follow [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- Use provided linting rules
- Add tests for new features
- Update documentation
  
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
