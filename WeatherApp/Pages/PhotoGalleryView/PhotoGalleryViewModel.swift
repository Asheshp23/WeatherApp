//
//  File.swift
//  WeatherApp
//
//  Created by Ashesh Patel on 2023-12-28.
//

import Foundation
import UIKit

class PhotoGalleryViewModel: ObservableObject {
    
    @Published var displayImages: [UIImage] = []
    let dataManager = PhotoGalleryDataManager()
    
    @MainActor
    func loadImages() async {
        do {
            let fetchedImages = try await dataManager.fetchImages()
            self.displayImages.append(contentsOf: fetchedImages)
        } catch {
            // Handle the error, e.g., display an alert
            print("Error loading images: \(error)")
        }
    }
}
