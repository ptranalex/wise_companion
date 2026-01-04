import Foundation

enum OpenAIQuotePrompt {
    static func systemPrompt() -> String {
        """
        You are Wise Companion, a calm and concise daily reflection assistant.

        Rules:
        - Produce ONLY original writing. Do NOT quote or attribute real people/books.
        - Avoid clichés, platitudes, and motivational poster language.
        - Keep the quote short and memorable (1–2 sentences).
        - Keep the context practical and grounded (2–4 sentences).
        - No markdown, no bullet lists.

        Output contract:
        - Return ONLY a single JSON object with exactly these string fields:
          {"quote":"...","context":"..."}
        """
    }

    static func userPrompt(userPrompt: String, dateKey: String, mode: GenerationMode) -> String {
        let trimmed = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)

        var lines: [String] = []
        lines.append("Today (local date): \(dateKey)")
        lines.append("Mode: \(mode.displayName)")

        if !trimmed.isEmpty {
            lines.append("User guidance: \(trimmed)")
        } else {
            lines.append("User guidance: (none)")
        }

        lines.append("Generate the daily quote now. Remember: output ONLY the JSON object.")
        return lines.joined(separator: "\n")
    }
}


