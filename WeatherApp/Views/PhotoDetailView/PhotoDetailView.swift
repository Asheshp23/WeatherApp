import SwiftUI
import Photos

struct PhotoDetailView: View {
  let imageName : UIImage
  @State var brightness: Double = 0
  @State var contrast: Double = 1
  @State var saturation: Double = 1
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
      Image(uiImage: imageName)
        .resizable()
        .scaledToFit()
    }
  }
  
  var filteredImageView: some View {
    VStack {
      Image(uiImage: imageName)
        .resizable()
        .scaledToFit()
        .brightness(brightness)
        .contrast(contrast)
        .saturation(saturation)
      
      HStack {
        Text("Brightness")
        Slider(value: $brightness, in: -1...1, step: 0.1)
      }.padding()
      
      HStack {
        Text("Contrast")
        Slider(value: $contrast, in: 0...2, step: 0.1)
      }.padding()
      
      HStack {
        Text("Saturation")
        Slider(value: $saturation, in: 0...2, step: 0.1)
      }.padding()
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
                             image: imageName,
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
    .onAppear {
      self.customAlbum = self.getOrCreateAlbum(named: "Custom Album Name")
    }
    .alert(isPresented: $vm.showAlert, content: {
      Alert(title: Text(vm.message), dismissButton: .destructive(Text("ok")))
    })
    .toolbar {
      if vm.startEditing {
        ToolbarItem (placement: .navigationBarTrailing) {
          Button(action: { if vm.startAnnotating { vm.savingCanvas() } else {saveImage()} }, label: { Text("save") })
        }
        ToolbarItem (placement: .navigationBarLeading) {
          HStack {
            Button(action: { vm.startEditing.toggle()}, label: { Text("Cancel").padding(.trailing)})
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
  
  func getOrCreateAlbum(named name: String) -> PHAssetCollection? {
    guard PHPhotoLibrary.authorizationStatus() == .authorized else {
      PHPhotoLibrary.requestAuthorization { _ in }
      return nil
    }
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "localizedTitle = %@", "JOB-\(name)")
    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    if let existingAlbum = collections.firstObject {
      return existingAlbum
    }
    var albumPlaceholder: PHObjectPlaceholder?
    do {
      try PHPhotoLibrary.shared().performChangesAndWait {
        let createAlbumRequest = PHAssetCollectionChangeRequest
          .creationRequestForAssetCollection(withTitle: "JOB-\(name)")
        albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
      }
      if let albumPlaceholder = albumPlaceholder {
        let fetchResult = PHAssetCollection
          .fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
        return fetchResult.firstObject
      }
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }
  
  func saveImage() {
    PHPhotoLibrary.requestAuthorization { status in
      guard status == .authorized else { return }
      
      let context = CIContext()
      let img = self.imageName
      let inputImage = CIImage(image: img)
      let filter = CIFilter(name: "CIColorControls")
      filter?.setValue(inputImage, forKey: kCIInputImageKey)
      filter?.setValue(self.brightness, forKey: kCIInputBrightnessKey)
      filter?.setValue(self.contrast, forKey: kCIInputContrastKey)
      filter?.setValue(self.saturation, forKey: kCIInputSaturationKey)
      
      guard let outputImage = filter?.outputImage else { return }
      if let image = context.createCGImage(outputImage, from: outputImage.extent) {
        let fileManager = FileManager.default
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("newImageName.png")
        let uiImage = UIImage(cgImage: image)
        if let pngData = uiImage.pngData() {
          fileManager.createFile(atPath: path, contents: pngData, attributes: nil)
        }
        guard let customAlbum = customAlbum else { return }
        // Save image to custom album
        PHPhotoLibrary.shared().performChanges ({
          let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(cgImage: image))
          let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
          let albumChangeRequest = PHAssetCollectionChangeRequest(for: customAlbum)
          let enumeration: NSArray = [assetPlaceholder!]
          albumChangeRequest!.addAssets(enumeration)
        }, completionHandler: {success, error in
          Task { @MainActor in
            self.vm.showAlert.toggle()
            self.vm.message = "saved successfully"
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
}

struct PhotoDetailView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoDetailView(imageName: UIImage(imageLiteralResourceName: "IMG1"))
  }
}
