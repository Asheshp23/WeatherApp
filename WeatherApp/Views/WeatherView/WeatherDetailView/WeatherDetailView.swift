import SwiftUI
import CoreLocation

/// Main weather screen.
///
/// Order is by what people check first: city → alerts (only when present) → current temperature,
/// condition, today's range → next hours → coming days → air quality → other conditions →
/// sun & moon → quiet footer (updated time, day of year, quote).
struct WeatherDetailView: View {
  @StateObject private var vm: WeatherDetailVM
  @State private var locationManager: LocationManager

  init(locationManager: LocationManager = LocationManager(), prefetchedCity: String? = nil, prefetchedWeather: WeatherModel? = nil) {
    _locationManager = State(wrappedValue: locationManager)
    _vm = StateObject(wrappedValue: WeatherDetailVM(weatherService: WeatherDataService(), initialCity: prefetchedCity, initialWeather: prefetchedWeather))
  }

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy, isDay: vm.isDay)
      content
    }
    .onAppear {
      locationManager.requestLocation()
      if vm.weather == nil && !vm.selectedCity.isEmpty {
        vm.fetchWeather()
      } else {
        vm.loadForecastIfNeeded()
        vm.generateQuoteIfNeeded()
      }
    }
    .onChange(of: vm.selectedCity) { oldValue, newValue in
      handleCityChange(oldValue: oldValue, newValue: newValue)
    }
    .onChange(of: locationManager.location) { oldValue, newValue in
      handleLocationChange(oldValue: oldValue, newValue: newValue)
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) { locationButton }
      ToolbarItemGroup(placement: .topBarTrailing) {
        mapButton
        SettingsButtonView(showSettings: $vm.showSettings)
      }
    }
    .sheet(isPresented: $vm.showCityList) {
      ListOfCitiesView(selectedCity: $vm.selectedCity, weatherService: vm.weatherService) {
        handleLocationButtonTap()
      }
    }
    .sheet(isPresented: $vm.showSettings) {
      SettingsView(tempUnit: $vm.tempUnit)
    }
  }

  // MARK: Content states

  @ViewBuilder
  private var content: some View {
    if vm.weather != nil {
      loadedContent
    } else if let issue = vm.loadIssue, !vm.isLoading {
      ScrollView {
        cityHeader
          .padding(.horizontal, DS.Space.page)
        errorState(for: issue)
          .frame(maxWidth: .infinity)
          .padding(.top, DS.Space.xxl)
      }
      .refreshable { vm.fetchWeather() }
    } else {
      loadingContent
    }
  }

  private var loadingContent: some View {
    VStack(alignment: .leading, spacing: DS.Space.xl) {
      cityHeader
      WeatherHero(temperature: "20°", conditionText: "Partly cloudy", conditionSymbol: "cloud.sun.fill",
                  high: "24°", low: "15°", feelsLike: "20", precipitationChance: nil)
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)
      HStack(spacing: DS.Space.s) {
        SwiftUI.ProgressView().tint(DS.Palette.onSky)
        Text("Loading weather…")
          .font(DS.Typo.footnote)
          .foregroundStyle(DS.Palette.onSkySecondary)
      }
      .accessibilityElement(children: .combine)
      .accessibilityIdentifier("loadingView")
      Spacer()
    }
    .padding(.horizontal, DS.Space.page)
    .padding(.top, DS.Space.s)
  }

  @ViewBuilder
  private func errorState(for issue: WeatherDetailVM.LoadIssue) -> some View {
    switch issue {
    case .missingAPIKey:
      WeatherStateView(symbol: "key.slash",
                       title: "API key missing",
                       message: "Add your WeatherAPI key to config.plist, then relaunch the app.")
    case .rejected:
      WeatherStateView(symbol: "magnifyingglass",
                       title: "Can't load \(vm.selectedCity)",
                       message: "WeatherAPI didn't recognize this city or your API key. Choose another city or check config.plist.",
                       actionTitle: "Choose a city") { vm.handleShowCityListButtonTap() }
    case .offline, .unknown:
      WeatherStateView(symbol: "wifi.slash",
                       title: "Can't load weather",
                       message: "Check your connection and try again.",
                       actionTitle: "Try Again") { vm.fetchWeather() }
    }
  }

  private var loadedContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: DS.Space.xl) {
        cityHeader
        if vm.weatherError != nil {
          staleDataNotice
        }
        if !vm.alerts.isEmpty {
          NavigationLink { WeatherAlertsView(vm: vm) } label: { AlertBanner(alerts: vm.alerts) }
            .buttonStyle(.plain)
            .accessibilityIdentifier("goToAlerts")
        }
        today
          .padding(.bottom, DS.Space.s)
        forecastSections
        airQualityRow
        conditionsSection
        sunMoonSection
        footer
      }
      .padding(.horizontal, DS.Space.page)
      .padding(.top, DS.Space.s)
      .padding(.bottom, DS.Space.xxl)
    }
    .scrollIndicators(.hidden)
    .refreshable { vm.fetchWeather() }
  }

  // MARK: Sections

  /// The signature block: a plain sentence about what's coming, then the next 24 hours as a dial.
  /// Until the hourly forecast arrives, the plain hero shows the current conditions instead.
  @ViewBuilder
  private var today: some View {
    if let dial = vm.dayDialModel {
      VStack(alignment: .leading, spacing: DS.Space.l) {
        if let briefing = vm.briefingText {
          BriefingText(text: briefing, isAIGenerated: vm.isBriefingAIGenerated)
            .animation(.default, value: briefing)
        }
        DayDialView(model: dial)
        TodayFacts(high: vm.todayHighText, low: vm.todayLowText, feelsLike: vm.feelslike,
                   precipitationChance: nil, alignment: .center)
          .frame(maxWidth: .infinity)
      }
      .task(id: vm.ruleBriefing) { await vm.polishBriefing() }
    } else {
      WeatherHero(
        temperature: "\(vm.temperature)°",
        conditionText: vm.conditionText,
        conditionSymbol: vm.conditionSymbolName,
        high: vm.todayHighText,
        low: vm.todayLowText,
        feelsLike: vm.feelslike,
        precipitationChance: vm.meaningfulPrecipitationChance
      )
    }
  }

  private var cityHeader: some View {
    Button(action: vm.handleShowCityListButtonTap) {
      HStack(spacing: DS.Space.s) {
        Text(vm.selectedCity)
          .font(.title2.weight(.semibold))
          .multilineTextAlignment(.leading)
        Image(systemName: "chevron.down")
          .font(.subheadline.weight(.bold))
          .accessibilityHidden(true)
      }
      .foregroundStyle(DS.Palette.onSky)
      .frame(minHeight: DS.Size.minTarget)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("goToCityList")
    .accessibilityLabel(vm.selectedCity)
    .accessibilityHint("Choose a city")
  }

  /// Shown when a refresh failed but older data is still on screen.
  private var staleDataNotice: some View {
    Plate(padding: DS.Space.m) {
      HStack(spacing: DS.Space.m) {
        Image(systemName: "exclamationmark.circle")
          .accessibilityHidden(true)
        Text("Check your connection and try again.")
          .font(DS.Typo.footnote)
        Spacer(minLength: 0)
        Button("Try Again") { vm.fetchWeather() }
          .font(.footnote.weight(.semibold))
          .frame(minHeight: DS.Size.minTarget)
      }
      .foregroundStyle(DS.Palette.onSky)
    }
  }

  @ViewBuilder
  private var forecastSections: some View {
    let hours = vm.upcomingHours(6)
    if !hours.isEmpty {
      Plate {
        NavigationLink { HourlyForecastView(vm: vm) } label: {
          SectionTitle(title: "Hourly Forecast", showsChevron: true)
            .frame(minHeight: DS.Size.minTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("goToHourlyForecast")
        HourlyStrip(hours: hours, tempUnit: vm.tempUnit, timeZone: vm.cityTimeZone)
          .padding(.top, DS.Space.xs)
      }
    } else if vm.isForecastLoading {
      Plate {
        HStack {
          SwiftUI.ProgressView().tint(DS.Palette.onSky)
          Spacer()
        }
        .frame(minHeight: DS.Size.minTarget)
      }
    } else if vm.forecastFailed {
      Plate {
        HStack(spacing: DS.Space.m) {
          Text("Forecast unavailable")
            .font(DS.Typo.rowLabel)
          Spacer(minLength: 0)
          Button("Try Again") { vm.loadForecastIfNeeded() }
            .font(.body.weight(.semibold))
            .frame(minHeight: DS.Size.minTarget)
        }
        .foregroundStyle(DS.Palette.onSky)
      }
    }

    if !vm.forecastDays.isEmpty {
      Plate {
        // The free WeatherAPI plan returns 3 days; the title states the real count instead of
        // promising a week.
        SectionTitle(title: "\(vm.forecastDays.count)-Day Forecast")
          .frame(minHeight: DS.Size.minTarget)
        DailyForecastList(days: vm.forecastDays, tempUnit: vm.tempUnit)
      }
    }
  }

  @ViewBuilder
  private var airQualityRow: some View {
    if let airQuality = vm.airQuality {
      NavigationLink { AirQualityView(vm: vm) } label: {
        Plate(padding: DS.Space.l) {
          HStack(spacing: DS.Space.m) {
            Text("Air Quality")
              .font(DS.Typo.metricLabel)
              .foregroundStyle(DS.Palette.onSkySecondary)
            Spacer(minLength: DS.Space.s)
            Circle()
              .fill(DS.Palette.aqi(airQuality.usEpaIndex))
              .frame(width: 10, height: 10)
              .accessibilityHidden(true)
            Text(airQuality.usEpaCategory)
              .font(DS.Typo.rowValue)
              .multilineTextAlignment(.trailing)
            Image(systemName: "chevron.right")
              .font(.footnote.weight(.semibold))
              .foregroundStyle(DS.Palette.onSkySecondary)
              .accessibilityHidden(true)
          }
          .foregroundStyle(DS.Palette.onSky)
          .frame(minHeight: DS.Size.minTarget)
        }
      }
      .buttonStyle(.plain)
      .accessibilityElement(children: .combine)
      .accessibilityIdentifier("goToAirQuality")
    }
  }

  private var conditionsSection: some View {
    Plate {
      SectionTitle(title: "Conditions")
        .frame(minHeight: DS.Size.minTarget)
      // Ordered by how often each changes what people do: UV and wind first, pressure last.
      MetricRow(label: "UV Index", value: vm.uvIndexText, detail: vm.uvDescription)
      PlateDivider()
      MetricRow(label: "Wind", value: vm.windText)
      PlateDivider()
      MetricRow(label: "Humidity", value: vm.humidityText)
      PlateDivider()
      MetricRow(label: "Visibility", value: vm.visibilityText)
      PlateDivider()
      MetricRow(label: "Pressure", value: vm.pressureText)
    }
  }

  @ViewBuilder
  private var sunMoonSection: some View {
    if vm.todayAstro != nil {
      Plate {
        SectionTitle(title: "Sun & Moon")
          .frame(minHeight: DS.Size.minTarget)
        MetricRow(label: "Sunrise", value: vm.sunriseText)
        PlateDivider()
        MetricRow(label: "Sunset", value: vm.sunsetText)
        PlateDivider()
        MetricRow(label: "Moon Phase", value: vm.moonPhaseText)
      }
    }
  }

  /// Decorative information lives here, deliberately quiet.
  private var footer: some View {
    VStack(alignment: .leading, spacing: DS.Space.s) {
      if !vm.weatherQuote.isEmpty {
        Text("\u{201C}\(vm.weatherQuote)\u{201D}")
          .font(DS.Typo.footnote.italic())
          .fixedSize(horizontal: false, vertical: true)
          .transition(.opacity)
      }
      Text("Updated \(vm.lastUpdatedAt)")
        .font(.caption)
      Text(vm.dayOfYearText)
        .font(.caption)
    }
    .foregroundStyle(DS.Palette.onSkySecondary)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, DS.Space.xs)
  }

  // MARK: Toolbar

  private var locationButton: some View {
    Button(action: handleLocationButtonTap) {
      Image(systemName: vm.isLocationButtonTapped ? "location.fill" : "location")
    }
    .tint(DS.Palette.onSky)
    .accessibilityLabel("Use current location")
  }

  private var mapButton: some View {
    NavigationLink {
      WeatherMapView(cityName: $vm.selectedCity, temperature: vm.temperature,
                     userLocation: vm.isLocationButtonTapped ? vm.userLocation : vm.selectedCityLocation)
    } label: {
      Image(systemName: "map")
    }
    .tint(DS.Palette.onSky)
    .accessibilityLabel("Map")
    .accessibilityIdentifier("goToMapView")
  }

  // MARK: Actions

  private func handleLocationButtonTap() {
    locationManager.requestLocation()
    vm.handleLocationButtonTap()
  }

  private func handleCityChange(oldValue: String, newValue: String) {
    Task {
      if !newValue.isEmpty {
        vm.getLocationFromCityName()
        vm.forecast = nil
        vm.forecastFailed = false
        vm.weatherQuote = ""
        vm.fetchWeather()
      }
    }
  }

  private func handleLocationChange(oldValue: CLLocation?, newValue: CLLocation?) {
    if let newLocation = newValue, vm.isLocationButtonTapped {
      vm.userLocation = newLocation.coordinate
      Task { await vm.handleLocationUpdate(newValue: newLocation) }
    }
  }
}

#Preview {
  NavigationStack {
    WeatherDetailView(prefetchedCity: "Toronto")
  }
}
