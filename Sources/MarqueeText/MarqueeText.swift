import Foundation
import SwiftUI

/// A SwiftUI view that displays one line of text and scrolls it horizontally when it is wider than its container.
///
/// `MarqueeText` measures both the rendered text and the available container width. Text that fits is shown
/// statically, while overflowing text is duplicated and animated so the label can loop continuously. The view
/// responds to layout, font, Dynamic Type, locale, right-to-left layout direction, and Reduce Motion changes.
///
/// The view reports the same size as an equivalent single line `Text`, including on the very first layout pass,
/// so it can be dropped into stacks, lists, and toolbars without changing the surrounding layout. When the text
/// overflows but cannot scroll — for example while Reduce Motion is enabled — it truncates like `Text` instead of
/// being cut off mid glyph.
public struct MarqueeText: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.layoutDirection) private var layoutDirection
  @Environment(\.locale) private var locale

  let configuration: MarqueeConfiguration
  let content: MarqueeContent

  @State private var animationStartDate = Date()
  @State private var measurement = MarqueeMeasurement.zero

  /// Creates a localized marquee text view.
  /// - Parameters:
  ///   - text: The localized text resource to display.
  ///   - duration: The duration, in seconds, of one scrolling pass. Invalid or non-positive values use `8.0`.
  ///   - delay: The delay, in seconds, before each scrolling pass. Invalid or negative values use `0`.
  ///   - spacing: The spacing between repeated text instances during animation. Invalid or negative values use `0`.
  public init(
    _ text: LocalizedStringResource,
    duration: TimeInterval = 8.0,
    delay: TimeInterval = 1.0,
    spacing: CGFloat = 50
  ) {
    self.init(
      content: .localized(text),
      configuration: MarqueeConfiguration(
        duration: duration,
        delay: delay,
        spacing: spacing
      )
    )
  }

  /// Creates a marquee text view from a runtime string without looking it up in localization tables.
  /// - Parameters:
  ///   - text: The exact string to display.
  ///   - duration: The duration, in seconds, of one scrolling pass. Invalid or non-positive values use `8.0`.
  ///   - delay: The delay, in seconds, before each scrolling pass. Invalid or negative values use `0`.
  ///   - spacing: The spacing between repeated text instances during animation. Invalid or negative values use `0`.
  public init(
    verbatim text: String,
    duration: TimeInterval = 8.0,
    delay: TimeInterval = 1.0,
    spacing: CGFloat = 50
  ) {
    self.init(
      content: .verbatim(text),
      configuration: MarqueeConfiguration(
        duration: duration,
        delay: delay,
        spacing: spacing
      )
    )
  }

  /// Creates a marquee text view from a runtime string.
  ///
  /// This overload is disfavored so string literals keep using the localized initializer. Prefer
  /// ``init(verbatim:duration:delay:spacing:)`` when the value is intentionally not localized.
  /// - Parameters:
  ///   - text: The exact string to display.
  ///   - duration: The duration, in seconds, of one scrolling pass. Invalid or non-positive values use `8.0`.
  ///   - delay: The delay, in seconds, before each scrolling pass. Invalid or negative values use `0`.
  ///   - spacing: The spacing between repeated text instances during animation. Invalid or negative values use `0`.
  @_disfavoredOverload
  public init(
    _ text: String,
    duration: TimeInterval = 8.0,
    delay: TimeInterval = 1.0,
    spacing: CGFloat = 50
  ) {
    self.init(
      verbatim: text,
      duration: duration,
      delay: delay,
      spacing: spacing
    )
  }

  init(
    content: MarqueeContent,
    configuration: MarqueeConfiguration,
    measurement: MarqueeMeasurement = .zero,
    animationStartDate: Date = Date()
  ) {
    self.content = content
    self.configuration = configuration
    _animationStartDate = State(initialValue: animationStartDate)
    _measurement = State(initialValue: measurement)
  }

  /// The rendered marquee view.
  public var body: some View {
    let layout = MarqueeResolvedLayout(
      configuration: configuration,
      content: content,
      layoutDirection: layoutDirection,
      localeIdentifier: locale.identifier,
      measurement: measurement,
      reduceMotion: reduceMotion
    )

    MarqueeSizingLayout(
      alignment: layout.alignment,
      isScrolling: layout.shouldScroll,
      spacing: configuration.spacing
    ) {
      if layout.shouldScroll {
        scrollingText(layout: layout)
      } else {
        truncatingText
      }

      // A single weightless probe carries both measurements back into view state. The layout already
      // knows the natural text width and the container width, so it just proposes them as this probe's
      // size. Laying the text out a second time to measure it, and reading the container with its own
      // background geometry reader, together cost more than the rest of the view combined.
      MarqueeMeasurementReader()
        .allowsHitTesting(false)
    }
    // Clip horizontally only. A full `clipped()` would also cut glyph overhang — diacritics, emoji, and
    // script fonts routinely draw outside the typographic line box, and `Text` never clips them.
    .clipShape(MarqueeHorizontalClipShape())
    .contentShape(Rectangle())
    .onPreferenceChange(MarqueeMeasurementPreferenceKey.self, perform: updateMeasurement)
    // Keep the measurement preference private to this view so ancestors are not invalidated by it.
    .transformPreference(MarqueeMeasurementPreferenceKey.self) { $0 = nil }
    .onAppear { restartAnimation(shouldAnimate: layout.shouldScroll) }
    .onChange(of: layout.animationIdentity) { _ in
      restartAnimation(shouldAnimate: layout.shouldScroll)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(content.text)
    .accessibilityAddTraits(.isStaticText)
  }

  /// Text laid out at its natural width. Used for the scrolling copies, which must not truncate.
  var intrinsicText: some View {
    content.text
      .lineLimit(1)
      .fixedSize()
  }

  /// Text that fits the container and truncates, matching `Text` whenever the marquee is not scrolling.
  var truncatingText: some View {
    content.text
      .lineLimit(1)
  }

  func restartAnimation(shouldAnimate: Bool) {
    guard shouldAnimate else { return }

    animationStartDate = Date()
  }

  func scrollingText(layout: MarqueeResolvedLayout) -> some View {
    TimelineView(.animation) { timeline in
      HStack(spacing: configuration.spacing) {
        intrinsicText
        intrinsicText
      }
      .offset(
        x: layout.offset(
          at: timeline.date,
          startDate: animationStartDate
        )
      )
    }
  }

  func updateMeasurement(_ newValue: MarqueeMeasurement?) {
    guard let newValue, measurement != newValue else { return }

    measurement = newValue
  }
}
