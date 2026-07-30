@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueeSizingLayoutTests {
  @Test
  func placementHonorsLayoutAlignment() {
    let bounds = CGRect(x: 10, y: 20, width: 80, height: 30)
    let leadingLayout = MarqueeSizingLayout(alignment: .leading, isScrolling: false, spacing: 0)
    let trailingLayout = MarqueeSizingLayout(alignment: .trailing, isScrolling: false, spacing: 0)

    #expect(leadingLayout.placementAnchor == .leading)
    #expect(leadingLayout.placementPoint(in: bounds) == CGPoint(x: 10, y: 35))
    #expect(trailingLayout.placementAnchor == .trailing)
    #expect(trailingLayout.placementPoint(in: bounds) == CGPoint(x: 90, y: 35))
  }

  @Test
  func unspecifiedProposalUsesIntrinsicSize() {
    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: 120, height: 18),
        proposedWidth: nil,
        proposedHeight: nil
      ) == CGSize(width: 120, height: 18)
    )
  }

  @Test
  func finiteWidthIsCappedAtIntrinsicWidth() {
    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: 120, height: 18),
        proposedWidth: 80,
        proposedHeight: nil
      ) == CGSize(width: 80, height: 18)
    )

    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: 120, height: 18),
        proposedWidth: 200,
        proposedHeight: nil
      ) == CGSize(width: 120, height: 18)
    )
  }

  @Test
  func generousHeightProposalsNeverStretchTheMarquee() {
    // A single line `Text` keeps its own height no matter how much room it is offered. Growing to fill
    // would make the marquee behave like `Color` inside stacks, overlays, and z-stacks.
    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: 120, height: 18),
        proposedWidth: 80,
        proposedHeight: 400
      ) == CGSize(width: 80, height: 18)
    )
  }

  @Test
  func tightHeightProposalsAreHonoredLikeText() {
    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: 120, height: 18),
        proposedWidth: nil,
        proposedHeight: 12
      ) == CGSize(width: 120, height: 12)
    )
  }

  @Test
  func invalidProposalsFallBackOrClampSafely() {
    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: 120, height: 18),
        proposedWidth: .infinity,
        proposedHeight: .nan
      ) == CGSize(width: 120, height: 18)
    )

    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: 120, height: 18),
        proposedWidth: -10,
        proposedHeight: -4
      ) == .zero
    )
  }

  @Test
  func invalidIntrinsicSizeIsSanitizedBeforeResolvingProposal() {
    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: CGFloat.nan, height: CGFloat.infinity),
        proposedWidth: nil,
        proposedHeight: nil
      ) == .zero
    )

    #expect(
      MarqueeSizingLayout.resolvedSize(
        intrinsicSize: CGSize(width: CGFloat.infinity, height: CGFloat.nan),
        proposedWidth: 40,
        proposedHeight: 12
      ) == .zero
    )
  }
}
