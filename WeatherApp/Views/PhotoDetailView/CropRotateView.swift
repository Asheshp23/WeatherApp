import SwiftUI
import AVFoundation

struct CropRotateView: View {
  @Bindable var viewModel: PhotoDetailVM
  @State private var cropRect: CGRect = .zero
  @State private var imageFrame: CGRect = .zero

  private var previewImage: UIImage { viewModel.editedPhoto ?? viewModel.photo }

  var body: some View {
    GeometryReader { proxy in
      let containerSize = proxy.size

      ZStack {
        Color.black

        Image(uiImage: previewImage)
          .resizable()
          .scaledToFit()
          .frame(width: containerSize.width, height: containerSize.height)

        if cropRect != .zero {
          CropOverlay(rect: $cropRect, bounds: imageFrame)
        }
      }
      .onAppear {
        setupCropRect(containerSize: containerSize)
      }
      .onChange(of: cropRect) { _, newValue in
        viewModel.cropRect = newValue
        viewModel.cropContainerSize = containerSize
      }

      VStack {
        Spacer()
        HStack(spacing: 28) {
          Button {
            viewModel.rotateEditedPhoto(by: -90)
            setupCropRect(containerSize: containerSize)
          } label: {
            Image(systemName: "rotate.left")
          }
          Button {
            viewModel.flipEditedPhotoHorizontally()
            setupCropRect(containerSize: containerSize)
          } label: {
            Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
          }
          Button {
            viewModel.rotateEditedPhoto(by: 90)
            setupCropRect(containerSize: containerSize)
          } label: {
            Image(systemName: "rotate.right")
          }
          Spacer()
          Button("Apply") {
            viewModel.applyCrop()
          }
          .buttonStyle(.borderedProminent)
        }
        .font(.title3)
        .foregroundStyle(.white)
        .padding()
        .background(.black.opacity(0.5))
      }
    }
  }

  private func setupCropRect(containerSize: CGSize) {
    let frame = AVMakeRect(aspectRatio: previewImage.size, insideRect: CGRect(origin: .zero, size: containerSize))
    imageFrame = frame
    cropRect = frame
    viewModel.cropRect = frame
    viewModel.cropContainerSize = containerSize
  }
}

private struct CropOverlay: View {
  @Binding var rect: CGRect
  let bounds: CGRect
  private let handleSize: CGFloat = 24
  private let minSize: CGFloat = 60

  private enum Corner { case topLeading, topTrailing, bottomLeading, bottomTrailing }

  var body: some View {
    ZStack {
      Rectangle()
        .strokeBorder(Color.yellow, lineWidth: 2)
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)

      handle(at: CGPoint(x: rect.minX, y: rect.minY), corner: .topLeading)
      handle(at: CGPoint(x: rect.maxX, y: rect.minY), corner: .topTrailing)
      handle(at: CGPoint(x: rect.minX, y: rect.maxY), corner: .bottomLeading)
      handle(at: CGPoint(x: rect.maxX, y: rect.maxY), corner: .bottomTrailing)
    }
  }

  private func handle(at point: CGPoint, corner: Corner) -> some View {
    Circle()
      .fill(Color.yellow)
      .frame(width: handleSize, height: handleSize)
      .contentShape(Circle())
      .position(point)
      .gesture(
        DragGesture()
          .onChanged { value in
            let location = CGPoint(x: point.x + value.translation.width, y: point.y + value.translation.height)
            updateRect(corner: corner, location: location)
          }
      )
  }

  private func updateRect(corner: Corner, location: CGPoint) {
    let clampedX = min(max(location.x, bounds.minX), bounds.maxX)
    let clampedY = min(max(location.y, bounds.minY), bounds.maxY)
    var newRect = rect

    switch corner {
    case .topLeading:
      newRect = CGRect(x: clampedX, y: clampedY, width: rect.maxX - clampedX, height: rect.maxY - clampedY)
    case .topTrailing:
      newRect = CGRect(x: rect.minX, y: clampedY, width: clampedX - rect.minX, height: rect.maxY - clampedY)
    case .bottomLeading:
      newRect = CGRect(x: clampedX, y: rect.minY, width: rect.maxX - clampedX, height: clampedY - rect.minY)
    case .bottomTrailing:
      newRect = CGRect(x: rect.minX, y: rect.minY, width: clampedX - rect.minX, height: clampedY - rect.minY)
    }

    guard newRect.width >= minSize, newRect.height >= minSize else { return }
    rect = newRect
  }
}
