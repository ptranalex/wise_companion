import Foundation

protocol HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

struct URLSessionTransport: HTTPTransport {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw OpenAIClientError.invalidResponse
        }
        return (data, http)
    }
}

enum OpenAIClientError: Error, Equatable {
    case missingAPIKey
    case invalidResponse
    case httpStatus(Int)
    case apiErrorMessage(String)
    case timedOut
    case decodingFailed
    case invalidQuoteJSON(QuoteJSONParser.ParseError)
}

struct OpenAIModelConfig: Equatable {
    let model: String
    let maxOutputTokens: Int
    let temperature: Double

    static func forMode(_ mode: GenerationMode) -> OpenAIModelConfig {
        switch mode {
        case .economy:
            // Balanced + low cost.
            return OpenAIModelConfig(model: "gpt-4o-mini", maxOutputTokens: 180, temperature: 0.7)
        case .premium:
            // Balanced + higher quality (still strictly capped).
            return OpenAIModelConfig(model: "gpt-4o", maxOutputTokens: 220, temperature: 0.7)
        }
    }
}

final class OpenAIClient {
    private let transport: HTTPTransport
    private let baseURL: URL
    private let apiKeyProvider: () throws -> String?

    init(
        transport: HTTPTransport = URLSessionTransport(),
        baseURL: URL = URL(string: "https://api.openai.com")!,
        apiKeyProvider: @escaping () throws -> String?
    ) {
        self.transport = transport
        self.baseURL = baseURL
        self.apiKeyProvider = apiKeyProvider
    }

    func generateDailyQuote(dateKey: String, userPrompt: String, mode: GenerationMode) async throws -> QuoteCachePayload {
        let apiKey = try apiKeyProvider()?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let apiKey, !apiKey.isEmpty else { throw OpenAIClientError.missingAPIKey }

        let config = OpenAIModelConfig.forMode(mode)

        let requestBody = ChatCompletionsRequest(
            model: config.model,
            messages: [
                .init(role: "system", content: OpenAIQuotePrompt.systemPrompt()),
                .init(role: "user", content: OpenAIQuotePrompt.userPrompt(userPrompt: userPrompt, dateKey: dateKey, mode: mode)),
            ],
            temperature: config.temperature,
            max_tokens: config.maxOutputTokens
        )

        var req = URLRequest(url: baseURL.appendingPathComponent("/v1/chat/completions"))
        req.httpMethod = "POST"
        req.timeoutInterval = 20
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            req.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw OpenAIClientError.decodingFailed
        }

        do {
            let (data, http) = try await transport.data(for: req)

            guard (200...299).contains(http.statusCode) else {
                if let apiError = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    throw OpenAIClientError.apiErrorMessage(apiError.error.message)
                }
                throw OpenAIClientError.httpStatus(http.statusCode)
            }

            let decoded: ChatCompletionsResponse
            do {
                decoded = try JSONDecoder().decode(ChatCompletionsResponse.self, from: data)
            } catch {
                throw OpenAIClientError.decodingFailed
            }

            guard let content = decoded.choices.first?.message.content else {
                throw OpenAIClientError.invalidResponse
            }

            do {
                let parsed = try QuoteJSONParser.parse(content)
                return QuoteCachePayload(
                    dateKey: dateKey,
                    mode: mode,
                    quote: parsed.quote,
                    context: parsed.context,
                    createdAt: Date()
                )
            } catch let parseError as QuoteJSONParser.ParseError {
                throw OpenAIClientError.invalidQuoteJSON(parseError)
            } catch {
                throw OpenAIClientError.decodingFailed
            }
        } catch let urlError as URLError where urlError.code == .timedOut {
            throw OpenAIClientError.timedOut
        }
    }
}

// MARK: - Chat Completions wire types

struct ChatCompletionsRequest: Codable, Equatable {
    struct Message: Codable, Equatable {
        let role: String
        let content: String
    }

    let model: String
    let messages: [Message]
    let temperature: Double
    let max_tokens: Int
}

struct ChatCompletionsResponse: Decodable, Equatable {
    struct Choice: Decodable, Equatable {
        struct Message: Decodable, Equatable {
            let content: String
        }
        let message: Message
    }

    let choices: [Choice]
}

struct OpenAIErrorResponse: Decodable, Equatable {
    struct ErrorObject: Decodable, Equatable {
        let message: String
    }
    let error: ErrorObject
}


