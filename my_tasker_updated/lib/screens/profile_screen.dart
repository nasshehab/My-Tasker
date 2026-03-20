// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';
import '../widgets/widgets.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl   = TextEditingController();
  final _geminiCtrl = TextEditingController();
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text   = DB.getProfile().name;
    _geminiCtrl.text = DB.getSettings().geminiApiKey ?? '';
  }

  @override
  void dispose() { _nameCtrl.dispose(); _geminiCtrl.dispose(); super.dispose(); }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img == null) return;
    final p = DB.getProfile()..photoPath = img.path;
    await DB.saveProfile(p);
    ref.read(profileProvider.notifier).refresh();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final profile  = ref.watch(profileProvider);
    final isOnline = ref.watch(connectivityProvider).value ?? false;

    return Scaffold(
      backgroundColor: C.bg,
      body: CustomScrollView(slivers: [
        // Hero app bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: C.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [C.primary, Color(0xFF2563EB)],
                  ),
                ),
              ),
              // Decorative circles
              Positioned(top: -20, right: -20, child: Container(width: 120, height: 120,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
              Positioned(bottom: 20, left: -30, child: Container(width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
              Positioned.fill(child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(children: [
                        Container(
                          width: 76, height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: ClipOval(
                            child: profile.photoPath != null
                                ? Image.file(File(profile.photoPath!), fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 40))
                                : const Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                        ),
                        Positioned(bottom: 0, right: 0, child: Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 13),
                        )),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_editingName)
                          TextField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                              isDense: true, contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) async {
                              setState(() => _editingName = false);
                              if (_nameCtrl.text.trim().isNotEmpty) {
                                final p = DB.getProfile()..name = _nameCtrl.text.trim();
                                await DB.saveProfile(p);
                                ref.read(profileProvider.notifier).refresh();
                              }
                            },
                          )
                        else
                          Row(children: [
                            Expanded(child: Text(profile.name, style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                            GestureDetector(
                              onTap: () => setState(() => _editingName = true),
                              child: const Icon(Icons.edit_outlined, color: Colors.white60, size: 18),
                            ),
                          ]),
                        const SizedBox(height: 4),
                        const Text('মাই ট্যাস্কার ব্যবহারকারী',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    )),
                  ]),
                ),
              )),
            ]),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Stats
              Row(children: [
                Expanded(child: StatTile(label: 'মোট পড়া',
                    value: K.fmtDuration(profile.totalStudyMinutes),
                    icon: Icons.timer_outlined, color: C.primary)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(label: 'বর্তমান ধারা',
                    value: '${K.tobn(profile.currentStreak)} দিন',
                    icon: Icons.local_fire_department, color: C.accent)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(label: 'সর্বোচ্চ',
                    value: '${K.tobn(profile.longestStreak)} দিন',
                    icon: Icons.emoji_events_outlined, color: C.yellow)),
              ]).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 20),

              // Daily goal
              const SHead(title: 'দৈনিক লক্ষ্যমাত্রা'),
              SCard(child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: C.primaryDim, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.track_changes, color: C.primary, size: 22)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('প্রতিদিনের পড়াশোনার লক্ষ্য',
                      style: TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('সময় নির্ধারণ করুন', style: TextStyle(color: C.textSub, fontSize: 12)),
                ])),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: C.textSub),
                  onPressed: () async {
                    final p = DB.getProfile();
                    p.dailyGoalMinutes = (p.dailyGoalMinutes - 15).clamp(15, 720);
                    await DB.saveProfile(p);
                    ref.read(profileProvider.notifier).refresh();
                  },
                ),
                Text(K.fmtDuration(profile.dailyGoalMinutes),
                    style: const TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: C.primary),
                  onPressed: () async {
                    final p = DB.getProfile();
                    p.dailyGoalMinutes = (p.dailyGoalMinutes + 15).clamp(15, 720);
                    await DB.saveProfile(p);
                    ref.read(profileProvider.notifier).refresh();
                  },
                ),
              ])),
              const SizedBox(height: 16),

              // History
              const SHead(title: 'কার্যক্রমের ইতিহাস'),
              SCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                child: const Row(children: [
                  Icon(Icons.history, color: C.primary, size: 22), SizedBox(width: 12),
                  Expanded(child: Text('সব কার্যক্রম দেখুন',
                      style: TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w500))),
                  Icon(Icons.chevron_right, color: C.textHint),
                ]),
              ),
              const SizedBox(height: 10),
              SCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: const Row(children: [
                  Icon(Icons.settings_outlined, color: C.primary, size: 22), SizedBox(width: 12),
                  Expanded(child: Text('সেটিংস',
                      style: TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w500))),
                  Icon(Icons.chevron_right, color: C.textHint),
                ]),
              ),
              const SizedBox(height: 16),

              // AI
              const SHead(title: 'AI সেটিংস'),
              SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: isOnline ? C.primaryDim : C.surface2,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.auto_awesome, color: isOnline ? C.primary : C.textHint, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AI পড়াশোনা সহায়ক',
                        style: TextStyle(color: isOnline ? C.text : C.textSub, fontSize: 14, fontWeight: FontWeight.w500)),
                    Text(isOnline ? 'Gemini AI দ্বারা পরিচালিত' : 'ইন্টারনেট সংযোগ প্রয়োজন',
                        style: const TextStyle(color: C.textSub, fontSize: 12)),
                  ])),
                  if (!isOnline) const Icon(Icons.wifi_off, color: C.textHint, size: 18),
                ]),
                if (isOnline) ...[
                  const SizedBox(height: 12),
                  TextField(controller: _geminiCtrl,
                      style: const TextStyle(color: C.text), obscureText: true,
                      decoration: const InputDecoration(
                          hintText: 'Gemini API Key লিখুন',
                          prefixIcon: Icon(Icons.key_outlined, color: C.textHint))),
                  const SizedBox(height: 10),
                  PBtn(label: 'API Key সেভ করুন', fullWidth: true,
                    onTap: () async {
                      final s = DB.getSettings()..geminiApiKey = _geminiCtrl.text.trim();
                      await DB.saveSettings(s);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('API Key সেভ হয়েছে')));
                    }),
                ],
              ])),
              const SizedBox(height: 28),

              // Developer card
              _buildDevCard(),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildDevCard() => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [C.primaryDim, Color(0xFFEEF2FF)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: C.primary.withOpacity(0.2)),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ডেভেলপার',
          style: TextStyle(color: C.textHint, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
      const SizedBox(height: 14),
      Row(children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.primary.withOpacity(0.3), width: 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/images/developer_photo.jpg', fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset('assets/images/developer_photo.png', fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: C.primaryDim,
                  child: const Icon(Icons.person, color: C.primary, size: 36)))),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nowshad Abrar Shehab',
              style: TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w700)),
          SizedBox(height: 2),
          Text('Developer',
              style: TextStyle(color: C.primary, fontSize: 12, fontWeight: FontWeight.w500)),
        ])),
      ]),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _ContactBtn(Icons.email_outlined, 'ইমেইল', C.primary,
            () => _launch('mailto:shehab.eidgah2006@gmail.com')),
        _ContactBtn(Icons.facebook_outlined, 'ফেসবুক', const Color(0xFF1877F2),
            () => _launch('https://www.facebook.com/nowshadabrarshehab')),
        _ContactBtn(Icons.chat_outlined, 'হোয়াটসঅ্যাপ', C.green,
            () => _launch('https://wa.me/8801855841672')),
      ]),
    ]),
  );
}

class _ContactBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ContactBtn(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Press(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15), const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}
