import SwiftUI
import Photos

struct PhotoDetailView: View {
    var photo: UIImage
    
    @State var editedPhoto: UIImage?
    @State var brightness: Double = 0
    @State var contrast: Double = 1
    @State var saturation: Double = 1
    @State var isSaturationChanged: Bool = false
    @State var isBrightnessChanged: Bool = false
    @State var isContrastChanged: Bool = false
    @State var customAlbum: PHAssetCollection?
    @StateObject var vm = DrawingKitVM()
    
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
    }
    
    var initialImageView: some View {
        HStack(alignment: .center) {
            Image(uiImage: self.editedPhoto ?? self.photo)
                .resizable()
                .scaledToFit()
        }
    }
    
    var filteredImageView: some View {
        VStack {
            if let editedPhoto = editedPhoto {
                Image(uiImage: editedPhoto)
                    .resizable()
                    .scaledToFit()
            }
            HStack {
                Text("Brightness")
                Slider(value: $brightness, in: -1...1, step: 0.1)
            }
            .padding()
            .onChange(of: brightness) { newValue in
                self.isBrightnessChanged = true
                if let editedPhoto = editedPhoto {
                    self.editedPhoto = self.applyFilter(to: editedPhoto)
                } else {
                    self.editedPhoto = self.applyFilter(to: self.photo)
                }
            }
            
            HStack {
                Text("Contrast")
                Slider(value: $contrast, in: 0...2, step: 0.1)
            }
            .padding()
            .onChange(of: contrast) { newValue in
                self.isContrastChanged = true
                if let editedPhoto = editedPhoto {
                    self.editedPhoto = self.applyFilter(to: editedPhoto)
                } else {
                    self.editedPhoto = self.applyFilter(to: self.photo)
                }
            }
            
            HStack {
                Text("Saturation")
                Slider(value: $saturation, in: 0...2, step: 0.1)
            }
            .padding()
            .onChange(of: saturation) { newValue in
                self.isSaturationChanged = true
                if let editedPhoto = editedPhoto {
                    self.editedPhoto = self.applyFilter(to: editedPhoto)
                } else {
                    self.editedPhoto = self.applyFilter(to: self.photo)
                }
            }
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
                                               image: self.applyFilter(to: self.editedPhoto ?? self.photo) ?? self.photo,
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
                            self.editedPhoto = image
                        } else {
                            save(image: self.editedPhoto ?? self.photo)
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
                                    self.editedPhoto = image
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
    
    func getIndex(tb: CustomTextBox) -> Int {
        return vm.textBoxes.firstIndex { cb in
            return cb.id == tb.id
        } ?? 0
    }
    
    // Create or fetch custom album
    private func getOrCreateCustomAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "Custom Album Name")
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let album = collection.firstObject {
            return album
        } else {
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Custom Album Name")
                }
                return collection.firstObject
            } catch {
                print("Error creating album: \(error)")
                return nil
            }
        }
    }
    
    func applyFilter(to image: UIImage) -> UIImage? {
        let context = CIContext()
        guard let inputImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        if self.isBrightnessChanged {
            filter?.setValue(self.brightness, forKey: kCIInputBrightnessKey)
            self.isBrightnessChanged.toggle()
        }
        if self.isContrastChanged {
            filter?.setValue(self.contrast, forKey: kCIInputContrastKey)
            self.isContrastChanged = false
        }
        if self.isSaturationChanged {
            filter?.setValue(self.saturation, forKey: kCIInputSaturationKey)
            self.isSaturationChanged.toggle()
        }
        
        guard let outputImage = filter?.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func save(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo library access not authorized.")
                return
            }
            
            guard let imageData = image.pngData() else {
                print("Failed to convert filtered image to PNG data.")
                DispatchQueue.main.async {
                    self.vm.showAlert.toggle()
                    self.vm.message = "Failed to save image"
                }
                return
            }
            
            let fileManager = FileManager.default
            let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("newImageName.png")
            
            do {
                try imageData.write(to: URL(fileURLWithPath: path))
            } catch {
                print("Failed to write image data to file: \(error)")
                DispatchQueue.main.async {
                    self.vm.showAlert.toggle()
                    self.vm.message = "Failed to save image"
                }
                return
            }
            
            guard let customAlbum = getOrCreateCustomAlbum() else {
                print("Custom album not found.")
                return
            }
            
            // Save image to custom album
            PHPhotoLibrary.shared().performChanges ({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: customAlbum)
                let enumeration: NSArray = [assetPlaceholder!]
                albumChangeRequest!.addAssets(enumeration)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    self.vm.showAlert.toggle()
                    if success {
                        self.vm.message = "Saved successfully"
                        self.vm.startEditing = false
                    } else {
                        self.vm.message = "Failed to save image"
                    }
                }
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    print("Error deleting file: \(error)")
                }
            })
        }
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(photo: UIImage(imageLiteralResourceName: "IMG1"))
    }
}
