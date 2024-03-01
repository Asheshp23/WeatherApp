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
    
    func savingCanvas() -> UIImage? {
        // Generate image from canvas
        guard let generatedImage = generateImage() else {
            print("Failed to generate image.")
            return nil
        }
        
        return generatedImage
      
    }
    
    // Generate image from canvas
    private func generateImage() -> UIImage? {
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
        defer { UIGraphicsEndImageContext() }
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
