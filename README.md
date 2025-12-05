# Cangkang Sawit App

Flutter application for managing palm shell (cangkang sawit) business operations with role-based access for Admin, Mitra Bisnis, and Drivers.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and configurations
│   ├── config/             # App configurations (feature flags, etc.)
│   ├── constants/          # Constants and enums
│   ├── errors/             # Error handling
│   ├── helpers/            # Helper functions
│   ├── services/           # Low-level services (Supabase)
│   └── utils/              # Utility functions
│
├── shared/                 # Shared across features
│   ├── models/            # Data models
│   ├── providers/         # Riverpod providers
│   ├── repositories/      # Data repositories
│   ├── services/          # Business services
│   └── widgets/           # Reusable widgets
│
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   │   ├── controllers/  # Business logic
│   │   ├── pages/        # UI screens
│   │   └── widgets/      # Feature-specific widgets
│   ├── admin/            # Admin features
│   ├── mitra/            # Mitra Bisnis features
│   └── driver/           # Driver features
│
└── main.dart             # App entry point
```

## 🎯 Key Features

### For Admin
- Dashboard with statistics
- Order management
- Shipment tracking
- User management
- Reports and analytics

### For Mitra Bisnis
- Product catalog
- Order placement
- Inventory management
- Sales tracking

### For Drivers
- Task management
- Delivery tracking
- Route optimization
- Proof of delivery

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Backend**: Supabase
- **UI**: Material Design 3
- **Maps**: Google Maps Flutter
- **Responsive**: Flutter ScreenUtil

## 📦 Key Packages

```yaml
dependencies:
  flutter_riverpod: ^2.x      # State management
  supabase_flutter: ^2.x      # Backend & Auth
  flutter_screenutil: ^5.x    # Responsive UI
  google_maps_flutter: ^2.x   # Maps integration
  flutter_dotenv: ^5.x        # Environment variables
  intl: ^0.x                  # Internationalization
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Supabase account

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd cangkang_sawit_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   Create `.env` file in root:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏛️ Code Standards

### Clean Architecture Principles
1. **Separation of Concerns**: UI, Business Logic, Data layers are separate
2. **Dependency Rule**: Inner layers don't depend on outer layers
3. **Single Responsibility**: Each class has one reason to change

### State Management
- Use **Riverpod** for all state management
- Controllers handle business logic
- UI only displays state and dispatches events

### Error Handling
- Use `Result<T>` pattern for operations that can fail
- User-friendly error messages via `ErrorMessages` helper
- Proper exception handling at all layers

### Feature Flags
- Use `FeatureFlags` to enable/disable features
- Show "Coming Soon" for disabled features
- Easy to toggle features for testing

## 📁 Project Structure Details

### Controllers
Located in `features/*/controllers/`
- Handle business logic
- Manage state with Riverpod
- Delegate to repositories/services

Example:
```dart
class LoginController extends Notifier<LoginState> {
  Future<void> login({required String email, required String password}) {
    // Business logic here
  }
}
```

### Repositories
Located in `shared/repositories/`
- Handle data operations
- Return `Result<T>` for error handling
- Use services for actual API calls

### Services
Located in `shared/services/`
- Low-level API calls
- Supabase queries
- Data transformation

### Models
Located in `shared/models/`
- Data classes
- JSON serialization
- Immutable where possible

## 🎨 UI Guidelines

### Responsive Design
- Use `ScreenUtil` for all sizes (`.w`, `.h`, `.sp`, `.r`)
- Design size: 375x812 (iPhone X)
- Support both portrait and landscape

### Colors
- Primary: `Color(0xFF1B5E20)` (Green)
- Background: `Color(0xFFF5F5F5)` (Light Gray)
- Error: `Colors.red`
- Success: `Colors.green`

### Widgets
- Reusable widgets in `shared/widgets/`
- Feature-specific widgets in `features/*/widgets/`
- Use composition over inheritance

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📝 Contributing

1. Follow the existing architecture
2. Use enums instead of magic numbers
3. Add documentation to public APIs
4. Write tests for new features
5. Use feature flags for incomplete features

## 📄 License

[Your License Here]

## 👥 Team

[Your Team Information]

---

**Note**: This is a production-ready codebase following clean architecture and best practices. All P0 (Critical) and P1 (High Priority) refactoring tasks have been completed.
