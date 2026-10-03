# WeatherApp redesign

A design, information architecture and copy pass. Networking, data models, the meaning of localization keys, and the analysis and quote logic are unchanged. No third-party UI libraries.

The brief's screenshots weren't attached, so the audit below is based on the code at `d918018` rather than on images.

---

## 1. Audit: what looked templated

| Screen | Issue | Why it reads as a template |
| --- | --- | --- |
| Main | Every metric (humidity, wind, UV, visibility, pressure, sunrise, moon, day of year, AQI) sat in its own glass card with an icon | A grid of same-size cards gives everything equal weight. The temperature had to compete with "Day 275". |
| Main | Per-card `.ultraThinMaterial` over a photo | Contrast depended on which part of the image was behind each card. The light parts of clear and snow skies made white text fail. |
| Main | Text shadows on labels | A patch for the contrast problem that made type look muddy. |
| Main | "Explore" tile grid linking to Hourly, Daily, Alerts, Saved Cities, Air Quality | A navigation hub on a screen that should answer "what's the weather?" Daily only had 3 days and hid behind a tap. |
| Main | Bright yellow °C/°F pill in the hero area | The most saturated thing on screen was a setting you change once. |
| Main | Hourly as a long horizontal line | Hard to scan, and no precipitation context. |
| Search sheet | Popular-city chips over a frosted sheet | Chip clouds are a stock search pattern. They wrap badly in Hindi and Gujarati and give no subtitle (region/country). |
| Saved Cities | A separate screen with its own search | Two ways to search for and pick a city. |
| Forecast | Daily rows showing only high/low numbers | No way to compare days at a glance. |
| AQI | Colored badge as the main signal | The color carried the meaning, the yellow band failed contrast, and pollutants had the same weight as the category. |
| Gallery | Rounded, padded tiles over the sky | Decoration with no weather meaning. The sky made photo edges hard to see. |
| Editor | Tool buttons below 44pt, no selected trait | VoiceOver users couldn't tell which tool was active. |
| Contact form | Form over the sky photo, errors shown before typing | Read as a stock form, and it was hostile on first view. |
| Widget | Single family, decorative gradient, fake placeholder numbers | The placeholder looked like real data. |
| Copy | "Stunning", "masterpieces", "effortlessly", "cutting-edge" in the README and gallery copy | Marketing language rather than describing what the app does. |

---

## 2. Information architecture

```
Tab: Weather
  Toolbar: [current location]                    [map] [settings]
  City header (tap → search sheet)
  Alert banner (only if alerts) → Alert detail
  Hero: temperature · condition · high/low · feels like · rain % (if ≥20%)
  Hourly (next 6 hours) → Hourly detail (24 hours)
  3-Day Forecast (inline, range bars)
  Air Quality row → AQI detail
  Conditions: UV, wind, humidity, visibility, pressure
  Sun & Moon: sunrise, sunset, moon phase
  Footer: quote · updated · day of year
Tab: Photos
  Gallery → Editor
Sheets
  Choose a city (search + saved + popular)
  Settings (unit, Contact Us)
```

Why it's ordered this way:

- **Order follows decisions.** "Do I need a coat now?" is answered by the hero. "Will it rain at 4?" by hourly. "What about the weekend?" by daily. Then health (AQI), then details. Alerts come above the hero because they override everything else.
- **Daily is inline, not a link.** The API returns 3 days. A separate screen to show three rows costs a tap for nothing. The "3-Day Forecast" title states the limit honestly, so there's no "10-day" promise.
- **Saved cities live inside the search sheet.** There's one place to pick a city: saved cities when idle, results while typing, a star to save. `SavedCitiesView` was removed.
- **Map is in the toolbar.** It's a secondary view of the same location. **Settings is a sheet** holding the unit and Contact Us. The unit toggle left prime space, and its footer explains that it also switches wind, visibility and pressure.
- **Photos stay a separate tab** so the weather tab has a single job.

