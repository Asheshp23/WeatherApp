import SwiftUI

struct WheelPickerView: View {
  @Binding var selectedValue: CGFloat
  @State var isLoaded: Bool = false
  
  var body: some View {
    GeometryReader { proxy in
      let size = proxy.size
      let padding = size.width / 2
      
      ScrollView(.horizontal) {
        HStack(spacing: 5) {
          ForEach(-100...100, id: \.self) { number in
            let remainder = number % 5
            Divider()
              .background(remainder == 0 ? Color.primary :
                  . gray)
              .frame(width: 0,
                     height: remainder == 0 ? 20 : 10, alignment: .center)
              .frame(maxHeight: 20, alignment:
                  .bottom)
              .overlay(alignment: .bottom) {
                if remainder == 0 {
                  Text("\((number))")
                    .font(.caption)
                    .textScale(.secondary)
                    .fixedSize()
                    .fontWeight(.semibold)
                    .offset(y: 20)
                }
              }
          }
        }
        .frame(height: size.height)
        .scrollTargetLayout()
      }
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: .init(get: {
        let value: Int? = isLoaded ? Int(selectedValue) : 0
        return value
      }, set: { newValue in
        if let newValue { self.selectedValue = CGFloat(newValue) }
      }))
      .overlay(alignment: .bottom) {
        RoundedRectangle(cornerRadius: 25.0)
          .frame(width: 1, height: 20)
          .padding(.bottom, 50)
      }
      .scrollIndicators(.hidden)
      .safeAreaPadding(.horizontal, padding)
      .onAppear {
        if !isLoaded { isLoaded = true }
      }
    }
  }
}

#Preview {
  WheelPickerView(selectedValue: .constant(0))
}
