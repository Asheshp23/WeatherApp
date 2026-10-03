# WeatherApp

WeatherApp is a SwiftUI weather app for iOS 17 and later. It shows current conditions, an hourly and 3-day forecast, air quality and alerts for any city, and uses Liquid Glass on iOS 26. See [Docs/Redesign.md](Docs/Redesign.md) for the design system and the reasoning behind the layout.

Key Features:

- Day Dial: The next 24 hours as a clock face — daylight arc, hour-by-hour temperature colors, rain ticks and a sun/moon marker for now. Tap or touch-and-hold to read any hour; fully VoiceOver-adjustable.
- Briefing: One plain sentence about what's coming ("Rain likely from about 4 PM. Take an umbrella."), worked out from the forecast and optionally reworded by Apple Intelligence without changing any facts.
- Real-time Weather Updates: Get accurate temperature information for any selected city with just a tap.
- Condition-Aware Sky: The background scene (clear, clouds, fog, rain, snow) and particle effects adapt to the current weather condition, day or night.
- Weather Details at a Glance: Humidity, wind, UV index, visibility, and pressure are all shown alongside the current conditions.
- Sun & Moon: Today's sunrise and sunset times, plus the current moon phase (with matching SF Symbol) and illumination percentage.
- Day of the Year: A quick "Day 275 of 365" card on the main screen.
- Apple Intelligence Weather Quote: A short, poetic one-line quote about the current weather, generated on-device with the Foundation Models framework. Falls back to a curated, localized quote on devices without Apple Intelligence.
- Air Quality: The US EPA category in words, its position on a 6-level scale, and a breakdown of PM2.5, PM10, O₃, NO₂, SO₂ and CO.
- City Search and Saved Cities: One sheet with live autocomplete (backed by WeatherAPI), saved cities, popular cities and your current location.
- Temperature Unit: Switch between Celsius and Fahrenheit in Settings. Wind, visibility and pressure units switch too.
- Hourly and 3-Day Forecast: The next hours with rain chance when it's 20% or more, and daily temperature range bars.
- Weather Alerts: Active alerts for the selected location, shown above the forecast with severity in words.
- Contact Us: A form with field validation, in Settings.
- Photo Gallery: A grid of photos you can open in the editor.
- Image Editing: Draw with PencilKit, crop and rotate, add stickers and text, and apply filter presets or adjust brightness, contrast and saturation.
- Save Edited Images: Save edited photos to your photo library.
- Widgets: Small and medium home screen widgets with the current conditions.

## Localization

The app is fully localized using String Catalogs into:

- English
- Spanish
- French
- Hindi
- Gujarati
- Punjabi

Details:

- All UI text, accessibility labels, and permission prompts are translated.
- Weather condition text is requested from WeatherAPI in the user's language.
- Moon phases, AQI categories, and UV levels are mapped to localized names.
- Relative "Updated … ago" times use `RelativeDateTimeFormatter` for correct grammar in every language.
- Numbers and times (temperature, humidity, sunrise/sunset, etc.) are rendered in native digits for Hindi (देवनागरी), Gujarati (ગુજરાતી), and Punjabi (ਗੁਰਮੁਖੀ).
- The Apple Intelligence quote is generated in Spanish/French when active, and uses localized fallback quotes for languages the on-device model doesn't support yet.

To try a language in Xcode: **Product → Scheme → Edit Scheme → Run → Options → App Language**.

## Accessibility

- VoiceOver: labels for icon-only buttons, combined rows/cards so each item is read as one unit, header traits on section titles, and custom announcements for severity and precipitation.
- Dynamic Type: large hero numbers scale with `@ScaledMetric`, and text wraps instead of truncating at larger sizes.
- Contrast: AQI colors, error text, and map labels were adjusted to meet WCAG contrast ratios over the photographic sky backgrounds.

## Requirements

- Xcode 26 or later, iOS 17+ (Apple Intelligence quote requires iOS 26 on a supported device)
- A [WeatherAPI.com](https://www.weatherapi.com) API key in `config.plist` (`API_KEY`). The free plan returns up to 3 forecast days.

## App
https://github.com/Asheshp23/WeatherApp/assets/22404192/e643c07c-be7e-45f6-a0de-19dff10cec5c

## Widget

![Weathr Widget](https://github.com/Asheshp23/WeatherApp/assets/22404192/99ec369a-00fa-471d-9ae3-b805e84f46da)
