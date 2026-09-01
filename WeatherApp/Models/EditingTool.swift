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
    case .adjust: return "Adjust"
    case .filters: return "Filters"
    case .crop: return "Crop"
    case .stickers: return "Stickers"
    case .annotate: return "Draw"
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
