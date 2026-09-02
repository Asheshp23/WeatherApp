import SwiftUI

private struct SearchRequest: Equatable {
  let query: String
  let attempt: Int
}

struct ListOfCitiesView: View {
  @Binding var selectedCity: String

  @Environment(\.dismiss) private var dismiss
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  @State private var search: CitySearchModel
  @State private var query = ""
  @State private var retryAttempt = 0
  @State private var detent: PresentationDetent = .medium
  @FocusState private var searchFocused: Bool

  private static let popularCities = ["London", "Paris", "New York City", "Tokyo", "Rome", "Sydney", "Bangkok", "Istanbul", "Dubai", "Hong Kong", "Barcelona", "Madrid", "Moscow", "Beijing", "Los Angeles", "Chicago", "Shanghai", "Toronto", "Singapore", "Berlin"]

  @MainActor
  init(selectedCity: Binding<String>, weatherService: any WeatherServiceProtocol) {
    _selectedCity = selectedCity
    _search = State(wrappedValue: CitySearchModel(service: weatherService))
  }

  var body: some View {
    sheetContainer
      .task(id: SearchRequest(query: query, attempt: retryAttempt)) {
        await search.search(query)
      }
      .onChange(of: searchFocused) { (_: Bool, isFocused: Bool) in
        guard isFocused else { return }
        withAnimation(Motion.resolve(Motion.gentle, reduceMotion: reduceMotion)) { detent = .large }
      }
  }

  private var sheetContainer: some View {
    VStack(spacing: 16) {
      SheetGrabber()
      searchField
      content
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .presentationDetents([.medium, .large], selection: $detent)
    .presentationBackground(.ultraThinMaterial)
    .presentationDragIndicator(.hidden)
    .presentationCornerRadius(Radius.sheet)
    .accessibilityIdentifier("cityList")
  }

  private var searchField: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
      TextField("Search for a city", text: $query)
        .accessibilityIdentifier("citySearchField")
        .submitLabel(.search)
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled()
        .focused($searchFocused)
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
      popularCitiesGrid
    case .searching:
      Spacer(minLength: 0)
      ProgressView(tintColor: .primary)
      Text("Searching…")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Spacer(minLength: 0)
    case .results(let cities):
      resultsList(cities)
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

  private var popularCitiesGrid: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
        ForEach(Self.popularCities, id: \.self) { city in
          Button {
            select(city)
          } label: {
            Text(city)
              .font(.subheadline.weight(.medium))
              .lineLimit(1)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 10)
          }
          .buttonStyle(PressableButtonStyle())
          .glassSurface(cornerRadius: Radius.control)
        }
      }
      .padding(.vertical, 4)
    }
  }

  private func resultsList(_ cities: [CitySearchResult]) -> some View {
    ScrollView {
      LazyVStack(spacing: 8) {
        ForEach(cities) { city in
          Button {
            select(city.name)
          } label: {
            HStack {
              Image(systemName: "building.2.fill")
                .foregroundStyle(.secondary)
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
            .padding(12)
          }
          .buttonStyle(PressableButtonStyle())
          .glassSurface(cornerRadius: Radius.card)
        }
      }
      .padding(.vertical, 4)
    }
  }

  private func select(_ city: String) {
    searchFocused = false
    if selectedCity != city {
      selectedCity = city
    }
    dismiss()
  }
}

struct ListOfCitiesView_Previews: PreviewProvider {
  static var previews: some View {
    ListOfCitiesView(selectedCity: .constant("Toronto"), weatherService: WeatherDataService())
  }
}
