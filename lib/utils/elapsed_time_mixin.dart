import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Exposes a continuously increasing [time] (in seconds) driven by a [Ticker].
///
/// Pass [time] as a [CustomPainter.repaint] listenable so only `paint` runs
/// per frame. Unlike a repeating [AnimationController], time never wraps, so
/// sine-based motion loops seamlessly at any speed.
///
/// Respects the platform "reduce motion" setting.
mixin ElapsedTimeMixin<T extends StatefulWidget>
    on SingleTickerProviderStateMixin<T> {
  final ValueNotifier<double> time = ValueNotifier<double>(0);

  late final Ticker _ticker = createTicker(
    (elapsed) =>
        time.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion && _ticker.isActive) {
      _ticker.stop();
    } else if (!reduceMotion && !_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    time.dispose();
    super.dispose();
  }
}
