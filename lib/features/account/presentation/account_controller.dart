import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_model.dart';

part 'account_controller.g.dart';

@riverpod
Future<User> userProfile(UserProfileRef ref) {
  // Mengambil profile dari repository yang datanya bersumber dari lokal
  return ref.watch(authRepositoryProvider).getUserProfile();
}