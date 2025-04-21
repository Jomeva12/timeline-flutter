import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationUtils {
  static void showOverlayNotification({
    required BuildContext context,
    required String mensaje,
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => NotificationOverlay(
        message: mensaje,
        type: type,
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  static void showErrorNotification(BuildContext context, String mensaje) {
    showOverlayNotification(
      context: context,
      mensaje: mensaje,
      type: NotificationType.error,
    );
  }

  static void showSuccessNotification(BuildContext context, String mensaje) {
    showOverlayNotification(
      context: context,
      mensaje: mensaje,
      type: NotificationType.success,
    );
  }

  static void showWarningNotification(BuildContext context, String mensaje) {
    showOverlayNotification(
      context: context,
      mensaje: mensaje,
      type: NotificationType.warning,
    );
  }
}

enum NotificationType { success, error, warning, info }

class NotificationOverlay extends StatelessWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const NotificationOverlay({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: _NotificationCard(
          message: message,
          type: type,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_animation),
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (_) => widget.onDismiss(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Uso de ejemplo:
// NotificationUtils.showSuccessNotification(context, 'Operación exitosa');
// NotificationUtils.showErrorNotification(context, 'Ocurrió un error');
// NotificationUtils.showWarningNotification(context, 'Advertencia');