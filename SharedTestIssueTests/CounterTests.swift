import ComposableArchitecture
import Testing
@testable import SharedTestIssue

@MainActor
struct SharedTestIssueTests {
    @Test
    func startButtonTapped() async {
        let rows: IdentifiedArrayOf<Row.State> = withDependencies {
            $0.uuid = .incrementing
        } operation: {
            .init(uniqueElements: [0, 0, 0].map(Row.State.init))
        }
        let clock = TestClock()
        let store = TestStore(initialState: .init()) {
            Counter()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.continuousClock = clock
        }
        await store.send(.buttonTapped) {
            $0.started = true
        }
        await store.receive(\.response) {
            $0.rows = rows
            $0.currentId = .init(0)
        }
        await clock.run()
        await store.receive(\.rows[id: .init(0)].start) {
            $0.rows[id: .init(0)]?.$count.withLock { $0 = 3 }
            $0.rows[id: .init(1)]?.$count.withLock { $0 = 3 }
            $0.rows[id: .init(2)]?.$count.withLock { $0 = 3 }
        }
        await store.receive(\.rows[id: .init(0)].increment)
        await store.receive(\.rows[id: .init(0)].increment)
        await store.receive(\.rows[id: .init(0)].increment)
        await store.receive(\.rows[id: .init(0)].finish) {
            $0.currentId = .init(1)
        }
        await store.receive(\.rows[id: .init(1)].start)
        await store.receive(\.rows[id: .init(1)].increment)
        await store.receive(\.rows[id: .init(1)].increment)
        await store.receive(\.rows[id: .init(1)].increment)
        await store.receive(\.rows[id: .init(1)].finish) {
            $0.currentId = .init(2)
        }
        await store.receive(\.rows[id: .init(2)].start)
        await store.receive(\.rows[id: .init(2)].increment)
        await store.receive(\.rows[id: .init(2)].increment)
        await store.receive(\.rows[id: .init(2)].increment)
        await store.receive(\.rows[id: .init(2)].finish)
    }
}
