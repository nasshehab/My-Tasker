// lib/widgets/widgets.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

// ─── Animated Brand Logo ───────────────────────────────────────────────────────
class AppLogo extends StatefulWidget {
  final double size;
  final bool showText;
  const AppLogo({super.key, this.size = 36, this.showText = false});
  @override State<AppLogo> createState() => _AppLogoState();
}
class _AppLogoState extends State<AppLogo> with TickerProviderStateMixin {
  late final AnimationController _rot;
  late final AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _rot   = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  }
  @override void dispose() { _rot.dispose(); _pulse.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(
        animation: Listenable.merge([_rot, _pulse]),
        builder: (_, __) => CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _LogoPainter(_rot.value, _pulse.value),
        ),
      ),
      if (widget.showText) ...[
        const SizedBox(width: 8),
        Text('মাই ট্যাস্কার', style: TextStyle(
          color: C.primary, fontSize: widget.size * 0.44,
          fontWeight: FontWeight.w700,
        )),
      ],
    ]);
  }
}

class _LogoPainter extends CustomPainter {
  final double rot, pulse;
  _LogoPainter(this.rot, this.pulse);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;
    canvas.drawCircle(Offset(cx, cy), r * 0.9,
      Paint()..color = C.primary.withOpacity(0.10 + pulse * 0.12)
             ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(Offset(cx, cy), r * 0.60,
      Paint()..color = C.accent.withOpacity(0.30)
             ..style = PaintingStyle.stroke..strokeWidth = 1.2);
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rot * 2 * math.pi);
    final tr = r * 0.34;
    final tri = Path()..moveTo(0, -tr)..lineTo(tr * 0.866, tr * 0.5)..lineTo(-tr * 0.866, tr * 0.5)..close();
    canvas.drawPath(tri, Paint()..color = C.primary..style = PaintingStyle.fill);
    final tri2 = Path()..moveTo(0, tr * 0.7)..lineTo(tr * 0.6, -tr * 0.35)..lineTo(-tr * 0.6, -tr * 0.35)..close();
    canvas.drawPath(tri2, Paint()..color = C.accent.withOpacity(0.65)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset.zero, r * 0.08, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.restore();
    for (int i = 0; i < 3; i++) {
      final angle = rot * 2 * math.pi + i * 2 * math.pi / 3;
      canvas.drawCircle(
        Offset(cx + r * 0.72 * math.cos(angle), cy + r * 0.72 * math.sin(angle)),
        2.5,
        Paint()..color = C.primary.withOpacity(0.35 + pulse * 0.5)..style = PaintingStyle.fill,
      );
    }
  }
  @override bool shouldRepaint(_LogoPainter old) => true;
}

// ─── Press ─────────────────────────────────────────────────────────────────────
class Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const Press({super.key, required this.child, this.onTap, this.onLongPress});
  @override State<Press> createState() => _PressState();
}
class _PressState extends State<Press> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _c     = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => _c.forward(),
    onTapUp:     (_) { _c.reverse(); widget.onTap?.call(); },
    onTapCancel: () => _c.reverse(),
    onLongPress: widget.onLongPress,
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}

// ─── SCard ─────────────────────────────────────────────────────────────────────
class SCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;
  final BoxBorder? border;
  const SCard({super.key, required this.child, this.padding, this.color,
      this.radius = 16, this.onTap, this.border});
  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? C.surface,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: C.border, width: 1),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Press(onTap: onTap, child: card);
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────
class SHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SHead({super.key, required this.title, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
    child: Row(children: [
      Text(title, style: const TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w700)),
      const Spacer(),
      if (action != null)
        GestureDetector(onTap: onAction,
            child: Text(action!, style: const TextStyle(color: C.primary, fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );
}

// ─── Primary Button ────────────────────────────────────────────────────────────
class PBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outline;
  final bool fullWidth;
  const PBtn({super.key, required this.label, this.onTap,
      this.icon, this.outline = false, this.fullWidth = false});
  @override
  Widget build(BuildContext context) => Press(
    onTap: onTap,
    child: Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : C.primary,
        border: outline ? Border.all(color: C.primary, width: 1.5) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: outline ? C.primary : Colors.white), const SizedBox(width: 8)],
          Text(label, style: TextStyle(
            color: outline ? C.primary : Colors.white,
            fontWeight: FontWeight.w700, fontSize: 15,
          )),
        ],
      ),
    ),
  );
}

// ─── Stat Tile ─────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const StatTile({super.key, required this.label, required this.value,
      required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.18)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 34, height: 34,
        decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: color, size: 19)),
      const SizedBox(height: 9),
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 1),
      Text(label, style: const TextStyle(color: C.textSub, fontSize: 11)),
    ]),
  );
}

// ─── Priority Badge ────────────────────────────────────────────────────────────
class PriorityBadge extends StatelessWidget {
  final int priority;
  const PriorityBadge({super.key, required this.priority});
  @override
  Widget build(BuildContext context) {
    final labels = ['কম', 'মধ্যম', 'জরুরি'];
    final colors = [C.green, C.yellow, C.red];
    final bgs    = [C.greenDim, C.yellowDim, C.redDim];
    final p      = priority.clamp(0, 2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgs[p], borderRadius: BorderRadius.circular(6)),
      child: Text(labels[p], style: TextStyle(color: colors[p], fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Progress Bar ──────────────────────────────────────────────────────────────
class PBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  const PBar({super.key, required this.value, this.color, this.height = 6});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      backgroundColor: C.border,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? C.primary),
      minHeight: height,
    ),
  );
}

