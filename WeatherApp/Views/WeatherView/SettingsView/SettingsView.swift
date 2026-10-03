import SwiftUI

/// Settings sheet. Holds things people change rarely, so they stay out of the weather screen.
struct SettingsView: View {
  @Binding var tempUnit: TemperatureUnit

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TemperatureUnitToggle(selection: $tempUnit)
            .listRowInsets(EdgeInsets(top: DS.Space.m, leading: DS.Space.l, bottom: DS.Space.m, trailing: DS.Space.l))
        } header: {
          Text("Temperature Unit")
        } footer: {
          Text("Also switches wind, visibility and pressure units.")
        }

        Section {
          NavigationLink {
            ContactUsView()
          } label: {
            Label("Contact Us", systemImage: "envelope")
          }
          .accessibilityIdentifier("goToContactUs")
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .sheetBackground()
  }
}

#Preview {
  Text("Weather")
    .sheet(isPresented: .constant(true)) {
      SettingsView(tempUnit: .constant(.celcius))
    }
}
