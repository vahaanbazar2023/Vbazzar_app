/// Offset of an endlessly looping marquee row.
///
/// The row shows a pattern that repeats every [period] pixels (one full cycle
/// of its items). Moving exactly one [period] and then wrapping back to [base]
/// is invisible, and the position depends only on [progress] (0..1), never on
/// the list's estimated length, so the motion is smooth and constant-speed.
double marqueeOffset({
  required double base,
  required double period,
  required double progress,
  required bool reverse,
}) {
  return base + (reverse ? -1 : 1) * period * progress;
}
