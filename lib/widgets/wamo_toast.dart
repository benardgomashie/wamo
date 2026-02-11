import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Toast/Snackbar helper following DESIGN_SYSTEM.md Component Specs
/// Duration: 3-4s (errors can be 4-6s)
/// One action max (e.g., "Retry")
/// Copy rule: be direct and calm (no blame, no jargon)
class WamoToast {
  static void show(
    BuildContext context, {
    required String message,
    WamoToastType type = WamoToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);
    final duration = type == WamoToastType.error
        ? const Duration(seconds: 5)
        : const Duration(seconds: 3);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static Color _getColor(WamoToastType type) {
    switch (type) {
      case WamoToastType.success:
        return AppTheme.successColor;
      case WamoToastType.warning:
        return AppTheme.warningColor;
      case WamoToastType.error:
        return AppTheme.errorColor;
      case WamoToastType.info:
        return AppTheme.primaryColor;
    }
  }

  static IconData _getIcon(WamoToastType type) {
    switch (type) {
      case WamoToastType.success:
        return Icons.check_circle;
      case WamoToastType.warning:
        return Icons.warning_amber;
      case WamoToastType.error:
        return Icons.error;
      case WamoToastType.info:
        return Icons.info;
    }
  }

  /// Success toast - for confirmations
  static void success(BuildContext context, String message) {
    show(context, message: message, type: WamoToastType.success);
  }

  /// Warning toast - for alerts and network delays
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: WamoToastType.warning);
  }

  /// Error toast - for failures (4-6s duration, calm language)
  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(
      context,
      message: message,
      type: WamoToastType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Info toast - for general notifications
  static void info(BuildContext context, String message) {
    show(context, message: message, type: WamoToastType.info);
  }
}

enum WamoToastType {
  success,
  warning,
  error,
  info,
}
