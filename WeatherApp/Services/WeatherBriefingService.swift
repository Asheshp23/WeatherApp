import Foundation
import FoundationModels

protocol WeatherBriefingServiceProtocol: Sendable {
  /// Returns a more natural wording of `briefing`, or nil to keep the rule-based text.
  func polish(_ briefing: String) async -> String?
}

/// Rephrases the rule-based briefing with the on-device Apple Intelligence model.
///
/// The model only rewords; it never sees raw forecast data, and any rewrite whose numbers differ
/// from the original is thrown away. Tradeoff: the wording is less varied than letting the model
/// write from the data, but it can't invent a rain start time.
struct WeatherBriefingService: WeatherBriefingServiceProtocol {
  // Same language support as the quote: Hindi, Gujarati and Punjabi keep the localized rule text.
  private static let modelSupportedLanguageNames: [String: String] = [
    "en": "English",
    "es": "Spanish",
    "fr": "French"
  ]

  func polish(_ briefing: String) async -> String? {
    guard !briefing.isEmpty else { return nil }
    guard #available(iOS 26.0, *) else { return nil }
    guard SystemLanguageModel.default.availability == .available else { return nil }

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    guard let language = Self.modelSupportedLanguageNames[languageCode] else { return nil }

    let session = LanguageModelSession(
      instructions: """
        You reword weather briefings for a weather app. Reply in \(language) with one or two short, \
        plain sentences, under 25 words in total. Keep every time and number exactly as written. \
        Don't add facts, greetings, emoji or quotation marks.
        """
    )

    do {
      let response = try await session.respond(to: briefing)
      let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
      return Self.preservesFacts(original: briefing, rewrite: text) ? text : nil
    } catch {
      return nil
    }
  }

  /// A rewrite is accepted only if it's short and contains exactly the same numbers as the original.
  static func preservesFacts(original: String, rewrite: String) -> Bool {
    guard !rewrite.isEmpty, rewrite.count <= 220 else { return false }
    return numbers(in: original) == numbers(in: rewrite)
  }

  private static func numbers(in text: String) -> [String] {
    text.split(whereSeparator: { !$0.isNumber }).map(String.init).sorted()
  }
}
