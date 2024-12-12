import Foundation
import PencilKit
import SwiftUI
import PhotosUI

@Observable @MainActor
class PhotoDetailVM {
  var photo: UIImage
  
  var canvas = PKCanvasView()
  var toolPicker = PKToolPicker()
  var textBoxes: [CustomTextBox] = []
  var addNewBox = false
  var currentIndex: Int = 0
  var rect: CGRect = .zero
  var startEditing = false
  var startAnnotating = false
  var showAlert = false
  var message = ""
  var editedPhoto: UIImage?
  var brightness: Double = 0
  var contrast: Double = 1
  var saturation: Double = 1
  var isSaturationChanged: Bool = false
  var isBrightnessChanged: Bool = false
  var isContrastChanged: Bool = false
  var customAlbum: PHAssetCollection?
  var previousSaturation: Double = 1.0
  
  init(photo: UIImage) {
    self.photo = photo
  }
  
  func toggleBold() {
    textBoxes[currentIndex].isBold.toggle()
  }
  
  func toggleItalic() {
    textBoxes[currentIndex].isItalic.toggle()
  }
  
  func toggleUnderline() {
    textBoxes[currentIndex].isUnderlined.toggle()
  }
  
  func handleLongPress(textBox: CustomTextBox) {
    toolPicker.setVisible(false, forFirstResponder: canvas)
    canvas.resignFirstResponder()
    currentIndex = getIndex(tb: textBox)
    textBoxes[currentIndex].isEditing = true
    withAnimation {
      addNewBox = true
    }
  }
  
  func handleDragGesture(value: DragGesture.Value, textBox: CustomTextBox) {
    let current = value.translation
    let newOffset = CGSize(width: textBox.lastOffset.width + current.width , height: textBox.lastOffset.height + current.height)
    
    textBoxes[getIndex(tb: textBox)].offset = newOffset
  }
  
  func handleDragGestureEnd(value: DragGesture.Value, tb: CustomTextBox) {
    textBoxes[getIndex(tb: tb)].lastOffset = value.translation
  }
  
  func handleCancelButtonTap() {
    withAnimation {
      if !textBoxes.isEmpty {
        if textBoxes[currentIndex].isAdded && !textBoxes[currentIndex].isEditing {
          textBoxes.removeLast()
          currentIndex = textBoxes.count - 1
        }
        addNewBox = false
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
      }
    }
  }
  
  func handleAddButtonTap() {
    toolPicker.setVisible(true, forFirstResponder: canvas)
    canvas.becomeFirstResponder()
    withAnimation {
      addNewBox = false
    }
  }
  
  func addNewTextBox() {
    withAnimation {
      textBoxes.append(CustomTextBox())
      currentIndex = textBoxes.count - 1
      addNewBox = true
      toolPicker.setVisible(false, forFirstResponder: canvas)
      canvas.resignFirstResponder()
    }
  }
  
  func redoCanvasAction() {
    canvas.undoManager?.redo()
  }
  
  func undoCanvasAction() {
    canvas.undoManager?.undo()
  }
  
  func undoAllCanvasAction() {
    guard let undoManager = canvas.undoManager else {
      return
    }
    
    // Perform undo until the undo manager has no more actions
    while undoManager.canUndo {
      undoManager.undo()
    }
  }
  
  func toggleAnnotatingMode() {
    startAnnotating.toggle()
  }
  
  func toggleEditingMode() {
    startEditing.toggle()
    self.brightness = 0
    self.contrast = 1
    self.contrast = 1
  }
  
  func toggleAnnotatingOrEditing() {
    if startAnnotating {
      toggleAnnotatingMode()
      undoAllCanvasAction()
    } else {
      toggleEditingMode()
    }
  }
  
