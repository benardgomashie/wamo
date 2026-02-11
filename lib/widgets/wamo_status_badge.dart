import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Status badge component following DESIGN_SYSTEM.md Component Specs
/// Never relies on color alone - always pairs with icon/text
class WamoStatusBadge extends StatelessWidget {
  final String label;
  final WamoStatusBadgeType type;
  final IconData? icon;
  final bool small;

  const WamoStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
    this.small = false,
  });

  Color get _backgroundColor {
    switch (type) {
      case WamoStatusBadgeType.success:
        return AppTheme.successColor.withOpacity(0.1);
      case WamoStatusBadgeType.warning:
        return AppTheme.warningColor.withOpacity(0.1);
      case WamoStatusBadgeType.error:
        return AppTheme.errorColor.withOpacity(0.1);
      case WamoStatusBadgeType.info:
        return AppTheme.primaryColor.withOpacity(0.1);
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case WamoStatusBadgeType.success:
        return AppTheme.successColor;
      case WamoStatusBadgeType.warning:
        return AppTheme.warningColor;
      case WamoStatusBadgeType.error:
        return AppTheme.errorColor;
      case WamoStatusBadgeType.info:
        return AppTheme.primaryColor;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case WamoStatusBadgeType.success:
        return Icons.check_circle;
      case WamoStatusBadgeType.warning:
        return Icons.warning_amber;
      case WamoStatusBadgeType.error:
        return Icons.error;
      case WamoStatusBadgeType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(999), // radius.full
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? _defaultIcon,
            size: small ? 14 : 16,
            color: _foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: small ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: _foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum WamoStatusBadgeType {
  success,
  warning,
  error,
  info,
}
