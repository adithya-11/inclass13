import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
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
        chipTheme: ChipThemeData(
          backgroundColor: blue.withOpacity(0.18),
          selectedColor: gold.withOpacity(0.18),
          labelStyle: const TextStyle(color: Colors.white),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

/// ---------------- Welcome Screen ----------------
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
                // Animated title
                SizedBox(
                  height: 130,
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
                      // modern param name
                      isRepeatingAnimation: false,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'A dark-themed, interactive signup journey — gold & blue vibes ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: gold.withOpacity(0.86)),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text('Begin Adventure'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: Text('Jump straight to signup',
                      style: TextStyle(color: blue.withOpacity(0.9))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- Signup Screen ----------------
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';
  int? _selectedAvatarIndex;

  // validation flags for bounce check
  final List<bool> _fieldValid = [false, false, false];

  // progress 0..1
  double _progress = 0.0;
  final Set<int> _milestonesTriggered = {};

  // confetti
  late ConfettiController _confettiController;

  // shake
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  bool _showInvalidTooltip = false;

  final List<String> avatarEmojis = ['🧭', '🦊', '🐉', '🪄', '🧑‍🚀'];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  double _passwordStrength(String pw) {
    if (pw.isEmpty) return 0.0;
    double score = 0;
    if (pw.length >= 8) score += 0.35;
    if (RegExp(r'[A-Z]').hasMatch(pw)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(pw)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pw)) score += 0.25;
    return score.clamp(0.0, 1.0);
  }

  Color _strengthColor(double s) {
    // Map 0->red, 0.5->gold, 1->green for visual clarity (but UI accent is gold & blue)
    if (s < 0.5) {
      return Color.lerp(Colors.red.shade400, const Color(0xFFFFC857), s / 0.5)!;
    } else {
      return Color.lerp(const Color(0xFFFFC857), Colors.green.shade400, (s - 0.5) / 0.5)!;
    }
  }

  void _recalculateProgress() {
    int total = 4;
    int done = 0;
    if (_name.trim().isNotEmpty) done++;
    if (_validateEmail(_email)) done++;
    if (_passwordStrength(_password) >= 0.6) done++;
    if (_selectedAvatarIndex != null) done++;

    double target = done / total;
    setState(() {
      _progress = target;
    });

    int percent = (_progress * 100).round();
    for (int threshold in [25, 50, 75, 100]) {
      if (percent >= threshold && !_milestonesTriggered.contains(threshold)) {
        _milestonesTriggered.add(threshold);
        _triggerMilestone(threshold);
      }
    }
  }

  void _triggerMilestone(int threshold) {
    String msg;
    switch (threshold) {
      case 25:
        msg = 'Great start!';
        break;
      case 50:
        msg = 'Halfway there!';
        break;
      case 75:
        msg = 'Almost done!';
        break;
      case 100:
        msg = 'Ready for adventure!';
        break;
      default:
        msg = '';
    }

    // confetti on significant milestones
    if (threshold >= 50) _confettiController.play();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$msg ($threshold%)'),
        backgroundColor: Colors.black87,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _trySubmit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      _shakeController.forward(from: 0);
      setState(() {
        _showInvalidTooltip = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showInvalidTooltip = false);
      });
      return;
    }
    _formKey.currentState?.save();

    // determine badges
    final now = DateTime.now();
    List<String> badges = [];
    if (_passwordStrength(_password) >= 0.8) badges.add('Strong Password Master');
    if (now.hour < 12) badges.add('The Early Bird Special');
    if (_name.trim().isNotEmpty &&
        _validateEmail(_email) &&
        _passwordStrength(_password) >= 0.6 &&
        _selectedAvatarIndex != null) {
      badges.add('Profile Completer');
    }

    // go to success
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          name: _name,
          avatarIndex: _selectedAvatarIndex ?? 0,
          badges: badges,
        ),
      ),
    );
  }

  Widget _bounceCheck(bool valid) {
    return AnimatedScale(
      scale: valid ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 330),
      curve: Curves.elasticOut,
      child: const Icon(Icons.check_circle, color: Colors.lightGreenAccent, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFFFC857);
    final blue = const Color(0xFF0B3D91);

    return Scaffold(
      appBar: AppBar(title: const Text('Signup Adventure')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset =
                  sin(_shakeController.value * pi * 4) * (_shakeAnim.value);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AdventureProgressWidget(progress: _progress),
                  const SizedBox(height: 14),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Full name',
                                  hintText: 'Your explorer name',
                                  suffixIcon: _bounceCheck(_fieldValid[0]),
                                ),
                                onChanged: (v) {
                                  _name = v;
                                  _fieldValid[0] = v.trim().isNotEmpty;
                                  _recalculateProgress();
                                },
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Please enter your name'
                                        : null,
                                onSaved: (v) => _name = v ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Email
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'example@adventure.com',
                            suffixIcon: _bounceCheck(_fieldValid[1]),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (v) {
                            _email = v;
                            _fieldValid[1] = _validateEmail(v);
                            _recalculateProgress();
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter an email';
                            if (!_validateEmail(v)) return 'Invalid email';
                            return null;
                          },
                          onSaved: (v) => _email = v ?? '',
                        ),
                        const SizedBox(height: 12),

                        // Password
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Make a strong password',
                            suffixIcon: _bounceCheck(_fieldValid[2]),
                          ),
                          obscureText: true,
                          onChanged: (v) {
                            _password = v;
                            final s = _passwordStrength(v);
                            _fieldValid[2] = s >= 0.6;
                            _recalculateProgress();
                          },
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter a password';
                            if (_passwordStrength(v) < 0.35) return 'Password too weak';
                            return null;
                          },
                          onSaved: (v) => _password = v ?? '',
                        ),
                        const SizedBox(height: 8),

                        // Strength meter
                        Builder(builder: (context) {
                          final s = _passwordStrength(_password);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black.withOpacity(0.25),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: s,
                                    minHeight: 10,
                                    backgroundColor: Colors.transparent,
                                    valueColor:
                                        AlwaysStoppedAnimation(_strengthColor(s)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                s <= 0.25
                                    ? 'Very weak'
                                    : s <= 0.5
                                        ? 'Weak'
                                        : s <= 0.75
                                            ? 'Good'
                                            : 'Strong',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 18),

                        // Avatar selection
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose an avatar',
                            style: TextStyle(fontWeight: FontWeight.bold, color: gold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 86,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: avatarEmojis.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final selected = _selectedAvatarIndex == i;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAvatarIndex = i;
                                  });
                                  _recalculateProgress();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.all(selected ? 6 : 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: blue.withOpacity(0.25),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: CircleAvatar(
                                    radius: selected ? 36 : 30,
                                    backgroundColor: selected
                                        ? blue.withOpacity(0.12)
                                        : Colors.grey[900],
                                    child: Text(
                                      avatarEmojis[i],
                                      style: TextStyle(fontSize: selected ? 32 : 26),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),

                        if (_showInvalidTooltip)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.error_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Please fix highlighted fields',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.rocket_launch),
                          label: const Text('Complete Signup'),
                          onPressed: _trySubmit,
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.topCenter,
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            shouldLoop: false,
                            emissionFrequency: 0.04,
                            numberOfParticles: 20,
                            maxBlastForce: 20,
                            minBlastForce: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- Adventure Progress Widget ----------------
class AdventureProgressWidget extends StatefulWidget {
  final double progress; // 0..1
  const AdventureProgressWidget({super.key, required this.progress});

  @override
  State<AdventureProgressWidget> createState() =>
      _AdventureProgressWidgetState();
}

class _AdventureProgressWidgetState extends State<AdventureProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant AdventureProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _milestoneMessage(int pct) {
    if (pct >= 100) return 'Ready for adventure!';
    if (pct >= 75) return 'Almost done!';
    if (pct >= 50) return 'Halfway there!';
    if (pct >= 25) return 'Great start!';
    return 'Begin your adventure!';
  }

  @override
  Widget build(BuildContext context) {
    final percent = (widget.progress * 100).round();
    final gold = const Color(0xFFFFC857);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizeTransition(
                sizeFactor: _anim,
                axis: Axis.horizontal,
                axisAlignment: -1,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 12,
                  backgroundColor: Colors.black.withOpacity(0.25),
                  valueColor: AlwaysStoppedAnimation(gold),
                ),
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
              child: Text('$percent%'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
              _milestoneMessage(percent),
              style: const TextStyle(fontWeight: FontWeight.w600),
            )),
          ],
        )
      ],
    );
  }
}