// ─── Week Date Strip ───────────────────────────────────────────────────────────
class WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  const WeekStrip({super.key, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days  = List.generate(7, (i) {
      final offset = i - 3;
      return DateTime(today.year, today.month, today.day + offset);
    });
    const dayNames = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'];
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final d     = days[i];
          final isSel = K.dateKey(d) == K.dateKey(selected);
          final isTod = K.dateKey(d) == K.dateKey(today);
          return Press(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              decoration: BoxDecoration(
                color: isSel ? C.primary : isTod ? C.primaryDim : C.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: isSel ? C.primary : isTod ? C.primary.withOpacity(0.4) : C.border),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(dayNames[(d.weekday - 1) % 7],
                    style: TextStyle(color: isSel ? Colors.white.withOpacity(0.75) : C.textSub,
                        fontSize: 9, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(K.tobn(d.day),
                    style: TextStyle(color: isSel ? Colors.white : isTod ? C.primary : C.text,
                        fontSize: 17, fontWeight: FontWeight.w700)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ─── Week Dots ─────────────────────────────────────────────────────────────────
// NOTE: parameter is `startOfWeek` (not `weekStart`)
class WeekDots extends StatelessWidget {
  final Map<String, bool> log;
  final DateTime startOfWeek;
  const WeekDots({super.key, required this.log, required this.startOfWeek});
  @override
  Widget build(BuildContext context) {
    const labels = ['শু', 'শ', 'র', 'সো', 'মঙ', 'বু', 'বৃ'];
    final today  = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final d      = startOfWeek.add(Duration(days: i));
        final key    = K.dateKey(d);
        final done   = log[key];
        final isTod  = key == K.dateKey(today);
        final past   = d.isBefore(DateTime(today.year, today.month, today.day));
        Color bg, textColor, borderColor;
        if (done == true) {
          bg = C.green; textColor = Colors.white; borderColor = C.green;
        } else if (past && done != true) {
          bg = C.redDim; textColor = C.red; borderColor = C.red.withOpacity(0.4);
        } else {
          bg = C.surface2; textColor = C.textSub; borderColor = C.border;
        }
        return Column(children: [
          Text(labels[i], style: const TextStyle(color: C.textHint, fontSize: 9)),
          const SizedBox(height: 4),
          Container(
            width: 33, height: 33,
            decoration: BoxDecoration(
              color: bg, shape: BoxShape.circle,
              border: Border.all(color: isTod ? C.primary : borderColor, width: isTod ? 2.0 : 1.5),
            ),
            child: Center(child: Text(K.tobn(d.day),
                style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w600))),
          ),
        ]);
      }),
    );
  }
}

// ─── Color Picker ─────────────────────────────────────────────────────────────
class ColorPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const ColorPicker({super.key, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: C.palette.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => Press(
        onTap: () => onSelect(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: C.palette[i], shape: BoxShape.circle,
            border: selected == i ? Border.all(color: C.text, width: 2.5) : null,
          ),
          child: selected == i ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
        ),
      ),
    ),
  );
}

// ─── Icon Picker ──────────────────────────────────────────────────────────────
const List<IconData> kIcons = [
  Icons.menu_book_outlined, Icons.science_outlined, Icons.calculate_outlined,
  Icons.history_edu_outlined, Icons.computer, Icons.language,
  Icons.music_note_outlined, Icons.sports_soccer, Icons.palette_outlined,
  Icons.psychology_outlined, Icons.biotech_outlined, Icons.architecture,
  Icons.electric_bolt, Icons.eco_outlined, Icons.public, Icons.medical_services_outlined,
];

class IconPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const IconPicker({super.key, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8,
    children: kIcons.map((ic) {
      final isSel = selected == ic.codePoint;
      return Press(
        onTap: () => onSelect(ic.codePoint),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isSel ? C.primary : C.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? C.primary : C.border),
          ),
          child: Icon(ic, color: isSel ? Colors.white : C.textSub, size: 22),
        ),
      );
    }).toList(),
  );
}

// ─── Empty View ────────────────────────────────────────────────────────────────
class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 72, height: 72,
          decoration: BoxDecoration(color: C.primaryDim, borderRadius: BorderRadius.circular(20)),
          child: Icon(icon, color: C.primary, size: 36)),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: C.textSub, fontSize: 14), textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ─── Sheet Handle ─────────────────────────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(2))),
  );
}

// ─── Offline Banner ────────────────────────────────────────────────────────────
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: C.yellowDim,
    child: const Row(children: [
      Icon(Icons.wifi_off, color: C.yellow, size: 16),
      SizedBox(width: 8),
      Expanded(child: Text('অফলাইন — AI সুবিধা পাওয়া যাচ্ছে না',
          style: TextStyle(color: C.yellow, fontSize: 12, fontWeight: FontWeight.w500))),
    ]),
  );
}
