import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (context) => mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('LoginPage should render correctly', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Don\'t have an account?'), findsOneWidget);
  });

  testWidgets('Login button should be disabled when form is empty', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    final loginButton = find.byType(ElevatedButton);

    // Assert
    expect(tester.widget<ElevatedButton>(loginButton).enabled, isFalse);
  });

  testWidgets('Login button should be enabled when form is valid', (WidgetTester tester) async {
    // Arrange
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Enter email
    await tester.enterText(find.byKey(const Key('emailField')), testEmail);
    // Enter password
    await tester.enterText(find.byKey(const Key('passwordField')), testPassword);
    
    await tester.pump(); // Rebuild the widget with the new state

    // Assert
    final loginButton = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(loginButton).enabled, isTrue);
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
    const errorMessage = 'Invalid credentials';
    when(() => mockAuthBloc.state).thenReturn(AuthError(message: errorMessage));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
  });
}
