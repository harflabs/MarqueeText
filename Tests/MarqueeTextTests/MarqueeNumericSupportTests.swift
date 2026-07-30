@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueeSizeHelperTests {
  @Test
  func sanitizesInvalidSizes() {
    #expect(CGSize(width: -.infinity, height: .nan).marqueeSanitized == .zero)
    #expect(CGSize(width: 44, height: 12).marqueeSanitized == CGSize(width: 44, height: 12))
  }

  @Test
  func scalarSanitizersHandleFiniteAndInvalidValues() {
    #expect(CGFloat(12).marqueeNonNegative == 12)
    #expect(CGFloat(-1).marqueeNonNegative == 0)
    #expect(CGFloat.nan.marqueeNonNegative == 0)
    #expect(CGFloat.infinity.marqueeNonNegative == 0)

    #expect(TimeInterval(2).marqueeNonNegative == 2)
    #expect(TimeInterval(-2).marqueeNonNegative == 0)
    #expect(TimeInterval.nan.marqueeNonNegative == 0)
    #expect(TimeInterval.infinity.marqueeNonNegative == 0)

    #expect(TimeInterval(2).marqueePositive(or: 8) == 2)
    #expect(TimeInterval(0).marqueePositive(or: 8) == 8)
    #expect(TimeInterval.infinity.marqueePositive(or: 8) == 8)

    #expect(CGFloat(-0.5).marqueeClamped(to: 0...1) == 0)
    #expect(CGFloat(0.5).marqueeClamped(to: 0...1) == 0.5)
    #expect(CGFloat(1.5).marqueeClamped(to: 0...1) == 1)
    #expect(CGFloat.nan.marqueeClamped(to: 0...1) == 0)
    #expect(CGFloat.infinity.marqueeClamped(to: 0...1) == 1)
    #expect(CGFloat(-CGFloat.infinity).marqueeClamped(to: 0...1) == 0)
  }
}
