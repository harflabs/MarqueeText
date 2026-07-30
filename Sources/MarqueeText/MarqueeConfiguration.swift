import Foundation
import SwiftUI

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