### Recommended cuts (not made — your call)

| Candidate | Recommendation | Tradeoff |
| --- | --- | --- |
| Contact Us | Cut, or replace it with a `mailto:` link | There's no backend, so the form only shows a thank-you. Keeping it shows form validation skills in a portfolio, but a user who submits it is misled. |
| Photo gallery + editor | Move to a separate portfolio target, or keep it as-is in its own tab | It isn't related to weather and dilutes the app. It's also the most technically interesting code (PencilKit, Core Image). |
| Day of year | Keep it in the footer only | It's trivia. It was demoted, not removed, because you asked for the feature. |

---

## 3. Design system

Source: `WeatherApp/SharedComponents/DesignSystem/DesignTokens.swift` (`DS`).

### Surfaces

- **Sky + scrim.** The photo is always under a vertical gradient scrim whose strength depends on the scene. All content text is white on this scrim.
- **Plate.** One flat tint per *section*, never per metric. It isn't blurred, so contrast is predictable.
- **Glass.** Only for things that float above content: toolbar items, the city button, state-view actions and sheets. On iOS 26 this is Liquid Glass (`glassEffect(.regular.interactive())`, and system sheets). On iOS 17–25 it's `.thinMaterial` for controls and `.regularMaterial` for sheets.

### Color tokens

| Token | Value | Use |
| --- | --- | --- |
| `onSky` | white | Primary text and glyphs on the sky |
| `onSkySecondary` | white 80% | Labels and section titles (only on a plate or a strong scrim) |
| `separator` | white 18% | Row hairlines |
| `precipitation` | #BDE8FF | Rain % accent, about 8:1 on the plate |
| `plate` | black 30%; navy #1A2133 under Reduce Transparency | Section background |
| `alertFill` | severe #B3261F · moderate #8F5400 · other #1F4FA3 | Alert banner and header; white text ≥ 4.5:1 |
| `aqi(1…6)` | green, yellow, orange, red, purple, maroon (EPA order) | Scale segments and dot. Never the only signal. |
| `temperatureRamp` | blue → mint → yellow → orange | Daily range bars |

Light/dark × sky condition: the weather screen is always on a photo, so it doesn't follow system light/dark. Instead the **scrim** varies by scene and time of day:

| Scene | Scrim (top → bottom max) | Night tint | Particles |
| --- | --- | --- | --- |
| Clear | 0.32 | navy 0.62 | none |
| Clouds | 0.36 | navy 0.62 | none |
| Fog | 0.42 | navy 0.62 | none |
| Rain | 0.15 (the image is already dark) | navy 0.62 | rain, 70% opacity |
| Snow | 0.40 (bright image) | navy 0.62 | snow, 70% opacity |

Settings, Contact Us and the search sheet use system colors, so they follow light and dark mode automatically.

### Type scale

All numeric styles use `.monospacedDigit()`. Section titles keep their source case: there's no uppercase transform, because it does nothing for Indic scripts and widens Spanish and French.

| Token | Font | Use |
| --- | --- | --- |
| Hero | System 96 thin, `@ScaledMetric`, tabular | Current temperature |
| `condition` | Title 3 medium | Condition under the hero |
| `supporting` | Headline regular, tabular | High/Low/Feels like line |
| `sectionTitle` | Subheadline semibold | "Hourly Forecast", "Conditions" |
| `metricLabel` | Subheadline | Row labels |
| `metricValue` | Title 3 medium, tabular | Large values |
| `rowValue` | Body semibold, tabular | Row values, temperatures |
| `rowLabel` | Body | Row text |
| `footnote` | Footnote | Footer |

Tabular figures aren't available in every Devanagari, Gujarati and Gurmukhi font, so layouts never depend on fixed digit widths.

### Spacing and radii

