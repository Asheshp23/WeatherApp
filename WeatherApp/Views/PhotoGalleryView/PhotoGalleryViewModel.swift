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
      // Handle the error, e.g., display an alert
      print("Error loading images: \(error)")
    }
  }
}
