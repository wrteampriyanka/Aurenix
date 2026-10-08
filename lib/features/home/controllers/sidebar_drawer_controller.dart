import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Open/closed position of the home sidebar drawer.
///
/// Owned by [HomeController] rather than by the drawer widget: the sidebar
/// and the project screen both close the drawer from their own controllers,
/// which have no way to reach a widget's state.
class SidebarDrawerController {
  SidebarDrawerController({required TickerProvider vsync}) {
    position = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    )..addListener(() => isOpen.value = position.value > 0);
  }

  /// 0 closed, 1 open.
  late final AnimationController position;

  final isOpen = false.obs;

  void toggle() => position.isDismissed ? open() : close();

  void open() => position.forward();

  void close() => position.reverse();

  /// Shuts the drawer with no animation, for when the screen underneath is
  /// already covered and the drawer must not be there on the way back.
  void snapShut() => position.value = 0;

  void dispose() {
    position.dispose();
    isOpen.close();
  }
}
