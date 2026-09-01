import SwiftUI

struct FilterPresetsView: View {
  @Bindable var viewModel: PhotoDetailVM

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 14) {
        ForEach(FilterPreset.allCases) { filter in
          Button {
            viewModel.applyFilterPreset(filter)
          } label: {
            VStack(spacing: 6) {
              Image(uiImage: filter.apply(to: viewModel.filterThumbnailSource))
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                  RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(viewModel.selectedFilter == filter ? Color.accentColor : Color.clear, lineWidth: 2)
                )
              Text(filter.rawValue)
                .font(.caption2)
                .foregroundStyle(viewModel.selectedFilter == filter ? Color.accentColor : .secondary)
            }
          }
        }
      }
      .padding(.horizontal, 16)
    }
    .padding(.vertical, 12)
    .background(.regularMaterial)
  }
}
