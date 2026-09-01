import SwiftUI

@MainActor
struct TextStylingBarView: View {
  @Bindable var viewModel: PhotoDetailVM

  var body: some View {
    if !viewModel.textBoxes.isEmpty {
      VStack(spacing: 10) {
        fontPicker

        HStack(spacing: 14) {
          ColorPicker("", selection: $viewModel.textBoxes[viewModel.currentIndex].textColor)
            .labelsHidden()
            .frame(width: 28, height: 28)

          Divider().frame(height: 20)

          TextStyleButton(systemImageName: "bold", isActive: viewModel.textBoxes[viewModel.currentIndex].isBold) {
            viewModel.toggleBold()
          }

          TextStyleButton(systemImageName: "italic", isActive: viewModel.textBoxes[viewModel.currentIndex].isItalic) {
            viewModel.toggleItalic()
          }

          TextStyleButton(systemImageName: "underline", isActive: viewModel.textBoxes[viewModel.currentIndex].isUnderlined) {
            viewModel.toggleUnderline()
          }

          Divider().frame(height: 20)

          Image(systemName: "textformat.size")
            .font(.caption)
            .foregroundStyle(.secondary)
          Slider(value: $viewModel.textBoxes[viewModel.currentIndex].fontSize, in: 16...72)
            .frame(width: 90)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
  }

  private var fontPicker: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        ForEach(AppFont.allCases) { font in
          Button {
            viewModel.textBoxes[viewModel.currentIndex].fontName = font.rawValue
          } label: {
            Text("Aa")
              .font(font.font(size: 18))
              .foregroundColor(viewModel.textBoxes[viewModel.currentIndex].fontName == font.rawValue ? .white : .black)
              .frame(width: 40, height: 32)
              .background(
                viewModel.textBoxes[viewModel.currentIndex].fontName == font.rawValue ? Color.accentColor : Color.black.opacity(0.06),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
              )
          }
        }
      }
    }
  }
}

private struct TextStyleButton: View {
  let systemImageName: String
  let isActive: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: systemImageName)
        .font(.subheadline.weight(.semibold))
        .foregroundColor(isActive ? .white : .black)
        .frame(width: 32, height: 32)
        .background(isActive ? Color.accentColor : Color.clear, in: Circle())
    }
  }
}
