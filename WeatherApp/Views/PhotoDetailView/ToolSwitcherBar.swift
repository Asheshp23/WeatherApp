import SwiftUI

/// Bottom tool switcher for the photo editor. A toolbar is where HIG intends materials/glass,
/// so this keeps a bar background; each tool is a full-height 44pt+ target.
struct ToolSwitcherBar: View {
  @Bindable var viewModel: PhotoDetailVM

  var body: some View {
    HStack(spacing: 0) {
      ForEach(EditingTool.allCases) { tool in
        let isActive = viewModel.activeTool == tool
        Button {
          viewModel.selectTool(tool)
        } label: {
          VStack(spacing: DS.Space.xs) {
            Image(systemName: tool.systemImage)
              .font(.body)
            Text(tool.title)
              .font(.caption2)
              .lineLimit(1)
              .minimumScaleFactor(0.8)
          }
          .foregroundStyle(isActive ? Color.accentColor : Color.primary)
          .frame(maxWidth: .infinity, minHeight: DS.Size.minTarget)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? .isSelected : [])
      }
    }
    .padding(.vertical, DS.Space.s)
    .background(.bar)
  }
}
