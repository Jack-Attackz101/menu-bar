import XCTest
@testable import MenuBar

final class UsageMeterTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_783_737_600) // 2026-09-07 12:00:00 UTC

    func testLabelsAreClaudeAndCodexNotCPU() {
        let pair = UsageStore.readings(credentials: .empty, now: now)
        XCTAssertEqual(pair.claude.label, "Claude")
        XCTAssertEqual(pair.codex.label, "Codex")
        XCTAssertEqual(pair.claude.source, .demo)
        XCTAssertEqual(pair.codex.source, .demo)
        XCTAssertGreaterThan(pair.claude.fraction, 0)
        XCTAssertTrue(pair.claude.caption.lowercased().contains("demo"))
    }

    func testForceEmptyIsDesignedZero() {
        let pair = UsageStore.readings(credentials: UsageCredentials(forceEmpty: true), now: now)
        XCTAssertEqual(pair.claude.source, .empty)
        XCTAssertEqual(pair.codex.source, .empty)
        XCTAssertEqual(pair.claude.fraction, 0)
        XCTAssertEqual(pair.claude.caption, "No key")
    }

    func testKeyPresentWithoutFetchIsLoading() {
        let creds = UsageCredentials(claudeKey: "sk-ant-test", codexKey: "sk-test")
        let pair = UsageStore.readings(credentials: creds, now: now)
        XCTAssertEqual(pair.claude.source, .loading)
        XCTAssertEqual(pair.codex.source, .loading)
        XCTAssertTrue(pair.claude.caption.contains("Updating"))
    }

    func testSnapshotFileIsLiveUsage() {
        let snap = UsageSnapshot(claudeUsed: 0.61, codexUsed: 0.17, updatedAt: now)
        let pair = UsageStore.readings(credentials: .empty, snapshot: snap, now: now)
        XCTAssertEqual(pair.claude.source, .live)
        XCTAssertEqual(pair.codex.source, .live)
        XCTAssertEqual(pair.claude.fraction, 0.61)
        XCTAssertEqual(pair.codex.fraction, 0.17)
        XCTAssertEqual(pair.claude.caption, "live")
    }

    func testSuccessfulFetchIsLive() {
        let creds = UsageCredentials(claudeKey: "sk-ant", codexKey: "sk")
        let pair = UsageStore.readings(
            credentials: creds,
            fetch: (claude: .ok, claudeUsed: 0.33, codex: .ok, codexUsed: 0.8),
            now: now
        )
        XCTAssertEqual(pair.claude.source, .live)
        XCTAssertEqual(pair.codex.source, .live)
        XCTAssertEqual(pair.claude.fraction, 0.33)
        XCTAssertEqual(pair.codex.fraction, 0.8)
    }

    func testUnauthorizedFetchIsError() {
        let creds = UsageCredentials(claudeKey: "sk-ant", codexKey: "sk")
        let pair = UsageStore.readings(
            credentials: creds,
            fetch: (claude: .unauthorized, claudeUsed: nil, codex: .unauthorized, codexUsed: nil),
            now: now
        )
        XCTAssertEqual(pair.claude.source, .error)
        XCTAssertTrue(pair.claude.caption.contains("cannot read usage"))
    }

    func testUnavailableFetchIsError() {
        let creds = UsageCredentials(claudeKey: "sk-ant")
        let pair = UsageStore.readings(
            credentials: creds,
            fetch: (claude: .unavailable, claudeUsed: nil, codex: nil, codexUsed: nil),
            now: now
        )
        XCTAssertEqual(pair.claude.source, .error)
        XCTAssertTrue(pair.claude.caption.contains("Couldn't refresh"))
        XCTAssertEqual(pair.codex.source, .demo)
    }

    func testClampFraction() {
        XCTAssertEqual(UsageReading.clampFraction(-1), 0)
        XCTAssertEqual(UsageReading.clampFraction(0.4), 0.4)
        XCTAssertEqual(UsageReading.clampFraction(2), 1)
    }

    func testUsageLineReadsAsUsedAndRemaining() {
        XCTAssertEqual(UsageDisplay.percentUsed(0.42), "42%")
        XCTAssertEqual(UsageDisplay.remainingLabel(0.42), "58% left")
        XCTAssertEqual(UsageDisplay.usageLine(used: 0.42), "42% used · 58% left")
        XCTAssertEqual(UsageDisplay.usageLine(used: 0), "0% used · 100% left")
        XCTAssertEqual(UsageDisplay.usageLine(used: 1), "100% used · 0% left")
    }

    func testLastUpdatedFormats() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        XCTAssertEqual(UsageDisplay.lastUpdated(nil, now: now, calendar: calendar), "")
        XCTAssertEqual(UsageDisplay.lastUpdated(now.addingTimeInterval(-4), now: now, calendar: calendar), "Just now")
        let earlier = now.addingTimeInterval(-3600)
        let sameDay = UsageDisplay.lastUpdated(earlier, now: now, calendar: calendar)
        XCTAssertTrue(sameDay.hasPrefix("Updated "))
        XCTAssertTrue(sameDay.contains("AM") || sameDay.contains("PM"))
    }

    func testEnvironmentPrefersNonEmptyKeys() {
        let creds = UsageKeyResolver.resolve(
            environment: ["ANTHROPIC_API_KEY": "  ", "OPENAI_API_KEY": "ok"]
        )
        XCTAssertNil(creds.claudeKey)
        XCTAssertEqual(creds.codexKey, "ok")
    }

    func testEnvFileMergesUnderProcessEnvironment() {
        let file = UsageKeyResolver.parseEnvFile("""
        # comment
        ANTHROPIC_API_KEY=from-file
        OPENAI_API_KEY=file-codex
        SUPER_SPADE_USAGE_DEMO=0
        """)
        XCTAssertEqual(file["ANTHROPIC_API_KEY"], "from-file")
        let creds = UsageKeyResolver.resolve(
            environment: ["ANTHROPIC_API_KEY": "from-env"],
            fileMap: file
        )
        XCTAssertEqual(creds.claudeKey, "from-env")
        XCTAssertEqual(creds.codexKey, "file-codex")
    }

    func testTruthyDemoAndEmptyFlags() {
        let demo = UsageKeyResolver.resolve(environment: ["SUPER_SPADE_USAGE_DEMO": "true"])
        XCTAssertTrue(demo.forceDemo)
        let empty = UsageKeyResolver.resolve(environment: ["SUPER_SPADE_USAGE_EMPTY": "1"])
        XCTAssertTrue(empty.forceEmpty)
    }

    func testSnapshotJSONParse() {
        let data = Data("""
        {"claude":{"used":0.55},"codexUsed":0.1,"updatedAt":"2026-09-07T12:00:00Z"}
        """.utf8)
        let snap = UsageSnapshot.parse(data: data)
        XCTAssertEqual(snap?.claudeUsed, 0.55)
        XCTAssertEqual(snap?.codexUsed, 0.1)
        XCTAssertNotNil(snap?.updatedAt)
    }

    func testHTTPClassifyAndUsedFraction() {
        XCTAssertEqual(UsageHTTP.classifyStatus(200), .ok)
        XCTAssertEqual(UsageHTTP.classifyStatus(401), .unauthorized)
        XCTAssertEqual(UsageHTTP.classifyStatus(403), .unauthorized)
        XCTAssertEqual(UsageHTTP.classifyStatus(500), .unavailable)
        let data = Data(#"{"usage":{"used_percent":37}}"#.utf8)
        XCTAssertEqual(UsageHTTP.usedFraction(fromJSON: data), 0.37)
    }

    func testFirstKeyUnwrapThenTrim() {
        XCTAssertEqual(UsageKeyResolver.firstKey("  sk-ant  ", "other"), "sk-ant")
        XCTAssertNil(UsageKeyResolver.firstKey(nil, "  ", ""))
    }
}

