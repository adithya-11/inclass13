import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SignupAdventureApp());
}

class SignupAdventureApp extends StatelessWidget {
  const SignupAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF0B3D91);
    final gold = const Color(0xFFFFC857);
    final surface = const Color(0xFF0A0F1A);

    return MaterialApp(
      title: 'Signup Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: surface,
        primaryColor: blue,
        colorScheme: ColorScheme.dark(
          primary: blue,
          secondary: gold,
          background: surface,
          surface: const Color(0xFF0F1724),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF061020),
          foregroundColor: gold,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0B1522),
          labelStyle: TextStyle(color: gold.withOpacity(0.95)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFFFC857);
    final blue = const Color(0xFF0B3D91);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: gold,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: blue.withOpacity(0.6),
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText('Signup Adventure',
                            speed: const Duration(milliseconds: 60)),
                        TypewriterAnimatedText('Make a profile. Earn badges. 🎉',
                            speed: const Duration(milliseconds: 45)),
                      ],
                      isRepeatingAnimation: false,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'A dark-themed, interactive signup journey — gold & blue vibes ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: gold.withOpacity(0.86)),
                ),
                const SizedBox(height: 26),
                ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text('Begin Adventure'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreenStage1()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignupScreenStage1 extends StatefulWidget {
  const SignupScreenStage1({super.key});

  @override
  State<SignupScreenStage1> createState() => _SignupScreenStage1State();
}

class _SignupScreenStage1State extends State<SignupScreenStage1> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  double _progress = 0.0;

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _recalculateProgress() {
    int total = 3;
    int done = 0;
    if (_name.trim().isNotEmpty) done++;
    if (_validateEmail(_email)) done++;
    if (_password.length >= 6) done++;
    setState(() {
      _progress = done / total;
    });
  }

  void _trySubmit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors before continuing')),
      );
      return;
    }
    _formKey.currentState?.save();
    // For stage1 just show a simple dialog success
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signup Complete'),
        content: Text('Welcome, ${_name.split(' ').first}!'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFFFC857);
    return Scaffold(
      appBar: AppBar(title: const Text('Signup Adventure')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // progress
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 12,
                        backgroundColor: Colors.black.withOpacity(0.25),
                        valueColor: AlwaysStoppedAnimation(gold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text('${(_progress*100).round()}%'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Full name'),
                        onChanged: (v) {
                          _name = v;
                          _recalculateProgress();
                        },
                        validator: (v) => (v==null || v.trim().isEmpty) ? 'Enter your name' : null,
                        onSaved: (v) => _name = v ?? '',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (v) {
                          _email = v;
                          _recalculateProgress();
                        },
                        validator: (v) {
                          if (v==null || v.trim().isEmpty) return 'Enter email';
                          final ok = _validateEmail(v);
                          return ok ? null : 'Invalid email';
                        },
                        onSaved: (v) => _email = v ?? '',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (v) {
                          _password = v;
                          _recalculateProgress();
                        },
                        validator: (v) {
                          if (v==null || v.isEmpty) return 'Enter a password';
                          if (v.length < 6) return 'Use at least 6 chars';
                          return null;
                        },
                        onSaved: (v) => _password = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.rocket_launch),
                        label: const Text('Complete Signup'),
                        onPressed: _trySubmit,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}