Spacing is on a 4pt grid: `xxs 2 · xs 4 · s 8 · m 12 · l 16 · xl 24 · xxl 32`, with page margins of 20. Radii are: plate 22, inset 14, bar 3. Minimum target is 44pt.

### Component rules

- **Icons are only for weather conditions** (hero, hourly, daily) and system affordances (chevron, star, location). Metric rows have no icons.
- **Precipitation is shown only when it's ≥ 20%** (`WeatherDetailVM.meaningfulPrecipitationThreshold`). Hourly columns reserve the space either way so rows stay aligned.
- **Range bars.** The track spans the 3-day min to max. The filled segment shows the day's low–high, colored from the full-track gradient so equal temperatures always get the same color.
- **Dynamic Type.** At accessibility sizes the hourly strip becomes a list, daily rows wrap onto two lines, and metric rows stack label over value. Nothing truncates. The hero scales down to 50% rather than clipping.
- **Motion.** Particles are hidden under Reduce Motion, and `DS.animation` switches to a 0.12s linear animation.
- **Transparency.** Under Reduce Transparency, plates become opaque navy. Materials and glass follow the system automatically.

---

## 4. Screens

**Main, no alerts.**
- Toolbar: location button, then map and settings.
- City name as a large tappable header.
- Hero.
- Hourly plate: 6 columns showing time, symbol, temp and rain %, with "Now" first.
- 3-Day Forecast plate: day, symbol, low, range bar, high.
- Air Quality row: dot plus category in words, with a chevron.
- Conditions plate.
- Sun & Moon plate.
- Footer.

**Main, with alerts.**
- A severity-colored banner sits between the city header and the hero.
- It shows "Weather Alerts", the event and "Severe severity", and opens the alert detail.
- Severity is written out, so the color isn't the only signal.

**Day/night.**
- `isDay` from the API selects the night tint.
- The hero and condition symbol use the API's day/night icon.

**Clear, rain, snow.** See the scrim table. Rain and snow add particles, which are hidden under Reduce Motion.

**Search sheet.**
- Medium and large detents. Title "Choose a city", system search field, Done.
- Idle sections: "Use current location", "Saved Cities" (swipe or VoiceOver action to remove), "Popular Cities".
- While typing: results with a region subtitle and a star to save.

**Hourly detail.** The next 24 hours as list rows on one plate, in the city's time zone.

**AQI detail.**
- The category is the title in Large Title.
- "Level 2 of 6".
- A 6-segment scale where the current segment is taller and outlined, so position carries the meaning as well as color.
- Source line: "US EPA Air Quality Index".
- A secondary "Pollutants" plate in health order: PM2.5, PM10, O₃, NO₂, SO₂, CO, in µg/m³.

**Alert detail.** Severity header with the effective–expires range, then the description and instructions.

**Gallery.** Edge-to-edge square grid with 2pt gutters and no rounded corners. Failure uses `ContentUnavailableView` with "Try Again".

**Editor.** Unchanged except the tool bar: 44pt targets, `.isSelected` trait, and a system `.bar` background.

**Contact form.** A plain grouped Form on system background. Errors appear only after typing. The success message is "Thanks. Customer support will contact you soon."

**Widgets.**
- Small: city, temperature, symbol, condition.
- Medium: the small layout plus Feels like, Humidity, Wind and UV.
- Both use dark condition gradients and `widgetAccentable` for tinted modes. The placeholder is redacted instead of showing fake data.

---

## 5. States

