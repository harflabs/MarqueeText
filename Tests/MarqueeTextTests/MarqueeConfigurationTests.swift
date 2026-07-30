@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueeConfigurationTests {
  @Test
  func validConfigurationIsPreserved() {
    let configuration = MarqueeConfiguration(
      duration: 4.5,
      delay: 0.25,
      spacing: 12
    )

    #expect(
      configuration == MarqueeConfiguration(
        duration: 4.5,
        delay: 0.25,
        spacing: 12
      )
    )
  }

  @Test
  func invalidConfigurationIsClamped() {
    #expect(
      MarqueeConfiguration(
        duration: -1,
        delay: -.infinity,
        spacing: .nan
      ) == MarqueeConfiguration(
        duration: MarqueeConfiguration.defaultDuration,
        delay: 0,
        spacing: 0
      )
    )
  }

  @Test
  func zeroDurationUsesDefaultButZeroDelayAndSpacingAreAllowed() {
    #expect(
      MarqueeConfiguration(
        duration: 0,
        delay: 0,
        spacing: 0
      ) == MarqueeConfiguration(
        duration: MarqueeConfiguration.defaultDuration,
        delay: 0,
        spacing: 0
      )
    )
  }

  @Test
  func positiveInfinityConfigurationValuesAreClamped() {
    #expect(
      MarqueeConfiguration(
        duration: .infinity,
        delay: .infinity,
        spacing: .infinity
      ) == MarqueeConfiguration(
        duration: MarqueeConfiguration.defaultDuration,
        delay: 0,
        spacing: 0
      )
    )
  }
}
