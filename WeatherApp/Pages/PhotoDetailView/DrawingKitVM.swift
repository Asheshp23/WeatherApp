import Foundation
import PencilKit
import SwiftUI

class DrawingKitVM: ObservableObject {
  @Published var canvas = PKCanvasView()
  @Published var toolPicker = PKToolPicker()
  @Published var textBoxes: [CustomTextBox] = []
  @Published var addNewBox = false
  @Published var currentIndex: Int = 0
  @Published var rect: CGRect = .zero

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
      UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: path)!, nil, nil, nil)
      Task { @MainActor in
        self.showAlert.toggle()
        self.message = "saved successfully"
      }
    }

  }
}
