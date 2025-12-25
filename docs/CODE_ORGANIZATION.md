# Code Organization Guide

## Overview

This document provides guidance on the organization of code in the Cangkang Sawit application following Clean Architecture principles.

---

## ✅ Properly Organized (Clean Architecture)

### Feature-Based Structure

All features now follow Clean Architecture with proper layer separation:

```
lib/features/{feature_name}/
├── domain/
│   ├── entities/        # Pure business objects
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
├── data/
│   ├── models/          # Data transfer objects
│   ├── datasources/     # Remote/local data sources
│   └── repositories/    # Repository implementations
└── presentation/
    ├── pages/           # UI screens
    ├── widgets/         # Feature-specific widgets
    └── providers/       # State management (Riverpod)
```

### Completed Features

- ✅ **Auth** - Authentication & authorization
- ✅ **Products** - Product catalog management
- ✅ **Orders** - Order management
- ✅ **Tracking** - Real-time location tracking
- ✅ **Shipments** - Shipment management
- ✅ **Driver** - Driver delivery management
- ✅ **Admin** - Admin dashboard & monitoring
- ✅ **Mitra** - Partner/customer order tracking
- ✅ **Cart** - Shopping cart (local storage)

---

## 🔧 Core Infrastructure

### Core Layer Structure

```
lib/core/
├── constants/          # App-wide constants
├── di/                # Dependency injection (Riverpod providers)
├── error/             # Error handling (failures, exceptions)
├── router/            # App navigation (go_router)
├── usecase/           # Base use case classes
└── utils/             # Utility functions
```

All core infrastructure is properly organized and follows best practices.

---

## ⚠️ Legacy Code (To Be Cleaned)

### Shared Directory

**Location:** `lib/shared/`

**Status:** Contains legacy code from before Clean Architecture refactoring

**Contents:**

- `models/` - Old model classes (superseded by feature models)
- `repositories/` - Old repository implementations (superseded by feature repositories)
- `services/` - Old service classes (business logic moved to use cases)

**Action Required:**

1. Review each file to ensure no active dependencies
2. Move any still-used code to appropriate features
3. Delete deprecated files
4. Update imports in any remaining files

### Shared Models Analysis

Most models in `lib/shared/models/` are duplicated in features:

- `order.dart` → `lib/features/orders/domain/entities/order.dart`
- `product.dart` → `lib/features/products/domain/entities/product.dart`
- `shipment.dart` → `lib/features/shipments/domain/entities/shipment.dart`
- `driver_location.dart` → `lib/features/tracking/domain/entities/driver_location.dart`
- `user_profile.dart` → `lib/features/auth/domain/entities/user.dart`

### Shared Repositories Analysis

All repositories in `lib/shared/repositories/` have been refactored:

- `auth_repository.dart` → `lib/features/auth/domain/repositories/`
- `product_repository.dart` → `lib/features/products/domain/repositories/`
- `order_repository.dart` → `lib/features/orders/domain/repositories/`
- `shipment_repository.dart` → `lib/features/shipments/domain/repositories/`
- `tracking_repository.dart` → `lib/features/tracking/domain/repositories/`

### Shared Services Analysis

Services have been replaced by use cases:

- `mitra_service.dart` → Replaced by `lib/features/mitra/domain/usecases/`
- `driver_service.dart` → Replaced by `lib/features/driver/domain/usecases/`
- `shipment_service.dart` → Replaced by `lib/features/shipments/domain/usecases/`
- `admin_dashboard_service.dart` → Replaced by `lib/features/admin/domain/usecases/`

**Exception:** `notification_service.dart` and `file_upload_service.dart` may still be in use as they're cross-cutting concerns.

---

## ✨ Shared Widgets

### Truly Shared Widgets

**Location:** `lib/widgets/`

These widgets are genuinely reusable across multiple features:

#### Common Widgets (`lib/widgets/common/`)

- ✅ `buttons.dart` - Reusable button components
- ✅ `cards.dart` - Card components
- ✅ `common_widgets.dart` - Generic widgets
- ✅ `form_elements.dart` - Form inputs
- ✅ `status_badge.dart` - Status indicators
- ✅ `navigation.dart` - Navigation components
- ✅ `logout_button.dart` - Logout functionality

#### Animation Widgets

