import SwiftUI

@MainActor
struct TextStylingBarView: View {
  @Bindable var viewModel: PhotoDetailVM
  
  var textStylingBarView: some View {
    VStack {
      if !viewModel.textBoxes.isEmpty {
        HStack {
          ColorPicker("", selection: $viewModel.textBoxes[viewModel.currentIndex].textColor)
            .labelsHidden()
            .padding()
            .background(
              neumorphicBackground(isActive: false)
                .frame(width: 45, height: 45)
            )
          
          TextStyleButton(label: "B", systemImageName: "bold", isActive: viewModel.textBoxes[viewModel.currentIndex].isBold) {
            viewModel.toggleBold()
          }
          
          Divider()
          
          TextStyleButton(label: "I", systemImageName: "italic", isActive: viewModel.textBoxes[viewModel.currentIndex].isItalic) {
            viewModel.toggleItalic()
          }
          
          Divider()
          
          TextStyleButton(label: "U", systemImageName: "underline", isActive: viewModel.textBoxes[viewModel.currentIndex].isUnderlined) {
            viewModel.toggleUnderline()
          }
        }
      }
    }
  }
  
  func neumorphicBackground(isActive: Bool) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12.0)
        .fill(.black)
        .overlay(
          RoundedRectangle(cornerRadius: 12.0)
            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: isActive ? Color.blue : Color.gray.opacity(0.5), radius: 3, x: 2, y: 2)
        .shadow(color: isActive ? Color.blue : Color.white.opacity(0.9), radius: 3, x: -2, y: -2)
    }
  }
  
  var body: some View {
    textStylingBarView
  }
}

struct TextStyleButton: View {
  let label: String
  let systemImageName: String
  let isActive: Bool
  let action: () -> Void
  
  func neumorphicBackground(isActive: Bool) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12.0)
        .fill(.black)
        .overlay(
          RoundedRectangle(cornerRadius: 12.0)
            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: isActive ? Color.blue : Color.gray.opacity(0.5), radius: 3, x: 2, y: 2)
        .shadow(color: isActive ? Color.blue : Color.white.opacity(0.9), radius: 3, x: -2, y: -2)
    }
  }
  
  var body: some View {
    Button(action: action) {
      VStack {
        Image(systemName: systemImageName)
          .foregroundColor(isActive ? .blue : .white)
      }
      .padding()
      .background(
        neumorphicBackground(isActive: isActive)
      )
    }
  }
}
