import 'package:flutter/material.dart';

enum AppNoticeType {
  success,
  info,
  warning,
}

extension AppNoticeMessenger on BuildContext {
  void showAppNotice({
    required String title,
    required String message,
    AppNoticeType type = AppNoticeType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
        content: _AppNoticeCard(
          title: title,
          message: message,
          type: type,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }
}

class _AppNoticeCard extends StatelessWidget {
  const _AppNoticeCard({
    required this.title,
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final AppNoticeType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = switch (type) {
      AppNoticeType.success => _NoticePalette(
          background: const Color(0xFF243336),
          accent: const Color(0xFF67D39C),
          icon: Icons.check_circle_rounded,
        ),
      AppNoticeType.info => _NoticePalette(
          background: const Color(0xFF2B3150),
          accent: const Color(0xFF8FA8FF),
          icon: Icons.info_rounded,
        ),
      AppNoticeType.warning => _NoticePalette(
          background: const Color(0xFF3C3026),
          accent: const Color(0xFFFFB363),
          icon: Icons.local_fire_department_rounded,
        ),
    };

    return Container(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                palette.icon,
                color: palette.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFFD2D9EA),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: onAction,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticePalette {
  const _NoticePalette({
    required this.background,
    required this.accent,
    required this.icon,
  });

  final Color background;
  final Color accent;
  final IconData icon;
}
