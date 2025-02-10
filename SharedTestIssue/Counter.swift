import ComposableArchitecture
import SwiftUI

@Reducer
struct Counter {
    @ObservableState
    struct State: Equatable {
        @Shared(value: 0) var count
        var label = "Start"
    }
    
    enum Action {
        case startButtonTapped
        case increment
        case stop
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.label = "Counting..."
                return .run { send in
                    @Dependency(\.continuousClock) var clock
                    for _ in 1...3 {
                        try await clock.sleep(for: .seconds(1))
                        await send(.increment)
                    }
                    await send(.stop)
                }
            case .increment:
                state.$count.withLock { $0 += 1 }
                return .none
            case .stop:
                state.label = "✅"
                return .none
            }
        }
    }
}

struct CounterView: View {
    let store: StoreOf<Counter>
    
    var body: some View {
        VStack {
            Text("Count: \(store.count)")
                .font(.title)
                .padding(.top, 10)
            
            Button(store.label) {
                store.send(.startButtonTapped)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
    }
}

#Preview {
    CounterView(
        store: .init(initialState: .init()) {
            Counter()
        }
    )
}
