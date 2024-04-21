import Foundation
import PencilKit
import SwiftUI
import PhotosUI

@Observable
class PhotoDetailVM {
  var photo: UIImage
  
  @MainActor var canvas = PKCanvasView()
  var toolPicker = PKToolPicker()
  var textBoxes: [CustomTextBox] = []
  var addNewBox = false
  @MainActor var currentIndex: Int = 0
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
  
  @MainActor
  func toggleBold() {
    textBoxes[currentIndex].isBold.toggle()
  }
  
  @MainActor
  func toggleItalic() {
    textBoxes[currentIndex].isItalic.toggle()
  }
  
  @MainActor
  func toggleUnderline() {
    textBoxes[currentIndex].isUnderlined.toggle()
  }
   
  @MainActor
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
  
  @MainActor
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
  
  @MainActor
  func handleAddButtonTap() {
    toolPicker.setVisible(true, forFirstResponder: canvas)
    canvas.becomeFirstResponder()
    withAnimation {
      addNewBox = false
    }
  }
  
  @MainActor
  func addNewTextBox() {
    withAnimation {
      textBoxes.append(CustomTextBox())
      currentIndex = textBoxes.count - 1
      addNewBox = true
      toolPicker.setVisible(false, forFirstResponder: canvas)
      canvas.resignFirstResponder()
    }
  }
  
  @MainActor
  func redoCanvasAction() {
    canvas.undoManager?.redo()
  }
  
  @MainActor
  func undoCanvasAction() {
    canvas.undoManager?.undo()
  }
  
  @MainActor
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
  
  @MainActor
  func toggleAnnotatingOrEditing() {
    if startAnnotating {
      toggleAnnotatingMode()
      undoAllCanvasAction()
    } else {
      toggleEditingMode()
    }
  }
  
  @MainActor func handleSaveAction() {
    if let image = savingCanvas(), startAnnotating {
      editedPhoto = image
      startAnnotating = false
      addNewBox = false
    } else {
      if let editedPhoto = editedPhoto {
        save(image: editedPhoto)
      } else {
        save(image: photo)
      }
    }
  }
  
  @MainActor func savingCanvas() -> UIImage? {
    // Generate image from canvas
    guard let generatedImage = generateImage() else {
      print("Failed to generate image.")
      return nil
    }
    
    return generatedImage
    
  }
  
  // Generate image from canvas
  @MainActor private func generateImage() -> UIImage? {
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
    
    guard let controller = UIHostingController (rootView: SWIFTUIVIEWS).view else { return nil }
    controller.frame = rect
    controller.backgroundColor = .clear
    canvas.backgroundColor = .clear
    canvas.drawingPolicy = .anyInput
    controller.drawHierarchy (in: CGRect (origin: .zero, size: rect.size), afterScreenUpdates: true)
    defer { UIGraphicsEndImageContext() }
    canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  func getIndex(tb: CustomTextBox) -> Int {
    return textBoxes.firstIndex { cb in
      return cb.id == tb.id
    } ?? 0
  }
  
  // Create or fetch custom album
  private func getOrCreateCustomAlbum() -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", "Custom Album Name")
    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    if let album = collection.firstObject {
      return album
    } else {
      do {
        try PHPhotoLibrary.shared().performChangesAndWait {
          PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Custom Album Name")
        }
        return collection.firstObject
      } catch {
        print("Error creating album: \(error)")
        return nil
      }
    }
  }
  
  func applyFilter(to image: UIImage) -> UIImage? {
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
  
  @MainActor
  func save(image: UIImage) {
    PHPhotoLibrary.requestAuthorization { status in
      guard status == .authorized else {
        print("Photo library access not authorized.")
        return
      }
      
      guard let filteredImage = self.applyFilter(to: image)  else {
        print("doesnt have the filterd image")
        return
      }
      Task { @MainActor in
        self.editedPhoto = filteredImage
      }
      guard let imageData = filteredImage.pngData() else {
        print("Failed to convert filtered image to PNG data.")
        DispatchQueue.main.async {
          self.showAlert.toggle()
          self.message = "Failed to save image"
        }
        return
      }
      
      let fileManager = FileManager.default
      let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("newImageName.png")
      
      do {
        try imageData.write(to: URL(fileURLWithPath: path))
      } catch {
        print("Failed to write image data to file: \(error)")
        Task {
          self.showAlert.toggle()
          self.message = "Failed to save image"
        }
        return
      }
      
      guard let customAlbum = self.getOrCreateCustomAlbum() else {
        print("Custom album not found.")
        return
      }
      
      do {
        // Save image to custom album
        try PHPhotoLibrary.shared().performChangesAndWait ({
          let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
          let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
          let albumChangeRequest = PHAssetCollectionChangeRequest(for: customAlbum)
          let enumeration: NSArray = [assetPlaceholder!]
          albumChangeRequest!.addAssets(enumeration)
          Task { [weak self] in
            self?.showAlert.toggle()
            self?.message = "Saved successfully"
            self?.startEditing = false
          }
          do {
            try fileManager.removeItem(atPath: path)
          } catch {
            print("Error deleting file: \(error)")
          }
        })
      } catch {
        print("Failed to write image data to file: \(error)")
       Task {
          self.showAlert.toggle()
          self.message = "Failed to save image"
        }
        return
      }
    }
  }
}
