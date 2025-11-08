# Development Guide - Cangkang Sawit App

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.9.2+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Git

### Setup Development Environment

1. **Clone Repository**

   ```bash
   git clone <repository-url>
   cd cangkang_sawit_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Setup Supabase**

   - Follow instructions in `docs/SUPABASE_SETUP.md`
   - Update `lib/core/constants/app_constants.dart` with your Supabase credentials

4. **Run Application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # App constants and enums
│   │   └── app_constants.dart
│   └── services/              # External services
│       └── supabase_service.dart
├── features/                  # Feature modules
│   ├── auth/                  # Authentication feature
│   │   ├── providers/         # Riverpod providers
│   │   ├── screens/           # UI screens
│   │   └── widgets/           # Feature-specific widgets
│   ├── admin/                 # Admin dashboard feature
│   ├── mitra/                 # Mitra bisnis feature
│   ├── driver/                # Driver feature
│   └── tracking/              # Real-time tracking feature
├── shared/                    # Shared components
│   ├── models/                # Data models
│   ├── repositories/          # Data access layer
│   ├── providers/             # Global providers
│   └── widgets/               # Reusable widgets
└── main.dart                  # App entry point
```

## 🏗️ Architecture

### Clean Architecture Layers

1. **Presentation Layer** (`features/*/screens/` & `features/*/widgets/`)

   - UI Components (Screens, Widgets)
   - State Management (Riverpod Providers)

2. **Domain Layer** (`shared/models/`)

   - Business Models
   - Use Cases (Business Logic)

3. **Data Layer** (`shared/repositories/` & `core/services/`)
   - Repositories (Data Sources Abstraction)
   - Services (External APIs)

### State Management with Riverpod

```dart
// Provider Example
final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(repository);
});

// Consumer in Widget
class OrdersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (orders) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

## 📱 Feature Development

### Creating New Feature

1. **Create Feature Directory**

   ```
   lib/features/new_feature/
   ├── providers/
   ├── screens/
   └── widgets/
   ```

2. **Create Models**

   ```dart
   // lib/shared/models/new_model.dart
   class NewModel {
     final String id;
     final String name;

     NewModel({required this.id, required this.name});

     factory NewModel.fromJson(Map<String, dynamic> json) {
       return NewModel(
         id: json['id'],
         name: json['name'],
       );
     }
   }
   ```

3. **Create Repository**

   ```dart
   // lib/shared/repositories/new_repository.dart
   class NewRepository {
     final SupabaseService _supabaseService;

     NewRepository(this._supabaseService);

     Future<List<NewModel>> getAll() async {
       final response = await _supabaseService.database()
         .from('new_table')
         .select();

       return response.map((json) => NewModel.fromJson(json)).toList();
     }
   }
   ```

4. **Create Provider**

   ```dart
   // lib/features/new_feature/providers/new_provider.dart
   final newRepositoryProvider = Provider((ref) {
     final supabaseService = ref.watch(supabaseServiceProvider);
     return NewRepository(supabaseService);
   });

   final newDataProvider = FutureProvider<List<NewModel>>((ref) {
     final repository = ref.watch(newRepositoryProvider);
     return repository.getAll();
   });
   ```

5. **Create Screen**
   ```dart
   // lib/features/new_feature/screens/new_screen.dart
   class NewScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final data = ref.watch(newDataProvider);

       return Scaffold(
         appBar: AppBar(title: Text('New Feature')),
         body: data.when(
           data: (items) => ListView.builder(...),
           loading: () => Center(child: CircularProgressIndicator()),
           error: (error, stack) => ErrorWidget(error),
         ),
       );
     }
   }
   ```

### Adding Navigation

```dart
// lib/core/router/app_router.dart
GoRoute(
  path: '/new-feature',
  builder: (context, state) => NewScreen(),
),
```

## 🎨 UI Development Guidelines

### Design System

#### Colors

```dart
// Use Material 3 Color Scheme
final colorScheme = Theme.of(context).colorScheme;

// Primary colors
colorScheme.primary
colorScheme.onPrimary
colorScheme.primaryContainer

// Surface colors
colorScheme.surface
colorScheme.onSurface
colorScheme.surfaceVariant
```

#### Typography

```dart
// Use Material 3 Typography
final textTheme = Theme.of(context).textTheme;

Text('Title', style: textTheme.headlineMedium)
Text('Body', style: textTheme.bodyLarge)
Text('Caption', style: textTheme.labelSmall)
```

#### Spacing & Sizing

```dart
// Use ScreenUtil for responsive design
SizedBox(height: 16.h)         // Height
SizedBox(width: 20.w)          // Width
EdgeInsets.all(16.r)           // Padding/Margin
Container(
  width: 100.w,                // Responsive width
  height: 50.h,                // Responsive height
)
```

### Component Guidelines

#### Loading States

```dart
// Use consistent loading indicators
AsyncValue.when(
  data: (data) => DataWidget(data),
  loading: () => Center(
    child: CircularProgressIndicator(),
  ),
  error: (error, stack) => ErrorState(
    error: error,
    onRetry: () => ref.refresh(dataProvider),
  ),
)
```

#### Error Handling

```dart
// Create reusable error widget
class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64.r),
        SizedBox(height: 16.h),
        Text('Terjadi kesalahan'),
        if (onRetry != null) ...[
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Coba Lagi'),
          ),
        ],
      ],
    );
  }
}
```

#### Form Validation

```dart
// Use consistent form validation
class FormValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }
    if (!value.contains('@')) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    if (!value.startsWith('+62') && !value.startsWith('08')) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }
}
```

## 🔄 Data Flow

### CRUD Operations Pattern

```dart
// Repository pattern for data operations
class ExampleRepository {
  final SupabaseService _supabaseService;

