import Foundation

struct QuoteCachePayload: Codable, Equatable {
    var dateKey: String
    var mode: GenerationMode
    var quote: String
    var context: String
    var createdAt: Date
}


