import Foundation
import UIKit

struct PhotoGalleryDataManager {
  
  func fetchImages() async throws -> [UIImage] {
    let urlStrings = [
      "https://picsum.photos/300",
      "https://picsum.photos/300",
      "https://picsum.photos/300",
      "https://picsum.photos/300",
      "https://picsum.photos/300",
    ]
    return try await withThrowingTaskGroup(of: UIImage?.self) { group in
      var images: [UIImage] = []
      images.reserveCapacity(urlStrings.count)
      
      for urlString in urlStrings {
        group.addTask {
          try? await self.fetchImage(urlString: urlString)
        }
      }
      
      for try await image in group {
        if let image = image {
          images.append(image)
        }
      }
      
      return images
    }
  }
  
  private func fetchImage(urlString: String) async throws -> UIImage {
    guard let url = URL(string: urlString) else {
      throw URLError(.badURL)
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
      if let image = UIImage(data: data) {
        return image
      } else {
        throw URLError(.badURL)
      }
    } catch {
      throw error
    }
  }
}
