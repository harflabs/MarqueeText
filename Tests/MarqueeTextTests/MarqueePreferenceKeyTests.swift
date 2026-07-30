@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueePreferenceKeyTests {
  @Test
  func measurementPreferenceDefaultsAndReduces() {
    #expect(MarqueeMeasurementPreferenceKey.defaultValue == .zero)

    var value = MarqueeMeasurement.zero
    MarqueeMeasurementPreferenceKey.reduce(value: &value) {
      MarqueeMeasurement(textWidth: 180, containerWidth: 100)
    }

    #expect(value == MarqueeMeasurement(textWidth: 180, containerWidth: 100))
  }

  @Test
  func nonMeasuringSiblingsCannotEraseAMeasurement() {
    // SwiftUI folds every child of a container into the preference, including children that never write
    // one and therefore contribute `defaultValue`. Those must not clear a real measurement.
    var value = MarqueeMeasurement.zero

    MarqueeMeasurementPreferenceKey.reduce(value: &value) { MarqueeMeasurement(textWidth: 180, containerWidth: 100) }
    MarqueeMeasurementPreferenceKey.reduce(value: &value) { .zero }

    #expect(value == MarqueeMeasurement(textWidth: 180, containerWidth: 100))
  }

  @Test
  func realMeasurementsStillOverwriteEarlierOnes() {
    var value = MarqueeMeasurement.zero

    MarqueeMeasurementPreferenceKey.reduce(value: &value) { MarqueeMeasurement(textWidth: 180, containerWidth: 100) }
    MarqueeMeasurementPreferenceKey.reduce(value: &value) { MarqueeMeasurement(textWidth: 220, containerWidth: 100) }

    #expect(value == MarqueeMeasurement(textWidth: 220, containerWidth: 100))
  }

  @Test
  func invalidContributionsAreSanitizedToZeroAndIgnored() {
    var value = MarqueeMeasurement(textWidth: 180, containerWidth: 100)

    MarqueeMeasurementPreferenceKey.reduce(value: &value) {
      MarqueeMeasurement(textWidth: .nan, containerWidth: -.infinity)
    }

    #expect(value == MarqueeMeasurement(textWidth: 180, containerWidth: 100))
  }
}
