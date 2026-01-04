import XCTest
@testable import WiseCompanion

final class OpenAIClientTests: XCTestCase {
    func test_generateDailyQuote_success_parsesJSONContent() async throws {
        let transport = MockTransport { _ in
            let body = """
            {
              "choices": [
                { "message": { "content": "{\\"quote\\":\\"q\\",\\"context\\":\\"c\\"}" } }
              ]
            }
            """
            return (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }

        let client = OpenAIClient(transport: transport, baseURL: URL(string: "https://api.openai.com")!) {
            "sk-test"
        }

        let payload = try await client.generateDailyQuote(dateKey: "2026-01-04", userPrompt: "", mode: .economy)
        XCTAssertEqual(payload.dateKey, "2026-01-04")
        XCTAssertEqual(payload.mode, .economy)
        XCTAssertEqual(payload.quote, "q")
        XCTAssertEqual(payload.context, "c")
    }

    func test_generateDailyQuote_missingKey_throws() async {
        let transport = MockTransport { _ in
            XCTFail("Should not hit network without API key")
            return (Data(), HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }

        let client = OpenAIClient(transport: transport, baseURL: URL(string: "https://api.openai.com")!) {
            nil
        }

        do {
            _ = try await client.generateDailyQuote(dateKey: "2026-01-04", userPrompt: "", mode: .economy)
            XCTFail("Expected missingAPIKey")
        } catch let e as OpenAIClientError {
            XCTAssertEqual(e, .missingAPIKey)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_generateDailyQuote_httpError_decodesOpenAIMessage() async {
        let transport = MockTransport { _ in
            let body = """
            { "error": { "message": "bad key" } }
            """
            return (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!)
        }

        let client = OpenAIClient(transport: transport, baseURL: URL(string: "https://api.openai.com")!) {
            "sk-bad"
        }

        do {
            _ = try await client.generateDailyQuote(dateKey: "2026-01-04", userPrompt: "", mode: .economy)
            XCTFail("Expected apiErrorMessage")
        } catch let e as OpenAIClientError {
            XCTAssertEqual(e, .apiErrorMessage("bad key"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_generateDailyQuote_invalidJSONContent_mapsError() async {
        let transport = MockTransport { _ in
            let body = """
            { "choices": [ { "message": { "content": "not json" } } ] }
            """
            return (Data(body.utf8), HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }

        let client = OpenAIClient(transport: transport, baseURL: URL(string: "https://api.openai.com")!) {
            "sk-test"
        }

        do {
            _ = try await client.generateDailyQuote(dateKey: "2026-01-04", userPrompt: "", mode: .economy)
            XCTFail("Expected invalidQuoteJSON")
        } catch let e as OpenAIClientError {
            if case .invalidQuoteJSON = e {
                // ok
            } else {
                XCTFail("Unexpected mapped error: \(e)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_generateDailyQuote_timeout_mapsError() async {
        let transport = MockTransport { _ in
            throw URLError(.timedOut)
        }

        let client = OpenAIClient(transport: transport, baseURL: URL(string: "https://api.openai.com")!) {
            "sk-test"
        }

        do {
            _ = try await client.generateDailyQuote(dateKey: "2026-01-04", userPrompt: "", mode: .economy)
            XCTFail("Expected timedOut")
        } catch let e as OpenAIClientError {
            XCTAssertEqual(e, .timedOut)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private final class MockTransport: HTTPTransport {
    typealias Handler = (URLRequest) throws -> (Data, HTTPURLResponse)
    private let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        try handler(request)
    }
}


