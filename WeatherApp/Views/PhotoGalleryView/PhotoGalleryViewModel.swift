import Foundation
import UIKit

@Observable
class PhotoGalleryViewModel {
  var images: [UIImage]?
  var loadFailed = false
  private let dataManager: PhotoGalleryDataManager = PhotoGalleryDataManager()

  @MainActor
  func loadImages() async {
    loadFailed = false
    do {
      let fetchedImages = try await dataManager.fetchImages()
      if fetchedImages.isEmpty {
        self.images = nil
        self.loadFailed = true
      } else {
        self.images = fetchedImages
      }
    } catch {
      print("Error loading images: \(error)")
      self.images = nil
      self.loadFailed = true
    }
  }
}
