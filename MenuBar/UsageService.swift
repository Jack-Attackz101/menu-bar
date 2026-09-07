import Foundation

protocol UsageTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionTransport: UsageTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}

/// Resolves optional env / local config, then demo or live fetch. Never writes keys to UserDefaults.
enum UsageService {
    static let defaultEnvRelativePath = ".config/super-spade/usage.env"
    static let defaultSnapshotRelativePath = ".config/super-spade/usage.json"

    static func refresh(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser,
        now: Date = Date(),
        transport: UsageTransport? = nil
    ) async -> (claude: UsageReading, codex: UsageReading) {
        let envFileURL = homeDirectory.appendingPathComponent(defaultEnvRelativePath)
        let fileMap = readString(envFileURL).map { UsageKeyResolver.parseEnvFile($0) } ?? [:]
        let credentials = UsageKeyResolver.resolve(environment: environment, fileMap: fileMap)

        let snapshotURL: URL
        if let custom = credentials.snapshotPath, !custom.isEmpty {
            snapshotURL = URL(fileURLWithPath: custom)
        } else {
            snapshotURL = homeDirectory.appendingPathComponent(defaultSnapshotRelativePath)
        }
        let snapshot = readData(snapshotURL).flatMap { UsageSnapshot.parse(data: $0) }

        if credentials.forceEmpty || credentials.forceDemo {
            return UsageStore.readings(credentials: credentials, snapshot: snapshot, now: now)
        }

        if snapshot != nil, credentials.claudeKey == nil, credentials.codexKey == nil {
            return UsageStore.readings(credentials: credentials, snapshot: snapshot, now: now)
        }

        let shouldFetchClaude = credentials.claudeKey != nil
        let shouldFetchCodex = credentials.codexKey != nil
        if !shouldFetchClaude, !shouldFetchCodex {
            return UsageStore.readings(credentials: credentials, snapshot: snapshot, now: now)
        }

        let hop = transport ?? URLSessionTransport()
        var claudeKind: UsageHTTP?
        var claudeUsed: Double?
        var codexKind: UsageHTTP?
        var codexUsed: Double?
        if let key = credentials.claudeKey {
            let result = await fetch(
                request: anthropicRequest(key: key, now: now),
                transport: hop
            )
            claudeKind = result.0
            claudeUsed = result.1
        }
        if let key = credentials.codexKey {
            let result = await fetch(
                request: openAIRequest(key: key, now: now),
                transport: hop
            )
            codexKind = result.0
            codexUsed = result.1
        }
        return UsageStore.readings(
            credentials: credentials,
            snapshot: snapshot,
            fetch: (claude: claudeKind, claudeUsed: claudeUsed, codex: codexKind, codexUsed: codexUsed),
            now: now
        )
    }

    static func anthropicRequest(key: String, now: Date) -> URLRequest {
        let end = now
        let start = now.addingTimeInterval(-86_400)
        var components = URLComponents(string: "https://api.anthropic.com/v1/organizations/usage_report/messages")!
        components.queryItems = [
            URLQueryItem(name: "starting_at", value: ISO8601DateFormatter().string(from: start)),
            URLQueryItem(name: "ending_at", value: ISO8601DateFormatter().string(from: end))
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 8
        return request
    }

    static func openAIRequest(key: String, now: Date) -> URLRequest {
        let start = Int(now.addingTimeInterval(-86_400).timeIntervalSince1970)
        var components = URLComponents(string: "https://api.openai.com/v1/organization/usage/completions")!
        components.queryItems = [
            URLQueryItem(name: "start_time", value: String(start)),
            URLQueryItem(name: "bucket_width", value: "1d")
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 8
        return request
    }

    private static func fetch(
        request: URLRequest,
        transport: UsageTransport
    ) async -> (UsageHTTP, Double?) {
        do {
            let (data, response) = try await transport.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            let kind = UsageHTTP.classifyStatus(code)
            return (kind, UsageHTTP.usedFraction(fromJSON: data))
        } catch {
            return (.unavailable, nil)
        }
    }

    private static func readString(_ url: URL) -> String? {
        guard let data = readData(url) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func readData(_ url: URL) -> Data? {
        try? Data(contentsOf: url)
    }
}
