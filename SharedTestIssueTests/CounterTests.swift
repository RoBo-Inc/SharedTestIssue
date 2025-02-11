import ComposableArchitecture
import Foundation
import Testing
@testable import SharedTestIssue

@MainActor
struct SharedTestIssueTests {
    @Test
    func startButtonTapped() async {
        let clock = TestClock()
        let store = TestStore(initialState: .init()) {
            Counter()
        } withDependencies: {
            $0.continuousClock = clock
        }
        await store.send(.startButtonTapped) {
            $0.label = "Counting..."
        }
        await clock.run()
        await store.receive(\.increment) {
            $0.$count.withLock { $0 = 3 }
        }
        await store.receive(\.increment)
        await store.receive(\.increment)
        await store.receive(\.stop) {
            $0.label = "✅"
        }
    }
}
