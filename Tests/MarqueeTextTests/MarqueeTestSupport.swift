@testable import MarqueeText
import SwiftUI
import Testing

func resolvedLayout(
  textWidth: CGFloat = 120,
  containerWidth: CGFloat = 100,
  configuration: MarqueeConfiguration = MarqueeConfiguration(),
  content: MarqueeContent = .verbatim("Title"),
  layoutDirection: LayoutDirection = .leftToRight,
  localeIdentifier: String = "en",
  reduceMotion: Bool = false
) -> MarqueeResolvedLayout {
  MarqueeResolvedLayout(
    configuration: configuration,
    content: content,
    layoutDirection: layoutDirection,
    localeIdentifier: localeIdentifier,
    measurement: MarqueeMeasurement(textWidth: textWidth, containerWidth: containerWidth),
    reduceMotion: reduceMotion
  )
}
