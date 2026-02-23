import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const HeartFormulaApp());
}

class HeartFormulaApp extends StatelessWidget {
  const HeartFormulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Formula',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Georgia',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A1A1A),
          secondary: Color(0xFFE8322A),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// LOGO WIDGET
// ─────────────────────────────────────────────
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Heart Formula',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Georgia',
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE8322A),
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SPLASH SCREEN
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.32, curve: Curves.easeIn),
      ),
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.68, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward().then((_) {
      if (mounted) {
        // Use pushReplacement so splash is removed from stack entirely
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AgeInputScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final opacity =
            _ctrl.value < 0.68 ? _fadeIn.value : _fadeOut.value;
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: _Logo(),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN 1 — Age Input
// FIX: removed fade-out-then-navigate pattern.
// Now navigates directly — the page route handles the fade.
// ─────────────────────────────────────────────
class AgeInputScreen extends StatefulWidget {
  const AgeInputScreen({super.key});

  @override
  State<AgeInputScreen> createState() => _AgeInputScreenState();
}

class _AgeInputScreenState extends State<AgeInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ageCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final age = int.tryParse(_ageCtrl.text.trim());
    if (age == null || age > 120) {
      setState(() => _error = 'Please enter a valid age');
      return;
    }
    if (age < 16) {
      setState(() => _error = 'You must be 16 or older to use this app');
      return;
    }

    // FIX: Navigate directly without reversing the fade animation first.
    // The previous reverse() left a blank screen in the nav stack.
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PartnerTypeScreen(age: age),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                _Logo(),
                const SizedBox(height: 72),
                const Text(
                  'What is your age?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You must be 16 or older to use this app.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF888888),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: true,
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -2,
                  ),
                  decoration: InputDecoration(
                    hintText: '25',
                    hintStyle: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade200,
                      letterSpacing: -2,
                    ),
                    border: InputBorder.none,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xFFE0E0E0), width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xFF1A1A1A), width: 2),
                    ),
                    errorText: _error,
                    errorStyle: const TextStyle(
                      color: Color(0xFFE8322A),
                      fontSize: 13,
                    ),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN 2 — Younger or Older?
// FIX: same navigation fix — no reverse() before push
// FIX: corrected formula assignment for each partner type
// ─────────────────────────────────────────────
class PartnerTypeScreen extends StatefulWidget {
  final int age;
  const PartnerTypeScreen({super.key, required this.age});

  @override
  State<PartnerTypeScreen> createState() => _PartnerTypeScreenState();
}

class _PartnerTypeScreenState extends State<PartnerTypeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) return;

    // FIX: Corrected formulas
    // If YOU are the OLDER partner → find youngest you can date = (your age / 2) + 7
    // If YOU are the YOUNGER partner → find oldest you can date = (your age - 7) * 2
    final double result = _selected == 'older'
        ? (widget.age / 2.0) + 7   // youngest the older person can date
        : (widget.age - 7) * 2.0;  // oldest the younger person can date

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(
          myAge: widget.age,
          partnerType: _selected!,
          result: result,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                _Logo(),
                const SizedBox(height: 72),
                const Text(
                  'Are you the younger\nor older partner?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This helps us apply the right formula.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 40),
                _ChoiceCard(
                  label: 'I am the older partner',
                  subtitle: 'Find the youngest age I can date',
                  emoji: '🌳',
                  selected: _selected == 'older',
                  onTap: () => setState(() => _selected = 'older'),
                ),
                const SizedBox(height: 16),
                _ChoiceCard(
                  label: 'I am the younger partner',
                  subtitle: 'Find the oldest age I can date',
                  emoji: '🌱',
                  selected: _selected == 'younger',
                  onTap: () => setState(() => _selected = 'younger'),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected != null ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6BFF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCCDDFF),
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Calculate',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F5FF) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
            selected ? const Color(0xFF1A6BFF) : const Color(0xFFE8E8E8),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF1A6BFF)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF1A6BFF), size: 22),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCREEN 3 — Result
// ─────────────────────────────────────────────
class ResultScreen extends StatefulWidget {
  final int myAge;
  final String partnerType;
  final double result;

  const ResultScreen({
    super.key,
    required this.myAge,
    required this.partnerType,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _restart() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AgeInputScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOlder = widget.partnerType == 'older';
    final label = isOlder
        ? 'The youngest person\nyou should date is'
        : 'The oldest person\nyou should date is';
    final int resultAge = widget.result.round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                _Logo(),
                const SizedBox(height: 72),
                SlideTransition(
                  position: _slide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555),
                          height: 1.4,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$resultAge',
                            style: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                              height: 1,
                              letterSpacing: -4,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16, left: 6),
                            child: Text(
                              'yrs',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFAAAAAA),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 14, left: 2),
                            child: Text(
                              '.',
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE8322A),
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isOlder
                            ? 'Based on the universal dating rule, the youngest person you are compatible with is $resultAge.'
                            : 'Based on the universal dating rule, the oldest person you are compatible with is $resultAge.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF888888),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _restart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Over',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}