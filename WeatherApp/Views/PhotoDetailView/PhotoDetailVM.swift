import Foundation
import PencilKit
import SwiftUI
import PhotosUI
import AVFoundation

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
  var activeTool: EditingTool = .adjust
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

  // Filters
  var selectedFilter: FilterPreset = .none
  @ObservationIgnored private var cachedFilterThumbnailSource: UIImage?

  // Crop
  var cropRect: CGRect = .zero
  var cropContainerSize: CGSize = .zero

  // Stickers
  var stickers: [StickerItem] = []
  var showStickerPicker = false

  // Share
  var showShareSheet = false
  var shareImage: UIImage?

  var startAnnotating: Bool { activeTool == .annotate }

  var filterThumbnailSource: UIImage {
    if let cached = cachedFilterThumbnailSource { return cached }
    let generated = Self.downscaled(photo, maxDimension: 120)
    cachedFilterThumbnailSource = generated
    return generated
  }

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

  func deleteCurrentTextBox() {
    guard !textBoxes.isEmpty else { return }
    withAnimation {
      textBoxes.remove(at: currentIndex)
      currentIndex = max(0, textBoxes.count - 1)
      addNewBox = false
      toolPicker.setVisible(true, forFirstResponder: canvas)
      canvas.becomeFirstResponder()
    }
  }

  func duplicateCurrentTextBox() {
    guard !textBoxes.isEmpty else { return }
    var copy = textBoxes[currentIndex]
    copy.id = UUID().uuidString
    copy.offset = CGSize(width: copy.offset.width + 24, height: copy.offset.height + 24)
    copy.lastOffset = copy.offset
    withAnimation {
      textBoxes.append(copy)
      currentIndex = textBoxes.count - 1
    }
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
    let idx = getIndex(tb: tb)
    textBoxes[idx].lastOffset = textBoxes[idx].offset
  }

  func handleTextMagnification(value: CGFloat, textBox: CustomTextBox) {
    let idx = getIndex(tb: textBox)
    textBoxes[idx].scale = textBoxes[idx].lastScale * value
  }

  func handleTextMagnificationEnd(textBox: CustomTextBox) {
    let idx = getIndex(tb: textBox)
    textBoxes[idx].lastScale = textBoxes[idx].scale
  }

  func handleTextRotation(value: Angle, textBox: CustomTextBox) {
    let idx = getIndex(tb: textBox)
    textBoxes[idx].rotation = textBoxes[idx].lastRotation + value.degrees
  }

  func handleTextRotationEnd(textBox: CustomTextBox) {
    let idx = getIndex(tb: textBox)
    textBoxes[idx].lastRotation = textBoxes[idx].rotation
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

  // Stickers
  func addSticker(_ emoji: String) {
    withAnimation(.spring()) {
      stickers.append(StickerItem(emoji: emoji))
    }
    showStickerPicker = false
  }

  func deleteSticker(_ sticker: StickerItem) {
    withAnimation {
      stickers.removeAll { $0.id == sticker.id }
    }
  }

  private func stickerIndex(_ sticker: StickerItem) -> Int? {
    stickers.firstIndex { $0.id == sticker.id }
  }

  func handleStickerDrag(value: DragGesture.Value, sticker: StickerItem) {
    guard let idx = stickerIndex(sticker) else { return }
    let current = value.translation
    stickers[idx].offset = CGSize(width: stickers[idx].lastOffset.width + current.width,
                                   height: stickers[idx].lastOffset.height + current.height)
  }

  func handleStickerDragEnd(sticker: StickerItem) {
    guard let idx = stickerIndex(sticker) else { return }
    stickers[idx].lastOffset = stickers[idx].offset
  }

  func handleStickerMagnification(value: CGFloat, sticker: StickerItem) {
    guard let idx = stickerIndex(sticker) else { return }
    stickers[idx].scale = stickers[idx].lastScale * value
  }

  func handleStickerMagnificationEnd(sticker: StickerItem) {
    guard let idx = stickerIndex(sticker) else { return }
    stickers[idx].lastScale = stickers[idx].scale
  }

  func handleStickerRotation(value: Angle, sticker: StickerItem) {
    guard let idx = stickerIndex(sticker) else { return }
    stickers[idx].rotation = stickers[idx].lastRotation + value
  }

  func handleStickerRotationEnd(sticker: StickerItem) {
    guard let idx = stickerIndex(sticker) else { return }
    stickers[idx].lastRotation = stickers[idx].rotation
  }

  // Filters
  func applyFilterPreset(_ filter: FilterPreset) {
    selectedFilter = filter
    guard filter != .none else { return }
    let base = editedPhoto ?? photo
    editedPhoto = filter.apply(to: base)
  }

  // Crop & rotate
  func rotateEditedPhoto(by degrees: CGFloat) {
    let base = editedPhoto ?? photo
    editedPhoto = Self.rotated(base, by: degrees)
    cropRect = .zero
  }

  func flipEditedPhotoHorizontally() {
    let base = editedPhoto ?? photo
    editedPhoto = Self.flippedHorizontally(base)
    cropRect = .zero
  }

  func applyCrop() {
    let base = editedPhoto ?? photo
    guard cropContainerSize.width > 0, cropContainerSize.height > 0 else { return }
    let imageFrame = AVMakeRect(aspectRatio: base.size, insideRect: CGRect(origin: .zero, size: cropContainerSize))
    guard imageFrame.width > 0, imageFrame.height > 0 else { return }

    let scaleX = base.size.width / imageFrame.width
    let scaleY = base.size.height / imageFrame.height

    let cropZone = CGRect(
      x: (cropRect.minX - imageFrame.minX) * scaleX,
      y: (cropRect.minY - imageFrame.minY) * scaleY,
      width: cropRect.width * scaleX,
      height: cropRect.height * scaleY
    ).intersection(CGRect(origin: .zero, size: base.size))

    guard cropZone.width > 0, cropZone.height > 0, let cgImage = base.cgImage?.cropping(to: cropZone) else { return }
    editedPhoto = UIImage(cgImage: cgImage, scale: base.scale, orientation: base.imageOrientation)
    cropRect = .zero
    selectTool(.adjust)
  }

  private static func rotated(_ image: UIImage, by degrees: CGFloat) -> UIImage {
    let radians = degrees * .pi / 180
    let newSize = CGSize(width: image.size.height, height: image.size.width)
    UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    guard let context = UIGraphicsGetCurrentContext() else { return image }
    context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
    context.rotate(by: radians)
    image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
    return UIGraphicsGetImageFromCurrentImageContext() ?? image
  }

  private static func flippedHorizontally(_ image: UIImage) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    guard let context = UIGraphicsGetCurrentContext() else { return image }
    context.translateBy(x: image.size.width, y: 0)
    context.scaleBy(x: -1, y: 1)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    return UIGraphicsGetImageFromCurrentImageContext() ?? image
  }

  private static func downscaled(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
    let scale = min(1, maxDimension / max(image.size.width, image.size.height))
    guard scale < 1 else { return image }
    let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
  }

  // Share
  func presentShareSheet() {
    shareImage = editedPhoto ?? photo
    showShareSheet = true
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

  func selectTool(_ tool: EditingTool) {
    if activeTool == .annotate && tool != .annotate {
      undoAllCanvasAction()
    }
    withAnimation {
      activeTool = tool
    }
  }

  func toggleEditingMode() {
    if startEditing {
      exitEditingSession()
    } else {
      startEditing = true
      activeTool = .adjust
    }
  }

  private func exitEditingSession() {
    startEditing = false
    activeTool = .adjust
    brightness = 0
    contrast = 1
    saturation = 1
    selectedFilter = .none
  }

  func handleToolbarCancel() {
    if activeTool == .annotate {
      selectTool(.adjust)
    } else {
      exitEditingSession()
    }
  }

  func handleSaveAction() {
    if activeTool == .annotate, let image = savingCanvas() {
      editedPhoto = image
      selectTool(.adjust)
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
    
    // Create SwiftUI views for text and sticker rendering
    let swiftUIView = ZStack {
      ForEach(self.textBoxes) { tb in
        Text(self.textBoxes[self.currentIndex].id == tb.id && self.addNewBox ? "" : tb.text)
          .font((AppFont(rawValue: tb.fontName) ?? .system).font(size: tb.fontSize))
          .fontWeight(tb.isBold ? .bold : .regular)
          .italic(tb.isItalic)
          .underline(tb.isUnderlined)
          .foregroundColor(tb.textColor)
          .scaleEffect(tb.scale)
          .rotationEffect(.degrees(tb.rotation))
          .offset(tb.offset)
      }
      ForEach(self.stickers) { sticker in
        Text(sticker.emoji)
          .font(.system(size: 60))
          .scaleEffect(sticker.scale)
          .rotationEffect(sticker.rotation)
          .offset(sticker.offset)
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
