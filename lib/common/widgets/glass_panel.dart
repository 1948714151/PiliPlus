import 'dart:ui';

import 'package:flutter/material.dart';

/// 毛玻璃面板（液态玻璃/Glassmorphism）
/// 用 BackdropFilter 模糊背后的内容，叠加半透明背景与顶部高光，形成 iOS 毛玻璃质感。
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderSide,
    this.radius = BorderRadius.zero,
    this.opacity = 0.62,
    this.blur = 24,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final BorderSide? borderSide;

  /// 圆角，默认无。悬浮面板建议传入圆角。
  final BorderRadius radius;

  /// 背景不透明度（0~1），数值越大越不透明。
  final double opacity;

  /// 模糊强度（像素）。
  final double blur;

  final EdgeInsets? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final bg = scheme.surface.withValues(alpha: opacity);
    final border = borderSide ??
        BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.8);

    return ClipRRect(
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.fromBorderSide(border),
          ),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}
