import SwiftUI

struct SettingsView: View {
  @Binding var tempUnit: TemperatureUnit
  @Binding var showSettings: Bool
  
  var body: some View {
    ZStack {
      SkyImageView()
      VStack(alignment: .center) {
        Text("Choose the Temperature Unit")
          .font(.title)
          .padding(.all)
          .fontWeight(.bold)
        Picker("Temperature Unit", selection: $tempUnit) {
          ForEach(TemperatureUnit.allCases) { unit in
            Text("°\(unit.rawValue.capitalized)")
              .fontWeight(.bold)
              .tag(unit)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .accessibilityIdentifier("temperatureUnit")
        .padding(.all)
        Spacer()
      }
      .onChange(of: tempUnit) { oldValue, newValue in
        DispatchQueue.main.async {
          showSettings.toggle()
        }
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    let unit : TemperatureUnit = .celcius
    SettingsView(tempUnit: .constant(unit), showSettings: .constant(false))
  }
}
