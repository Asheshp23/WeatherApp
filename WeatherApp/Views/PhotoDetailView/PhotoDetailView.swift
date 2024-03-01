import SwiftUI
import Photos

struct PhotoDetailView: View {
    @StateObject var vm: PhotoDetailVM
    
    var textStylingBarView: some View {
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
    }
    
    var textInputoverlayView: some View {
        ZStack {
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
            .overlay(textStylingBarView)
            .frame(maxHeight: .infinity,alignment: .top)
        }
    }
    
    var textBoxesDisplay: some View {
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
                    
                    vm.textBoxes[vm.getIndex(tb: tb)].offset = new
                }).onEnded({ value in
                    vm.textBoxes[vm.getIndex(tb: tb)].lastOffset = value.translation
                }))
                .onLongPressGesture {
                    vm.toolPicker.setVisible(false, forFirstResponder:  vm.canvas)
                    vm.canvas.resignFirstResponder()
                    vm.currentIndex = vm.getIndex(tb: tb)
                    withAnimation {
                        vm.addNewBox = true
                    }
                }
        }
    }
    
    var initialImageView: some View {
        HStack(alignment: .center) {
            Image(uiImage: self.vm.editedPhoto ?? self.vm.photo)
                .resizable()
                .scaledToFit()
        }
    }
    
    var filteredImageView: some View {
        VStack {
            Image(uiImage: vm.editedPhoto ?? vm.photo)
                .resizable()
                .scaledToFit()
                .brightness(vm.brightness)
                .saturation(vm.saturation)
                .contrast(vm.contrast)
            HStack {
                Text("Brightness")
                Slider(value: $vm.brightness, in: -1...1, step: 0.1)
            }
            .padding()
            
            HStack {
                Text("Contrast")
                Slider(value: $vm.contrast, in: 0...2, step: 0.1)
            }
            .padding()
            
            HStack {
                Text("Saturation")
                Slider(value: $vm.saturation, in: 0...2, step: 0.1)
            }
            .padding()
        }
    }
    
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
                            if vm.startEditing {
                                if vm.startAnnotating {
                                    CanvasView(canvas: $vm.canvas,
                                               toolPicker: $vm.toolPicker,
                                               image: self.vm.applyFilter(to: self.vm.editedPhoto ?? self.vm.photo) ?? self.vm.photo,
                                               rect: size)
                                } else {
                                    filteredImageView
                                }
                            } else {
                                initialImageView
                            }
                        }
                        textBoxesDisplay
                        if vm.addNewBox {
                            textInputoverlayView
                        }
                    }
                )
            }
        }
        .alert(isPresented: $vm.showAlert, content: {
            Alert(title: Text(vm.message), dismissButton: .destructive(Text("ok")))
        })
        .navigationBarBackButtonHidden(vm.startEditing)
        .toolbar {
            if vm.startEditing {
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button(action: {
                        if let image = vm.savingCanvas(), vm.startAnnotating {
                            self.vm.editedPhoto = image
                        } else {
                            vm.save(image: self.vm.editedPhoto ?? self.vm.photo)
                        }
                    },
                           label: { Text(vm.startAnnotating ? "Done" : "Save") })
                }
                
                ToolbarItem (placement: .navigationBarLeading) {
                    HStack {
                        Button(action: {
                            if vm.startAnnotating {
                                vm.startAnnotating.toggle()
                                if let image = vm.savingCanvas() {
                                    self.vm.editedPhoto = image
                                }
                            } else {
                                vm.startEditing.toggle()
                            }
                        }, label: { Text("Cancel").padding(.trailing)})
                        Button(action: { vm.canvas.undoManager?.undo()}, label:{ Image(systemName: "arrow.uturn.backward")})
                        Button(action: { vm.canvas.undoManager?.redo()}, label:{ Image(systemName: "arrow.uturn.forward")})
                        Button(action: { vm.startAnnotating.toggle() }, label:{ Image(systemName: "pencil")})
                        
                        if vm.startAnnotating {
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
                        }
                    }
                }
            } else {
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button(action: {
                        vm.startEditing.toggle()
                    }, label:
                            {
                        Text("Edit")
                            .padding()
                    })
                }
            }
        }
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(vm: PhotoDetailVM(photo: UIImage(imageLiteralResourceName: "IMG1")))
    }
}
