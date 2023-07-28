import Foundation
import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
  @Binding var canvas: PKCanvasView
  @Binding var toolPicker: PKToolPicker
  var image: UIImage?
  var rect: CGSize

  func makeUIView(context: Context) -> PKCanvasView {
    canvas.isHidden = false
    canvas.backgroundColor = .clear
    canvas.drawingPolicy = .anyInput
    if let image = image {
      let imageView = UIImageView(image: image)
      imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
      imageView.contentMode = .scaleAspectFit
      imageView.clipsToBounds = true
      let subView = canvas.subviews[0]
      subView.addSubview(imageView)
      subView.sendSubviewToBack(imageView)
      toolPicker.setVisible(true, forFirstResponder: canvas)
      canvas.alwaysBounceVertical = true
      toolPicker.addObserver(canvas)
      canvas.becomeFirstResponder()
    }

    return canvas
  }

  func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