/// ---------------- Success Screen ----------------
class SuccessScreen extends StatefulWidget {
  final String name;
  final int avatarIndex;
  final List<String> badges;

  const SuccessScreen({
    super.key,
    required this.name,
    required this.avatarIndex,
    required this.badges,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late ConfettiController _confettiController;
  final List<String> avatarEmojis = ['🧭', '🦊', '🐉', '🪄', '🧑‍🚀'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _badgeChip(String badge) {
    IconData icon;
    if (badge.contains('Strong')) icon = Icons.shield;
    else if (badge.contains('Early')) icon = Icons.wb_sunny;
    else icon = Icons.verified;

    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(badge),
      backgroundColor: const Color(0xFF0B3D91),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = avatarEmojis[
        widget.avatarIndex.clamp(0, avatarEmojis.length - 1)];
    final gold = const Color(0xFFFFC857);

    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.name.split(' ').first}!')),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.black.withOpacity(0.25),
                      child: Text(avatar, style: const TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Adventure awaits, ${widget.name}!',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: gold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You unlocked ${widget.badges.length} badge(s).',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: widget.badges.isNotEmpty
                          ? widget.badges.map((b) => _badgeChip(b)).toList()
                          : [
                              Chip(
                                label: const Text('No badges yet — try completing fields'),
                                backgroundColor: Colors.grey.shade800,
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                              )
                            ],
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.explore),
                      label: const Text('Back to Home'),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              maxBlastForce: 25,
            ),
          ),
        ],
      ),
    );
  }
}