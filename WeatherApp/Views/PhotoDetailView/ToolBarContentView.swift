import SwiftUI

@MainActor
struct ToolBarContentView: ToolbarContent {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if viewModel.startEditing {
        Button(action: viewModel.handleSaveAction) {
          Text(viewModel.startAnnotating ? "Done" : "Save")
        }
      } else {
        Button(action: viewModel.toggleEditingMode) {
          Text("Edit")
        }
      }
    }
    
    if viewModel.startEditing {
      ToolbarItem(placement: .navigationBarLeading) {
        HStack {
          Button(action: viewModel.toggleAnnotatingOrEditing) {
            Text("Cancel")
          }
          
          
          if !viewModel.startAnnotating {
            Button(action: viewModel.toggleAnnotatingMode) {
              Image(systemName: "pencil.tip.crop.circle")
            }
          }
          
          if viewModel.startAnnotating {
            Button(action: viewModel.undoCanvasAction) {
              Image(systemName: "arrow.uturn.backward")
            }
            
            Button(action: viewModel.redoCanvasAction) {
              Image(systemName: "arrow.uturn.forward")
            }
            
            Button(action: viewModel.addNewTextBox) {
              Image(systemName: "plus")
            }
          }
        }
      }
    }
  }
}
