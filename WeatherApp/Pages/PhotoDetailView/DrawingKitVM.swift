import Foundation
import PencilKit
import SwiftUI
import PhotosUI

class DrawingKitVM: ObservableObject {
  @Published var canvas = PKCanvasView()
  @Published var toolPicker = PKToolPicker()
  @Published var textBoxes: [CustomTextBox] = []
  @Published var addNewBox = false
  @Published var currentIndex: Int = 0
  @Published var rect: CGRect = .zero
  @Published var startEditing = false
  @Published var startAnnotating = false
  @Published var startFiltering = false
  @Published var showAlert = false
  @Published var message = ""

  func savingCanvas() {
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)

    let SWIFTUIVIEWS = ZStack {
      ForEach(self.textBoxes) { tb in
        Text(self.textBoxes[self.currentIndex].id == tb.id && self.addNewBox ? "" :  tb.text)
          .font(.system(size: 30, weight: self.textBoxes[self.currentIndex].isBold ? .bold : .regular ))
          .italic(self.textBoxes[self.currentIndex].isItalic)
          .underline(self.textBoxes[self.currentIndex].isUnderlined)
          .foregroundColor(tb.textColor)
          .offset(tb.offset)
      }
    }

    let controller = UIHostingController (rootView: SWIFTUIVIEWS).view!
    controller.frame = rect
    controller.backgroundColor = .clear
    canvas.backgroundColor = .clear
    controller.drawHierarchy (in: CGRect (origin: .zero, size: rect.size), afterScreenUpdates: true)
    let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    if let image = generatedImage {
      let fileManager = FileManager.default
      let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("newImageName.png")
      let data = image.pngData()
      fileManager.createFile(atPath: path, contents: data, attributes: nil)

      // Create custom album if it doesn't exist
      var customAlbum: PHAssetCollection!
      let fetchOptions = PHFetchOptions()
      fetchOptions.predicate = NSPredicate(format: "title = %@", "Custom Album Name")
      let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
      if let _: AnyObject = collection.firstObject {
        if collection.firstObject != nil {
          customAlbum = collection.firstObject
        }
      } else {
        try! PHPhotoLibrary.shared().performChangesAndWait {
          let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Custom Album Name")
          let placeHolder = createAlbumRequest.placeholderForCreatedAssetCollection
        }
      }

      // Save image to custom album
      PHPhotoLibrary.shared().performChanges ({
        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
        let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
        let albumChangeRequest = PHAssetCollectionChangeRequest(for: customAlbum)
        let enumeration: NSArray = [assetPlaceholder!]
        albumChangeRequest!.addAssets(enumeration)
      }, completionHandler: {success, error in
        Task { @MainActor in
          self.showAlert.toggle()
          self.message = "saved successfully"
        }
        do {
          try fileManager.removeItem(atPath: path)
        } catch {
          print("Error deleting file: \(error)")
        }
      })
    }
  }
}