  func handleSaveAction() {
    if let image = savingCanvas(), startAnnotating {
      editedPhoto = image
      startAnnotating = false
      addNewBox = false
    } else {
      if let editedPhoto = editedPhoto {
        do {
        try save(image: editedPhoto)
      } catch {
        print(error.localizedDescription)
      }
      } else {
        do {
          try save(image: photo)
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }
  
  func savingCanvas() -> UIImage? {
    // Generate image from canvas
    guard let generatedImage = generateImage() else {
      print("Failed to generate image.")
      return nil
    }
    
    return generatedImage
    
  }
  
  private func generateImage() -> UIImage? {
    // Begin image context
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    defer { UIGraphicsEndImageContext() }
    
    // Draw the canvas hierarchy
    canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
    
    // Create SwiftUI views for text rendering
    let swiftUIView = ZStack {
      ForEach(self.textBoxes) { tb in
        Text(self.textBoxes[self.currentIndex].id == tb.id && self.addNewBox ? "" : tb.text)
          .font(.system(size: 30, weight: tb.isBold ? .bold : .regular))
          .italic(tb.isItalic)
          .underline(tb.isUnderlined)
          .foregroundColor(tb.textColor)
          .offset(tb.offset)
      }
    }
    
    // Convert SwiftUI view to UIKit for rendering
    let hostingController = UIHostingController(rootView: swiftUIView)
    guard let hostingView = hostingController.view else { return nil }
    hostingView.frame = CGRect(origin: .zero, size: rect.size)
    hostingView.backgroundColor = .clear
    
    // Render the SwiftUI view hierarchy
    hostingView.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    // Get the generated image
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  func getIndex(tb: CustomTextBox) -> Int {
    return textBoxes.firstIndex { cb in
      return cb.id == tb.id
    } ?? 0
  }
  
  private func getOrCreateCustomAlbum(named albumName: String) -> PHAssetCollection? {
    // Check if the album already exists
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    
    if let existingAlbum = collections.firstObject {
      return existingAlbum
    }
    
    // Album doesn't exist, attempt to create it
    var createdAlbum: PHAssetCollection?
    do {
      try PHPhotoLibrary.shared().performChangesAndWait {
        let creationRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        let placeholder = creationRequest.placeholderForCreatedAssetCollection
        let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
        createdAlbum = result.firstObject
      }
    } catch {
      print("Error creating album: \(error)")
      return nil
    }
    
    return createdAlbum
  }

  func applyFilter(to image: UIImage) throws -> UIImage? {
    guard let inputImage = CIImage(image: image) else {
      print("Failed to create CIImage from input image")
      return nil
    }
    
    guard let filter = CIFilter(name: "CIColorControls") else {
      print("Failed to create CIFilter")
      return nil
    }
    
    filter.setValue(inputImage, forKey: kCIInputImageKey)
    filter.setValue(self.brightness, forKey: kCIInputBrightnessKey)
    filter.setValue(self.contrast, forKey: kCIInputContrastKey)
    filter.setValue(self.saturation, forKey: kCIInputSaturationKey)
    
    guard let outputImage = filter.outputImage else {
      print("Failed to get output image from filter")
      return nil
    }
    
    let context = CIContext()
    guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
      print("Failed to create CGImage from output image")
      return nil
    }
    
    return UIImage(cgImage: cgImage)
  }
  
  func save(image: UIImage) throws {
    guard let filteredImage = try self.applyFilter(to: image) else {
      print("Filtered image creation failed.")
      return
    }
    
    guard let imageData = filteredImage.pngData() else {
      DispatchQueue.main.async {
        self.showAlert.toggle()
        self.message = "Failed to convert image to PNG."
      }
      return
    }
    
    let fileManager = FileManager.default
    let tempPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("newImageName.png")
    
    do {
      try imageData.write(to: URL(fileURLWithPath: tempPath))
    } catch {
      DispatchQueue.main.async {
        self.showAlert.toggle()
        self.message = "Failed to save image file."
      }
      print("File write error: \(error)")
      return
    }
    
    guard let customAlbum = self.getOrCreateCustomAlbum(named: "WA") else {
      print("Custom album not found.")
      return
    }
    
    try PHPhotoLibrary.shared().performChangesAndWait({
      let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
      guard let assetPlaceholder = assetRequest.placeholderForCreatedAsset,
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: customAlbum) else {
        print("Failed to create asset or album change request.")
        return
      }
      albumChangeRequest.addAssets([assetPlaceholder] as NSArray)
      DispatchQueue.main.async {
        self.showAlert.toggle()
        self.message = "Image saved successfully."
        self.startEditing = false
      }
      do {
        try fileManager.removeItem(atPath: tempPath)
      } catch {
        print("Failed to delete temp file: \(error)")
      }
    })
  }
}
