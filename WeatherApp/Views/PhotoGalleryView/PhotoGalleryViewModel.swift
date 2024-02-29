import Foundation
import UIKit

class PhotoGalleryViewModel: ObservableObject {
  
  @Published var images: [UIImage] = []
  let dataManager: PhotoGalleryDataManager
  
  init(dataManager: PhotoGalleryDataManager) {
    self.dataManager = dataManager
  }
  
  @MainActor
  func loadImages() async {
    do {
      let fetchedImages = try await dataManager.fetchImages()
      self.images.append(contentsOf: fetchedImages)
    } catch {
      // Handle the error, e.g., display an alert
      print("Error loading images: \(error)")
    }
  }
}
