import SwiftUI

enum MarqueeContent: Equatable {
  case localized(LocalizedStringResource)
  case verbatim(String)

  var text: Text {
    switch self {
    case .localized(let text):
      Text(text)
    case .verbatim(let text):
      Text(verbatim: text)
    }
  }
}

// The two widths the marquee needs in view state in order to decide whether to scroll.
//
// Both are already known to ``MarqueeSizingLayout``, which hands them back by proposing them as the size
// of a weightless probe subview: width carries the natural text width, height carries the container width.
// Only the widths matter — the view's height comes from the layout, not from view state.
