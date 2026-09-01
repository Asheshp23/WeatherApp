import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum FilterPreset: String, CaseIterable, Identifiable {
  case none = "Original"
  case mono = "Mono"
  case sepia = "Sepia"
  case vivid = "Vivid"
  case cool = "Cool"
  case warm = "Warm"

  var id: String { rawValue }

  private static let context = CIContext()

  func apply(to image: UIImage) -> UIImage {
    guard self != .none, let ciImage = CIImage(image: image) else { return image }
    let output = filtered(ciImage)
    guard let cgImage = Self.context.createCGImage(output, from: output.extent) else { return image }
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
  }

  private func filtered(_ image: CIImage) -> CIImage {
    switch self {
    case .none:
      return image
    case .mono:
      return image.applyingFilter("CIPhotoEffectMono")
    case .sepia:
      return image.applyingFilter("CISepiaTone", parameters: [kCIInputIntensityKey: 0.8])
    case .vivid:
      return image.applyingFilter("CIVibrance", parameters: [kCIInputAmountKey: 1.0])
    case .cool:
      return image.applyingFilter("CITemperatureAndTint", parameters: [
        "inputNeutral": CIVector(x: 5500, y: 0),
        "inputTargetNeutral": CIVector(x: 7500, y: 0)
      ])
    case .warm:
      return image.applyingFilter("CITemperatureAndTint", parameters: [
        "inputNeutral": CIVector(x: 5500, y: 0),
        "inputTargetNeutral": CIVector(x: 4000, y: 0)
      ])
    }
  }
}
