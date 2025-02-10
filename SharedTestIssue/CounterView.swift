import ComposableArchitecture
import SwiftUI

@Reducer
struct Counter {
    @ObservableState
    struct State {
        var count = 0
        var label = "Start"
    }
    
    enum Action {
        case startButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.label = "Counting..."
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
