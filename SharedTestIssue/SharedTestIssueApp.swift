import SwiftUI

@main
struct SharedTestIssueApp: App {
    var body: some Scene {
        WindowGroup {
            CounterView(
                store: .init(initialState: .init()) {
                    Counter()
                }
            )
        }
    }
}
