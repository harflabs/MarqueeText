import MarqueeText
import SwiftUI

struct ContentView: View {
  var body: some View {
    ScrollView(.vertical) {
      VStack(alignment: .leading, spacing: 30) {
        // Header
        Section {
          VStack(spacing: 8) {
            Text("MarqueeText")
              .font(.largeTitle)
              .fontWeight(.bold)

            Text("Smooth horizontal scrolling text for SwiftUI")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }

        // Main showcase
        section(title: "Main Showcase") {
          MarqueeText("🚀 This is a spectacular marquee text that scrolls beautifully across the screen with smooth animations and perfect timing! ✨")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundStyle(.primary)
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
            )
        }

        // Music player example
        section(title: "Music Player Style") {
          HStack(alignment: .center, spacing: 12) {
            Image(systemName: "music.note")
              .font(.title2)
              .foregroundStyle(.pink)

            VStack(alignment: .leading, spacing: 4) {
              MarqueeText(
                "Now Playing: Bohemian Rhapsody - Queen (Live at Wembley Stadium 1985)",
                duration: 12.0,
                delay: 1.5
              )
              .font(.headline)
              .fontWeight(.semibold)

              MarqueeText(
                "Queen • A Night at the Opera • 1975 • Rock • 5:55",
                duration: 15.0,
                delay: 2.0
              )
              .font(.caption)
              .foregroundStyle(.secondary)
            }
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(.regularMaterial)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(.pink.opacity(0.3), lineWidth: 1)
              )
          )
        }

        // News ticker example
        section(title: "News Ticker Style") {
          HStack(alignment: .center, spacing: 8) {
            Text("BREAKING")
              .font(.caption)
              .fontWeight(.bold)
              .foregroundStyle(.white)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(.red)
              .clipShape(Capsule())

            MarqueeText(
              "🚨 Major breakthrough in AI technology announced today • Scientists discover new method for quantum computing • Stock markets reach all-time high • Weather forecast: Sunny skies expected for the weekend",
              duration: 20.0,
              delay: 1.0
            )
            .font(.subheadline)
            .foregroundStyle(.primary)
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(.ultraThinMaterial)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(.gray.opacity(0.2), lineWidth: 1)
              )
          )
        }

        // Short text example
        section(title: "Short Text (Static)") {
          MarqueeText("This text is short")
            .font(.title3)
            .fontWeight(.medium)
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(.green.opacity(0.1))
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(.green.opacity(0.3), lineWidth: 1)
                )
            )
        }

        // Custom timing example
        section(title: "Custom Timing") {
          MarqueeText(
            "⚡ Super fast scrolling text with custom timing parameters for maximum impact! ⚡",
            duration: 4.0,
            delay: 0.5,
            spacing: 30
          )
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(.orange)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(.orange.opacity(0.1))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(.orange.opacity(0.3), lineWidth: 1)
              )
          )
        }

        // Status bar example
        section(title: "Status Bar Style") {
          HStack(alignment: .center, spacing: 8) {
            Circle()
              .fill(.green)
              .frame(width: 8, height: 8)

            MarqueeText(
              "🟢 System Online • All services operational • Last backup: 2 minutes ago • CPU: 23% • Memory: 4.2GB • Disk: 78% free",
              duration: 25.0,
              delay: 1.0
            )
            .font(.caption)
            .foregroundStyle(.primary)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(
            RoundedRectangle(cornerRadius: 6)
              .fill(.green.opacity(0.1))
              .overlay(
                RoundedRectangle(cornerRadius: 6)
                  .stroke(.green.opacity(0.3), lineWidth: 1)
              )
          )
        }

        // Social media feed example
        section(title: "Social Media Feed") {
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
              Circle()
                .fill(.blue)
                .frame(width: 32, height: 32)
                .overlay(
                  Text("U")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                )

              VStack(alignment: .leading, spacing: 2) {
                MarqueeText(
                  "@username • 2h • Following",
                  duration: 8.0,
                  delay: 1.0
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                MarqueeText(
                  "Just discovered this amazing SwiftUI marquee text component! The animations are so smooth and the API is incredibly clean. Perfect for music players, news tickers, and status displays. #SwiftUI #iOS #OpenSource",
                  duration: 15.0,
                  delay: 1.5
                )
                .font(.subheadline)
                .foregroundStyle(.primary)
              }
            }
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(.ultraThinMaterial)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(.blue.opacity(0.2), lineWidth: 1)
              )
          )
        }

        // Notification banner example
        section(title: "Notification Banner") {
          HStack(alignment: .center, spacing: 12) {
            Image(systemName: "bell.fill")
              .font(.title3)
              .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 4) {
              MarqueeText(
                "New message from Sarah Johnson",
                duration: 6.0,
                delay: 0.5
              )
              .font(.headline)
              .fontWeight(.semibold)

              MarqueeText(
                "Hey! I just saw your latest project on GitHub. The marquee text component looks incredible! Can we schedule a call to discuss potential collaboration?",
                duration: 12.0,
                delay: 1.0
              )
              .font(.subheadline)
              .foregroundStyle(.secondary)
            }
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(.yellow.opacity(0.1))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(.yellow.opacity(0.3), lineWidth: 1)
              )
          )
        }

        // Loading screen example
        section(title: "Loading Screen") {
          VStack(spacing: 16) {
            ProgressView()

            MarqueeText(
              "Loading your personalized experience • Fetching latest updates • Preparing content • Almost ready...",
              duration: 18.0,
              delay: 0.5
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(.purple.opacity(0.1))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(.purple.opacity(0.3), lineWidth: 1)
              )
          )
        }

        // Terminal/Console example
        section(title: "Terminal/Console") {
          VStack(alignment: .leading, spacing: 4) {
            HStack {
              Text("$")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.green)

              MarqueeText(
                "swift build && swift test && xcodebuild -scheme MarqueeText -destination 'platform=iOS Simulator,name=iPhone 15' build",
                duration: 20.0,
                delay: 1.0
              )
              .font(.system(.caption, design: .monospaced))
              .foregroundStyle(.white)
            }

            HStack {
              Text("$")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.green)

              MarqueeText(
                "git add . && git commit -m 'Add comprehensive marquee text component with smooth animations' && git push origin main",
                duration: 25.0,
                delay: 1.5
              )
              .font(.system(.caption, design: .monospaced))
              .foregroundStyle(.white)
            }
          }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(.black.opacity(0.8))
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(.gray.opacity(0.3), lineWidth: 1)
              )
          )
        }

        // Footer

        VStack(spacing: 8) {
          Text(AttributedString("Built with ❤️ by ") + AttributedString("Harf Labs", attributes: AttributeContainer([.link: URL(string: "https://harflabs.com")!])))
            .font(.caption)
            .foregroundStyle(.secondary)

          Text("Smooth • Responsive • Customizable")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
      }
      .padding(20)
    }
  }

  private func section(title: LocalizedStringResource, content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.headline)
        .foregroundColor(.secondary)
      content()
    }
  }
}
