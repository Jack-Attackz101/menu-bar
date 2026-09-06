import Combine
import Foundation
import IOKit.pwr_mgt
import os

/// Process-owned idle-sleep assertion. Closing the bubble must not drop it.
@MainActor
final class KeepAwakeController: ObservableObject {
    static let shared = KeepAwakeController()

    @Published private(set) var isEnabled = false

    private var displayAssertion: IOPMAssertionID = 0
    private var idleAssertion: IOPMAssertionID = 0
    private var caffeinateProcess: Process?
    private let log = Logger(subsystem: "com.jack-attackz101.menu-bar", category: "keep-awake")

    private init() {}

    func toggle() {
        if isEnabled {
            stop()
        } else {
            start()
        }
    }

    func start() {
        if isEnabled { return }

        let reason = KeepAwakeIdentity.assertionName as CFString
        displayAssertion = createAssertion(
            type: kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            name: reason
        )
        idleAssertion = createAssertion(
            type: kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            name: reason
        )

        let ioKitHeld = displayAssertion != 0 || idleAssertion != 0
        if !ioKitHeld {
            startCaffeinateFallback()
        }

        let running = ioKitHeld || (caffeinateProcess?.isRunning == true)
        isEnabled = running
        if running {
            ProcessInfo.processInfo.disableAutomaticTermination("keep-awake")
            log.info("keep-awake on")
        } else {
            log.error("keep-awake failed to start")
        }
    }

    func stop() {
        if displayAssertion != 0 {
            IOPMAssertionRelease(displayAssertion)
            displayAssertion = 0
        }
        if idleAssertion != 0 {
            IOPMAssertionRelease(idleAssertion)
            idleAssertion = 0
        }
        if let process = caffeinateProcess {
            process.terminate()
            caffeinateProcess = nil
        }
        if isEnabled {
            ProcessInfo.processInfo.enableAutomaticTermination("keep-awake")
        }
        isEnabled = false
        log.info("keep-awake off")
    }

    private func createAssertion(type: CFString, name: CFString) -> IOPMAssertionID {
        var assertionID: IOPMAssertionID = 0
        let status = IOPMAssertionCreateWithName(
            type,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            name,
            &assertionID
        )
        if status == kIOReturnSuccess {
            return assertionID
        }
        log.error("IOPMAssertionCreateWithName failed: \(status, privacy: .public)")
        return 0
    }

    private func startCaffeinateFallback() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-dims"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            process.terminationHandler = { [weak self] _ in
                Task { @MainActor in
                    guard let self, self.caffeinateProcess != nil else { return }
                    self.caffeinateProcess = nil
                    if self.displayAssertion == 0, self.idleAssertion == 0 {
                        self.isEnabled = false
                    }
                }
            }
            try process.run()
            caffeinateProcess = process
        } catch {
            log.error("caffeinate fallback failed: \(error.localizedDescription, privacy: .public)")
            caffeinateProcess = nil
        }
    }
}
