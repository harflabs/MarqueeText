import SwiftUI

/// Carries the probe's measurement, using `nil` to mean "this subtree did not measure anything".
///
/// SwiftUI folds every child of a container into the preference, including children that never write one
/// and therefore contribute `defaultValue`. Those must not clear a real measurement. Distinguishing "no
/// contribution" (`nil`) from "measured, and the answer is zero" (`.some(.zero)`) is what lets a genuinely
/// empty measurement still overwrite an earlier one, instead of leaving stale widths behind.
struct MarqueeMeasurementPreferenceKey: PreferenceKey {
  static var defaultValue: MarqueeMeasurement? {
    nil
  }

  static func reduce(value: inout MarqueeMeasurement?, nextValue: () -> MarqueeMeasurement?) {
    guard let next = nextValue() else { return }

    value = next
  }
}

/// Reports back whatever size the layout proposes to it, which is how both widths reach view state.
struct MarqueeMeasurementReader: View {
  var body: some View {
    GeometryReader { geometry in
      Color.clear
        .allowsHitTesting(false)
        .preference(
          key: MarqueeMeasurementPreferenceKey.self,
          value: MarqueeMeasurement(probeSize: geometry.size) as MarqueeMeasurement?
        )
    }
  }
}

// A rectangle that spans the view horizontally but extends well past it vertically.
//
// Clipping horizontally is what hides the off screen marquee copies. Clipping vertically is not wanted:
// glyphs such as Arabic diacritics, emoji, and tall accents legitimately paint outside the line box and
// `Text` renders them, so the marquee must not cut them off.
