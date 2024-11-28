import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_gill/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set the duration for the splash screen to be visible
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to the next screen after the duration
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Make the splash screen full screen and hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Text(
          'TheGill',
          style: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
