import ComposableArchitecture
import SwiftUI

@Reducer
struct Counter {
    @ObservableState
    struct State: Equatable {
        var rows: IdentifiedArrayOf<Row.State> = [.init(), .init(), .init()]
        var started = false
        var currentId: UUID? = nil
    }
    
    enum Action {
        case buttonTapped
        case rows(IdentifiedActionOf<Row>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                state.started = true
                return nextStart(&state)
            case let .rows(.element(id: id, action: action)):
                guard case .finish = action,
                      let currentIndex = state.rows.index(id: id) else { return .none }
                return nextStart(&state, currentIndex)
            }
        }
        .forEach(\.rows, action: \.rows) {
            Row()
        }
    }
    
    private func nextStart(_ state: inout State, _ currentIndex: Int? = nil) -> Effect<Action> {
        let nextIndex = currentIndex.map(state.rows.index(after:)) ?? state.rows.startIndex
        guard nextIndex < state.rows.endIndex else { return .none }
        var nextRow = state.rows[nextIndex]
        state.currentId = nextRow.id
        return nextRow.start()
    }
}

struct CounterView: View {
    let store: StoreOf<Counter>
    
    var body: some View {
        List {
            ForEach(store.scope(state: \.rows, action: \.rows)) { row in
                RowView(store: row)
            }
        }
        .listStyle(PlainListStyle())
        if !store.started {
            Button("Start") {
                store.send(.buttonTapped)
            }
            .font(.title)
            .padding()
        }
    }
}

#Preview {
    CounterView(
        store: .init(initialState: .init()) {
            Counter()
        }
    )
}
