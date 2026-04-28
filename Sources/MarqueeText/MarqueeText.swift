import Foundation
import SwiftUI

/// A SwiftUI view that displays one line of text and scrolls it horizontally when it is wider than its container.
///
/// `MarqueeText` measures both the rendered text and the available container width. Text that fits is shown
/// statically, while overflowing text is duplicated and animated so the label can loop continuously. The view
/// responds to layout, font, Dynamic Type, locale, right-to-left layout direction, and Reduce Motion changes.
public struct MarqueeText: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.layoutDirection) private var layoutDirection
  @Environment(\.locale) private var locale

  let configuration: MarqueeConfiguration
  let content: MarqueeContent

  @State private var animationStartDate = Date()
  @State private var containerSize: CGSize = .zero
  @State private var textSize: CGSize = .zero

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
    containerSize: CGSize = .zero,
    textSize: CGSize = .zero,
    animationStartDate: Date = Date()
  ) {
    self.content = content
    self.configuration = configuration
    _animationStartDate = State(initialValue: animationStartDate)
    _containerSize = State(initialValue: containerSize.marqueeSanitized)
    _textSize = State(initialValue: textSize.marqueeSanitized)
  }

  /// The rendered marquee view.
  public var body: some View {
    let layout = MarqueeResolvedLayout(
      textSize: textSize,
      containerSize: containerSize,
      configuration: configuration,
      contentIdentity: content.animationIdentity,
      layoutDirection: layoutDirection,
      localeIdentifier: locale.identifier,
      reduceMotion: reduceMotion
    )

    MarqueeSizingLayout(alignment: layout.alignment) {
      measuredText
        .hidden()

      if layout.shouldScroll {
        scrollingText(layout: layout)
      } else {
        displayText
      }
    }
    .frame(height: layout.height, alignment: layout.alignment)
    .clipped()
    .overlay(
      MarqueeContainerSizeReader()
        .allowsHitTesting(false)
    )
    .onPreferenceChange(MarqueeContainerSizePreferenceKey.self, perform: updateContainerSize)
    .onPreferenceChange(MarqueeTextSizePreferenceKey.self, perform: updateTextSize)
    .onAppear { restartAnimation(shouldAnimate: layout.shouldAnimate) }
    .onChange(of: layout.animationIdentity) { _ in
      restartAnimation(shouldAnimate: layout.shouldAnimate)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(content.text)
  }

  var measuredText: some View {
    displayText
      .background(MarqueeTextSizeReader())
  }

  var displayText: some View {
    content.text
      .lineLimit(1)
      .fixedSize()
  }

  func restartAnimation(shouldAnimate: Bool) {
    guard shouldAnimate else { return }

    animationStartDate = Date()
  }

  func scrollingText(layout: MarqueeResolvedLayout) -> some View {
    TimelineView(.animation(paused: !layout.shouldAnimate)) { timeline in
      HStack(spacing: configuration.spacing) {
        displayText
        displayText
      }
      .offset(
        x: layout.offset(
          at: timeline.date,
          startDate: animationStartDate
        )
      )
    }
  }

  func updateContainerSize(_ newValue: CGSize) {
    updateSize(&containerSize, to: newValue)
  }

  func updateTextSize(_ newValue: CGSize) {
    updateSize(&textSize, to: newValue)
  }

  func updateSize(_ size: inout CGSize, to newValue: CGSize) {
    let sanitizedValue = newValue.marqueeSanitized

    guard size.isMeaningfullyDifferent(from: sanitizedValue) else { return }

    size = sanitizedValue
  }
}

enum MarqueeContent {
  case localized(LocalizedStringResource)
  case verbatim(String)

  var text: Text {
    switch self {
    case .localized(let text):
      Text(text)
    case .verbatim(let text):
      Text(verbatim: text)
    }
  }

  var animationIdentity: String {
    switch self {
    case .localized(let text):
      "localized:\(String(describing: text))"
    case .verbatim(let text):
      "verbatim:\(text)"
    }
  }
}

