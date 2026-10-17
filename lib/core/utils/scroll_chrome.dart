import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Tracks whether a vertical list is being scrolled, so bars (search, filter,
/// bottom nav) can be tucked away while it moves and shown again once it stops.
///
/// Attach [onNotification] to a `NotificationListener<ScrollNotification>`.
/// Horizontal notifications (e.g. a tab pager) are ignored, and the
/// notification is never consumed.
class ScrollChrome {
  ScrollChrome({this.showDelay = const Duration(milliseconds: 350)});

  /// How long the list must be still before the bars come back.
  final Duration showDelay;

  /// True while the user is scrolling.
  final hidden = false.obs;

  Timer? _timer;

  bool onNotification(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final moving =
        (n is ScrollUpdateNotification && (n.scrollDelta ?? 0) != 0) ||
        n is OverscrollNotification;
    if (moving) {
      _timer?.cancel();
      if (!hidden.value) hidden.value = true;
    } else if (n is ScrollEndNotification) {
      _timer?.cancel();
      _timer = Timer(showDelay, () => hidden.value = false);
    }
    return false;
  }

  void dispose() => _timer?.cancel();
}
