import ComposableArchitecture
import SwiftUI

@Reducer
struct Counter {
    @ObservableState
    struct State: Equatable {
        var rows: IdentifiedArrayOf<Row.State> = []
        var started = false
        var currentId: UUID? = nil
    }
    
    enum Action {
        case buttonTapped
        case response(Result<[Int], Error>)
        case rows(IdentifiedActionOf<Row>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                state.started = true
                return .run { send in
                    @Dependency(\.client) var client
                    let result = await Result { try await client.numbers() }
                    await send(.response(result))
                }
            case .response(let result):
                guard case .success(let numbers) = result, !numbers.isEmpty else { return .none }
                state.rows = .init(uniqueElements: numbers.map(Row.State.init))
                let firstId = state.rows[0].id
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
        if store.started {
            if store.rows.isEmpty {
                ProgressView()
            } else {
                List {
                    ForEach(store.scope(state: \.rows, action: \.rows)) { row in
                        RowView(store: row)
                    }
                }
                .listStyle(PlainListStyle())
            }
        } else {
            Button("Start") { store.send(.buttonTapped) }
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
