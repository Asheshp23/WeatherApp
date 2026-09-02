import SwiftUI

private struct SavedCitySearchRequest: Equatable {
  let query: String
}

struct SavedCitiesView: View {
  @Binding var selectedCity: String

  @Environment(\.dismiss) private var dismiss
  @State private var store = SavedCitiesStore()
  @State private var search: CitySearchModel
  @State private var query = ""

  init(selectedCity: Binding<String>, weatherService: any WeatherServiceProtocol) {
    _selectedCity = selectedCity
    _search = State(wrappedValue: CitySearchModel(service: weatherService))
  }

  var body: some View {
    ZStack {
      SkyImageView()
        .ignoresSafeArea()
      VStack(spacing: 16) {
        searchField
        content
      }
      .padding()
    }
    .foregroundColor(.white)
    .navigationTitle("Saved Cities")
    .navigationBarTitleDisplayMode(.inline)
    .task(id: SavedCitySearchRequest(query: query)) {
      await search.search(query)
    }
  }

  private var searchField: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
      TextField("Search to add a city", text: $query)
        .accessibilityIdentifier("savedCitiesSearchField")
        .submitLabel(.search)
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled()
      if !query.isEmpty {
        Button {
          query = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Clear search")
      }
    }
    .padding(12)
    .glassSurface(cornerRadius: Radius.card)
  }

  @ViewBuilder
  private var content: some View {
    switch search.phase {
    case .idle:
      savedCitiesList
    case .searching:
      Spacer(minLength: 0)
      ProgressView(tintColor: .white)
      Spacer(minLength: 0)
    case .results(let cities):
      searchResultsList(cities)
    case .empty:
      ContentUnavailableView.search(text: query)
    case .failed:
      ContentUnavailableView {
        Label("Search unavailable", systemImage: "wifi.slash")
      } description: {
        Text("Check your connection and try again.")
      }
    }
  }

  private var savedCitiesList: some View {
    Group {
      if store.cities.isEmpty {
        ContentUnavailableView("No Saved Cities", systemImage: "star", description: Text("Search above to add a city you want quick access to."))
      } else {
        ScrollView {
          LazyVStack(spacing: 8) {
            ForEach(store.cities) { city in
              savedCityRow(city)
            }
          }
          .padding(.vertical, 4)
        }
      }
    }
  }

  private func savedCityRow(_ city: CitySearchResult) -> some View {
    HStack {
      Button {
        selectedCity = city.name
        dismiss()
      } label: {
        HStack {
          Image(systemName: "star.fill")
            .foregroundStyle(.yellow)
          VStack(alignment: .leading, spacing: 2) {
            Text(city.name)
              .font(.body.weight(.semibold))
            if !city.subtitle.isEmpty {
              Text(city.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          Spacer()
        }
      }
      Button {
        store.remove(city)
      } label: {
        Image(systemName: "trash")
          .foregroundStyle(.secondary)
      }
      .accessibilityLabel("Remove \(city.name)")
    }
    .padding(12)
    .glassSurface(cornerRadius: Radius.card)
  }

  private func searchResultsList(_ cities: [CitySearchResult]) -> some View {
    ScrollView {
      LazyVStack(spacing: 8) {
        ForEach(cities) { city in
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text(city.name)
                .font(.body.weight(.semibold))
              if !city.subtitle.isEmpty {
                Text(city.subtitle)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
            Spacer()
            Button {
              store.add(city)
              query = ""
            } label: {
              Image(systemName: store.contains(id: city.id) ? "checkmark.circle.fill" : "plus.circle.fill")
                .foregroundStyle(store.contains(id: city.id) ? .green : .white)
            }
            .disabled(store.contains(id: city.id))
          }
          .padding(12)
          .glassSurface(cornerRadius: Radius.card)
        }
      }
      .padding(.vertical, 4)
    }
  }
}

struct SavedCitiesView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SavedCitiesView(selectedCity: .constant("Toronto"), weatherService: WeatherDataService())
    }
  }
}
