import Foundation

enum EditingTool: String, CaseIterable, Identifiable {
  case adjust
  case filters
  case crop
  case stickers
  case annotate

  var id: String { rawValue }

  var title: String {
    switch self {
    case .adjust: return String(localized: "tool_adjust", defaultValue: "Adjust")
    case .filters: return String(localized: "tool_filters", defaultValue: "Filters")
    case .crop: return String(localized: "tool_crop", defaultValue: "Crop")
    case .stickers: return String(localized: "tool_stickers", defaultValue: "Stickers")
    case .annotate: return String(localized: "tool_draw", defaultValue: "Draw")
    }
  }

  var systemImage: String {
    switch self {
    case .adjust: return "slider.horizontal.3"
    case .filters: return "camera.filters"
    case .crop: return "crop"
    case .stickers: return "face.smiling"
    case .annotate: return "pencil.tip.crop.circle"
    }
  }
}
