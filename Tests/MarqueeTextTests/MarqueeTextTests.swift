@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueeConfigurationTests {
  @Test
  func validConfigurationIsPreserved() {
    let configuration = MarqueeConfiguration(
      duration: 4.5,
      delay: 0.25,
      spacing: 12
    )

    #expect(
      configuration == MarqueeConfiguration(
        duration: 4.5,
        delay: 0.25,
        spacing: 12
      )
    )
  }

  @Test
  func invalidConfigurationIsClamped() {
    #expect(
      MarqueeConfiguration(
        duration: -1,
        delay: -.infinity,
        spacing: .nan
      ) == MarqueeConfiguration(
        duration: MarqueeConfiguration.defaultDuration,
        delay: 0,
        spacing: 0
      )
    )
  }

  @Test
  func zeroDurationUsesDefaultButZeroDelayAndSpacingAreAllowed() {
    #expect(
      MarqueeConfiguration(
        duration: 0,
        delay: 0,
        spacing: 0
      ) == MarqueeConfiguration(
        duration: MarqueeConfiguration.defaultDuration,
        delay: 0,
        spacing: 0
      )
    )
  }

  @Test
  func positiveInfinityConfigurationValuesAreClamped() {
    #expect(
      MarqueeConfiguration(
        duration: .infinity,
        delay: .infinity,
        spacing: .infinity
      ) == MarqueeConfiguration(
        duration: MarqueeConfiguration.defaultDuration,
        delay: 0,
        spacing: 0
      )
    )
  }
}

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
  func contentIdentityChangesWhenTextChanges() {
    #expect(MarqueeContent.verbatim("Title A").animationIdentity == "verbatim:Title A")
    #expect(MarqueeContent.verbatim("Title A").animationIdentity != MarqueeContent.verbatim("Title B").animationIdentity)
    #expect(MarqueeContent.localized("Title A").animationIdentity != MarqueeContent.localized("Title B").animationIdentity)
  }

  @Test
  func bodiesCanBeCreatedForLocalizedAndVerbatimContent() {
    _ = MarqueeText("Localized title").body
    _ = MarqueeText(verbatim: "Runtime title").body
    _ = MarqueeText(
      content: .verbatim("Overflowing runtime title"),
      configuration: MarqueeConfiguration(duration: 2, delay: 0, spacing: 12),
      containerSize: CGSize(width: 80, height: 20),
      textSize: CGSize(width: 180, height: 18)
    )
    .body
  }

  #if os(macOS)
  @Test
  func staticTextCanBeRenderedToAnImage() {
    if #available(macOS 13.0, *) {
      let renderer = ImageRenderer(
        content: MarqueeText("Rendered title")
          .frame(width: 240, height: 44)
      )

      #expect(renderer.nsImage != nil)
    }
  }

  @Test
  func overflowingTextCanBeRenderedToAnImage() {
    if #available(macOS 13.0, *) {
      let renderer = ImageRenderer(
        content: MarqueeText(
          content: .verbatim("Rendered overflowing title"),
          configuration: MarqueeConfiguration(duration: 2, delay: 0, spacing: 12),
          containerSize: CGSize(width: 80, height: 18),
          textSize: CGSize(width: 220, height: 18),
          animationStartDate: Date(timeIntervalSince1970: 0)
        )
        .frame(width: 80, height: 44)
      )

      #expect(renderer.nsImage != nil)
    }
  }
  #endif

  @Test
  func internalViewHelpersCanBeCreatedAndAnimationCanRestart() {
    let view = MarqueeText(verbatim: "A long runtime title")
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 80, height: 20)
    )

    _ = view.measuredText
    _ = view.displayText
    _ = view.scrollingText(layout: layout)
    _ = MarqueeContainerSizeReader().body
    _ = MarqueeTextSizeReader().body

    view.restartAnimation(shouldAnimate: false)
    view.restartAnimation(shouldAnimate: true)
  }

  @Test
  func sizeUpdatesApplySubPointMeaningfulAndSanitizedChanges() {
    let view = MarqueeText(verbatim: "Runtime title")
    var size = CGSize(width: 10, height: 10)

    view.updateSize(&size, to: CGSize(width: 10.4, height: 10.4))
    #expect(size == CGSize(width: 10.4, height: 10.4))

    view.updateSize(&size, to: CGSize(width: 12, height: 10))
    #expect(size == CGSize(width: 12, height: 10))

    view.updateSize(&size, to: CGSize(width: .nan, height: -.infinity))
    #expect(size == .zero)

    view.updateContainerSize(CGSize(width: 40, height: 20))
    view.updateTextSize(CGSize(width: 80, height: 20))
  }

  @Test
  func subPointSizeChangesAreAppliedSoOverflowCanRecompute() {
    let view = MarqueeText(verbatim: "Runtime title")
    var size = CGSize(width: 100.4, height: 18)

    view.updateSize(&size, to: CGSize(width: 100.8, height: 18))

    #expect(size == CGSize(width: 100.8, height: 18))
  }

  @Test
  func sizeUpdatesRepairInvalidCurrentValues() {
    let view = MarqueeText(verbatim: "Runtime title")
    var size = CGSize(width: CGFloat.nan, height: CGFloat.infinity)

    view.updateSize(&size, to: .zero)

    #expect(size == .zero)
  }
}

