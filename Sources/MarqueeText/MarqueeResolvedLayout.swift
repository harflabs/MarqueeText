import Foundation
import SwiftUI

struct MarqueeResolvedLayout: Equatable {
  static let overflowTolerance: CGFloat = 0.5

  var configuration: MarqueeConfiguration
  var content: MarqueeContent
  var layoutDirection: LayoutDirection
  var localeIdentifier: String
  var measurement: MarqueeMeasurement
  var reduceMotion: Bool

  var alignment: Alignment {
    isRightToLeft ? .trailing : .leading
  }

  var animationIdentity: MarqueeAnimationIdentity {
    MarqueeAnimationIdentity(
      containerWidth: measurement.containerWidth,
      content: content,
      delay: configuration.delay,
      duration: configuration.duration,
      isRightToLeft: isRightToLeft,
      localeIdentifier: localeIdentifier,
      reduceMotion: reduceMotion,
      shouldScroll: shouldScroll,
      spacing: configuration.spacing,
      textWidth: measurement.textWidth
    )
  }

  var hasMeasuredContainer: Bool {
    measurement.containerWidth > 0
  }

  var hasMeasuredText: Bool {
    measurement.textWidth > 0
  }

  var isRightToLeft: Bool {
    layoutDirection == .rightToLeft
  }

  var offset: CGFloat {
    offset(progress: 1)
  }

  var overflows: Bool {
    guard hasMeasuredContainer, hasMeasuredText else { return false }

    return measurement.textWidth - measurement.containerWidth > Self.overflowTolerance
  }

  var scrollDistance: CGFloat {
    measurement.textWidth + configuration.spacing
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

struct MarqueeAnimationIdentity: Equatable {
  var containerWidth: CGFloat
  var content: MarqueeContent
  var delay: TimeInterval
  var duration: TimeInterval
  var isRightToLeft: Bool
  var localeIdentifier: String
  var reduceMotion: Bool
  var shouldScroll: Bool
  var spacing: CGFloat
  var textWidth: CGFloat
}
