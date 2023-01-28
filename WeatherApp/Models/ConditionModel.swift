import Foundation

struct ConditionModel: Codable {
  let text: String
  let icon: String
  let code: Int

  enum CodingKeys: String, CodingKey {
    case text = "text"
    case icon = "icon"
    case code = "code"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    text = try values.decode(String.self, forKey: .text)
    icon = try values.decode(String.self, forKey: .icon)
    code = try values.decode(Int.self, forKey: .code)
  }

  init() {
    text = ""
    icon = ""
    code = 0
  }
}

