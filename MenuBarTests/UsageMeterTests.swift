import XCTest
@testable import MenuBar

final class UsageMeterTests: XCTestCase {
    func testLabelsAreClaudeAndCodexNotCPU() {
        let pair = UsageStore.readings(claudeKey: nil, codexKey: nil)
        XCTAssertEqual(pair.claude.label, "Claude")
        XCTAssertEqual(pair.codex.label, "Codex")
        XCTAssertEqual(pair.claude.source, .missingKey)
        XCTAssertEqual(pair.codex.source, .missingKey)
        XCTAssertEqual(pair.claude.fraction, 0)
    }

    func testKeyPresentStaysLabeledStub() {
        let pair = UsageStore.readings(claudeKey: "sk-ant-test", codexKey: "sk-test")
        XCTAssertEqual(pair.claude.source, .stub)
        XCTAssertEqual(pair.codex.source, .stub)
        XCTAssertTrue(pair.claude.caption.contains("usage API"))
        XCTAssertGreaterThan(pair.claude.fraction, 0)
    }

    func testClampFraction() {
        XCTAssertEqual(UsageReading.clampFraction(-1), 0)
        XCTAssertEqual(UsageReading.clampFraction(0.4), 0.4)
        XCTAssertEqual(UsageReading.clampFraction(2), 1)
    }

    func testEnvironmentPrefersNonEmptyKeys() {
        let defaults = UserDefaults(suiteName: "superSpade.tests.usage.\(UUID().uuidString)")!
        let pair = UsageStore.readingsFromEnvironment(
            environment: ["ANTHROPIC_API_KEY": "  ", "OPENAI_API_KEY": "ok"],
            defaults: defaults
        )
        XCTAssertEqual(pair.claude.source, .missingKey)
        XCTAssertEqual(pair.codex.source, .stub)
    }
}
