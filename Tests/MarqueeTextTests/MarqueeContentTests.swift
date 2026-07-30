@testable import MarqueeText
import SwiftUI
import Testing

@MainActor
struct MarqueeContentTests {
  @Test
  func stringLiteralsUseLocalizedContent() {
    let view = MarqueeText("Localized title")

    switch view.content {
    case .localized:
      break
    case .verbatim:
      Issue.record("String literals should keep using LocalizedStringResource.")
    }
  }

  @Test
  func runtimeStringsUseVerbatimContent() {
    let title = String("Runtime title")
    let view = MarqueeText(title)

    switch view.content {
    case .localized:
      Issue.record("Runtime strings should use verbatim text.")
    case .verbatim(let text):
      #expect(text == "Runtime title")
    }
  }

  @Test
  func explicitVerbatimInitializerUsesVerbatimContent() {
    let view = MarqueeText(verbatim: "Exact title")

    switch view.content {
    case .localized:
      Issue.record("Verbatim initializer should keep the exact string.")
    case .verbatim(let text):
      #expect(text == "Exact title")
    }
  }

  @Test
  func textViewsCanBeCreatedForBothContentKinds() {
    let localizedText: Text = MarqueeContent.localized("Title").text
    let verbatimText: Text = MarqueeContent.verbatim("Title").text

    _ = localizedText
    _ = verbatimText
  }

  @Test
  func contentComparesByValueWithoutReflection() {
    // Comparing equal-looking operands is the point here: it proves equality is by value, not by identity.
    // swiftlint:disable identical_operands
    #expect(MarqueeContent.verbatim("Title A") == MarqueeContent.verbatim("Title A"))
    #expect(MarqueeContent.verbatim("Title A") != MarqueeContent.verbatim("Title B"))
    #expect(MarqueeContent.localized("Title A") == MarqueeContent.localized("Title A"))
    // swiftlint:enable identical_operands
    #expect(MarqueeContent.localized("Title A") != MarqueeContent.localized("Title B"))
    #expect(MarqueeContent.localized("Title A") != MarqueeContent.verbatim("Title A"))
  }

  @Test
  func bodiesCanBeCreatedForLocalizedAndVerbatimContent() {
    _ = MarqueeText("Localized title").body
    _ = MarqueeText(verbatim: "Runtime title").body
    _ = MarqueeText(
      content: .verbatim("Overflowing runtime title"),
      configuration: MarqueeConfiguration(duration: 2, delay: 0, spacing: 12),
      measurement: MarqueeMeasurement(textWidth: 180, containerWidth: 80)
    )
    .body
  }

  #if os(macOS)
  @Test
  func staticTextCanBeRenderedToAnImage() {
    let renderer = ImageRenderer(
      content: MarqueeText("Rendered title")
        .frame(width: 240, height: 44)
    )

    #expect(renderer.nsImage != nil)
  }

  @Test
  func overflowingTextCanBeRenderedToAnImage() {
    let renderer = ImageRenderer(
      content: MarqueeText(
        content: .verbatim("Rendered overflowing title"),
        configuration: MarqueeConfiguration(duration: 2, delay: 0, spacing: 12),
        measurement: MarqueeMeasurement(textWidth: 220, containerWidth: 80),
        animationStartDate: Date(timeIntervalSince1970: 0)
      )
      .frame(width: 80, height: 44)
    )

    #expect(renderer.nsImage != nil)
  }
  #endif

  @Test
  func internalViewHelpersCanBeCreatedAndAnimationCanRestart() {
    let view = MarqueeText(verbatim: "A long runtime title")
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 80
    )

    _ = view.intrinsicText
    _ = view.truncatingText
    _ = view.scrollingText(layout: layout)
    _ = MarqueeMeasurementReader().body

    view.restartAnimation(shouldAnimate: false)
    view.restartAnimation(shouldAnimate: true)
  }

  @Test
  func measurementUpdatesAreSanitizedAndSubPointChangesStillApply() {
    let view = MarqueeText(verbatim: "Runtime title")

    // Sub-point changes matter: they decide which side of the overflow threshold the text lands on.
    #expect(
      MarqueeMeasurement(textWidth: 100.4, containerWidth: 100)
        != MarqueeMeasurement(textWidth: 100.8, containerWidth: 100)
    )
    #expect(
      MarqueeMeasurement(textWidth: .nan, containerWidth: -.infinity) == .zero
    )

    view.updateMeasurement(MarqueeMeasurement(textWidth: 80, containerWidth: 40))
  }

  @Test
  func probeProposalRoundTripsThroughTheProbeSize() {
    let measurement = MarqueeMeasurement(textWidth: 180, containerWidth: 100)
    let proposal = measurement.probeProposal

    #expect(proposal.width == 180)
    #expect(proposal.height == 100)
    #expect(MarqueeMeasurement(probeSize: CGSize(width: 180, height: 100)) == measurement)
  }
}