- ✅ `animation_widgets.dart` - Animation utilities
- ✅ `lottie_animations.dart` - Lottie animation wrappers
- ✅ `professional_animations.dart` - Professional animations
- ✅ `safe_dashboard_wrapper.dart` - Dashboard wrapper

**Status:** These are properly organized and can remain in `lib/widgets/`

---

## 📋 Cleanup Checklist

### Phase 12: Cleanup (To Be Executed)

#### Remove Deprecated Code

- [ ] Delete `lib/shared/models/` (after verifying no dependencies)
- [ ] Delete `lib/shared/repositories/` (after verifying no dependencies)
- [ ] Delete `lib/shared/services/` (except notification & file_upload if still used)
- [ ] Update any remaining imports

#### Code Quality

- [ ] Run `flutter analyze` and fix all issues
- [ ] Run `dart format lib/ test/`
- [ ] Review and update inline comments
- [ ] Check for unused imports

#### Verification

- [ ] Ensure all tests still pass
- [ ] Verify app builds without errors
- [ ] Test all major features manually

---

## 🎯 Best Practices

### Adding New Features

When adding new features, always follow this structure:

```
1. Create feature folder: lib/features/{feature_name}/
2. Create domain layer:
   - entities/     (pure business objects)
   - repositories/ (interface only)
   - usecases/     (business logic)
3. Create data layer:
   - models/       (with fromJson/toJson)
   - datasources/  (API/database calls)
   - repositories/ (implementation)
4. Create presentation layer:
   - providers/    (state management)
   - pages/        (screens)
   - widgets/      (feature-specific UI)
5. Register in DI container: lib/core/di/injection_container.dart
```

### Shared Code Guidelines

**When to put code in `lib/widgets/`:**

- Widget used by 3+ different features
- Generic UI component (buttons, cards, etc.)
- Animation/loading components
- Navigation components

**When to put code in feature folder:**

- Widget specific to one feature
- Business logic related to feature
- Feature-specific state management

**When to put code in `lib/core/`:**

- App-wide constants
- Error handling
- Routing
- Dependency injection
- Utility functions

---

## 📖 Documentation

### Feature Documentation

Each completed phase has comprehensive documentation:

- [Phase 4: Orders](../docs/PHASE-4-COMPLETION-REPORT.md)
- [Phase 5: Tracking](../docs/PHASE-5-COMPLETION-REPORT.md)
- [Phase 6: Shipments](../docs/PHASE-6-COMPLETION-REPORT.md)
- [Phase 7: Driver](../docs/PHASE-7-COMPLETION-REPORT.md)
- [Phase 8: Admin](../docs/PHASE-8-COMPLETION-REPORT.md)
- [Phase 9: Mitra](../docs/PHASE-9-COMPLETION-REPORT.md)
- [Phase 10: Cart](../docs/PHASE-10-COMPLETION-REPORT.md)

---

## 🔄 Migration Status

### Completed Migrations

- ✅ Auth feature - Fully migrated to Clean Architecture
- ✅ Products feature - Fully migrated to Clean Architecture
- ✅ Orders feature - Fully migrated to Clean Architecture
- ✅ Tracking feature - Fully migrated to Clean Architecture
- ✅ Shipments feature - Fully migrated to Clean Architecture
- ✅ Driver feature - Fully migrated to Clean Architecture
- ✅ Admin feature - Fully migrated to Clean Architecture
- ✅ Mitra feature - Fully migrated to Clean Architecture
- ✅ Cart feature - Fully migrated to Clean Architecture

### Pending Cleanup

- ⏳ Remove `lib/shared/models/` (verify dependencies first)
- ⏳ Remove `lib/shared/repositories/` (verify dependencies first)
- ⏳ Remove `lib/shared/services/` (except notification & file_upload)
- ⏳ Update all imports after cleanup

---

## 🚀 Next Steps

1. **Phase 12: Cleanup**

   - Verify no dependencies on legacy code
   - Delete deprecated files
   - Run code quality checks
   - Update documentation

2. **Phase 13: Testing**

   - Ensure unit tests pass
   - Run integration tests
   - Manual testing of all features

3. **Phase 14: Documentation**
   - Update README.md
   - Create architecture diagram
   - Document API endpoints
   - Create developer guide

---

_Last Updated: December 2024_
_Status: 🔧 In Progress (Phase 11)_
