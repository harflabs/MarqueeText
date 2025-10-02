# MarqueeText

A lightweight SwiftUI component that automatically creates marquee scrolling animations when text overflows its container. Perfect for music players, news tickers, status displays, and more.

## Features

- 🎯 **Automatic Detection** - Only scrolls when text overflows
- ⚡️ **Smooth Animations** - Customizable timing and easing
- 🎨 **SwiftUI Native** - Built with pure SwiftUI
- ♿️ **Accessible** - Full accessibility support
- ↔️ **Localizable** - Supports `LocalizedStringResource` and right to left layouts.
- 📱 **Multi-Platform** - iOS, macOS, tvOS, and visionOS

## Requirements

- iOS 16.0+
- macOS 13.0+
- tvOS 16.0+
- visionOS 1.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/harflabs/MarqueeText.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to your target

## Usage

### Basic Usage

```swift
import MarqueeText

MarqueeText("This is a long text that will scroll smoothly across the screen!")
```

### Custom Timing

```swift
MarqueeText(
    "Custom timing marquee text",
    duration: 4.0,    // Animation duration
    delay: 0.5,       // Delay before starting
    spacing: 30       // Space between repeated text
)
```

### With Styling

```swift
MarqueeText("Styled marquee text")
    .font(.headline)
    .fontWeight(.semibold)
    .foregroundStyle(.primary)
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(.ultraThinMaterial)
    )
```

## Examples

### Main Showcase
![Main Showcase](Assets/demo_1.gif)

### Music Player Style
![Music Player Style](Assets/demo_2.gif)

### News Ticker Style
![News Ticker Style](Assets/demo_3.gif)

### Short Text (Static)
![Short Text (Static)](Assets/demo_4.gif)

### Custom Timing
![Custom Timing](Assets/demo_5.gif)

### Status Bar Style
![Status Bar Style](Assets/demo_6.gif)

### Social Media Feed
![Social Media Feed](Assets/demo_7.gif)

### Notification Banner
![Notification Banner](Assets/demo_8.gif)

### Loading Screen
![Loading Screen](Assets/demo_9.gif)

### Terminal/Console
![Terminal/Console](Assets/demo_10.gif)


## Apps Using MarqueeText

- [Casti - Your Personalized Podcasts, Powered by AI](https://apps.apple.com/app/id6746376736)
- [Tilfaz - Live & On-Demand TV](https://apps.apple.com/app/id1668359578)

*Add your app here! Submit a pull request to include your app.*

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## About Harf Labs

This library is built by [Harf Labs](https://harflabs.com), a software development company that creates solutions for real problems.

If you like this project and need help with your own software projects, we'd love to hear from you! [Get in touch](https://harflabs.com/en/contact) and let's build something amazing together.
