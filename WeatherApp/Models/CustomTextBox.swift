import SwiftUI
import PencilKit

struct CustomTextBox: Identifiable {
  var id = UUID().uuidString
  var text: String = ""
  var isBold: Bool = false
  var isItalic: Bool = false
  var isUnderlined: Bool = false
  var strikeThrough: Bool = false
  var offset: CGSize = .zero
  var lastOffset: CGSize = .zero
  var rotation: Double = 0.0
  var lastRotation: Double = 0.0
  var textColor: Color = .black
  var isAdded: Bool = true
  var isEditing: Bool = false
}