| State | What the user sees | Notes |
| --- | --- | --- |
| Loading (first load) | Redacted hero and "Loading weather…" | No spinner over a blank sky |
| Loading (refresh with data) | Current data stays visible | |
| Offline / network error | "Can't load weather" · "Check your connection and try again." · **Try Again** | From `URLError` |
| Stale data + error | Data stays, with a one-line notice above the hero | |
| Missing API key | "API key missing" · "Add your WeatherAPI key to config.plist, then relaunch the app." | No button, because a retry can't fix it |
| Invalid key / location not found | "Can't load {city}" · "WeatherAPI didn't recognize this city or your API key. Choose another city or check config.plist." · **Choose a city** | Merged; see tradeoffs |
| No saved cities | Hint text in the Saved Cities section | |
| Forecast limited to 3 days | The title says "3-Day Forecast" (it uses the real count) | No upsell, no empty rows |
| Hourly unavailable | "Forecast unavailable" inside the plate | |
| AQI unavailable | "Air quality unavailable" with a next step | |
| Quote unavailable | The quote line is hidden | Placeholder text would be noise |
| Photos failed | "Couldn't load photos" · **Try Again** | |

---

## 6. Implementation map

| File | Change |
| --- | --- |
| `SharedComponents/DesignSystem/DesignTokens.swift` | **New.** Tokens, `Plate`, `SectionTitle`, `PlateDivider`, `glassControl(in:)`, `sheetBackground()` |
| `Views/WeatherView/Components/WeatherComponents.swift` | **New.** `WeatherHero`, `AlertBanner`, `HourlyStrip`, `HourListRow`, `DailyForecastList`, `TemperatureRangeBar`, `MetricRow`, `WeatherStateView` |
| `SupportingFiles/SkyImageView.swift` | Scene-based scrim, night tint, Reduce Motion particles |
| `WeatherDetailView.swift` | New layout, states and toolbar |
| `WeatherDetailVM.swift` | Presentation-only derived properties (`isDay`, `forecastDays`, `upcomingHours`, `loadIssue`, …) and `weatherError` capture. Fetching is unchanged. |
| `Helper.swift` | `localizedHour`/`localizedWeekday` in the city's time zone; native digits in relative time |
| `ListOfCitiesView.swift` | Unified search + saved + popular sheet |
| `SavedCitiesView.swift` | **Removed** (merged into the sheet) |
| `SettingsView.swift`, `TemperatureUnitToggle.swift` | Form sheet; neutral segmented toggle |
| `HourlyForecastView`, `DailyForecastView`, `AirQualityView`, `WeatherAlertsView` | Rebuilt on the shared components |
| `PhotoGalleryView`, `ToolSwitcherBar`, `ContactUsView`, `ContentView`, `WeatherMapView` | As described in §4 |
| `WeatherWidget*.swift` | Small + medium families |
| `Localizable.xcstrings` | New keys translated into es, fr, hi, gu, pa |
| `WeatherAppUITests.swift` | Contact Us is reached via Settings; the hero is found by the `currentTemperature` identifier |

iOS 26-only APIs are behind `#available(iOS 26.0, *)` with the fallbacks noted above. The deployment target stays at iOS 17.2.

---

## 7. Removed or demoted

| Item | Status | Why |
| --- | --- | --- |
| Explore tile grid | Removed | Its destinations are now inline or reached from their own section titles |
| Per-metric cards and their icons | Removed | One plate per section; hierarchy comes from type |
| Text shadows | Removed | The scrim handles contrast |
| Glass on every surface | Removed | Glass is reserved for controls and sheets |
| Yellow unit pill in the hero | Moved to Settings | You set it once, so it doesn't need prime space |
| Popular-city chips | Replaced by a list section | Wraps cleanly in every language, has subtitles, and shows clear targets |
| `SavedCitiesView` | Removed | Merged into the search sheet |
| Daily forecast link | Demoted to inline | Only 3 days to show |
| Day of year card | Demoted to footer | Trivia |
| Rounded gallery tiles | Removed | Photos are the content |
| Sky behind forms | Removed | Forms use system backgrounds for legibility |
| Widget placeholder data | Replaced with redaction | Fake numbers looked real |

---

## Tradeoffs and open issues

