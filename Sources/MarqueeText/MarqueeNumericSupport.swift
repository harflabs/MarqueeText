import Foundation
import SwiftUI

extension CGSize {
  var marqueeSanitized: CGSize {
    CGSize(
      width: width.marqueeNonNegative,
      height: height.marqueeNonNegative
    )
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
