import SwiftUI

@MainActor
struct ToolBarContentView: ToolbarContent {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if viewModel.startEditing {
        if !viewModel.addNewBox {
          Button(action: viewModel.handleSaveAction) {
            Text(viewModel.startAnnotating ? "Done" : "Save")
          }
        }
      } else {
        Button(action: viewModel.toggleEditingMode) {
          Text("Edit")
        }
      }
    }
    
    if viewModel.startEditing {
      if !viewModel.addNewBox {
        ToolbarItem(placement: .navigationBarLeading) {
          HStack {
            Button(action: viewModel.toggleAnnotatingOrEditing) {
              Text("Cancel")
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
            } else {
              Button(action: viewModel.toggleAnnotatingMode) {
                Image(systemName: "pencil.tip.crop.circle")
              }
            }
          }
        }
      }
    }
  }
}
