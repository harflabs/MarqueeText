@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueePreferenceKeyTests {
  @Test
  func measurementPreferenceStartsWithNothingMeasured() {
    #expect(MarqueeMeasurementPreferenceKey.defaultValue == nil)

    var value: MarqueeMeasurement?
    MarqueeMeasurementPreferenceKey.reduce(value: &value) {
      MarqueeMeasurement(textWidth: 180, containerWidth: 100)
    }

    #expect(value == MarqueeMeasurement(textWidth: 180, containerWidth: 100))
  }

  @Test
  func nonMeasuringSiblingsCannotEraseAMeasurement() {
    // SwiftUI folds every child of a container into the preference, including children that never write
    // one and therefore contribute `defaultValue`. Those must not clear a real measurement.
    var value: MarqueeMeasurement?

    MarqueeMeasurementPreferenceKey.reduce(value: &value) { MarqueeMeasurement(textWidth: 180, containerWidth: 100) }
    MarqueeMeasurementPreferenceKey.reduce(value: &value) { nil }

    #expect(value == MarqueeMeasurement(textWidth: 180, containerWidth: 100))
  }

  @Test
  func aGenuinelyEmptyMeasurementStillClearsAnEarlierOne() {
    // Emptying the text is a real measurement of zero, not an absent one. Rejecting it would leave the
    // view believing it still has wide text in a wide container.
    var value: MarqueeMeasurement?

    MarqueeMeasurementPreferenceKey.reduce(value: &value) { MarqueeMeasurement(textWidth: 180, containerWidth: 100) }
    MarqueeMeasurementPreferenceKey.reduce(value: &value) { .zero }

    #expect(value == .zero)
  }

  @Test
  func realMeasurementsStillOverwriteEarlierOnes() {
    var value: MarqueeMeasurement?

    MarqueeMeasurementPreferenceKey.reduce(value: &value) { MarqueeMeasurement(textWidth: 180, containerWidth: 100) }
    MarqueeMeasurementPreferenceKey.reduce(value: &value) { MarqueeMeasurement(textWidth: 220, containerWidth: 100) }

    #expect(value == MarqueeMeasurement(textWidth: 220, containerWidth: 100))
  }

  @Test
  func invalidContributionsAreSanitizedToZero() {
    var value: MarqueeMeasurement?

    MarqueeMeasurementPreferenceKey.reduce(value: &value) {
      MarqueeMeasurement(textWidth: .nan, containerWidth: -.infinity)
    }

    #expect(value == .zero)
  }
}
