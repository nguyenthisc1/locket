import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_firebase_repository.dart';
import 'package:locket/domain/auth/usecases_firebase/email_login_usecase.dart';

import 'sign_in_usecase_test.mocks.dart';

@GenerateMocks([AuthFirebaseRepository])
void main() {
  late EmailLoginUseCase emailLoginUseCase;
  late MockAuthFirebaseRepository mockAuthFirebaseRepository;

  setUp(() {
    mockAuthFirebaseRepository = MockAuthFirebaseRepository();
    emailLoginUseCase = EmailLoginUseCase(mockAuthFirebaseRepository);
  });

  const email = 'test@example.com';
  const password = '123456';
  final user = UserEntity(
    uid: 'abc123',
    email: email,
    phoneNumber: null,
    displayName: 'Test User',
    photoUrl: null,
    isEmailVerified: true,
  );

  group('emailLoginUseCase', () {
    test('should return UserEntity when login is successful', () async {
      // Arrange
      when(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(email, password),
      ).thenAnswer((_) async => user);

      // Act
      final result = await emailLoginUseCase(email, password);

      // Assert
      expect(result, Right(user));
      verify(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(email, password),
      ).called(1);
      verifyNoMoreInteractions(mockAuthFirebaseRepository);
    });

    test('should return AuthFailure when email is empty', () async {
      // Act
      final result = await emailLoginUseCase('', password);

      // Assert
      expect(
        result,
        Left(AuthFailure(message: 'Email and password cannot be empty')),
      );
      verifyNever(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(any, any),
      );
    });

    test('should return AuthFailure when password is empty', () async {
      // Act
      final result = await emailLoginUseCase(email, '');

      // Assert
      expect(
        result,
        Left(AuthFailure(message: 'Email and password cannot be empty')),
      );
      verifyNever(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(any, any),
      );
    });

    test(
      'should return AuthFailure when both email and password are empty',
      () async {
        // Act
        final result = await emailLoginUseCase('', '');

        // Assert
        expect(
          result,
          Left(AuthFailure(message: 'Email and password cannot be empty')),
        );
        verifyNever(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(any, any),
        );
      },
    );

    test(
      'should return AuthFailure when email contains only whitespace',
      () async {
        // Act
        final result = await emailLoginUseCase('   ', password);

        // Assert
        expect(
          result,
          Left(AuthFailure(message: 'Email and password cannot be empty')),
        );
        verifyNever(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(any, any),
        );
      },
    );

    test(
      'should return AuthFailure when password contains only whitespace',
      () async {
        // Act
        final result = await emailLoginUseCase(email, '   ');

        // Assert
        expect(
          result,
          Left(AuthFailure(message: 'Email and password cannot be empty')),
        );
        verifyNever(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(any, any),
        );
      },
    );

    test('should trim email and password before calling repository', () async {
      // Arrange
      when(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(email, password),
      ).thenAnswer((_) async => user);

      // Act
      final result = await emailLoginUseCase('  $email  ', '  $password  ');

      // Assert
      expect(result, Right(user));
      verify(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(email, password),
      ).called(1);
      verifyNoMoreInteractions(mockAuthFirebaseRepository);
    });

    test(
      'should return AuthFailure when repository throws exception',
      () async {
        // Arrange
        when(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(
            email,
            password,
          ),
        ).thenThrow(Exception('Login failed'));

        // Act
        final result = await emailLoginUseCase(email, password);

        // Assert
        expect(result, Left(AuthFailure(message: 'Đăng nhập thất bại')));
        verify(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(
            email,
            password,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthFirebaseRepository);
      },
    );

    test(
      'should return AuthFailure when repository throws specific auth error',
      () async {
        // Arrange
        when(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(
            email,
            password,
          ),
        ).thenThrow(StateError('User not found'));

        // Act
        final result = await emailLoginUseCase(email, password);

        // Assert
        expect(result, Left(AuthFailure(message: 'Đăng nhập thất bại')));
        verify(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(
            email,
            password,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthFirebaseRepository);
      },
    );

    test(
      'should return the same Failure when repository throws Failure',
      () async {
        // Arrange
        final authFailure = AuthFailure(message: 'Custom auth error');
        when(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(
            email,
            password,
          ),
        ).thenThrow(authFailure);

        // Act
        final result = await emailLoginUseCase(email, password);

        // Assert
        expect(result, Left(authFailure));
        verify(
          mockAuthFirebaseRepository.signInWithEmailAndPassword(
            email,
            password,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthFirebaseRepository);
      },
    );

    test('should handle user with minimal data', () async {
      // Arrange
      final minimalUser = UserEntity(
        uid: 'minimal123',
        email: email,
        phoneNumber: null,
        displayName: null,
        photoUrl: null,
        isEmailVerified: false,
      );

      when(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(email, password),
      ).thenAnswer((_) async => minimalUser);

      // Act
      final result = await emailLoginUseCase(email, password);

      // Assert
      expect(result, Right(minimalUser));
      expect(result.fold((l) => null, (r) => r.uid), 'minimal123');
      expect(result.fold((l) => null, (r) => r.isEmailVerified), false);
      verify(
        mockAuthFirebaseRepository.signInWithEmailAndPassword(email, password),
      ).called(1);
      verifyNoMoreInteractions(mockAuthFirebaseRepository);
    });
  });
}