struct MarqueeConfiguration: Equatable {
  static let defaultDelay: TimeInterval = 1
  static let defaultDuration: TimeInterval = 8
  static let defaultSpacing: CGFloat = 50

  var delay: TimeInterval
  var duration: TimeInterval
  var spacing: CGFloat

  init(
    duration: TimeInterval = Self.defaultDuration,
    delay: TimeInterval = Self.defaultDelay,
    spacing: CGFloat = Self.defaultSpacing
  ) {
    self.duration = duration.marqueePositive(or: Self.defaultDuration)
    self.delay = delay.marqueeNonNegative
    self.spacing = spacing.marqueeNonNegative
  }
}

struct MarqueeResolvedLayout: Equatable {
  static let defaultHeight: CGFloat = 20
  static let overflowTolerance: CGFloat = 0.5

  var configuration: MarqueeConfiguration
  var containerSize: CGSize
  var contentIdentity: String
  var layoutDirection: LayoutDirection
  var localeIdentifier: String
  var reduceMotion: Bool
  var textSize: CGSize

  init(
    textSize: CGSize,
    containerSize: CGSize,
    configuration: MarqueeConfiguration,
    contentIdentity: String,
    layoutDirection: LayoutDirection,
    localeIdentifier: String,
    reduceMotion: Bool
  ) {
    self.configuration = configuration
    self.containerSize = containerSize.marqueeSanitized
    self.contentIdentity = contentIdentity
    self.layoutDirection = layoutDirection
    self.localeIdentifier = localeIdentifier
    self.reduceMotion = reduceMotion
    self.textSize = textSize.marqueeSanitized
  }

  var alignment: Alignment {
    isRightToLeft ? .trailing : .leading
  }

  var animationIdentity: MarqueeAnimationIdentity {
    MarqueeAnimationIdentity(
      containerWidth: containerSize.width,
      contentIdentity: contentIdentity,
      delay: configuration.delay,
      duration: configuration.duration,
      isRightToLeft: isRightToLeft,
      localeIdentifier: localeIdentifier,
      reduceMotion: reduceMotion,
      shouldScroll: shouldScroll,
      spacing: configuration.spacing,
      textWidth: textSize.width
    )
  }

  var hasAnimation: Bool {
    shouldAnimate
  }

  var hasMeasuredContainer: Bool {
    containerSize.width > 0
  }

  var hasMeasuredText: Bool {
    textSize.width > 0 && textSize.height > 0
  }

  var height: CGFloat {
    textSize.height > 0 ? textSize.height : Self.defaultHeight
  }

  var isRightToLeft: Bool {
    layoutDirection == .rightToLeft
  }

  var offset: CGFloat {
    offset(progress: 1)
  }

  var overflows: Bool {
    guard hasMeasuredContainer, hasMeasuredText else { return false }

    return textSize.width - containerSize.width > Self.overflowTolerance
  }

  var scrollDistance: CGFloat {
    textSize.width + configuration.spacing
  }

  var shouldAnimate: Bool {
    shouldScroll
  }

  var shouldScroll: Bool {
    overflows && !reduceMotion
  }

  func offset(
    at date: Date,
    startDate: Date
  ) -> CGFloat {
    offset(progress: progress(at: date, startDate: startDate))
  }

  func offset(progress: CGFloat) -> CGFloat {
    guard shouldScroll else { return 0 }

    let distance = scrollDistance * progress.marqueeClamped(to: 0...1)
    return isRightToLeft ? distance : -distance
  }

  func progress(
    at date: Date,
    startDate: Date
  ) -> CGFloat {
    guard shouldScroll else { return 0 }

    let elapsed = max(0, date.timeIntervalSince(startDate))
    let cycleDuration = configuration.delay + configuration.duration
    guard cycleDuration.isFinite, cycleDuration > 0 else { return 0 }

    let cycleElapsed = elapsed.truncatingRemainder(dividingBy: cycleDuration)

    guard cycleElapsed > configuration.delay else { return 0 }

    return CGFloat((cycleElapsed - configuration.delay) / configuration.duration)
      .marqueeClamped(to: 0...1)
  }
}

