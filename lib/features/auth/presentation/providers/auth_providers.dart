import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(client: Supabase.instance.client);
});

/// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: dataSource);
});

/// Use Cases Providers
final loginUseCaseProvider = Provider<Login>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return Login(repository);
});

/// Current user provider
final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  final result = await repository.getCurrentUser();

  return result.fold((failure) => null, (user) => user);
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthRepository _repository;
  final Login _loginUseCase;

  AuthNotifier({
    required AuthRepository repository,
    required Login loginUseCase,
  }) : _repository = repository,
       _loginUseCase = loginUseCase,
       super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _loginUseCase.call(
      LoginParams(email: email, password: password),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final result = await _repository.logout();

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>((ref) {
      return AuthNotifier(
        repository: ref.read(authRepositoryProvider),
        loginUseCase: ref.read(loginUseCaseProvider),
      );
    });
