import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:nutrition_app/auth/login_page.dart';
import 'package:nutrition_app/core/theme.dart';
import 'package:nutrition_app/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences _prefs = await SharedPreferences.getInstance();

  final bool onboarded = _prefs.getBool('onboarded') ?? false;

  await dotenv.load(fileName: ".env");

  var apiKey = dotenv.env['GEMINI_API_KEY']!;

  Gemini.init(apiKey: apiKey);
  runApp(MyApp(onboarded: onboarded));
}

class MyApp extends StatelessWidget {
  final bool onboarded;
  const MyApp({super.key, required this.onboarded});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Wrapper(onboarded: onboarded),
    );
  }
}

class Wrapper extends StatelessWidget {
  final bool onboarded;
  const Wrapper({super.key, required this.onboarded});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return onboarded ? const LoginPage() : const OnboardingScreen();
    } else {
      return HomePage();
    }
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding.png',
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleLarge,
                      children: [
                        TextSpan(text: 'Track your'),
                        TextSpan(
                          text: ' Nutrition',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Theme.of(context).focusColor),
                        ),
                        TextSpan(text: ', Track your'),
                        TextSpan(
                          text: ' Health',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Theme.of(context).focusColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const LoginPage()),
                            (Route<dynamic> route) => false);

                        final SharedPreferences _prefs =
                            await SharedPreferences.getInstance();
                        await _prefs.setBool('onboarded', true);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).focusColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text(
                        'Get Started',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                ])),
          )
        ],
      ),
    );
  }
}