struct MarqueeAnimationIdentity: Equatable, Hashable {
  var containerWidth: CGFloat
  var contentIdentity: String
  var delay: TimeInterval
  var duration: TimeInterval
  var isRightToLeft: Bool
  var localeIdentifier: String
  var reduceMotion: Bool
  var shouldScroll: Bool
  var spacing: CGFloat
  var textWidth: CGFloat
}

struct MarqueeContainerSizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize {
    .zero
  }

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue().marqueeSanitized
  }
}

struct MarqueeTextSizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize {
    .zero
  }

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue().marqueeSanitized
  }
}

struct MarqueeContainerSizeReader: View {
  var body: some View {
    GeometryReader { geometry in
      Color.clear
        .allowsHitTesting(false)
        .preference(
          key: MarqueeContainerSizePreferenceKey.self,
          value: geometry.size
        )
    }
  }
}

struct MarqueeTextSizeReader: View {
  var body: some View {
    GeometryReader { geometry in
      Color.clear
        .allowsHitTesting(false)
        .preference(
          key: MarqueeTextSizePreferenceKey.self,
          value: geometry.size
        )
    }
  }
}

struct MarqueeSizingLayout: Layout {
  var alignment: Alignment

  var placementAnchor: UnitPoint {
    alignment == .trailing ? .trailing : .leading
  }

  static func resolvedSize(
    intrinsicSize: CGSize,
    proposedWidth: CGFloat?,
    proposedHeight: CGFloat?
  ) -> CGSize {
    let intrinsicSize = intrinsicSize.marqueeSanitized
    let width = proposedWidth
      .flatMap { $0.isFinite ? min($0.marqueeNonNegative, intrinsicSize.width) : nil }
      ?? intrinsicSize.width
    let height = proposedHeight
      .flatMap { $0.isFinite ? $0.marqueeNonNegative : nil }
      ?? intrinsicSize.height

    return CGSize(width: width, height: height)
      .marqueeSanitized
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) -> CGSize {
    let intrinsicSize = subviews[0].sizeThatFits(.unspecified)

    return Self.resolvedSize(
      intrinsicSize: intrinsicSize,
      proposedWidth: proposal.width,
      proposedHeight: proposal.height
    )
  }

  func placementPoint(in bounds: CGRect) -> CGPoint {
    alignment == .trailing
      ? CGPoint(x: bounds.maxX, y: bounds.midY)
      : CGPoint(x: bounds.minX, y: bounds.midY)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal _: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) {
    for subview in subviews {
      subview.place(
        at: placementPoint(in: bounds),
        anchor: placementAnchor,
        proposal: ProposedViewSize(
          width: bounds.width,
          height: bounds.height
        )
      )
    }
  }
}

extension CGSize {
  var marqueeSanitized: CGSize {
    CGSize(
      width: width.marqueeNonNegative,
      height: height.marqueeNonNegative
    )
  }

  func isMeaningfullyDifferent(
    from other: CGSize,
    tolerance: CGFloat = 0
  ) -> Bool {
    guard width.isFinite, height.isFinite, other.width.isFinite, other.height.isFinite else {
      return true
    }

    return abs(width - other.width) > tolerance
      || abs(height - other.height) > tolerance
  }
}

extension CGFloat {
  var marqueeNonNegative: CGFloat {
    isFinite && self > 0 ? self : 0
  }

  func marqueeClamped(to range: ClosedRange<CGFloat>) -> CGFloat {
    guard !isNaN else { return range.lowerBound }
    guard isFinite else {
      return self > 0 ? range.upperBound : range.lowerBound
    }

    return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
  }
}

extension TimeInterval {
  var marqueeNonNegative: TimeInterval {
    isFinite && self > 0 ? self : 0
  }

  func marqueePositive(or fallback: TimeInterval) -> TimeInterval {
    isFinite && self > 0 ? self : fallback
  }
}
