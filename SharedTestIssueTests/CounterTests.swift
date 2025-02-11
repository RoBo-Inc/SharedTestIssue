import ComposableArchitecture
import Foundation
import Testing
@testable import SharedTestIssue

@MainActor
struct SharedTestIssueTests {
    @Test
    func startButtonTapped() async {
        let clock = TestClock()
        let rows: IdentifiedArrayOf<Row.State> = withDependencies {
            $0.uuid = .incrementing
        } operation: { .init(uniqueElements: [.init(), .init(), .init()]) }
        let store = TestStore(initialState: .init()) {
            Counter()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.continuousClock = clock
        }
        
        await store.send(.buttonTapped)
        await store.receive(\.responsePictures) {
            $0.pictureRows = rows
            $0.started = true
            $0.cascadeLoadingId = .init(0)
        }
        
        await clock.run()
        await store.receive(\.pictureRows[id: .init(0)].downloadComponent.download.updateProgress) {
            $0.pictureRows[id: .init(0)]?.$downloadComponent.withLock { $0.status = .complete(.init()) }
        }
        await store.receive(\.pictureRows[id: .init(0)].downloadComponent.download.complete) {
            $0.cascadeLoadingId = .init(1)
        }
    }
}
