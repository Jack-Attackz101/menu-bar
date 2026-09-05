import Combine
import Darwin
import Foundation

/// Host CPU sample via public `host_statistics`. Updates about every 2 seconds.
final class CPUMonitor: ObservableObject {
    static let shared = CPUMonitor()

    @Published private(set) var percent: Int?

    private var previous: host_cpu_load_info?
    private var timer: Timer?

    private init() {}

    func start() {
        guard timer == nil else { return }
        sample()
        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.sample()
        }
        timer.tolerance = 0.4
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func sample() {
        guard let info = Self.loadInfo() else { return }
        if let previous {
            let user = Double(info.cpu_ticks.0 &- previous.cpu_ticks.0)
            let system = Double(info.cpu_ticks.1 &- previous.cpu_ticks.1)
            let idle = Double(info.cpu_ticks.2 &- previous.cpu_ticks.2)
            let nice = Double(info.cpu_ticks.3 &- previous.cpu_ticks.3)
            let total = user + system + idle + nice
            if total > 0 {
                percent = Int(((user + system + nice) / total * 100).rounded())
            }
        }
        previous = info
    }

    private static func loadInfo() -> host_cpu_load_info? {
        var info = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride)
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, rebound, &count)
            }
        }
        return result == KERN_SUCCESS ? info : nil
    }
}
