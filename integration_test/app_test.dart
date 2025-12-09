import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:niagara_smart_drip_irrigation/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    // final mockAuth = MockFirebaseAuth();
    
    setUpAll(() async {
      // Initialize Firebase with mock services
      await Firebase.initializeApp();
    });

    testWidgets('Complete sign up flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Verify we're on the login page
      expect(find.text('Welcome Back'), findsOneWidget);
      
      // Tap on 'Sign Up' button to navigate to sign up page
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();
      
      // Fill in the sign up form
      await tester.enterText(find.byKey(const Key('nameField')), 'Test User');
      await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('phoneField')), '+1234567890');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'password123');
      
      // Tap the sign up button
      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pumpAndSettle();
      
      // Verify OTP screen is shown
      expect(find.text('Verify OTP'), findsOneWidget);
      
      // Enter OTP
      for (int i = 0; i < 6; i++) {
        await tester.enterText(find.byKey(Key('otpField$i')), (i + 1).toString());
      }
      
      // Tap verify button
      await tester.tap(find.byKey(const Key('verifyButton')));
      await tester.pumpAndSettle();
      
      // Verify we're on the home page after successful verification
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('Login with email and password', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Enter login credentials
      await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      
      // Tap login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      
      // Verify we're on the home page after successful login
      expect(find.byType(DashboardPage), findsOneWidget);
    });
  });
}
