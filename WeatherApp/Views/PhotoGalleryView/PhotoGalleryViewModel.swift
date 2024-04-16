import Foundation
import UIKit

@Observable
class PhotoGalleryViewModel {
  var images: [UIImage]?
  private let dataManager: PhotoGalleryDataManager = PhotoGalleryDataManager()
  
  @MainActor
  func loadImages() async {
    do {
      self.images = try await dataManager.fetchImages()
    } catch {
      print("Error loading images: \(error)")
    }
  }
}
