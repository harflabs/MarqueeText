@testable import MarqueeText
import SwiftUI
import Testing

struct MarqueeLayoutTests {
  @Test
  func unmeasuredTextDoesNotScroll() {
    let layout = resolvedLayout(
      textWidth: 0,
      containerWidth: 100
    )

    #expect(!layout.hasMeasuredText)
    #expect(layout.hasMeasuredContainer)
    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
    #expect(layout.offset == 0)
  }

  @Test
  func unmeasuredContainerDoesNotScroll() {
    let layout = resolvedLayout(
      textWidth: 120,
      containerWidth: 0
    )

    #expect(layout.hasMeasuredText)
    #expect(!layout.hasMeasuredContainer)
    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
  }

  @Test
  func textWithinOverflowToleranceDoesNotScroll() {
    let layout = resolvedLayout(
      textWidth: 100.4,
      containerWidth: 100
    )

    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
  }

  @Test
  func textJustBeyondOverflowToleranceScrolls() {
    let layout = resolvedLayout(
      textWidth: 100.6,
      containerWidth: 100
    )

    #expect(layout.overflows)
    #expect(layout.shouldScroll)
  }

  @Test
  func unmeasuredTextNeverScrollsEvenWhenTheContainerIsKnown() {
    // Until the probe reports back, the text width is zero. Treating that as "narrower than the
    // container" would be wrong in the other direction, so it must simply not scroll yet.
    let layout = resolvedLayout(
      textWidth: 0,
      containerWidth: 100
    )

    #expect(!layout.hasMeasuredText)
    #expect(!layout.overflows)
    #expect(!layout.shouldScroll)
  }

  @Test
  func overflowingTextScrollsWhenMotionIsAllowed() {
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      configuration: MarqueeConfiguration(duration: 3, delay: 0.5, spacing: 24)
    )

    #expect(layout.overflows)
    #expect(layout.shouldScroll)
    #expect(layout.scrollDistance == 204)
    #expect(layout.offset == -204)
  }

  @Test
  func timelineProgressWaitsDuringDelayAndMovesLinearly() {
    let startDate = Date(timeIntervalSince1970: 100)
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      configuration: MarqueeConfiguration(duration: 4, delay: 1, spacing: 20)
    )

    #expect(layout.shouldScroll)
    #expect(layout.progress(at: startDate, startDate: startDate) == 0)
    #expect(layout.progress(at: startDate.addingTimeInterval(0.5), startDate: startDate) == 0)
    #expect(layout.progress(at: startDate.addingTimeInterval(3), startDate: startDate) == 0.5)
    #expect(layout.offset(at: startDate, startDate: startDate) == 0)
    #expect(layout.offset(at: startDate.addingTimeInterval(3), startDate: startDate) == -100)
    #expect(layout.progress(at: startDate.addingTimeInterval(5.5), startDate: startDate) == 0)
  }

  @Test
  func scrollLoopIsSeamlessBecauseOnePassEqualsTheCopySpacing() {
    let startDate = Date(timeIntervalSince1970: 0)
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      configuration: MarqueeConfiguration(duration: 4, delay: 0, spacing: 20)
    )

    // A full pass must travel exactly one text width plus the spacing, which puts the second copy
    // precisely where the first started. Anything else makes the loop visibly jump.
    #expect(layout.scrollDistance == 200)
    #expect(layout.offset(progress: 1) == -200)
    #expect(layout.offset(at: startDate.addingTimeInterval(4), startDate: startDate) == 0)
  }

  @Test
  func timelineProgressDoesNotMoveBeforeStartDate() {
    let startDate = Date(timeIntervalSince1970: 100)
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      configuration: MarqueeConfiguration(duration: 4, delay: 1, spacing: 20)
    )

    #expect(layout.progress(at: startDate.addingTimeInterval(-10), startDate: startDate) == 0)
    #expect(layout.offset(at: startDate.addingTimeInterval(-10), startDate: startDate) == 0)
  }

  @Test
  func timelineProgressHandlesOverflowingCycleDuration() {
    let startDate = Date(timeIntervalSince1970: 100)
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
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
        textWidth: 300,
        containerWidth: width,
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
      textWidth: 300,
      containerWidth: 100,
      configuration: MarqueeConfiguration(duration: 4, delay: 0, spacing: 20)
    )

    #expect(layout.offset(at: startDate.addingTimeInterval(2), startDate: startDate) == -160)
    #expect(layout.offset(at: startDate.addingTimeInterval(6), startDate: startDate) == -160)
    #expect(layout.offset(at: startDate.addingTimeInterval(10), startDate: startDate) == -160)
  }

  @Test
  func reducedMotionStopsScrollingEvenWhenTextOverflows() {
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      reduceMotion: true
    )

    #expect(layout.overflows)
    #expect(!layout.shouldScroll)
    #expect(layout.offset == 0)
    #expect(layout.progress(at: Date(), startDate: Date(timeIntervalSince1970: 0)) == 0)
  }

  @Test
  func rightToLeftLayoutMirrorsAlignmentAndOffset() {
    let layout = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
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
      textWidth: 180,
      containerWidth: 100,
      configuration: MarqueeConfiguration(duration: 3, delay: 0.5, spacing: 24),
      content: .verbatim("title"),
      layoutDirection: .rightToLeft
    )

    #expect(
      layout.animationIdentity == MarqueeAnimationIdentity(
        containerWidth: 100,
        content: .verbatim("title"),
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
  }

  @Test
  func animationIdentityChangesForContentAndLocaleChangesWithTheSameMeasurements() {
    let english = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      content: .verbatim("Title A"),
      localeIdentifier: "en"
    )
    let changedContent = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      content: .verbatim("Title B"),
      localeIdentifier: "en"
    )
    let changedLocale = resolvedLayout(
      textWidth: 180,
      containerWidth: 100,
      content: .verbatim("Title A"),
      localeIdentifier: "ar"
    )

    #expect(english.animationIdentity != changedContent.animationIdentity)
    #expect(english.animationIdentity != changedLocale.animationIdentity)
  }

  @Test
  func layoutSanitizesIncomingMeasurements() {
    let layout = resolvedLayout(
      textWidth: -.infinity,
      containerWidth: .nan
    )

    #expect(layout.measurement == .zero)
    #expect(!layout.shouldScroll)
  }
}
