import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  const testEmail = 'test@example.com';
  const testVerificationId = 'kjhkjfd';
  const testPhone = '123456';
  const testCountryCode = '123456';

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (context) => mockAuthBloc,
        child: const OtpVerificationPage(verificationId: testVerificationId, phone: testPhone, countryCode: testCountryCode,),
      ),
    );
  }

  testWidgets('OtpPage should render correctly', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('OTP Verification'), findsOneWidget);
    expect(find.text('Enter the verification code sent to $testEmail'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.text('Resend Code'), findsOneWidget);
  });

  testWidgets('Verify button should be disabled when OTP is empty', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    final verifyButton = find.text('Verify');

    // Assert
    expect(tester.widget<ElevatedButton>(verifyButton).enabled, isFalse);
  });

  testWidgets('Verify button should be enabled when OTP is entered', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    const testOtp = '123456';

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byKey(const Key('otpField')), testOtp);
    await tester.pump();

    // Assert
    final verifyButton = find.text('Verify');
    expect(tester.widget<ElevatedButton>(verifyButton).enabled, isTrue);
  });

  testWidgets('Should show loading indicator when state is AuthLoading', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthLoading());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should show error message when state is AuthError', (WidgetTester tester) async {
    // Arrange
    const errorMessage = 'Invalid OTP';
    when(() => mockAuthBloc.state).thenReturn(AuthError(message: errorMessage));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
  });
}
