import SwiftUI

/// The app's signature view: the next 24 hours as a clock face.
///
/// Midnight is at the bottom and noon at the top, so daylight arcs over the top like the sun's path.
/// - Outer arc: daylight, sunrise to sunset.
/// - Ring: one segment per hour, coloured by temperature on a fixed scale.
/// - Inner ticks: rain or snow chance, only where it's meaningful.
/// - Sun or moon marker: now.
///
/// Tap an hour, or touch and hold then drag (iOS 18+), to read it. VoiceOver users swipe up or down
/// to step through hours.
struct DayDialView: View {
  let model: DayDialModel

  @State private var selectedIndex: Int?
  @ScaledMetric(relativeTo: .largeTitle) private var temperatureSize: CGFloat = 64

  var body: some View {
    GeometryReader { proxy in
      let side = min(proxy.size.width, proxy.size.height)
      ZStack {
        Canvas { context, size in
          draw(in: &context, size: size)
        }
        centerLabel
          .frame(width: side * 0.44)
      }
      .frame(width: side, height: side)
      .contentShape(Circle())
      // Taps never compete with scrolling, so tap-to-inspect works on every iOS version.
      .onTapGesture { location in toggleSelection(at: location, side: side) }
      .modifier(ScrubModifier { location in
        if let location { select(at: location, side: side) } else { selectedIndex = nil }
      })
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .aspectRatio(1, contentMode: .fit)
    .frame(maxWidth: 360)
    .frame(maxWidth: .infinity)
    .sensoryFeedback(.selection, trigger: selectedIndex)
    .onChange(of: model.hours.first?.epoch) { _, _ in selectedIndex = nil }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text("Next 24 hours"))
    .accessibilityValue(Text(accessibilityValue))
    .accessibilityHint(Text("Swipe up or down to hear each hour."))
    .accessibilityAdjustableAction { direction in
      switch direction {
      case .increment:
        selectedIndex = min((selectedIndex ?? -1) + 1, model.hours.count - 1)
      case .decrement:
        if let selectedIndex { self.selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : nil }
      @unknown default:
        break
      }
    }
    .accessibilityIdentifier("currentTemperature")
  }

  private var selectedHour: DialHour? {
    selectedIndex.flatMap { model.hours.indices.contains($0) ? model.hours[$0] : nil }
  }

  // MARK: Center

  private var centerLabel: some View {
    VStack(spacing: DS.Space.xxs) {
      if let selectedHour, let selectedIndex {
        Text(hourLabel(selectedHour, index: selectedIndex))
          .font(DS.Typo.sectionTitle)
          .foregroundStyle(DS.Palette.onSkySecondary)
        temperatureText(selectedHour.displayTemperature)
        if selectedHour.precipitationChance >= WeatherDetailVM.meaningfulPrecipitationThreshold {
          Label("\(Helper.localizedNumber(selectedHour.precipitationChance))%",
                systemImage: selectedHour.isSnow ? "snowflake" : "drop.fill")
            .font(DS.Typo.supporting)
            .foregroundStyle(DS.Palette.precipitation)
        } else {
          Image(systemName: selectedHour.conditionSymbol)
            .symbolRenderingMode(.multicolor)
            .font(.title3)
        }
      } else {
        Text("Now")
          .font(DS.Typo.sectionTitle)
          .foregroundStyle(DS.Palette.onSkySecondary)
        temperatureText(model.currentTemperature)
        Label {
          Text(model.conditionText)
        } icon: {
          Image(systemName: model.conditionSymbol)
            .symbolRenderingMode(.multicolor)
        }
        .font(.subheadline.weight(.medium))
        .lineLimit(2)
      }
    }
    .multilineTextAlignment(.center)
    .minimumScaleFactor(0.5)
    .foregroundStyle(DS.Palette.onSky)
  }

  private func temperatureText(_ value: String) -> some View {
    Text(value)
      .font(.system(size: temperatureSize, weight: .thin))
      .monospacedDigit()
      .lineLimit(1)
      .minimumScaleFactor(0.4)
      .contentTransition(.numericText())
  }

  private func hourLabel(_ hour: DialHour, index: Int) -> String {
    index == 0 ? String(localized: "Now") : Helper.localizedHour(hour.epoch, timeZone: model.timeZone)
  }

  // MARK: Drawing

  /// Midnight at the bottom, then clockwise: 6 on the left, noon at the top, 18 on the right.
  private static func angle(_ dayFraction: Double) -> Angle {
    .degrees(90 + dayFraction * 360)
  }

  private static func point(_ center: CGPoint, _ radius: CGFloat, _ angle: Angle) -> CGPoint {
    CGPoint(x: center.x + radius * cos(angle.radians), y: center.y + radius * sin(angle.radians))
  }

  private func arc(_ center: CGPoint, _ radius: CGFloat, from start: Double, to end: Double) -> Path {
    var path = Path()
    // `clockwise: false` draws visually clockwise in SwiftUI's flipped coordinate space.
    path.addArc(center: center, radius: radius, startAngle: Self.angle(start), endAngle: Self.angle(end), clockwise: false)
    return path
  }

