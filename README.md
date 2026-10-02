# WeatherApp

WeatherApp is a cutting-edge iOS app crafted using SwiftUI and the latest technologies, delivering real-time weather information for any city of your choice. With a user-friendly interface, it allows you to switch temperature units seamlessly according to your preference.

Key Features:

- Real-time Weather Updates: Get accurate temperature information for any selected city with just a tap.
- Condition-Aware Sky: The background scene (clear, clouds, fog, rain, snow) and particle effects adapt to the current weather condition, day or night.
- Weather Details at a Glance: Humidity, wind, UV index, visibility, and pressure are all shown alongside the current conditions.
- Sun & Moon: Today's sunrise and sunset times, plus the current moon phase (with matching SF Symbol) and illumination percentage.
- Day of the Year: A quick "Day 275 of 365" card on the main screen.
- Apple Intelligence Weather Quote: A short, poetic one-line quote about the current weather, generated on-device with the Foundation Models framework. Falls back to a curated, localized quote on devices without Apple Intelligence.
- Air Quality: US EPA air quality index with a color-coded category badge and a breakdown of CO, NO₂, O₃, SO₂, PM2.5 and PM10.
- Live City Search: A frosted-glass bottom sheet with debounced, real-time city autocomplete (backed by WeatherAPI) and popular-city quick-select chips.
- Animated Temperature Unit Toggle: Switch between Celsius and Fahrenheit with an animated pill toggle and haptic feedback — instantly re-converts every unit shown in the app.
- Hourly & Daily Forecast: A vertical, easy-to-scan hour-by-hour list (with precipitation chance) and a multi-day forecast, both glass-styled and condition-icon driven.
- Weather Alerts: Active weather alerts for the selected location, when issued.
- Saved Cities: Search for and save cities for quick access, with one tap to switch the active location.
- Contact Us Form: Reach out to us effortlessly through the convenient "Contact Us" form for any inquiries or feedback.
- Stunning Photo Gallery: Discover a sleek and captivating photo gallery showcasing beautiful images.
- Creative Image Editing: Draw and doodle with PencilKit, crop and rotate, add stickers and text, and apply filter presets or adjust brightness, contrast, and saturation.
- Save Edited Images: Store your edited masterpieces directly to your device for quick sharing on social media or with friends.
- WeatherApp Widget: Stay updated with a compact widget that displays weather information right on your home screen.

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
