import SwiftUI

struct MarqueeSizingLayout: Layout {
  var alignment: Alignment
  var isScrolling: Bool
  var spacing: CGFloat

  var placementAnchor: UnitPoint {
    alignment == .trailing ? .trailing : .leading
  }

  /// Recovers the size of a single text run from the ideal size of the displayed content.
  ///
  /// While scrolling, the content is two copies separated by `spacing`, so one run is half of what is left
  /// after the gap. Otherwise the content is a single run already. Deriving it here is what lets the view
  /// avoid laying the text out a second time purely to measure it.
  static func singleTextSize(
    contentIdealSize: CGSize,
    isScrolling: Bool,
    spacing: CGFloat
  ) -> CGSize {
    let contentIdealSize = contentIdealSize.marqueeSanitized

    guard isScrolling else { return contentIdealSize }

    return CGSize(
      width: ((contentIdealSize.width - spacing.marqueeNonNegative) / 2).marqueeNonNegative,
      height: contentIdealSize.height
    )
  }

  /// Resolves the size the marquee reports to its parent.
  ///
  /// This mirrors a single line `Text`: the natural size, capped by whatever the parent proposes on each
  /// axis. It depends only on the content's ideal size, so it is already correct on the first layout pass
  /// and never changes as internal measurement state settles.
  static func resolvedSize(
    intrinsicSize: CGSize,
    proposedWidth: CGFloat?,
    proposedHeight: CGFloat?
  ) -> CGSize {
    let intrinsicSize = intrinsicSize.marqueeSanitized
    let width = proposedWidth
      .flatMap { $0.isFinite ? Swift.min($0.marqueeNonNegative, intrinsicSize.width) : nil }
      ?? intrinsicSize.width
    let height = proposedHeight
      .flatMap { $0.isFinite ? Swift.min($0.marqueeNonNegative, intrinsicSize.height) : nil }
      ?? intrinsicSize.height

    return CGSize(width: width, height: height)
      .marqueeSanitized
  }

  /// The natural size of one text run, derived from the displayed content.
  func intrinsicTextSize(subviews: Subviews) -> CGSize {
    guard let content = subviews.first else { return .zero }

    return Self.singleTextSize(
      contentIdealSize: content.sizeThatFits(.unspecified),
      isScrolling: isScrolling,
      spacing: spacing
    )
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) -> CGSize {
    Self.resolvedSize(
      intrinsicSize: intrinsicTextSize(subviews: subviews),
      proposedWidth: proposal.width,
      proposedHeight: proposal.height
    )
  }

  /// Forwards the text baselines so the marquee aligns with `Text` in `firstTextBaseline` stacks.
  func explicitAlignment(
    of guide: VerticalAlignment,
    in bounds: CGRect,
    proposal _: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) -> CGFloat? {
    guard guide == .firstTextBaseline || guide == .lastTextBaseline else { return nil }
    guard let content = subviews.first else { return nil }

    let dimensions = content.dimensions(in: .unspecified)
    let baseline = dimensions[guide]

    guard baseline.isFinite, dimensions.height.isFinite, bounds.height.isFinite else { return nil }

    return (bounds.height - dimensions.height) / 2 + baseline
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
    guard let content = subviews.first else { return }

    content.place(
      at: placementPoint(in: bounds),
      anchor: placementAnchor,
      proposal: ProposedViewSize(
        width: bounds.width,
        height: bounds.height
      )
    )

    // Any remaining subview is the measurement probe. Proposing the two widths makes it report them
    // back through a preference, so neither the text nor the container needs its own geometry reader.
    guard subviews.count > 1 else { return }

    let measurement = MarqueeMeasurement(
      textWidth: intrinsicTextSize(subviews: subviews).width,
      containerWidth: bounds.width
    )

    for index in 1..<subviews.count {
      subviews[index].place(
        at: placementPoint(in: bounds),
        anchor: placementAnchor,
        proposal: measurement.probeProposal
      )
    }
  }
}
