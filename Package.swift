// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "MarqueeText",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .visionOS(.v1),
    .watchOS(.v9)
  ],
  products: [
    .library(
      name: "MarqueeText",
      targets: ["MarqueeText"]
    )
  ],
  targets: [
    .target(
      name: "MarqueeText"
    ),
    .testTarget(
      name: "MarqueeTextTests",
      dependencies: ["MarqueeText"]
    )
  ]
)
