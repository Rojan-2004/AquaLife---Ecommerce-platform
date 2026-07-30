import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/features/auth/presentation/state/auth_state.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';

void main() {
  group('AuthState Tests', () {
    test('initial state should have correct default values', () {
      final state = AuthState.initial();

      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isSuccess, false);
      expect(state.user, isNull);
    });

test('copyWith should update only provided values', () {
       const user = AuthEntity(
         authId: '1',
         fullName: 'Test User',
         email: 'test@example.com',
         username: 'testuser',
       );

       final state = AuthState(
         isLoading: false,
         error: null,
         isSuccess: true,
         user: user,
       );

       final updated = state.copyWith(
         isLoading: true,
         error: 'Some error',
       );

       expect(updated.isLoading, true);
       expect(updated.error, 'Some error');
       expect(updated.isSuccess, true);
       expect(updated.user, user);
     });

     test('copyWith with all nulls should return identical state', () {
      const user = AuthEntity(
        authId: '1',
        fullName: 'Test User',
        email: 'test@example.com',
        username: 'testuser',
      );

      final state = AuthState(
        isLoading: true,
        error: 'Error',
        isSuccess: true,
        user: user,
      );

      final copy = state.copyWith();

      expect(copy.isLoading, state.isLoading);
      expect(copy.error, state.error);
      expect(copy.isSuccess, state.isSuccess);
      expect(copy.user, state.user);
    });
  });
}
