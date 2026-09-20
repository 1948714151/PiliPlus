import 'package:PiliPlus/common/widgets/slotted_layout_helper.dart';
import 'package:flutter/rendering.dart' show ChildLayoutHelper;
import 'package:material_ui/material_ui.dart';

enum MainType { sideBar, bottomNav, body }

class MainLayout
    extends SlottedMultiChildRenderObjectWidget<MainType, RenderBox> {
  const MainLayout({
    super.key,
    required this.sideBar,
    required this.bottomNav,
    required this.body,
    this.sideBarOnRight = false,
    this.glassFloating = false,
  });

  final Widget? sideBar;
  final Widget? bottomNav;
  final Widget body;

  /// 侧边栏是否位于右侧（右手模式）。
  final bool sideBarOnRight;

  /// 悬浮毛玻璃模式：body 铺满全屏，侧边栏浮在其上（配合 BackdropFilter）。
  final bool glassFloating;

  @override
  Iterable<MainType> get slots => MainType.values;

  @override
  Widget? childForSlot(slot) => switch (slot) {
    .sideBar => sideBar,
    .bottomNav => bottomNav,
    .body => body,
  };

  @override
  SlottedContainerRenderObjectMixin<MainType, RenderBox> createRenderObject(
    BuildContext context,
  ) {
    return _RenderMainLayout(
      sideBarOnRight: sideBarOnRight,
      glassFloating: glassFloating,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMainLayout renderObject,
  ) {
    renderObject
      ..sideBarOnRight = sideBarOnRight
      ..glassFloating = glassFloating;
  }
}

class _RenderMainLayout extends RenderBox
    with
        SlottedContainerRenderObjectMixin<MainType, RenderBox>,
        SlottedLayoutMixin {
  _RenderMainLayout({
    required this.sideBarOnRight,
    required this.glassFloating,
  });

  bool sideBarOnRight;
  bool glassFloating;

  RenderBox? get sideBar => childForSlot(.sideBar);
  RenderBox? get bottomNav => childForSlot(.bottomNav);
  RenderBox get body => childForSlot(.body)!;

  @override
  Iterable<MainType> get slots => MainType.values;

  @override
  void performLayout() {
    final constraints = this.constraints;
    size = constraints.biggest;

    final Offset bodyOffset;
    final BoxConstraints bodyConstraints;

    final sideBar = this.sideBar;
    if (sideBar != null) {
      final sideBarWidth = ChildLayoutHelper.layoutChild(
        sideBar,
        BoxConstraints.tightFor(height: constraints.maxHeight),
      ).width;

      if (sideBarOnRight) {
        // 右手模式：侧边栏在右，body 在左（玻璃模式同样让位，避免遮挡内容）
        setOffset(
          sideBar,
          Offset(constraints.maxWidth - sideBarWidth, 0),
        );
        bodyOffset = .zero;
        bodyConstraints = BoxConstraints.tightFor(
          width: constraints.maxWidth - sideBarWidth,
          height: constraints.maxHeight,
        );
      } else {
        // 默认：侧边栏在左
        setOffset(sideBar, .zero);
        bodyOffset = Offset(sideBarWidth, 0);
        bodyConstraints = BoxConstraints.tightFor(
          width: constraints.maxWidth - sideBarWidth,
          height: constraints.maxHeight,
        );
      }
    } else {
      final bottomNav = this.bottomNav;
      if (bottomNav != null) {
        final bottomNavSize = ChildLayoutHelper.layoutChild(
          bottomNav,
          constraints.loosen(),
        );
        setOffset(
          bottomNav,
          Offset(
            (constraints.maxWidth - bottomNavSize.width) / 2,
            constraints.maxHeight - bottomNavSize.height,
          ),
        );
      }

      bodyOffset = .zero;
      bodyConstraints = BoxConstraints.tightFor(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
      );
    }

    final body = this.body..layout(bodyConstraints);
    setOffset(body, bodyOffset);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void doPaint(RenderBox? child) {
      if (child != null) {
        context.paintChild(child, getOffset(child) + offset);
      }
    }

    if (glassFloating && sideBar != null) {
      // 毛玻璃模式：先画 body，侧边栏浮在其上才能模糊到内容
      doPaint(body);
      doPaint(sideBar);
      doPaint(bottomNav);
    } else {
      doPaint(sideBar);
      doPaint(body);
      doPaint(bottomNav);
    }
  }
}
