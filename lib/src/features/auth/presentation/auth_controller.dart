import 'package:nutriary_fe/src/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initial state is null (idle)
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = await ref.read(authRepositoryProvider).login(email, password);
      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: token);
      print('Login Success: $token'); 
    });
  }

  Future<void> register(String email, String password, String name, String username) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).register(email, password, name, username)
    );
  }
}
