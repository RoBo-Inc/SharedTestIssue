import Dependencies
import DependenciesMacros

@DependencyClient
struct Client {
    var numbers: @Sendable () async throws -> [Int]
    
    static let liveValue: Self = .init {
        @Dependency(\.continuousClock) var clock
        try await clock.sleep(for: .seconds(1))
        return [0, 0, 0]
    }
    
    static let previewValue: Self = .init {
        [0, 0, 0]
    }
}

extension DependencyValues {
    var client: Client {
        get { self[ClientKey.self] }
        set { self[ClientKey.self] = newValue }
    }
    
    private struct ClientKey: DependencyKey {
        static let liveValue: Client = .liveValue
        static let previewValue: Client = .previewValue
        static let testValue: Client = .previewValue
    }
}
