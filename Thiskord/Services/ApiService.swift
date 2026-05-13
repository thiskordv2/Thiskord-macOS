import Foundation

struct ApiService {
    static let shared = ApiService()
    private let baseURL = URL(string: "https://api.emre-ak.fr/api/")!

    func request<T: Decodable>(
        _ route: String,
        method: String,
        body: Data? = nil,
        token: String? = nil
    ) async throws -> T {
        let data = try await requestData(route, method: method, body: body, token: token)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ApiError.decodingFailed(error)
        }
    }

    func requestData(
        _ route: String,
        method: String,
        body: Data? = nil,
        token: String? = nil
    ) async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent(route))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? ""
            throw ApiError.httpError(statusCode: http.statusCode, message: message)
        }
        return data
    }

    func requestVoid(
        _ route: String,
        method: String,
        body: Data? = nil,
        token: String? = nil
    ) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(route))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? ""
            throw ApiError.httpError(statusCode: http.statusCode, message: message)
        }
    }
}

enum ApiError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case let .httpError(statusCode, message):
            if message.isEmpty {
                return "Server error (\(statusCode))."
            }
            return "Server error (\(statusCode)): \(message)"
        case let .decodingFailed(error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