- **Scrim + flat plates vs. glass cards.** You get predictable contrast in every scene. The cost is less of the "frosted" look on the content itself; the glass is kept for the floating layer, where iOS 26 puts it too.
- **20% precipitation threshold.** Below that, rain % is mostly noise. The cost is that a 15% chance isn't shown. The threshold is a single constant if you want to tune it.
- **Unknown city vs. bad API key are one state.** `NetworkService` only throws `invalidResponse`, with no HTTP status. Splitting them would mean changing networking, which is out of scope. The copy names both causes and offers the action that fixes the more common one.
- **The widget always shows °C.** The unit preference isn't in a shared App Group. Fixing this needs an entitlement and a storage change, so it was left as is.
- **Condition text stays English in Gujarati.** WeatherAPI doesn't translate conditions into Gujarati (seen in the simulator; Punjabi wasn't checked). Gujarati AM/PM also stays "AM"/"PM", because that's the CLDR data.
- **Contact form validation.** The name rule (`[A-Za-z]` only, more than 3 characters) rejects non-Latin names, which conflicts with the app's Indic localization. The email hint copy suggests "@" isn't allowed, but the rule accepts it. Both are in `ContactUsVM` (business logic), so they're flagged here rather than changed.
- **The tab bar overlaps content** while scrolling. This is standard iOS 26 behavior for floating tab bars; the last section scrolls clear of it.

---

## 8. Signature: Day Dial + Briefing

There are thousands of weather apps, and most of them lead with a big number. This one leads with **what's about to happen**, then shows the next 24 hours as one object you can read at a glance.

**Briefing** (`DayDial/DayBriefing.swift`): one or two plain sentences, for example "Rain likely from about 4 PM. Take an umbrella."

- The first sentence covers the next 12 hours. In order of priority it says:
  - when rain or snow stops (if it's falling now), or when it starts;
  - otherwise a possible shower;
  - otherwise the temperature trend.
- The second sentence gives at most one piece of advice: alert, then unhealthy air, then umbrella or travel time, then UV, then wind, then feels like.
- The rules are deterministic, localized into all six languages, and unit-tested (`DayBriefingTests`).
- The current hour is never named as a future time. Trend sentences don't say "dry", because current conditions can still read "patchy rain nearby".
- **Apple Intelligence** (`WeatherBriefingService`) only *rewords* the rule text, on iOS 26 devices where the model is available, in English, Spanish or French.
  - A rewrite is thrown away unless it contains exactly the same numbers.
  - When a rewrite is used, the screen labels it "Worded by Apple Intelligence".
  - Tradeoff: the wording is less varied than letting the model write from the raw data, but it can't invent a rain start time.

**Day Dial** (`DayDial/DayDialView.swift`): the next 24 hours as a clock face.

- **Layout:** midnight at the bottom and noon at the top, so daylight arcs over the top like the sun's path.
- **Outer track:** daylight from sunrise to sunset, with a sun or moon marker at the current time in the city.
- **Ring:** 24 hour segments, colored on a *fixed* °C scale, so blue always means cold. Segments fade with distance from now, so the seam behind the marker reads as "23 hours away".
- **Inner ticks:** rain or snow chance, only at 20% or more; length shows the chance.
- **Center:** "Now", the temperature and the condition, or the selected hour.
- **Interaction:**
  - Tap an hour to read it, and tap again to return to now.
  - On iOS 18+, touch and hold, then drag around the ring. This uses a UIKit long press through `UIGestureRecognizerRepresentable`, because a SwiftUI long-press-plus-drag blocks page scrolling. Selection changes give haptic feedback.
- **VoiceOver:** the dial is one adjustable element. Its value is a summary (now, warmest and coolest with times, sunrise and sunset). Swipe up or down to step through hours.
- **Fallback:** until the hourly forecast arrives, the plain temperature hero is shown.

Data note: current conditions and the hourly forecast come from different WeatherAPI endpoints, so the center ("Now 15° Overcast") can briefly disagree with the current hour's forecast (18°, drizzle). The app shows each source as it is rather than mixing them.