struct MarqueeLayoutTests {
  @Test
  func unmeasuredTextDoesNotScroll() {
    let layout = resolvedLayout(
      textSize: .zero,
      containerSize: CGSize(width: 100, height: 20)
    )

    #expect(!layout.hasMeasuredText)
    #expect(layout.hasMeasuredContainer)
    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
    #expect(!layout.shouldAnimate)
    #expect(!layout.hasAnimation)
    #expect(layout.height == MarqueeResolvedLayout.defaultHeight)
    #expect(layout.offset == 0)
  }

  @Test
  func unmeasuredContainerDoesNotScroll() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 120, height: 18),
      containerSize: .zero
    )

    #expect(layout.hasMeasuredText)
    #expect(!layout.hasMeasuredContainer)
    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
    #expect(layout.height == 18)
  }

  @Test
  func textWithinOverflowToleranceDoesNotScroll() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 100.4, height: 18),
      containerSize: CGSize(width: 100, height: 20)
    )

    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
  }

  @Test
  func textJustBeyondOverflowToleranceScrolls() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 100.6, height: 18),
      containerSize: CGSize(width: 100, height: 20)
    )

    #expect(layout.overflows)
    #expect(layout.shouldScroll)
  }

  @Test
  func textWithZeroHeightDoesNotScrollEvenWhenWidthOverflows() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 0),
      containerSize: CGSize(width: 100, height: 20)
    )

    #expect(!layout.hasMeasuredText)
    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
  }

  @Test
  func overflowingTextScrollsWhenMotionIsAllowed() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      configuration: MarqueeConfiguration(duration: 3, delay: 0.5, spacing: 24)
    )

    #expect(layout.overflows)
    #expect(layout.shouldScroll)
    #expect(layout.shouldAnimate)
    #expect(layout.hasAnimation)
    #expect(layout.scrollDistance == 204)
    #expect(layout.offset == -204)
  }

  @Test
  func timelineProgressWaitsDuringDelayAndMovesLinearly() {
    let startDate = Date(timeIntervalSince1970: 100)
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      configuration: MarqueeConfiguration(duration: 4, delay: 1, spacing: 20)
    )

    #expect(layout.shouldScroll)
    #expect(layout.shouldAnimate)
    #expect(layout.hasAnimation)
    #expect(layout.progress(at: startDate, startDate: startDate) == 0)
    #expect(layout.progress(at: startDate.addingTimeInterval(0.5), startDate: startDate) == 0)
    #expect(layout.progress(at: startDate.addingTimeInterval(3), startDate: startDate) == 0.5)
    #expect(layout.offset(at: startDate, startDate: startDate) == 0)
    #expect(layout.offset(at: startDate.addingTimeInterval(3), startDate: startDate) == -100)
    #expect(layout.progress(at: startDate.addingTimeInterval(5.5), startDate: startDate) == 0)
  }

  @Test
  func timelineProgressDoesNotMoveBeforeStartDate() {
    let startDate = Date(timeIntervalSince1970: 100)
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      configuration: MarqueeConfiguration(duration: 4, delay: 1, spacing: 20)
    )

    #expect(layout.progress(at: startDate.addingTimeInterval(-10), startDate: startDate) == 0)
    #expect(layout.offset(at: startDate.addingTimeInterval(-10), startDate: startDate) == 0)
  }

  @Test
  func timelineProgressHandlesOverflowingCycleDuration() {
    let startDate = Date(timeIntervalSince1970: 100)
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      configuration: MarqueeConfiguration(
        duration: .greatestFiniteMagnitude,
        delay: .greatestFiniteMagnitude,
        spacing: 20
      )
    )

    #expect(layout.progress(at: startDate.addingTimeInterval(1), startDate: startDate) == 0)
    #expect(layout.offset(at: startDate.addingTimeInterval(1), startDate: startDate) == 0)
  }

  @Test
  func repeatedGeometryChangesDoNotAccelerateTimelineMotion() {
    let startDate = Date(timeIntervalSince1970: 200)
    let date = startDate.addingTimeInterval(2)
    let configuration = MarqueeConfiguration(duration: 4, delay: 0, spacing: 20)
    let offsets = [80, 120, 160, 80, 120, 160].map { width in
      resolvedLayout(
        textSize: CGSize(width: 300, height: 18),
        containerSize: CGSize(width: width, height: 20),
        configuration: configuration
      )
      .offset(at: date, startDate: startDate)
    }

    #expect(offsets.allSatisfy { $0 == -160 })
  }

  @Test
  func repeatedTimelineCyclesDoNotAccumulateExtraDistance() {
    let startDate = Date(timeIntervalSince1970: 300)
    let layout = resolvedLayout(
      textSize: CGSize(width: 300, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      configuration: MarqueeConfiguration(duration: 4, delay: 0, spacing: 20)
    )

    #expect(layout.offset(at: startDate.addingTimeInterval(2), startDate: startDate) == -160)
    #expect(layout.offset(at: startDate.addingTimeInterval(6), startDate: startDate) == -160)
    #expect(layout.offset(at: startDate.addingTimeInterval(10), startDate: startDate) == -160)
  }

  @Test
  func reducedMotionStopsScrollingEvenWhenTextOverflows() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      reduceMotion: true
    )

    #expect(layout.overflows)
    #expect(!layout.shouldScroll)
    #expect(!layout.shouldAnimate)
    #expect(!layout.hasAnimation)
    #expect(layout.offset == 0)
    #expect(layout.progress(at: Date(), startDate: Date(timeIntervalSince1970: 0)) == 0)
  }

  @Test
  func rightToLeftLayoutMirrorsAlignmentAndOffset() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      configuration: MarqueeConfiguration(duration: 3, delay: 0.5, spacing: 24),
      layoutDirection: .rightToLeft
    )

    #expect(layout.isRightToLeft)
    #expect(layout.alignment == .trailing)
    #expect(layout.offset == 204)
    #expect(layout.offset(progress: 0.5) == 102)
  }

  @Test
  func leftToRightLayoutUsesLeadingAlignment() {
    let layout = resolvedLayout(layoutDirection: .leftToRight)

    #expect(!layout.isRightToLeft)
    #expect(layout.alignment == .leading)
  }

  @Test
  func animationIdentityCapturesLayoutInputs() {
    let layout = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      configuration: MarqueeConfiguration(duration: 3, delay: 0.5, spacing: 24),
      contentIdentity: "verbatim:title",
      layoutDirection: .rightToLeft
    )

    #expect(
      layout.animationIdentity == MarqueeAnimationIdentity(
        containerWidth: 100,
        contentIdentity: "verbatim:title",
        delay: 0.5,
        duration: 3,
        isRightToLeft: true,
        localeIdentifier: "en",
        reduceMotion: false,
        shouldScroll: true,
        spacing: 24,
        textWidth: 180
      )
    )
    #expect(Set([layout.animationIdentity]).contains(layout.animationIdentity))
  }

  @Test
  func animationIdentityChangesForContentAndLocaleChangesWithTheSameMeasurements() {
    let english = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      contentIdentity: "verbatim:Title A",
      localeIdentifier: "en"
    )
    let changedContent = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      contentIdentity: "verbatim:Title B",
      localeIdentifier: "en"
    )
    let changedLocale = resolvedLayout(
      textSize: CGSize(width: 180, height: 18),
      containerSize: CGSize(width: 100, height: 20),
      contentIdentity: "verbatim:Title A",
      localeIdentifier: "ar"
    )

    #expect(english.animationIdentity != changedContent.animationIdentity)
    #expect(english.animationIdentity != changedLocale.animationIdentity)
  }

  @Test
  func layoutSanitizesIncomingSizes() {
    let layout = resolvedLayout(
      textSize: CGSize(width: -.infinity, height: .nan),
      containerSize: CGSize(width: .nan, height: -.infinity)
    )

    #expect(layout.textSize == .zero)
    #expect(layout.containerSize == .zero)
  }
}

