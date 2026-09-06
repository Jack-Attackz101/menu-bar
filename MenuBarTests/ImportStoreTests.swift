import XCTest
@testable import MenuBar

final class ImportStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: ImportStore!
    private let suite = "superSpade.tests.import.\(UUID().uuidString)"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
        store = ImportStore(defaults: defaults, key: "imported")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        super.tearDown()
    }

    func testImportAddsOnce() {
        let extra = DiscoveredExtra(id: "wifi.1", title: "Wi‑Fi", appName: "Control Center")
        XCTAssertEqual(store.importExtra(extra).count, 1)
        XCTAssertEqual(store.importExtra(extra).count, 1)
        XCTAssertTrue(store.contains(id: extra.id))
    }

    func testRemoveDropsBookmark() {
        let extra = DiscoveredExtra(id: "bart", title: "Bartender", appName: "Bartender")
        store.importExtra(extra)
        XCTAssertTrue(store.remove(id: extra.id).isEmpty)
        XCTAssertFalse(store.contains(id: extra.id))
    }

    func testLoadRoundTrip() {
        let extra = DiscoveredExtra(id: "hidden", title: "Hidden Bar", appName: "Hidden Bar")
        store.importExtra(extra)
        let reloaded = ImportStore(defaults: defaults, key: "imported").load()
        XCTAssertEqual(reloaded, [extra])
    }
}
