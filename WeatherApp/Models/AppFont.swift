import SwiftUI

enum AppFont: String, CaseIterable, Identifiable {
  case system = "System"
  case helveticaNeue = "Helvetica Neue"
  case georgia = "Georgia"
  case courierNew = "Courier New"
  case markerFelt = "Marker Felt"
  case chalkboard = "Chalkboard SE"
  case snellRoundhand = "Snell Roundhand"
  case americanTypewriter = "American Typewriter"

  var id: String { rawValue }

  func font(size: CGFloat) -> Font {
    switch self {
    case .system:
      return .system(size: size)
    default:
      return .custom(rawValue, size: size)
    }
  }
}
