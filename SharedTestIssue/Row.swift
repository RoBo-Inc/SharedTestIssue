import ComposableArchitecture
import SwiftUI

@Reducer
struct Row {
    @ObservableState
    struct State: Identifiable, Equatable {
        @Shared(value: 0) var count
        var id: UUID
        
        init() {
            @Dependency(\.uuid) var uuid
            self.id = uuid()
        }
    }
    
    enum Action {
        case start
        case increment
        case finish
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start: return .run { send in
                @Dependency(\.continuousClock) var clock
                for _ in 1...3 {
                    try await clock.sleep(for: .seconds(1))
                    await send(.increment)
                }
                await send(.finish)
            }
            case .increment:
                state.$count.withLock { $0 += 1 }
                return .none
            case .finish:
                return .none
            }
        }
    }
}

struct RowView: View {
    let store: StoreOf<Row>
    
    var body: some View {
        Text("Count: \(store.count)")
            .font(.title)
            .padding(.top, 10)
    }
}

#Preview {
    RowView(
        store: .init(initialState: .init()) {
            Row()
        }
    )
}
