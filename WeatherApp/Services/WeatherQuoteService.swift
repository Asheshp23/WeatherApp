import Foundation
import FoundationModels

protocol WeatherQuoteServiceProtocol: Sendable {
  func generateQuote(cityName: String, condition: String, temperature: String) async -> String
}

/// Generates a short, warm one-line quote about the current weather using the
/// on-device Apple Intelligence model. Falls back to a static quote when the
/// model is unavailable (unsupported device/OS, Apple Intelligence disabled, etc).
struct WeatherQuoteService: WeatherQuoteServiceProtocol {
  func generateQuote(cityName: String, condition: String, temperature: String) async -> String {
    guard #available(iOS 26.0, *) else {
      return Self.fallbackQuote(for: condition)
    }
    guard SystemLanguageModel.default.availability == .available else {
      return Self.fallbackQuote(for: condition)
    }

    let session = LanguageModelSession(
      instructions: "You are a poetic weather companion. Reply with a single short, warm, one-sentence quote inspired by the weather, under 20 words. No preamble, no quotation marks."
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
      "Every kind of weather has its own kind of beauty.",
      "Wherever you go, take the sky with you.",
      "Some days call for sunshine, others for shelter — both are gifts.",
      "The sky is always doing something worth noticing.",
      "No weather lasts forever, so enjoy this moment of it."
    ]
    return quotes[abs(condition.hashValue) % quotes.count]
  }
}
