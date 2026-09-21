import Foundation
import FoundationModels

protocol WeatherQuoteServiceProtocol: Sendable {
  func generateQuote(cityName: String, condition: String, temperature: String) async -> String
}

/// Generates a short, warm one-line quote about the current weather using the
/// on-device Apple Intelligence model. Falls back to a static quote when the
/// model is unavailable (unsupported device/OS, Apple Intelligence disabled, etc).
struct WeatherQuoteService: WeatherQuoteServiceProtocol {
  // Languages Apple Intelligence's on-device model can currently generate text in.
  // Hindi/Gujarati/Punjabi aren't supported yet, so those fall back to the
  // (already localized) static quote below rather than risk an English reply
  // despite the rest of the UI being in the user's language.
  private static let modelSupportedLanguageNames: [String: String] = [
    "es": "Spanish",
    "fr": "French"
  ]

  func generateQuote(cityName: String, condition: String, temperature: String) async -> String {
    guard #available(iOS 26.0, *) else {
      return Self.fallbackQuote(for: condition)
    }
    guard SystemLanguageModel.default.availability == .available else {
      return Self.fallbackQuote(for: condition)
    }

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    guard languageCode == "en" || Self.modelSupportedLanguageNames[languageCode] != nil else {
      return Self.fallbackQuote(for: condition)
    }
    let languageInstruction = Self.modelSupportedLanguageNames[languageCode].map { " Reply only in \($0)." } ?? ""

    let session = LanguageModelSession(
      instructions: "You are a poetic weather companion. Reply with a single short, warm, one-sentence quote inspired by the weather, under 20 words. No preamble, no quotation marks.\(languageInstruction)"
    )

    do {
      let prompt = "The weather in \(cityName) right now is \(condition.lowercased()) at \(temperature)°."
      let response = try await session.respond(to: prompt)
      let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
      return text.isEmpty ? Self.fallbackQuote(for: condition) : text
    } catch {
      return Self.fallbackQuote(for: condition)
    }
  }

  private static func fallbackQuote(for condition: String) -> String {
    let quotes = [
      String(localized: "quote_fallback_1", defaultValue: "Every kind of weather has its own kind of beauty."),
      String(localized: "quote_fallback_2", defaultValue: "Wherever you go, take the sky with you."),
      String(localized: "quote_fallback_3", defaultValue: "Some days call for sunshine, others for shelter — both are gifts."),
      String(localized: "quote_fallback_4", defaultValue: "The sky is always doing something worth noticing."),
      String(localized: "quote_fallback_5", defaultValue: "No weather lasts forever, so enjoy this moment of it.")
    ]
    return quotes[abs(condition.hashValue) % quotes.count]
  }
}
