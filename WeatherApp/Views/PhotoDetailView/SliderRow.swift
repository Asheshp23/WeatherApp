import SwiftUI

struct SliderRow: View {
    let text: String
    @Binding var value: Double
    let inRange: ClosedRange<Double>
    
    var body: some View {
        HStack {
            Text(text)
            Slider(value: $value, in: inRange, step: 0.1)
        }
        .padding()
    }
}
