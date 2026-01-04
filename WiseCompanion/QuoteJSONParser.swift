import Foundation

enum QuoteJSONParser {
    struct Output: Codable, Equatable {
        let quote: String
        let context: String
    }

    enum ParseError: Error, Equatable {
        case empty
        case couldNotFindJSONObject
        case decodingFailed
        case missingFields
    }

    static func parse(_ rawModelContent: String) throws -> Output {
        let trimmed = rawModelContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ParseError.empty }

        // Some models may wrap JSON in ```json fences. Strip common fencing first.
        let unfenced = stripCodeFences(trimmed)

        // As a fallback, extract the first {...} span.
        guard let jsonString = extractFirstJSONObjectString(unfenced) else {
            throw ParseError.couldNotFindJSONObject
        }

        guard let data = jsonString.data(using: .utf8) else { throw ParseError.decodingFailed }

        do {
            let decoded = try JSONDecoder().decode(Output.self, from: data)
            let quote = decoded.quote.trimmingCharacters(in: .whitespacesAndNewlines)
            let context = decoded.context.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !quote.isEmpty, !context.isEmpty else { throw ParseError.missingFields }
            return Output(quote: quote, context: context)
        } catch {
            throw ParseError.decodingFailed
        }
    }

    private static func stripCodeFences(_ s: String) -> String {
        var out = s
        if out.hasPrefix("```") {
            // Remove first line fence and trailing fence if present.
            if let firstNewline = out.firstIndex(of: "\n") {
                out = String(out[out.index(after: firstNewline)...])
            }
            if let closingRange = out.range(of: "```", options: .backwards) {
                out = String(out[..<closingRange.lowerBound])
            }
        }
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractFirstJSONObjectString(_ s: String) -> String? {
        guard let start = s.firstIndex(of: "{"), let end = s.lastIndex(of: "}") else { return nil }
        guard start < end else { return nil }
        return String(s[start...end])
    }
}


