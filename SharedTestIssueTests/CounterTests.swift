import ComposableArchitecture
import Foundation
import Testing
@testable import SharedTestIssue

@MainActor
struct SharedTestIssueTests {
    @Test
    func startButtonTapped() async {
        let store = TestStore(initialState: .init()) {
            Counter()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        await store.send(.startButtonTapped) {
            $0.label = "Counting..."
        }
        await store.receive(\.increment) {
            $0.count = 1
        }
        await store.receive(\.increment) {
            $0.count = 2
        }
        await store.receive(\.increment) {
            $0.count = 3
        }
        await store.receive(\.stop) {
            $0.label = "✅"
        }
    }
}
