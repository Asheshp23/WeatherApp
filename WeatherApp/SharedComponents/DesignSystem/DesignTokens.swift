import SwiftUI

/// Design tokens for the weather experience.
///
/// Rules of use:
/// - Content over the sky is always white text on a *scrimmed* sky (see `SkyImageView`),
///   never per-card blur. Sections sit on a single flat `Plate` so contrast doesn't depend on
///   what the sky image happens to show behind a given card.
/// - Glass (Liquid Glass on iOS 26, materials before) is reserved for controls, toolbars and
///   sheets — the things that float above content.
/// - Hierarchy comes from the type scale, not from boxes or icons.
enum DS {

  // MARK: Spacing (4pt grid)
  enum Space {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    /// Horizontal page margin for scrolling content.
    static let page: CGFloat = 20
  }

  // MARK: Corner radii
  enum Corner {
    /// Section plates on the weather screen.
    static let plate: CGFloat = 22
    /// Banners and inline controls inside a plate.
    static let inset: CGFloat = 14
    /// Range bars and other small shapes.
    static let bar: CGFloat = 3
  }

  // MARK: Layout
  enum Size {
    /// Minimum interactive target (HIG).
    static let minTarget: CGFloat = 44
  }

  // MARK: Colors
  enum Palette {
    /// Primary text and glyphs over the scrimmed sky (always white; the scrim guarantees ≥ 4.5:1).
    static let onSky = Color.white
    /// Secondary text over the sky. 80% white still clears 4.5:1 on the darkest-allowed scrim.
    static let onSkySecondary = Color.white.opacity(0.8)
    /// Hairlines between rows on a plate.
    static let separator = Color.white.opacity(0.18)
    /// Precipitation accent, tuned for white-on-dark contexts (≈ 8:1 on the plate).
    static let precipitation = Color(red: 0.74, green: 0.91, blue: 1.0)

    /// Flat section background. Not blurred — a tint over an already-scrimmed sky.
    static func plate(reduceTransparency: Bool) -> Color {
      reduceTransparency ? Color(red: 0.10, green: 0.13, blue: 0.20) : Color.black.opacity(0.30)
    }

    /// Alert banner fills. White text on each is ≥ 4.5:1.
    static func alertFill(severity: String) -> Color {
      switch severity.lowercased() {
      case "extreme", "severe": return Color(red: 0.70, green: 0.15, blue: 0.12)
      case "moderate": return Color(red: 0.56, green: 0.33, blue: 0.0)
      default: return Color(red: 0.12, green: 0.31, blue: 0.64)
      }
    }

    /// US EPA band colors used for the scale and the dot next to the category word.
    /// Colour is never the only signal — the category is always spelled out.
    static func aqi(_ index: Int) -> Color {
      switch index {
      case 1: return Color(red: 0.30, green: 0.80, blue: 0.40)
      case 2: return Color(red: 0.98, green: 0.85, blue: 0.25)
      case 3: return Color(red: 1.0, green: 0.60, blue: 0.20)
      case 4: return Color(red: 0.95, green: 0.30, blue: 0.30)
      case 5: return Color(red: 0.70, green: 0.40, blue: 0.85)
      default: return Color(red: 0.60, green: 0.20, blue: 0.30)
      }
    }

    /// Cool→warm ramp for daily temperature range bars.
    static let temperatureRamp = Gradient(colors: [
      Color(red: 0.45, green: 0.75, blue: 1.0),
      Color(red: 0.55, green: 0.90, blue: 0.70),
      Color(red: 1.0, green: 0.85, blue: 0.35),
      Color(red: 1.0, green: 0.55, blue: 0.30)
    ])

    /// The daylight arc on the day dial.
    static let daylight = Color(red: 1.0, green: 0.84, blue: 0.42)

