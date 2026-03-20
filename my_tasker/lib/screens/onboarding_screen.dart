// lib/screens/onboarding_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';
import '../models/models.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _nameCtrl  = TextEditingController();
  final _pageCtrl  = PageController();
  int _page        = 0;
  int _goalMinutes = 120;
  bool _saving     = false;

  late final AnimationController _logoRot;
  late final AnimationController _logoPulse;

  @override
  void initState() {
    super.initState();
    _logoRot   = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _logoPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pageCtrl.dispose();
    _logoRot.dispose();
    _logoPulse.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final name = _nameCtrl.text.trim().isEmpty ? 'শিক্ষার্থী' : _nameCtrl.text.trim();
    final profile = UserProfile(name: name, createdAt: DateTime.now(), dailyGoalMinutes: _goalMinutes);
    await DB.saveProfile(profile);
    final settings = DB.getSettings()
      ..setupDone = true
      ..dailyStudyGoalMinutes = _goalMinutes;
    await DB.saveSettings(settings);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _nextPage() {
    if (_page < 2) {
      _pageCtrl.animateToPage(_page + 1,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          // Progress dots
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(children: List.generate(3, (i) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                height: 3,
                decoration: BoxDecoration(
                  color: i <= _page ? C.primary : C.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ))),
          ),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _page = p),
              children: [
                _WelcomePage(logoRot: _logoRot, logoPulse: _logoPulse),
                _NamePage(controller: _nameCtrl),
                _GoalPage(
                  goalMinutes: _goalMinutes,
                  onChanged: (v) => setState(() => _goalMinutes = v),
                ),
              ],
            ),
          ),
          // Bottom button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(children: [
              SizedBox(
                width: double.infinity,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _saving ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _page == 2 ? 'শুরু করুন' : 'পরবর্তী',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
              if (_page > 0) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pageCtrl.animateToPage(_page - 1,
                      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                  child: Text('পেছনে যান',
                      style: TextStyle(color: C.textSub, fontSize: 14)),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Page 1: Welcome ─────────────────────────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final AnimationController logoRot, logoPulse;
  const _WelcomePage({required this.logoRot, required this.logoPulse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Animated logo large
        AnimatedBuilder(
          animation: Listenable.merge([logoRot, logoPulse]),
          builder: (_, __) => CustomPaint(
            size: const Size(120, 120),
            painter: _BigLogoPainter(logoRot.value, logoPulse.value),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 32),
        Text('মাই ট্যাস্কার-এ',
            style: TextStyle(color: C.textSub, fontSize: 18, fontWeight: FontWeight.w400))
            .animate().fadeIn(delay: 200.ms),
        Text('স্বাগতম!',
            style: TextStyle(color: C.primary, fontSize: 36, fontWeight: FontWeight.w800,
                letterSpacing: -1.0))
            .animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        const SizedBox(height: 20),
        Text(
          'পড়াশোনার পরিকল্পনা, অভ্যাস ট্র্যাকিং ও মাসিক রিপোর্ট — সব এক জায়গায়।',
          textAlign: TextAlign.center,
          style: TextStyle(color: C.textSub, fontSize: 16, height: 1.6),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 40),
        // Feature pills
        Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
          children: [
            _FeaturePill(Icons.task_alt_outlined, 'কাজ ট্র্যাক', C.primary),
            _FeaturePill(Icons.repeat_outlined, 'অভ্যাস গঠন', C.green),
            _FeaturePill(Icons.menu_book_outlined, 'পড়াশোনা', C.accent),
            _FeaturePill(Icons.picture_as_pdf_outlined, 'PDF রিপোর্ট', C.yellow),
          ],
        ).animate().fadeIn(delay: 500.ms),
      ]),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _FeaturePill(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 15),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _BigLogoPainter extends CustomPainter {
  final double rot, pulse;
  _BigLogoPainter(this.rot, this.pulse);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;
    canvas.drawCircle(Offset(cx, cy), r * 0.9,
        Paint()..color = C.primary.withOpacity(0.08 + pulse * 0.1)
               ..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset(cx, cy), r * 0.65,
        Paint()..color = C.accent.withOpacity(0.2)
               ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rot * 2 * math.pi);
    final tr = r * 0.34;
    canvas.drawPath(
        Path()..moveTo(0, -tr)..lineTo(tr * 0.866, tr * 0.5)..lineTo(-tr * 0.866, tr * 0.5)..close(),
        Paint()..color = C.primary..style = PaintingStyle.fill);
    canvas.drawPath(
        Path()..moveTo(0, tr * 0.7)..lineTo(tr * 0.6, -tr * 0.35)..lineTo(-tr * 0.6, -tr * 0.35)..close(),
        Paint()..color = C.accent.withOpacity(0.65)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset.zero, r * 0.08,
        Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.restore();
    for (int i = 0; i < 3; i++) {
      final angle = rot * 2 * math.pi + i * 2 * math.pi / 3;
      canvas.drawCircle(
          Offset(cx + r * 0.72 * math.cos(angle), cy + r * 0.72 * math.sin(angle)),
          3.5, Paint()..color = C.primary.withOpacity(0.3 + pulse * 0.5));
    }
  }
  @override bool shouldRepaint(_BigLogoPainter o) => true;
}

// ── Page 2: Name ────────────────────────────────────────────────────────────────
class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  const _NamePage({required this.controller});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: C.primaryDim, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.person_outline, color: C.primary, size: 36),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
      const SizedBox(height: 28),
      Text('আপনার নাম কী?',
          style: TextStyle(color: C.text, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5))
          .animate().fadeIn(delay: 100.ms),
      const SizedBox(height: 10),
      Text('এই নাম অ্যাপের মধ্যে ও PDF রিপোর্টে দেখা যাবে।',
          textAlign: TextAlign.center,
          style: TextStyle(color: C.textSub, fontSize: 15))
          .animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 32),
      TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(color: C.text, fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'যেমন: Nowshad, Rafi, Ayesha...',
          hintStyle: TextStyle(color: C.textHint, fontSize: 16),
          prefixIcon: const Icon(Icons.badge_outlined, color: C.primary),
          filled: true,
          fillColor: C.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: C.primary, width: 1.8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),
      const SizedBox(height: 16),
      Text('নাম না দিলে "শিক্ষার্থী" ব্যবহার হবে।',
          style: TextStyle(color: C.textHint, fontSize: 13))
          .animate().fadeIn(delay: 400.ms),
    ]),
  );
}

