import Foundation

enum UsageSource: String, Equatable, Sendable {
    case live
    case stub
    case missingKey
}

/// One row of the Claude / Codex dual meter. Not CPU.
struct UsageReading: Equatable, Sendable {
    var label: String
    var fraction: Double
    var source: UsageSource
    var caption: String

    static func clampFraction(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

enum UsageStore {
    static func readings(
        claudeKey: String? = nil,
        codexKey: String? = nil
    ) -> (claude: UsageReading, codex: UsageReading) {
        (
            meter(
                label: "Claude",
                key: claudeKey,
                stubFraction: 0.42
            ),
            meter(
                label: "Codex",
                key: codexKey,
                stubFraction: 0.28
            )
        )
    }

    static func readingsFromEnvironment(
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> (claude: UsageReading, codex: UsageReading) {
        readings(
            claudeKey: firstKey(environment["ANTHROPIC_API_KEY"]),
            codexKey: firstKey(environment["OPENAI_API_KEY"])
        )
    }

    private static func firstKey(_ values: String?...) -> String? {
        guard let matched = values.first(where: { candidate in
            guard let candidate else { return false }
            return !candidate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }), let key = matched else {
            return nil
        }
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func meter(label: String, key: String?, stubFraction: Double) -> UsageReading {
        if let key, !key.isEmpty {
            // Personal keys are not org-admin usage keys. Show a labeled stub, not a fake live %.
            return UsageReading(
                label: label,
                fraction: UsageReading.clampFraction(stubFraction),
                source: .stub,
                caption: "key present · usage API not wired"
            )
        }
        return UsageReading(
            label: label,
            fraction: 0,
            source: .missingKey,
            caption: "no API key · stub"
        )
    }
}
