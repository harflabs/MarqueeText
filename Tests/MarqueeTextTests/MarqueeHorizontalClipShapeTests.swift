@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueeHorizontalClipShapeTests {
  @Test
  func clipMatchesTheViewHorizontallyAndExtendsPastItVertically() {
    let rect = CGRect(x: 0, y: 0, width: 120, height: 18)
    let clip = MarqueeHorizontalClipShape.clipRect(in: rect)

    #expect(clip.minX == rect.minX)
    #expect(clip.width == rect.width)
    #expect(clip.minY < rect.minY)
    #expect(clip.maxY > rect.maxY)
  }

  @Test
  func verticalOverhangComfortablyExceedsGlyphOverhang() {
    // Diacritics, emoji, and tall accents paint outside the line box; the clip must never cut them.
    #expect(MarqueeHorizontalClipShape.verticalOverhang(forHeight: 18) >= 18)
    #expect(MarqueeHorizontalClipShape.verticalOverhang(forHeight: 100) == 400)
    #expect(
      MarqueeHorizontalClipShape.verticalOverhang(forHeight: 0)
        == MarqueeHorizontalClipShape.minimumVerticalOverhang
    )
  }

  @Test
  func invalidRectsProduceAFiniteClip() {
    let clip = MarqueeHorizontalClipShape.clipRect(
      in: CGRect(x: CGFloat.nan, y: .infinity, width: .nan, height: .infinity)
    )

    #expect(clip.origin.x.isFinite)
    #expect(clip.origin.y.isFinite)
    #expect(clip.width == 0)
    #expect(clip.height.isFinite)

    _ = MarqueeHorizontalClipShape().path(in: CGRect(x: 0, y: 0, width: 120, height: 18))
  }
}
