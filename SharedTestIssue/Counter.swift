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
                guard let firstId = state.rows.first?.id else { return .none }
                state.currentId = firstId
                return .send(.rows(.element(id: firstId, action: .start)))
            case let .rows(.element(id: id, action: action)):
                guard case .finish = action,
                      let currentIndex = state.rows.index(id: id),
                      currentIndex < state.rows.index(before: state.rows.endIndex) else { return .none }
                let nextId = state.rows[state.rows.index(after: currentIndex)].id
                state.currentId = nextId
                return .send(.rows(.element(id: nextId, action: .start)))
            }
        }
        .forEach(\.rows, action: \.rows) {
            Row()
        }
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