  private func draw(in context: inout GraphicsContext, size: CGSize) {
    let half = min(size.width, size.height) / 2
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    let daylightRadius = half - 10
    let ringRadius = half * 0.80
    let ringWidth = half * 0.13
    let tickOuter = ringRadius - ringWidth / 2 - 5
    let tickMax = half * 0.11
    let labelRadius = half * 0.56

    // Daylight arc over a faint night track.
    context.stroke(Path(ellipseIn: CGRect(x: center.x - daylightRadius, y: center.y - daylightRadius,
                                          width: daylightRadius * 2, height: daylightRadius * 2)),
                   with: .color(.white.opacity(0.15)), lineWidth: 3)
    if let sunrise = model.sunriseFraction, let sunset = model.sunsetFraction, sunset > sunrise {
      context.stroke(arc(center, daylightRadius, from: sunrise, to: sunset),
                     with: .color(DS.Palette.daylight), style: StrokeStyle(lineWidth: 4, lineCap: .round))
    }

    // Temperature segments with a hairline gap between hours.
    let gap = 0.6 / 360
    for (index, hour) in model.hours.enumerated() {
      let start = Double(hour.hourOfDay) / 24 + gap
      let end = Double(hour.hourOfDay + 1) / 24 - gap
      let isSelected = index == selectedIndex
      // Fade with distance from now, so the seam behind the marker reads as "23 hours away".
      let distanceFade = 1 - 0.45 * Double(index) / Double(max(model.hours.count - 1, 1))
      let opacity = selectedIndex != nil && !isSelected ? 0.4 : distanceFade
      context.stroke(arc(center, ringRadius, from: start, to: end),
                     with: .color(DS.Palette.temperatureColor(celsius: hour.temperatureC).opacity(opacity)),
                     lineWidth: isSelected ? ringWidth * 1.35 : ringWidth)

      // Precipitation ticks, length proportional to chance.
      if hour.precipitationChance >= WeatherDetailVM.meaningfulPrecipitationThreshold {
        let middle = Self.angle((Double(hour.hourOfDay) + 0.5) / 24)
        let length = max(tickMax * 0.35, tickMax * CGFloat(hour.precipitationChance) / 100)
        var tick = Path()
        tick.move(to: Self.point(center, tickOuter, middle))
        tick.addLine(to: Self.point(center, tickOuter - length, middle))
        context.stroke(tick, with: .color(hour.isSnow ? .white : DS.Palette.precipitation),
                       style: StrokeStyle(lineWidth: 4, lineCap: .round))
      }
    }

    // Quarter-day labels in the city's local time.
    for hour in model.hours where hour.hourOfDay % 6 == 0 {
      let label = Text(Helper.localizedHour(hour.epoch, timeZone: model.timeZone))
        .font(.caption.weight(.semibold))
        .foregroundStyle(DS.Palette.onSky)
      context.draw(label, at: Self.point(center, labelRadius, Self.angle(Double(hour.hourOfDay) / 24)))
    }

    // Selected hour hand.
    if let selectedHour {
      let angle = Self.angle((Double(selectedHour.hourOfDay) + 0.5) / 24)
      var hand = Path()
      hand.move(to: Self.point(center, tickOuter - tickMax - 4, angle))
      hand.addLine(to: Self.point(center, daylightRadius, angle))
      context.stroke(hand, with: .color(.black.opacity(0.35)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
      context.stroke(hand, with: .color(.white), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
    }

    // Now: a sun or moon riding the outer track.
    let nowAngle = Self.angle(model.nowFraction)
    let nowPoint = Self.point(center, daylightRadius, nowAngle)
    let markerRadius: CGFloat = 13
    context.fill(Path(ellipseIn: CGRect(x: nowPoint.x - markerRadius, y: nowPoint.y - markerRadius,
                                        width: markerRadius * 2, height: markerRadius * 2)),
                 with: .color(Color(red: 0.10, green: 0.13, blue: 0.20).opacity(selectedIndex == nil ? 0.9 : 0.6)))
    var marker = context.resolve(Image(systemName: model.isDay ? "sun.max.fill" : "moon.fill"))
    marker.shading = .color(model.isDay ? DS.Palette.daylight : .white)
    context.draw(marker, in: CGRect(x: nowPoint.x - 8, y: nowPoint.y - 8, width: 16, height: 16))
  }

  // MARK: Interaction

  /// Tapping an hour shows it; tapping it again, or the middle, goes back to now.
  private func toggleSelection(at location: CGPoint, side: CGFloat) {
    let previous = selectedIndex
    select(at: location, side: side)
    if selectedIndex == previous || hypot(location.x - side / 2, location.y - side / 2) <= side * 0.15 {
      selectedIndex = nil
    }
  }

  private func select(at location: CGPoint, side: CGFloat) {
    let dx = location.x - side / 2
    let dy = location.y - side / 2
    // Ignore the middle, where the angle is meaningless.
    guard hypot(dx, dy) > side * 0.15 else { return }
    let degrees = atan2(dy, dx) * 180 / .pi
    var fraction = (degrees - 90) / 360
    fraction -= floor(fraction)
    let hourOfDay = Int(fraction * 24) % 24
    if let index = model.hours.firstIndex(where: { $0.hourOfDay == hourOfDay }), index != selectedIndex {
      selectedIndex = index
    }
  }

  // MARK: Accessibility

  private var accessibilityValue: String {
    if let selectedHour, let selectedIndex {
      return hourDescription(selectedHour, index: selectedIndex)
    }
    return summary
  }

  private func hourDescription(_ hour: DialHour, index: Int) -> String {
    let time = hourLabel(hour, index: index)
    guard hour.precipitationChance >= WeatherDetailVM.meaningfulPrecipitationThreshold else {
      return String(format: String(localized: "dial_hour", defaultValue: "%1$@, %2$@"), time, hour.displayTemperature)
    }
    let chance = "\(Helper.localizedNumber(hour.precipitationChance))%"
    let format = hour.isSnow
      ? String(localized: "dial_hour_snow", defaultValue: "%1$@, %2$@, %3$@ chance of snow")
      : String(localized: "dial_hour_rain", defaultValue: "%1$@, %2$@, %3$@ chance of rain")
    return String(format: format, time, hour.displayTemperature, chance)
  }

  private var summary: String {
    var parts = [String(format: String(localized: "dial_summary_now", defaultValue: "Now %1$@, %2$@."),
                        model.currentTemperature, model.conditionText)]
    if let warmest = model.hours.max(by: { $0.temperatureC < $1.temperatureC }),
       let coolest = model.hours.min(by: { $0.temperatureC < $1.temperatureC }) {
      parts.append(String(format: String(localized: "dial_summary_range",
                                         defaultValue: "Warmest %1$@ at %2$@, coolest %3$@ at %4$@."),
                          warmest.displayTemperature, Helper.localizedHour(warmest.epoch, timeZone: model.timeZone),
                          coolest.displayTemperature, Helper.localizedHour(coolest.epoch, timeZone: model.timeZone)))
    }
    if let sunrise = model.sunriseText, let sunset = model.sunsetText {
      parts.append(String(format: String(localized: "dial_summary_sun", defaultValue: "Sunrise %1$@, sunset %2$@."),
                          sunrise, sunset))
    }
    return parts.joined(separator: " ")
  }
}

// MARK: - Preview

extension DayDialModel {
  static let preview: DayDialModel = {
    let start = 1_791_000_000 - 1_791_000_000 % 3600
    let temps: [Double] = [17, 18, 19, 20, 21, 20, 18, 16, 15, 14, 13, 13, 12, 12, 11, 11, 11, 12, 13, 14, 15, 16, 16, 17]
    let rain = [0, 0, 10, 25, 60, 80, 70, 40, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    let hours = (0..<24).map { index in
      DialHour(epoch: start + index * 3600, hourOfDay: (14 + index) % 24, temperatureC: temps[index],
               displayTemperature: "\(Int(temps[index]))°", precipitationChance: rain[index], isSnow: false,
               conditionSymbol: rain[index] >= 50 ? "cloud.heavyrain.fill" : "cloud.sun.fill")
    }
    return DayDialModel(hours: hours, nowFraction: 14.4 / 24, sunriseFraction: 6.97 / 24, sunsetFraction: 18.68 / 24,
                        isDay: true, currentTemperature: "17°", conditionText: "Partly cloudy",
                        conditionSymbol: "cloud.sun.fill", sunriseText: "6:58 AM", sunsetText: "6:41 PM",
                        // `start` falls on 04:00 UTC, so +10h makes it 14:00 to match `hourOfDay`.
                        timeZone: TimeZone(secondsFromGMT: 10 * 3600))
  }()
}

#Preview {
  ZStack {
    SkyImageView(weatherCondition: .partlyCloudy)
    DayDialView(model: .preview)
      .padding(DS.Space.page)
  }
}

// MARK: - Scrubbing

/// Touch-and-hold, then drag around the ring to read hours.
///
/// A SwiftUI `LongPressGesture` sequenced before a `DragGesture` claims every touch inside a
/// `ScrollView`, so swipes that start on the dial wouldn't scroll the page. A UIKit long press
/// fails as soon as the finger moves before the delay, which leaves normal swipes to the scroll view.
/// It needs iOS 18; on iOS 17 the dial is tap-to-inspect only.
private struct ScrubModifier: ViewModifier {
  let onChange: (CGPoint?) -> Void

  func body(content: Content) -> some View {
    if #available(iOS 18.0, *) {
      content.gesture(ScrubRecognizer(onChange: onChange))
    } else {
      content
    }
  }
}

@available(iOS 18.0, *)
private struct ScrubRecognizer: UIGestureRecognizerRepresentable {
  let onChange: (CGPoint?) -> Void

  func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
    let recognizer = UILongPressGestureRecognizer()
    recognizer.minimumPressDuration = 0.25
    return recognizer
  }

  func handleUIGestureRecognizerAction(_ recognizer: UILongPressGestureRecognizer, context: Context) {
    switch recognizer.state {
    case .began, .changed:
      onChange(context.converter.location(in: .local))
    default:
      onChange(nil)
    }
  }
}
