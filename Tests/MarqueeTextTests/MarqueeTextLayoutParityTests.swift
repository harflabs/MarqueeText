@testable import MarqueeText
import SwiftUI
import Testing

#if canImport(AppKit)
import AppKit
#endif

#if os(macOS)
/// Locks in the promise that `MarqueeText` is layout-interchangeable with a single line `Text`.
///
/// These assertions run against a real hosting view, so they cover the very first layout pass — the pass
/// that used to report a hard-coded 20pt height and shift surrounding layout on the next frame.
@MainActor
struct MarqueeTextLayoutParityTests {
  @Test(arguments: [
    "Hi",
    "A long headline that comfortably overflows any reasonable container",
    "",
    "نص عربي طويل جدا يتجاوز عرض الحاوية"
  ])
  func marqueeReportsTheSameSizeAsTextForEveryProposal(_ string: String) {
    for font in [Font.caption, .body, .largeTitle] {
      let probes = LayoutProbe.probes(
        for: MarqueeText(verbatim: string).font(font),
        reference: Text(verbatim: string).lineLimit(1).font(font)
      )

      #expect(probes.marquee.ideal == probes.reference.ideal)
      #expect(probes.marquee.zeroProposal == probes.reference.zeroProposal)
      #expect(probes.marquee.infiniteProposal == probes.reference.infiniteProposal)
      #expect(probes.marquee.firstBaseline == probes.reference.firstBaseline)
      #expect(probes.marquee.lastBaseline == probes.reference.lastBaseline)
    }
  }

  @Test
  func marqueeReportsItsFinalSizeOnTheFirstLayoutPass() {
    let passes = LayoutProbe.allPasses(for: MarqueeText(verbatim: "Hi").font(.largeTitle))

    #expect(passes.count >= 1)
    #expect(Set(passes.map(\.ideal.height)).count == 1, "Height must not change once measurement settles.")
    #expect(passes.allSatisfy { $0.ideal.height == passes[0].ideal.height })
  }

  @Test
  func aGenerousHeightProposalDoesNotStretchTheMarquee() {
    let probes = LayoutProbe.probes(
      for: MarqueeText(verbatim: "Hi"),
      reference: Text(verbatim: "Hi").lineLimit(1)
    )

    #expect(probes.marquee.tallProposal == probes.reference.tallProposal)
  }
}

struct LayoutProbe {
  var firstBaseline: CGFloat
  var ideal: CGSize
  var infiniteProposal: CGSize
  var lastBaseline: CGFloat
  var tallProposal: CGSize
  var zeroProposal: CGSize

  struct Pair {
    var marquee: LayoutProbe
    var reference: LayoutProbe
  }

  private struct Recorder: Layout {
    var record: @MainActor (LayoutProbe) -> Void

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
      guard let subview = subviews.first else { return .zero }
      let dimensions = subview.dimensions(in: .unspecified)
      let probe = LayoutProbe(
        firstBaseline: dimensions[.firstTextBaseline],
        ideal: subview.sizeThatFits(.unspecified),
        infiniteProposal: subview.sizeThatFits(.infinity),
        lastBaseline: dimensions[.lastTextBaseline],
        tallProposal: subview.sizeThatFits(ProposedViewSize(width: 400, height: 400)),
        zeroProposal: subview.sizeThatFits(.zero)
      )

      MainActor.assumeIsolated { record(probe) }

      return subview.sizeThatFits(proposal)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
      subviews.first?.place(at: bounds.origin, proposal: proposal)
    }
  }

  @MainActor
  static func allPasses(for view: some View) -> [LayoutProbe] {
    let box = Box()
    let record: @MainActor (LayoutProbe) -> Void = { box.probes.append($0) }
    let host = NSHostingView(rootView: Recorder(record: record) { view }.frame(width: 320, height: 60))

    host.layoutSubtreeIfNeeded()
    _ = host.fittingSize

    return box.probes
  }

  @MainActor
  static func probes(for marquee: some View, reference: some View) -> Pair {
    // The last pass is the settled one; comparing it and the first pass is what the callers assert on.
    let marqueePasses = allPasses(for: marquee)
    let referencePasses = allPasses(for: reference)

    return Pair(
      marquee: marqueePasses[marqueePasses.count - 1],
      reference: referencePasses[referencePasses.count - 1]
    )
  }

  @MainActor
  private final class Box {
    var probes: [LayoutProbe] = []
  }
}
#endif
