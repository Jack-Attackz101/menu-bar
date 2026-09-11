import Foundation

/// Dual-meter source. Labels stay Claude / Codex — never CPU.
enum UsageSource: String, Equatable, Sendable {
    case empty
    case loading
    case live
    case demo
    case error
}

/// One row of the Claude / Codex dual meter.
struct UsageReading: Equatable, Sendable {
    var label: String
    var fraction: Double
    var source: UsageSource
    var caption: String
    var updatedAt: Date?

    var remainingFraction: Double {
        1 - Self.clampFraction(fraction)
    }

    static func clampFraction(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    func with(source: UsageSource, caption: String? = nil) -> UsageReading {
        var copy = self
        copy.source = source
        if let caption {
            copy.caption = caption
        }
        return copy
    }
}

struct UsageCredentials: Equatable, Sendable {
    var claudeKey: String?
    var codexKey: String?
    var forceDemo: Bool
    var forceEmpty: Bool
    var snapshotPath: String?

    init(
        claudeKey: String? = nil,
        codexKey: String? = nil,
        forceDemo: Bool = false,
        forceEmpty: Bool = false,
        snapshotPath: String? = nil
    ) {
        self.claudeKey = claudeKey
        self.codexKey = codexKey
        self.forceDemo = forceDemo
        self.forceEmpty = forceEmpty
        self.snapshotPath = snapshotPath
    }

    static let empty = UsageCredentials()
}

struct UsageSnapshot: Equatable, Sendable {
    var claudeUsed: Double?
    var codexUsed: Double?
    var updatedAt: Date?

    static func parse(data: Data) -> UsageSnapshot? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return parse(object: obj)
    }

    static func parse(object: [String: Any]) -> UsageSnapshot? {
        let claude = extract(object, key: "claude") ?? extract(object, key: "claudeUsed")
        let codex = extract(object, key: "codex") ?? extract(object, key: "codexUsed")
        var updatedAt: Date?
        if let iso = object["updatedAt"] as? String {
            updatedAt = ISO8601DateFormatter().date(from: iso)
        }
        if claude == nil, codex == nil, updatedAt == nil {
            return nil
        }
        return UsageSnapshot(claudeUsed: claude, codexUsed: codex, updatedAt: updatedAt)
    }

    private static func extract(_ object: [String: Any], key: String) -> Double? {
        if let number = object[key] as? Double {
            return UsageReading.clampFraction(number)
        }
        if let number = object[key] as? Int {
            return UsageReading.clampFraction(Double(number) > 1 ? Double(number) / 100 : Double(number))
        }
        if let nested = object[key] as? [String: Any] {
            if let used = nested["used"] as? Double {
                return UsageReading.clampFraction(used)
            }
            if let used = nested["used"] as? Int {
                return UsageReading.clampFraction(Double(used) > 1 ? Double(used) / 100 : Double(used))
            }
            if let percent = nested["used_percent"] as? Double {
                return UsageReading.clampFraction(percent / 100)
            }
            if let percent = nested["used_percent"] as? Int {
                return UsageReading.clampFraction(Double(percent) / 100)
            }
        }
        return nil
    }
}

enum UsageHTTP: Equatable, Sendable {
    case ok
    case unauthorized
    case unavailable

    static func classifyStatus(_ code: Int) -> UsageHTTP {
        switch code {
        case 200..<300: return .ok
        case 401, 403: return .unauthorized
        default: return .unavailable
        }
    }

    static func usedFraction(fromJSON data: Data) -> Double? {
        guard let value = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return usedFraction(from: value)
    }

