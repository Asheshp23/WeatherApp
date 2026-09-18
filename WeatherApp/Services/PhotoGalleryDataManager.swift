import Foundation
import UIKit

struct PhotoGalleryDataManager {
  
  func fetchImages() async throws -> [UIImage] {
    // picsum.photos is far more reliable than loremflickr, which frequently times out or 503s.
    // Each seed returns a stable, distinct image.
    let urlStrings = (1...9).map { "https://picsum.photos/seed/weather\($0)/400/400" }
    return try await withThrowingTaskGroup(of: UIImage?.self) { group in
      var images: [UIImage] = []
      images.reserveCapacity(urlStrings.count)
      
      for urlString in urlStrings {
        group.addTask {
          do {
            return try await self.fetchImage(urlString: urlString)
          } catch {
            print("Failed to load photo at \(urlString): \(error.localizedDescription)")
            return nil
          }
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
    
    var request = URLRequest(url: url)
    request.timeoutInterval = 10
    
    let (data, _) = try await URLSession.shared.data(for: request)
    guard let image = UIImage(data: data) else {
      throw URLError(.cannotDecodeContentData)
    }
    return image
  }
}
