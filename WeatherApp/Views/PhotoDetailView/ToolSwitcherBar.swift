import SwiftUI

struct ToolSwitcherBar: View {
  @Bindable var viewModel: PhotoDetailVM

  var body: some View {
    HStack(spacing: 0) {
      ForEach(EditingTool.allCases) { tool in
        Button {
          viewModel.selectTool(tool)
        } label: {
          VStack(spacing: 4) {
            Image(systemName: tool.systemImage)
              .font(.system(size: 18))
            Text(tool.title)
              .font(.caption2)
          }
          .foregroundStyle(viewModel.activeTool == tool ? Color.accentColor : Color.primary)
          .frame(maxWidth: .infinity)
        }
      }
    }
    .padding(.vertical, 10)
    .background(.regularMaterial)
  }
}
