import SwiftUI

struct MarqueeMeasurement: Equatable {
  static let zero = MarqueeMeasurement(textWidth: 0, containerWidth: 0)

  var containerWidth: CGFloat
  var textWidth: CGFloat

  init(textWidth: CGFloat, containerWidth: CGFloat) {
    self.containerWidth = containerWidth.marqueeNonNegative
    self.textWidth = textWidth.marqueeNonNegative
  }

  /// Rebuilds the measurement from the size the probe actually resolved to.
  init(probeSize: CGSize) {
    self.init(textWidth: probeSize.width, containerWidth: probeSize.height)
  }

  /// The proposal that makes a probe resolve to this measurement.
  var probeProposal: ProposedViewSize {
    ProposedViewSize(width: textWidth, height: containerWidth)
  }
}
