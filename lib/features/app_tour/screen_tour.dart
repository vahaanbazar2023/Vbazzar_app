import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/storage/local_storage_service.dart';
import '../../core/storage/storage_keys.dart';
import 'tour_overlay.dart';

/// One tip in a screen's tour, pointing at the [TourAnchor] with [anchorId].
class TourSpot {
  final String anchorId;
  final String title;
  final String body;
  final double padding;
  final bool circle;

  const TourSpot(
    this.anchorId,
    this.title,
    this.body, {
    this.padding = 8,
    this.circle = false,
  });
}

/// Gives a screen a first-visit guided tour.
///
/// Wrap the screen's body in a [TourScope] and wrap each widget to highlight
/// in a [TourAnchor]. Once the anchors have been on screen for a moment (so
/// data-driven screens get to load), the tour runs over whatever anchors are
/// present, in [spots] order, and is then marked seen for [tourId].
///
/// No global keys: the same screen can be open twice in the stack.
class TourScope extends StatefulWidget {
  /// Storage id; add it to [StorageKeys.screenTourIds] so "replay" resets it.
  final String tourId;
  final List<TourSpot> Function(BuildContext context) spots;
  final Widget child;

  /// Anchor ids that come from loaded data (e.g. the first list card). The
  /// tour waits for these (up to ~10 s) so it doesn't start on the header
  /// alone while the list is still loading.
  final List<String> waitFor;

  const TourScope({
    super.key,
    required this.tourId,
    required this.spots,
    required this.child,
    this.waitFor = const [],
  });

  @override
  State<TourScope> createState() => _TourScopeState();
}

class _TourScopeState extends State<TourScope> {
  final Map<String, BuildContext> _anchors = {};
  Timer? _timer;
  int _waits = 0;
  int _dataWaits = 0;
  bool _done = false;

  bool get _seen =>
      LocalStorageService.to.getBool(StorageKeys.screenTourSeen(widget.tourId));

  @override
  void initState() {
    super.initState();
    _done = _seen;
  }

  void _register(String id, BuildContext ctx) {
    _anchors.putIfAbsent(id, () => ctx); // first (top-most) instance wins
    _schedule(const Duration(milliseconds: 900));
  }

  void _unregister(String id, BuildContext ctx) {
    if (identical(_anchors[id], ctx)) _anchors.remove(id);
  }

  void _schedule(Duration delay) {
    if (_done) return;
    _timer?.cancel();
    _timer = Timer(delay, _tryStart);
  }

  Future<void> _tryStart() async {
    if (_done || !mounted) return;
    // Something on top (a dialog, a sheet, another screen): wait for it.
    if (ModalRoute.of(context)?.isCurrent != true) {
      if (++_waits < 60) _schedule(const Duration(seconds: 1));
      return;
    }
    // Data still loading: give it time before settling for the header alone.
    if (widget.waitFor.any((id) => !_anchors.containsKey(id)) &&
        ++_dataWaits < 20) {
      _schedule(const Duration(milliseconds: 500));
      return;
    }
    final steps = <TourStep>[];
    for (final spot in widget.spots(context)) {
      if (!_anchors.containsKey(spot.anchorId)) continue;
      steps.add(
        TourStep.forContext(
          // Looked up each time: a list rebuild can swap the anchored card.
          () {
            final ctx = _anchors[spot.anchorId];
            return ctx != null && ctx.mounted ? ctx : null;
          },
          title: spot.title,
          body: spot.body,
          padding: spot.padding,
          circle: spot.circle,
        ),
      );
    }
    if (steps.isEmpty) return; // nothing to point at yet
    _done = true;
    try {
      await showTourOverlay(context, steps);
    } finally {
      LocalStorageService.to.setBool(
        StorageKeys.screenTourSeen(widget.tourId),
        true,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Marks a widget as a tour target inside the nearest [TourScope].
/// Does nothing (just builds [child]) when there's no scope above it.
class TourAnchor extends StatefulWidget {
  final String id;
  final Widget child;

  const TourAnchor({super.key, required this.id, required this.child});

  @override
  State<TourAnchor> createState() => _TourAnchorState();
}

class _TourAnchorState extends State<TourAnchor> {
  _TourScopeState? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = context.findAncestorStateOfType<_TourScopeState>();
    if (scope != _scope) {
      _scope?._unregister(widget.id, context);
      _scope = scope;
      _scope?._register(widget.id, context);
    }
  }

  @override
  void dispose() {
    _scope?._unregister(widget.id, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
