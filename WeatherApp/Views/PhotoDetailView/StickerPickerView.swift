import SwiftUI

struct StickerPickerView: View {
  @Bindable var viewModel: PhotoDetailVM
  @Environment(\.dismiss) private var dismiss

  private let emojis = ["😀", "😂", "😍", "🔥", "❤️", "👍", "🎉", "⭐️",
                         "☀️", "🌧️", "❄️", "🌈", "😎", "🥳", "💯", "👏",
                         "🐶", "🌸", "🍕", "⚡️"]
  private let columns = Array(repeating: GridItem(.flexible()), count: 5)

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(emojis, id: \.self) { emoji in
            Button {
              viewModel.addSticker(emoji)
              dismiss()
            } label: {
              Text(emoji)
                .font(.system(size: 36))
            }
          }
        }
        .padding()
      }
      .navigationTitle("Add Sticker")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Close") { dismiss() }
        }
      }
    }
  }
}
