import SwiftUI

/// A SwiftUI view that displays text with a marquee scrolling animation when the text is wider than its container.
///
/// The MarqueeText view automatically detects when text overflows its container width and applies a smooth
/// horizontal scrolling animation. When text fits within the container, it displays as static text.
public struct MarqueeText: View {
  /// The text content to display
  private let text: LocalizedStringResource

  /// Duration of the scrolling animation in seconds
  private let duration: TimeInterval

  /// Delay before the animation starts in seconds
  private let delay: TimeInterval

  /// Spacing between the repeated text instances during animation
  private let spacing: CGFloat

  /// The measured size of the text content
  @State private var textSize: CGSize = .zero

  /// Controls whether the marquee animation should be active
  @State private var animate: Bool = false

  /// Creates a new MarqueeText view
  /// - Parameters:
  ///   - text: The text content to display
  ///   - duration: Duration of the scrolling animation in seconds (default: 8.0)
  ///   - delay: Delay before the animation starts in seconds (default: 1.0)
  ///   - spacing: Spacing between repeated text instances during animation (default: 50)
  public init(
    _ text: LocalizedStringResource,
    duration: TimeInterval = 8.0,
    delay: TimeInterval = 1.0,
    spacing: CGFloat = 50
  ) {
    self.text = text
    self.duration = duration
    self.delay = delay
    self.spacing = spacing
  }

  /// The main body of the MarqueeText view
  ///
  /// This view uses a GeometryReader to measure the available space and determines whether to show
  /// a marquee animation or static text based on whether the text overflows the container width.
  public var body: some View {
    GeometryReader { geo in
      let containerWidth = geo.size.width

      if textSize.width > containerWidth {
        // Marquee animation - only when text is wider than container
        ZStack {
          HStack(spacing: spacing) {
            // First text instance with size measurement
            Text(text)
              .fixedSize()
              .background(
                GeometryReader { textGeo in
                  Color.clear
                    .onAppear {
                      textSize = textGeo.size
                    }
                }
              )

            // Second text instance for seamless looping
            Text(text)
              .fixedSize()
          }
          // Animate the entire HStack from right to left
          .offset(x: animate ? -textSize.width - spacing : 0)
          .animation(
            animate
              ? Animation.easeInOut(duration: duration)
              .delay(delay)
              .repeatForever(autoreverses: false)
              : .default,
            value: animate
          )
        }
        .frame(width: containerWidth, height: textSize.height, alignment: .leading)
        .clipped() // Hide overflow to create the marquee effect
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityHint("Scrolling text")
        .accessibilityAddTraits([.updatesFrequently, .startsMediaSession])
        .onAppear {
          animate = true
        }
      } else {
        // Static text - when text fits in container
        Text(text)
          .fixedSize()
          .background(
            GeometryReader { textGeo in
              Color.clear
                .onAppear {
                  textSize = textGeo.size
                }
            }
          )
          .frame(height: textSize.height, alignment: .leading)
          .accessibilityElement(children: .combine)
          .accessibilityLabel(text)
          .onAppear {
            animate = false
          }
      }
    }
    // Ensure minimum height to prevent layout issues
    .frame(height: textSize.height > 0 ? textSize.height : 20)
  }
}