// ── Page 3: Daily Goal ─────────────────────────────────────────────────────────
class _GoalPage extends StatelessWidget {
  final int goalMinutes;
  final ValueChanged<int> onChanged;
  const _GoalPage({required this.goalMinutes, required this.onChanged});

  String _fmt(int m) {
    if (m < 60) return '$m মিনিট';
    final h = m ~/ 60, rem = m % 60;
    return rem == 0 ? '$h ঘণ্টা' : '$h ঘ $rem মি';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: C.yellow.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Icon(Icons.track_changes_outlined, color: C.yellow, size: 36),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
      const SizedBox(height: 28),
      Text('দৈনিক লক্ষ্যমাত্রা',
          style: TextStyle(color: C.text, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5))
          .animate().fadeIn(delay: 100.ms),
      const SizedBox(height: 10),
      Text('প্রতিদিন কতক্ষণ পড়াশোনা করতে চান?',
          textAlign: TextAlign.center,
          style: TextStyle(color: C.textSub, fontSize: 15))
          .animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 40),
      // Goal display
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: C.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.primary.withOpacity(0.25)),
        ),
        child: Column(children: [
          Text(_fmt(goalMinutes),
              style: TextStyle(color: C.primary, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text('প্রতিদিনের লক্ষ্য', style: TextStyle(color: C.textSub, fontSize: 14)),
        ]),
      ).animate().fadeIn(delay: 300.ms),
      const SizedBox(height: 28),
      // Stepper buttons
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _StepBtn(Icons.remove, () => onChanged((goalMinutes - 15).clamp(15, 480))),
        const SizedBox(width: 20),
        Text('১৫ মিনিট করে', style: TextStyle(color: C.textSub, fontSize: 13)),
        const SizedBox(width: 20),
        _StepBtn(Icons.add, () => onChanged((goalMinutes + 15).clamp(15, 480))),
      ]).animate().fadeIn(delay: 400.ms),
      const SizedBox(height: 24),
      // Preset chips
      Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
        children: [30, 60, 90, 120, 180, 240].map((m) {
          final sel = goalMinutes == m;
          return GestureDetector(
            onTap: () => onChanged(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? C.primary : C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? C.primary : C.border),
              ),
              child: Text(_fmt(m),
                  style: TextStyle(
                      color: sel ? Colors.white : C.textSub,
                      fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
            ),
          );
        }).toList(),
      ).animate().fadeIn(delay: 500.ms),
    ]),
  );
}

class _StepBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _StepBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
          color: C.primaryDim, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.primary.withOpacity(0.25))),
      child: Icon(icon, color: C.primary, size: 22),
    ),
  );
}