    static func usedFraction(from value: Any) -> Double? {
        if let number = value as? Double {
            return UsageReading.clampFraction(number)
        }
        if let number = value as? Int {
            return UsageReading.clampFraction(Double(number) > 1 ? Double(number) / 100 : Double(number))
        }
        guard let object = value as? [String: Any] else { return nil }
        if let number = object["used"] as? Double {
            return UsageReading.clampFraction(number)
        }
        if let number = object["fraction"] as? Double {
            return UsageReading.clampFraction(number)
        }
        if let number = object["used_percent"] as? Double {
            return UsageReading.clampFraction(number / 100)
        }
        if let number = object["used_percent"] as? Int {
            return UsageReading.clampFraction(Double(number) / 100)
        }
        if let nested = object["usage"] {
            return usedFraction(from: nested)
        }
        return nil
    }
}

enum UsageDisplay {
    static func percentUsed(_ fraction: Double) -> String {
        let clamped = UsageReading.clampFraction(fraction)
        return "\(Int((clamped * 100).rounded()))%"
    }

    static func remainingLabel(_ used: Double) -> String {
        let left = 1 - UsageReading.clampFraction(used)
        return "\(Int((left * 100).rounded()))% left"
    }

    static func usageLine(used: Double) -> String {
        "\(percentUsed(used)) used · \(remainingLabel(used))"
    }

    static func lastUpdated(
        _ date: Date?,
        now: Date,
        calendar: Calendar = .current
    ) -> String {
        guard let date else { return "" }
        if now.timeIntervalSince(date) < 10 {
            return "Just now"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if calendar.isDate(date, inSameDayAs: now) {
            formatter.dateFormat = "h:mm a"
            return "Updated \(formatter.string(from: date))"
        }
        formatter.dateFormat = "MMM d"
        return "Updated \(formatter.string(from: date))"
    }

    static func footer(_ reading: UsageReading, now: Date = Date(), calendar: Calendar = .current) -> String {
        let stamp = lastUpdated(reading.updatedAt, now: now, calendar: calendar)
        if stamp.isEmpty {
            return reading.caption
        }
        return "\(reading.caption) · \(stamp)"
    }
}

enum UsageKeyResolver {
    static func firstKey(_ values: String?...) -> String? {
        guard let matched = values.first(where: { candidate in
            guard let candidate else { return false }
            return !candidate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }), let key = matched else {
            return nil
        }
        return key.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func truthy(_ value: String?) -> Bool {
        guard let value else { return false }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed == "1" || trimmed == "true" || trimmed == "yes"
    }

    static func parseEnvFile(_ text: String) -> [String: String] {
        var out: [String: String] = [:]
        for rawLine in text.split(whereSeparator: \.isNewline) {
            let line = String(rawLine).trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#") { continue }
            guard let eq = line.firstIndex(of: "=") else { continue }
            let key = String(line[..<eq]).trimmingCharacters(in: .whitespaces)
            var value = String(line[line.index(after: eq)...]).trimmingCharacters(in: .whitespaces)
            if value.count >= 2 {
                let first = value.first
                let last = value.last
                if (first == "\"" && last == "\"") || (first == "'" && last == "'") {
                    value = String(value.dropFirst().dropLast())
                }
            }
            if !key.isEmpty {
                out[key] = value
            }
        }
        return out
    }

    static func resolve(
        environment: [String: String],
        fileMap: [String: String] = [:]
    ) -> UsageCredentials {
        let merged = fileMap.merging(environment) { _, env in env }
        return UsageCredentials(
            claudeKey: firstKey(
                merged["ANTHROPIC_API_KEY"],
                merged["CLAUDE_API_KEY"],
                merged["CLAUDE_USAGE_KEY"]
            ),
            codexKey: firstKey(
                merged["OPENAI_API_KEY"],
                merged["CODEX_API_KEY"],
                merged["CODEX_USAGE_KEY"]
            ),
            forceDemo: truthy(merged["SUPER_SPADE_USAGE_DEMO"]),
            forceEmpty: truthy(merged["SUPER_SPADE_USAGE_EMPTY"]),
            snapshotPath: firstKey(merged["SUPER_SPADE_USAGE_FILE"])
        )
    }
}

enum UsageStore {
    static let demoClaude = 0.42
    static let demoCodex = 0.28