struct MarqueeSizeHelperTests {
  @Test
  func sanitizesInvalidSizes() {
    #expect(CGSize(width: -.infinity, height: .nan).marqueeSanitized == .zero)
    #expect(CGSize(width: 44, height: 12).marqueeSanitized == CGSize(width: 44, height: 12))
  }

  @Test
  func detectsMeaningfulDifferences() {
    #expect(CGSize(width: 10, height: 10).isMeaningfullyDifferent(from: CGSize(width: 10.4, height: 10.4)))
    #expect(!CGSize(width: 10, height: 10).isMeaningfullyDifferent(from: CGSize(width: 10.4, height: 10.4), tolerance: 0.5))
    #expect(CGSize(width: 10, height: 10).isMeaningfullyDifferent(from: CGSize(width: 11, height: 10)))
    #expect(CGSize(width: 10, height: 10).isMeaningfullyDifferent(from: CGSize(width: 10, height: 11)))
    #expect(CGSize(width: CGFloat.nan, height: 10).isMeaningfullyDifferent(from: CGSize(width: 0, height: 10)))
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

struct MarqueePreferenceKeyTests {
  @Test
  func containerSizePreferenceDefaultsAndReduces() {
    #expect(MarqueeContainerSizePreferenceKey.defaultValue == .zero)

    var value = CGSize(width: 1, height: 1)
    MarqueeContainerSizePreferenceKey.reduce(value: &value) {
      CGSize(width: 20, height: 10)
    }
    #expect(value == CGSize(width: 20, height: 10))

    MarqueeContainerSizePreferenceKey.reduce(value: &value) {
      CGSize(width: -.infinity, height: .nan)
    }
    #expect(value == .zero)
  }

  @Test
  func textSizePreferenceDefaultsAndReduces() {
    #expect(MarqueeTextSizePreferenceKey.defaultValue == .zero)

    var value = CGSize(width: 1, height: 1)
    MarqueeTextSizePreferenceKey.reduce(value: &value) {
      CGSize(width: 30, height: 12)
    }
    #expect(value == CGSize(width: 30, height: 12))

    MarqueeTextSizePreferenceKey.reduce(value: &value) {
      CGSize(width: .nan, height: -.infinity)
    }
    #expect(value == .zero)
  }
}

struct MarqueeSizingLayoutTests {
  @Test
  func placementHonorsLayoutAlignment() {
    let bounds = CGRect(x: 10, y: 20, width: 80, height: 30)
    let leadingLayout = MarqueeSizingLayout(alignment: .leading)
    let trailingLayout = MarqueeSizingLayout(alignment: .trailing)

    #expect(leadingLayout.placementAnchor == .leading)
    #expect(leadingLayout.placementPoint(in: bounds) == CGPoint(x: 10, y: 35))
    #expect(trailingLayout.placementAnchor == .trailing)
    #expect(trailingLayout.placementPoint(in: bounds) == CGPoint(x: 90, y: 35))
  }

  @Test
  func unspecifiedWidthUsesIntrinsicSize() {
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
      ) == CGSize(width: 0, height: 12)
    )
  }
}

private func resolvedLayout(
  textSize: CGSize = CGSize(width: 120, height: 18),
  containerSize: CGSize = CGSize(width: 100, height: 20),
  configuration: MarqueeConfiguration = MarqueeConfiguration(),
  contentIdentity: String = "verbatim:Title",
  layoutDirection: LayoutDirection = .leftToRight,
  localeIdentifier: String = "en",
  reduceMotion: Bool = false
) -> MarqueeResolvedLayout {
  MarqueeResolvedLayout(
    textSize: textSize,
    containerSize: containerSize,
    configuration: configuration,
    contentIdentity: contentIdentity,
    layoutDirection: layoutDirection,
    localeIdentifier: localeIdentifier,
    reduceMotion: reduceMotion
  )
}