    /// Day dial segment colour on a *fixed* °C scale, so blue always means cold and orange
    /// always means hot. (The range bars use a relative scale instead, to compare days.)
    static func temperatureColor(celsius: Double) -> Color {
      let stops: [(celsius: Double, red: Double, green: Double, blue: Double)] = [
        (-5, 0.45, 0.75, 1.0),
        (10, 0.55, 0.90, 0.70),
        (22, 1.0, 0.85, 0.35),
        (32, 1.0, 0.55, 0.30)
      ]
      guard let first = stops.first, let last = stops.last else { return .white }
      if celsius <= first.celsius { return Color(red: first.red, green: first.green, blue: first.blue) }
      if celsius >= last.celsius { return Color(red: last.red, green: last.green, blue: last.blue) }
      for (low, high) in zip(stops, stops.dropFirst()) where celsius <= high.celsius {
        let t = (celsius - low.celsius) / (high.celsius - low.celsius)
        return Color(red: low.red + (high.red - low.red) * t,
                     green: low.green + (high.green - low.green) * t,
                     blue: low.blue + (high.blue - low.blue) * t)
      }
      return Color(red: last.red, green: last.green, blue: last.blue)
    }
  }

  // MARK: Type scale
  /// Every numeric style uses tabular figures so values don't jitter between updates.
  /// Verified with Devanagari, Gujarati and Gurmukhi digits: those fonts don't all ship
  /// tabular figures, so numeric styles never rely on fixed widths — rows use flexible layout.
  enum Typo {
    /// Section titles ("Hourly Forecast", "Conditions"). No uppercase transform — it doesn't
    /// apply to Indic scripts and makes Spanish/French labels much wider.
    static let sectionTitle = Font.subheadline.weight(.semibold)
    static let metricLabel = Font.subheadline
    static let metricValue = Font.title3.weight(.medium).monospacedDigit()
    static let rowValue = Font.body.weight(.semibold).monospacedDigit()
    static let rowLabel = Font.body
    static let condition = Font.title3.weight(.medium)
    static let supporting = Font.headline.weight(.regular).monospacedDigit()
    static let footnote = Font.footnote
  }

  // MARK: Motion
  static func animation(_ reduceMotion: Bool) -> Animation {
    reduceMotion ? .linear(duration: 0.12) : .spring(response: 0.4, dampingFraction: 0.85)
  }
}

// MARK: - Plate

/// The single container style for weather content. Use one plate per *section*, never per metric.
struct Plate<Content: View>: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  var padding: CGFloat = DS.Space.l
  @ViewBuilder var content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 0) { content }
      .padding(padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        DS.Palette.plate(reduceTransparency: reduceTransparency),
        in: RoundedRectangle(cornerRadius: DS.Corner.plate, style: .continuous)
      )
  }
}

/// A section title. Optionally a navigation affordance with a trailing chevron.
struct SectionTitle: View {
  let title: LocalizedStringKey
  var showsChevron = false

  var body: some View {
    HStack(spacing: DS.Space.xs) {
      Text(title)
        .font(DS.Typo.sectionTitle)
      if showsChevron {
        Image(systemName: "chevron.right")
          .font(.footnote.weight(.semibold))
          .accessibilityHidden(true)
      }
      Spacer(minLength: 0)
    }
    .foregroundStyle(DS.Palette.onSkySecondary)
    .accessibilityAddTraits(.isHeader)
  }
}

struct PlateDivider: View {
  var body: some View {
    Rectangle()
      .fill(DS.Palette.separator)
      .frame(height: 1 / UIScreen.main.scale)
      .accessibilityHidden(true)
  }
}

// MARK: - Glass controls

extension View {
  /// Floating controls (city switcher, toolbar-adjacent buttons). Liquid Glass on iOS 26,
  /// a standard material before that; Reduce Transparency is honoured by the system for both.
  @ViewBuilder
  func glassControl<S: Shape>(in shape: S) -> some View {
    if #available(iOS 26.0, *) {
      self.glassEffect(.regular.interactive(), in: shape)
    } else {
      self.background(.thinMaterial, in: shape)
    }
  }

  /// Sheets: on iOS 26 the system applies Liquid Glass automatically, so only set a
  /// background on earlier versions.
  @ViewBuilder
  func sheetBackground() -> some View {
    if #available(iOS 26.0, *) {
      self
    } else {
      self.presentationBackground(.regularMaterial)
    }
  }
}