    static func readings(
        credentials: UsageCredentials,
        snapshot: UsageSnapshot? = nil,
        fetch: (claude: UsageHTTP?, claudeUsed: Double?, codex: UsageHTTP?, codexUsed: Double?)? = nil,
        now: Date = Date()
    ) -> (claude: UsageReading, codex: UsageReading) {
        (
            reading(
                label: "Claude",
                key: credentials.claudeKey,
                demoFraction: demoClaude,
                snapshotUsed: snapshot?.claudeUsed,
                snapshotDate: snapshot?.updatedAt,
                forceEmpty: credentials.forceEmpty,
                forceDemo: credentials.forceDemo,
                fetchKind: fetch?.claude,
                fetchUsed: fetch?.claudeUsed,
                now: now
            ),
            reading(
                label: "Codex",
                key: credentials.codexKey,
                demoFraction: demoCodex,
                snapshotUsed: snapshot?.codexUsed,
                snapshotDate: snapshot?.updatedAt,
                forceEmpty: credentials.forceEmpty,
                forceDemo: credentials.forceDemo,
                fetchKind: fetch?.codex,
                fetchUsed: fetch?.codexUsed,
                now: now
            )
        )
    }

    static func placeholderReadings(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        now: Date = Date()
    ) -> (claude: UsageReading, codex: UsageReading) {
        readings(
            credentials: UsageKeyResolver.resolve(environment: environment),
            now: now
        )
    }

    static func loading(from reading: UsageReading) -> UsageReading {
        reading.with(source: .loading, caption: "Updating…")
    }

    private static func reading(
        label: String,
        key: String?,
        demoFraction: Double,
        snapshotUsed: Double?,
        snapshotDate: Date?,
        forceEmpty: Bool,
        forceDemo: Bool,
        fetchKind: UsageHTTP?,
        fetchUsed: Double?,
        now: Date
    ) -> UsageReading {
        if forceEmpty {
            return UsageReading(
                label: label,
                fraction: 0,
                source: .empty,
                caption: "No key",
                updatedAt: nil
            )
        }
        if forceDemo {
            return UsageReading(
                label: label,
                fraction: UsageReading.clampFraction(demoFraction),
                source: .demo,
                caption: "demo",
                updatedAt: now
            )
        }
        if let fetchKind {
            switch fetchKind {
            case .ok:
                if let fetchUsed {
                    return UsageReading(
                        label: label,
                        fraction: UsageReading.clampFraction(fetchUsed),
                        source: .live,
                        caption: "live",
                        updatedAt: now
                    )
                }
                return UsageReading(
                    label: label,
                    fraction: UsageReading.clampFraction(snapshotUsed ?? 0),
                    source: .error,
                    caption: "Couldn't refresh",
                    updatedAt: now
                )
            case .unauthorized:
                return UsageReading(
                    label: label,
                    fraction: UsageReading.clampFraction(snapshotUsed ?? 0),
                    source: .error,
                    caption: "Key cannot read usage",
                    updatedAt: now
                )
            case .unavailable:
                return UsageReading(
                    label: label,
                    fraction: UsageReading.clampFraction(snapshotUsed ?? 0),
                    source: .error,
                    caption: "Couldn't refresh",
                    updatedAt: now
                )
            }
        }
        if let snapshotUsed {
            return UsageReading(
                label: label,
                fraction: UsageReading.clampFraction(snapshotUsed),
                source: .live,
                caption: "live",
                updatedAt: snapshotDate ?? now
            )
        }
        if let key, !key.isEmpty {
            return UsageReading(
                label: label,
                fraction: 0,
                source: .loading,
                caption: "Updating…",
                updatedAt: nil
            )
        }
        return UsageReading(
            label: label,
            fraction: UsageReading.clampFraction(demoFraction),
            source: .demo,
            caption: "demo",
            updatedAt: now
        )
    }
}
