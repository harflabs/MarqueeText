import SwiftUI

struct MarqueeHorizontalClipShape: Shape {
  static let minimumVerticalOverhang: CGFloat = 64
  static let verticalOverhangMultiplier: CGFloat = 4

  static func verticalOverhang(forHeight height: CGFloat) -> CGFloat {
    Swift.max(height.marqueeNonNegative * verticalOverhangMultiplier, minimumVerticalOverhang)
  }

  static func clipRect(in rect: CGRect) -> CGRect {
    let width = rect.width.marqueeNonNegative
    let height = rect.height.marqueeNonNegative
    let overhang = verticalOverhang(forHeight: height)
    let originX = rect.origin.x.isFinite ? rect.origin.x : 0
    let originY = rect.origin.y.isFinite ? rect.origin.y : 0

    return CGRect(
      x: originX,
      y: originY - overhang,
      width: width,
      height: height + overhang * 2
    )
  }

  func path(in rect: CGRect) -> Path {
    Path(Self.clipRect(in: rect))
  }
}