  // CREATE
  Future<ExampleModel> create(ExampleModel item) async {
    final response = await _supabaseService.database()
      .from('examples')
      .insert(item.toJson())
      .select()
      .single();

    return ExampleModel.fromJson(response);
  }

  // READ
  Future<List<ExampleModel>> getAll() async {
    final response = await _supabaseService.database()
      .from('examples')
      .select();

    return response.map((json) => ExampleModel.fromJson(json)).toList();
  }

  // UPDATE
  Future<ExampleModel> update(String id, Map<String, dynamic> updates) async {
    final response = await _supabaseService.database()
      .from('examples')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    return ExampleModel.fromJson(response);
  }

  // DELETE
  Future<void> delete(String id) async {
    await _supabaseService.database()
      .from('examples')
      .delete()
      .eq('id', id);
  }
}
```

### State Management Pattern

```dart
// StateNotifier for complex state management
class ExampleNotifier extends StateNotifier<AsyncValue<List<ExampleModel>>> {
  final ExampleRepository _repository;

  ExampleNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await _repository.getAll();
      state = AsyncValue.data(data);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addItem(ExampleModel item) async {
    try {
      final newItem = await _repository.create(item);
      state = state.whenData((current) => [...current, newItem]);
    } catch (error) {
      // Handle error
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> updates) async {
    try {
      final updatedItem = await _repository.update(id, updates);
      state = state.whenData((current) =>
        current.map((item) => item.id == id ? updatedItem : item).toList()
      );
    } catch (error) {
      // Handle error
    }
  }
}
```

## 🧪 Testing Strategy

### Unit Tests

```dart
// test/unit/repositories/example_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late ExampleRepository repository;
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
    repository = ExampleRepository(mockService);
  });

  group('ExampleRepository', () {
    test('should return list of examples when getAll is called', () async {
      // Arrange
      when(mockService.database()).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.from('examples')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn([
        {'id': '1', 'name': 'Test'}
      ]);

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result, isA<List<ExampleModel>>());
      expect(result.length, 1);
    });
  });
}
```

### Widget Tests

```dart
// test/widget/screens/example_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('ExampleScreen displays loading initially', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ExampleScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cangkang_sawit_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login flow test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Find login form
    expect(find.byType(TextField), findsNWidgets(2)); // Email & Password

    // Enter credentials
    await tester.enterText(
      find.byKey(Key('email_field')),
      'test@example.com'
    );
    await tester.enterText(
      find.byKey(Key('password_field')),
      'password123'
    );

    // Tap login button
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();

    // Verify navigation to home screen
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

## 🚀 Deployment

### Build Commands

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release

# Split APKs by ABI
flutter build apk --split-per-abi --release
```

### Environment Configuration

```dart
// lib/core/config/environment.dart
enum Environment {
  development,
  staging,
  production,
}

class Config {
  static Environment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.development;
    }
  }

  static String get supabaseUrl {
    switch (environment) {
      case Environment.production:
        return 'https://prod-project.supabase.co';
      case Environment.staging:
        return 'https://staging-project.supabase.co';
      default:
        return 'https://dev-project.supabase.co';
    }
  }
}
```

Build with environment:

```bash
flutter build apk --dart-define=ENV=production
```

## 📊 Performance Guidelines

### Optimization Tips

1. **Use const constructors**

   ```dart
   const Text('Static text')
   const Icon(Icons.home)
   ```

2. **Avoid expensive operations in build methods**

   ```dart
   // ❌ Bad
   Widget build(BuildContext context) {
     final expensiveData = calculateExpensiveData();
     return Text(expensiveData);
   }

   // ✅ Good
   late final String expensiveData = calculateExpensiveData();
   Widget build(BuildContext context) {
     return Text(expensiveData);
   }
   ```

3. **Use ListView.builder for large lists**

   ```dart
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) => ItemWidget(items[index]),
   )
   ```

4. **Optimize images**
   ```dart
   Image.network(
     imageUrl,
     cacheWidth: 300,
     cacheHeight: 200,
   )
   ```

### Memory Management

- Use `AutomaticKeepAliveClientMixin` for tabs that should stay alive
- Dispose controllers in `dispose()` method
- Cancel timers and streams in `dispose()`
- Use `WeakReference` for large objects when appropriate

## 🔍 Debugging

### Debug Tools

1. **Flutter Inspector** - Visual debugging
2. **Network Inspector** - API calls monitoring
3. **Performance View** - Performance analysis
4. **Memory View** - Memory usage tracking

### Logging

```dart
// lib/core/utils/logger.dart
import 'dart:developer' as developer;

class Logger {
  static void info(String message, [String? name]) {
    developer.log(message, name: name ?? 'INFO');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message) {
    developer.log(message, name: 'DEBUG');
  }
}

// Usage
Logger.info('User logged in');
Logger.error('Failed to load data', error, stackTrace);
```

## 🤝 Contributing Guidelines

### Code Style

1. Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
2. Use `dart format` to format code
3. Run `dart analyze` to check for issues
4. Maximum line length: 80 characters

### Git Workflow

1. **Branch naming**:

   - `feature/feature-name`
   - `bugfix/bug-description`
   - `hotfix/critical-fix`

2. **Commit messages**:

   ```
   feat: add user authentication
   fix: resolve login validation issue
   docs: update API documentation
   refactor: improve code structure
   test: add unit tests for repository
   ```

3. **Pull Request**:
   - Create descriptive PR title
   - Add detailed description
   - Include screenshots for UI changes
   - Ensure all tests pass

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] No console errors or warnings
- [ ] Performance considerations addressed
- [ ] Security considerations reviewed
- [ ] Documentation updated if needed

---

📚 **Additional Resources:**

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart)
