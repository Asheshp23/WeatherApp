import SwiftUI

struct PhotoDetailView: View {
  @Binding var image : String
  @State private var brightnessAmount: Double = 0
  @State private var saturationAmount: Double = 1.0
  @StateObject var vm = DrawingKitVM()
  var body: some View {
    ZStack {
      GeometryReader { proxy -> AnyView in
        let size = proxy.frame(in: .global).size
        Task { @MainActor in
          if vm.rect == .zero {
            vm.rect = proxy.frame(in: .global)
          }
        }
       return AnyView (
        ZStack {
          ZStack {
            CanvasView(canvas: $vm.canvas,
                       toolPicker: $vm.toolPicker,
                       image: UIImage(named: image),
                       rect: size)
          }
          ForEach(vm.textBoxes) { tb in
            Text(vm.textBoxes[vm.currentIndex].id == tb.id && vm.addNewBox ? "" :  tb.text)
              .font(.system(size: 30, weight: vm.textBoxes[vm.currentIndex].isBold ? .bold : .regular ))
              .foregroundColor(tb.textColor)
              .italic(vm.textBoxes[vm.currentIndex].isItalic)
              .underline(vm.textBoxes[vm.currentIndex].isUnderlined)
              .offset(tb.offset)
              .gesture(DragGesture().onChanged({ value in
                let current =  value.translation
                let new = CGSize(width: tb.lastOffset.width + current.width , height: tb.lastOffset.height + current.height)

                vm.textBoxes[getIndex(tb: tb)].offset = new
              }).onEnded({ value in
                vm.textBoxes[getIndex(tb: tb)].lastOffset = value.translation
              }))
              .onLongPressGesture {
                vm.toolPicker.setVisible(false, forFirstResponder:  vm.canvas)
                vm.canvas.resignFirstResponder()
                vm.currentIndex = getIndex(tb: tb)
                withAnimation {
                  vm.addNewBox = true
                }
              }

          }

          if vm.addNewBox {
            Color.black.opacity(0.75)
              .ignoresSafeArea()
            TextField("Type here", text: $vm.textBoxes[vm.currentIndex].text)
              .font(.system(size: 35.0))
              .italic(vm.textBoxes[vm.currentIndex].isItalic)
              .underline(vm.textBoxes[vm.currentIndex].isUnderlined)
              .colorScheme(.dark)
              .padding()
              .foregroundColor(vm.textBoxes[vm.currentIndex].textColor)
            HStack {
              Button(action: {
                vm.toolPicker.setVisible(true, forFirstResponder: vm.canvas)
                vm.canvas.becomeFirstResponder()
                withAnimation {
                  vm.addNewBox = false
                }
              }, label: {
                Text("Add")
                  .fontWeight(.heavy)
                  .foregroundColor(.white)
                  .padding()
              })
              Spacer()
              Button(action: {
                withAnimation {
                  if vm.textBoxes[vm.currentIndex].isAdded {
                    vm.textBoxes.removeLast()
                  }
                  vm.addNewBox = false
                  vm.toolPicker.setVisible(true, forFirstResponder:  vm.canvas)
                  vm.canvas.becomeFirstResponder()
                }
              }, label: {
                Text("Cancel")
                  .fontWeight(.heavy)
                  .foregroundColor(.white)
                  .padding()
              })
            }
            .overlay(
              VStack {
                HStack {
                  ColorPicker("", selection: $vm.textBoxes[vm.currentIndex].textColor)
                    .labelsHidden()

                  Text("B")
                    .bold()
                    .padding()
                    .onTapGesture {
                      vm.textBoxes[vm.currentIndex].isBold.toggle()
                    }
                    .foregroundColor(.white)
                  Divider()
                  Text("I")
                    .italic()
                    .padding()
                    .onTapGesture {
                      vm.textBoxes[vm.currentIndex].isItalic.toggle()
                    }
                    .foregroundColor(.white)
                  Divider()
                  Text("U")
                    .underline()
                    .padding()
                    .onTapGesture {
                      vm.textBoxes[vm.currentIndex].isUnderlined.toggle()
                    }
                    .foregroundColor(.white)
                }

              }
            )
            .frame(maxHeight: .infinity,alignment: .top)
          }

        }
       )
      }
    }
    .alert(isPresented: $vm.showAlert, content: {
      Alert(title: Text(vm.message), dismissButton: .destructive(Text("OkAY")))
    })
    .toolbar {
      ToolbarItem (placement: .navigationBarTrailing) {
        Button(action: vm.savingCanvas, label:
         {
         Text("save")
        })
      }
      ToolbarItem (placement: .navigationBarLeading) {
        HStack {
          Button(action: {
            withAnimation {
              vm.textBoxes.append(CustomTextBox())
              vm.currentIndex = vm.textBoxes.count - 1
              vm.addNewBox = true
              vm.toolPicker.setVisible(false, forFirstResponder:  vm.canvas)
              vm.canvas.resignFirstResponder()
            }
          }) {
            Image(systemName: "plus")
          }
          Button(action: { vm.canvas.undoManager?.undo()}, label:{ Image(systemName: "arrow.uturn.backward")})
          Button(action: { vm.canvas.undoManager?.redo()}, label:{ Image(systemName: "arrow.uturn.forward")})

        }
      }
    }
  }
  func getIndex(tb: CustomTextBox) -> Int {
    return vm.textBoxes.firstIndex { cb in
      return cb.id == tb.id
    } ?? 0
  }
}

struct PhotoDetailView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoDetailView(image: .constant("IMG1"))
  }
}
