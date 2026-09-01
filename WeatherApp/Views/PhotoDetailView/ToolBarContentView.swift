import SwiftUI

@MainActor
struct ToolBarContentView: ToolbarContent {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if viewModel.startEditing {
        if !viewModel.addNewBox {
          Button(action: viewModel.handleSaveAction) {
            Label(viewModel.startAnnotating ? "Done" : "Save", systemImage: "checkmark")
          }
          .fontWeight(.semibold)
        }
      } else {
        Button(action: viewModel.presentShareSheet) {
          Image(systemName: "square.and.arrow.up")
        }
        Button(action: viewModel.toggleEditingMode) {
          Label("Edit", systemImage: "slider.horizontal.3")
        }
      }
    }

    if viewModel.startEditing && !viewModel.addNewBox {
      ToolbarItem(placement: .navigationBarLeading) {
        HStack(spacing: 18) {
          Button(action: viewModel.handleToolbarCancel) {
            Image(systemName: "xmark")
          }

          if viewModel.startAnnotating {
            Button(action: viewModel.undoCanvasAction) {
              Image(systemName: "arrow.uturn.backward")
            }

            Button(action: viewModel.redoCanvasAction) {
              Image(systemName: "arrow.uturn.forward")
            }

            Button(action: viewModel.addNewTextBox) {
              Image(systemName: "textformat")
            }
          }
        }
      }
    }
  }
}
