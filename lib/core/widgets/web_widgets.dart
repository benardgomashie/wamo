import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../app/theme.dart';

/// Web-aware button with hover effects
class WebButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isPrimary;
  final bool isOutlined;

  const WebButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.isPrimary = true,
    this.isOutlined = false,
  });

  @override
  State<WebButton> createState() => _WebButtonState();
}

class _WebButtonState extends State<WebButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(
              color: _isHovered ? AppTheme.primaryColor.withOpacity(0.8) : AppTheme.primaryColor,
              width: _isHovered ? 2 : 1.5,
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: _isHovered 
                ? AppTheme.primaryColor.withOpacity(0.9) 
                : AppTheme.primaryColor,
            elevation: _isHovered ? 4 : 0,
          );

    final button = widget.isOutlined
        ? OutlinedButton(
            onPressed: widget.onPressed,
            style: baseStyle.merge(widget.style),
            child: widget.child,
          )
        : ElevatedButton(
            onPressed: widget.onPressed,
            style: baseStyle.merge(widget.style),
            child: widget.child,
          );

    if (!kIsWeb) return button;

    return MouseRegion(
      cursor: widget.onPressed != null 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _isHovered 
            ? (Matrix4.identity()..scale(1.02)) 
            : Matrix4.identity(),
        child: button,
      ),
    );
  }
}

/// Card with web hover effects
class WebCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;

  const WebCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 12,
  });

  @override
  State<WebCard> createState() => _WebCardState();
}

class _WebCardState extends State<WebCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: widget.color ?? AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _isHovered ? AppTheme.primaryColor.withOpacity(0.3) : AppTheme.dividerColor,
        ),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );

    if (!kIsWeb || widget.onTap == null) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: card,
    );
  }
}

/// Interactive link with hover effect for web
class WebLink extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final TextStyle? style;
  final Color? color;

  const WebLink({
    super.key,
    required this.text,
    this.onTap,
    this.style,
    this.color,
  });

  @override
  State<WebLink> createState() => _WebLinkState();
}

class _WebLinkState extends State<WebLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final linkColor = widget.color ?? AppTheme.primaryColor;
    
    final textWidget = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150),
      style: (widget.style ?? const TextStyle()).copyWith(
        color: linkColor,
        decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
        decorationColor: linkColor,
      ),
      child: Text(widget.text),
    );

    if (!kIsWeb) {
      return GestureDetector(
        onTap: widget.onTap,
        child: textWidget,
      );
    }

    return MouseRegion(
      cursor: widget.onTap != null 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: textWidget,
      ),
    );
  }
}

/// Web-optimized image with loading and hover
class WebImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final bool enableHover;

  const WebImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
    this.placeholder,
    this.enableHover = false,
  });

  @override
  State<WebImage> createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      imageWidget = widget.placeholder ?? Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Icon(
          Icons.image_outlined,
          size: 48,
          color: AppTheme.textMutedColor,
        ),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: _isHovered && widget.enableHover ? 1.05 : 1.0,
          child: Image.network(
            widget.imageUrl!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return widget.placeholder ?? Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: AppTheme.textMutedColor,
                ),
              );
            },
          ),
        ),
      );
    }

    if (!kIsWeb || !widget.enableHover) return imageWidget;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: imageWidget,
    );
  }
}

/// Scrollbar wrapper for web with custom styling
class WebScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool alwaysVisible;

  const WebScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.alwaysVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return Scrollbar(
      controller: controller,
      thumbVisibility: alwaysVisible,
      thickness: 8,
      radius: const Radius.circular(4),
      child: child,
    );
  }
}

/// Navigation rail item for sidebar
class SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : _isHovered
                  ? AppTheme.primaryColor.withOpacity(0.05)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    widget.isSelected ? (widget.selectedIcon ?? widget.icon) : widget.icon,
                    size: 22,
                    color: isActive ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                      ),
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
