import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = themeProvider.isDark;

    void editName() {
      final ctrl = TextEditingController(text: settings.userName);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Name',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Your name',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                settings.setUserName(ctrl.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? kBgDark : Colors.white,
      body: Column(
        children: [
          Container(
            color: kPrimary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 14,
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Settings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Profile card
                  GestureDetector(
                    onTap: editName,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: kPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_outline,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(settings.userName,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ),
                          const Icon(Icons.edit,
                              color: Colors.black54, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Grid
                  Row(
                    children: [
                      Expanded(
                        child: _SettingsTile(
                          icon: isDark
                              ? Icons.dark_mode_outlined
                              : Icons.wb_sunny_outlined,
                          label: isDark ? 'Dark Mode' : 'Light Mode',
                          onTap: () => themeProvider.toggle(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SettingsTile(
                          icon: settings.silent
                              ? Icons.notifications_off
                              : Icons.notifications_active,
                          label: settings.silent ? 'Silent ON' : 'Silent',
                          onTap: () => settings.toggleSilent(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _SettingsTile(
                          customText: settings.useOz ? 'oz' : 'ml',
                          label: settings.useOz ? 'oz mode' : 'ml / oz',
                          onTap: () => settings.toggleUnit(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SettingsTile(
                          icon: Icons.favorite_border,
                          label: 'Apple Health',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _WideButton(
                    label: 'Help/Emergency',
                    onTap: () => showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (_) => const _HelpDialog(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _WideButton(
                    label: 'F.A.Q',
                    onTap: () => showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (_) => const _FaqDialog(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('Log Out',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAQ Dialog ────────────────────────────────────────────────────────────

const _faqItems = [
  ('How do I connect my device?',
      'Make sure Bluetooth is enabled on your phone, then tap the Bluetooth badge on the home screen. The app will automatically detect and connect to your SmartJuice machine.'),
  ('How do I add ingredients?',
      'Tap the + button on the home screen to open the ingredient picker. Search or scroll to find fruits, tap + next to each one to add them, then press Confirm.'),
  ('What does "Estimated time" mean?',
      'After you confirm your recipe, the machine estimates how long it will take to prepare your juice based on the selected fruits and cup count.'),
  ('Can I save my own recipes?',
      'Yes! Enter a name in the Recipe Name field before confirming. Your recipe will be saved and available in Last Recipes.'),
  ('How do I switch between ml and oz?',
      'Go to Settings and tap the ml/oz tile. The unit will toggle instantly across the entire app.'),
  ('What is Silent mode?',
      'Silent mode disables all sound notifications from the app. The machine itself may still produce operational sounds.'),
];

class _FaqDialog extends StatefulWidget {
  const _FaqDialog();

  @override
  State<_FaqDialog> createState() => _FaqDialogState();
}

class _FaqDialogState extends State<_FaqDialog> {
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: kPrimary.withValues(alpha: 0.35)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height * 0.75),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('F.A.Q',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ),
                    // Items
                    Flexible(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _faqItems.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final isOpen = _openIndex == i;
                          return GestureDetector(
                            onTap: () => setState(() =>
                                _openIndex = isOpen ? null : i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? kPrimary.withValues(alpha: 0.08)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(14),
                                border: isOpen
                                    ? Border.all(
                                        color: kPrimary.withValues(
                                            alpha: 0.3))
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _faqItems[i].$1,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: isOpen
                                                ? kPrimary
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isOpen
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: isOpen
                                            ? kPrimary
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  if (isOpen) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _faqItems[i].$2,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          height: 1.5),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Help Dialog ───────────────────────────────────────────────────────────

class _HelpDialog extends StatefulWidget {
  const _HelpDialog();

  @override
  State<_HelpDialog> createState() => _HelpDialogState();
}

class _HelpDialogState extends State<_HelpDialog> {
  final _problemCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _problemCtrl.dispose();
    _descCtrl.dispose();
    _mailCtrl.dispose();
    super.dispose();
  }

  void _send() {
    setState(() => _sent = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: kPrimary.withValues(alpha: 0.35)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: _sent ? _sentView() : _formView(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formView(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('How can we help?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpField(controller: _problemCtrl, hint: 'Problem Type'),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Description',
              hintStyle:
                  const TextStyle(color: Colors.black38, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _HelpField(
                      controller: _mailCtrl, hint: 'Mail Address')),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    elevation: 0,
                  ),
                  child: const Text('Send',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Call Service',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );

  Widget _sentView() => Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 44),
          SizedBox(height: 12),
          Text('Request sent!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
              'Our team will get back to you\nvia e-mail as soon as possible.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      );
}

class _HelpField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _HelpField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData? icon;
  final String? customText;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile({
    this.icon,
    this.customText,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final circleColor = _pressed ? Colors.white : kPrimary;
    final iconColor = _pressed ? kPrimary : Colors.white;

    Widget circleChild;
    if (widget.customText != null) {
      circleChild = Text(
        widget.customText!,
        style: TextStyle(
            color: iconColor, fontWeight: FontWeight.bold, fontSize: 16),
      );
    } else {
      circleChild = Icon(widget.icon, color: iconColor, size: 26);
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: _pressed ? kPrimary : const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: circleChild),
            ),
            const SizedBox(height: 12),
            Text(widget.label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _pressed ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _WideButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _WideButton({required this.label, required this.onTap});

  @override
  State<_WideButton> createState() => _WideButtonState();
}

class _WideButtonState extends State<_WideButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _pressed ? kPrimary : const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(widget.label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _pressed ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }
}
