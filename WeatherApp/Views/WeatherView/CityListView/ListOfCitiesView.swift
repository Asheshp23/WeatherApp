import SwiftUI

private struct SearchRequest: Equatable {
  let query: String
  let attempt: Int
}

/// City switcher. One place for current location, saved cities, search and popular cities.
/// Uses a standard grouped List so rows, swipe actions, Dynamic Type and VoiceOver
/// behave like the rest of iOS.
struct ListOfCitiesView: View {
  @Binding var selectedCity: String
  var onUseCurrentLocation: (() -> Void)? = nil

  @Environment(\.dismiss) private var dismiss

  @State private var search: CitySearchModel
  @State private var store = SavedCitiesStore()
  @State private var query = ""
  @State private var retryAttempt = 0

  private static let popularCities = ["London", "Paris", "New York City", "Tokyo", "Rome", "Sydney", "Bangkok", "Istanbul", "Dubai", "Hong Kong", "Barcelona", "Madrid", "Moscow", "Beijing", "Los Angeles", "Chicago", "Shanghai", "Toronto", "Singapore", "Berlin"]

  @MainActor
  init(selectedCity: Binding<String>, weatherService: any WeatherServiceProtocol, onUseCurrentLocation: (() -> Void)? = nil) {
    _selectedCity = selectedCity
    self.onUseCurrentLocation = onUseCurrentLocation
    _search = State(wrappedValue: CitySearchModel(service: weatherService))
  }

  var body: some View {
    NavigationStack {
      list
        .navigationTitle("Choose a city")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a city")
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") { dismiss() }
          }
        }
    }
    .task(id: SearchRequest(query: query, attempt: retryAttempt)) {
      await search.search(query)
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .sheetBackground()
    .accessibilityIdentifier("cityList")
  }

  @ViewBuilder
  private var list: some View {
    switch search.phase {
    case .idle:
      idleList
    case .searching:
      List {
        HStack(spacing: DS.Space.s) {
          SwiftUI.ProgressView()
          Text("Searching…").foregroundStyle(.secondary)
        }
      }
    case .results(let cities):
      List {
        ForEach(cities) { city in
          resultRow(city)
        }
      }
    case .empty:
      ContentUnavailableView.search(text: query)
    case .failed:
      ContentUnavailableView {
        Label("Search unavailable", systemImage: "wifi.slash")
      } description: {
        Text("Check your connection and try again.")
      } actions: {
        Button("Try Again") { retryAttempt += 1 }
      }
    }
  }

  private var idleList: some View {
    List {
      if let onUseCurrentLocation {
        Section {
          Button {
            onUseCurrentLocation()
            dismiss()
          } label: {
            Label("Use current location", systemImage: "location.fill")
              .foregroundStyle(.primary)
          }
        }
      }

      Section("Saved Cities") {
        if store.cities.isEmpty {
          Text("Search above to add a city you want quick access to.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        } else {
          ForEach(store.cities) { city in
            cityButton(name: city.name, subtitle: city.subtitle, isSaved: true)
              .swipeActions {
                Button(role: .destructive) { store.remove(city) } label: {
                  Label("Remove \(city.name)", systemImage: "trash")
                }
              }
              .accessibilityAction(named: Text("Remove \(city.name)")) { store.remove(city) }
          }
        }
      }

      Section("Popular Cities") {
        ForEach(Self.popularCities, id: \.self) { city in
          cityButton(name: city, subtitle: "", isSaved: false)
        }
      }
    }
  }

  private func resultRow(_ city: CitySearchResult) -> some View {
    let isSaved = store.contains(id: city.id)
    return HStack {
      cityButton(name: city.name, subtitle: city.subtitle, isSaved: false)
      Button {
        if isSaved { store.remove(city) } else { store.add(city) }
      } label: {
        Image(systemName: isSaved ? "star.fill" : "star")
          .foregroundStyle(isSaved ? Color.yellow : Color.secondary)
          .frame(minWidth: DS.Size.minTarget, minHeight: DS.Size.minTarget)
      }
      .buttonStyle(.borderless)
      .accessibilityLabel(isSaved ? "Remove \(city.name)" : "Add \(city.name)")
    }
  }

  private func cityButton(name: String, subtitle: String, isSaved: Bool) -> some View {
    Button {
      select(name)
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: DS.Space.xxs) {
          Text(name)
            .foregroundStyle(.primary)
          if !subtitle.isEmpty {
            Text(subtitle)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
        Spacer(minLength: 0)
        if name == selectedCity {
          Image(systemName: "checkmark")
            .foregroundStyle(.tint)
            .accessibilityHidden(true)
        }
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(name == selectedCity ? .isSelected : [])
  }

  private func select(_ city: String) {
    if selectedCity != city {
      selectedCity = city
    }
    dismiss()
  }
}

#Preview {
  Text("Weather")
    .sheet(isPresented: .constant(true)) {
      ListOfCitiesView(selectedCity: .constant("Toronto"), weatherService: WeatherDataService())
    }
}
