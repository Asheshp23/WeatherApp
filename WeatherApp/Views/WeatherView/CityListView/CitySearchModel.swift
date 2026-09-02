import Foundation

@MainActor
@Observable
final class CitySearchModel {
  enum Phase: Equatable {
    case idle
    case searching
    case results([CitySearchResult])
    case empty
    case failed
  }

  private(set) var phase: Phase = .idle

  private let service: any WeatherServiceProtocol
  private static let debounce: Duration = .milliseconds(300)
  private static let minimumQueryLength = 2

  init(service: any WeatherServiceProtocol) {
    self.service = service
  }

  /// Driven by `.task(id:)`. SwiftUI cancels the previous invocation before
  /// starting a new one, and on disappear — so this owns no Task handles.
  func search(_ rawQuery: String) async {
    let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)

    guard query.count >= Self.minimumQueryLength else {
      phase = .idle
      return
    }

    do { try await Task.sleep(for: Self.debounce) } catch { return }

    phase = .searching
    do {
      let results = try await service.searchCities(matching: query)
      guard !Task.isCancelled else { return }
      phase = results.isEmpty ? .empty : .results(results)
    } catch is CancellationError {
      return
    } catch let error as URLError where error.code == .cancelled {
      return
    } catch {
      guard !Task.isCancelled else { return }
      phase = .failed
    }
  }
}