final class UsageServiceTests: XCTestCase {
    func testRefreshWithoutKeysUsesDemo() async {
        let pair = await UsageService.refresh(
            environment: [:],
            homeDirectory: URL(fileURLWithPath: "/tmp/super-spade-missing"),
            now: Date(timeIntervalSince1970: 1_783_737_600),
            transport: FailingTransport()
        )
        XCTAssertEqual(pair.claude.source, .demo)
        XCTAssertEqual(pair.codex.source, .demo)
        XCTAssertEqual(pair.claude.label, "Claude")
    }

    func testRefreshWithKeysAndUnauthorizedTransportIsError() async {
        let pair = await UsageService.refresh(
            environment: ["ANTHROPIC_API_KEY": "sk-ant", "OPENAI_API_KEY": "sk"],
            homeDirectory: URL(fileURLWithPath: "/tmp/super-spade-missing"),
            now: Date(timeIntervalSince1970: 1_783_737_600),
            transport: StatusTransport(code: 401)
        )
        XCTAssertEqual(pair.claude.source, .error)
        XCTAssertEqual(pair.codex.source, .error)
    }
}

private struct FailingTransport: UsageTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.notConnectedToInternet)
    }
}

private struct StatusTransport: UsageTransport {
    var code: Int
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let url = request.url ?? URL(string: "https://example.invalid")!
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
        return (Data("{}".utf8), response)
    }
}
