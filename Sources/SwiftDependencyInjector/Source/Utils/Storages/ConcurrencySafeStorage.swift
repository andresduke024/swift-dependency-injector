//
//  ConcurrencySafeStorage.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 3/04/25.
//

struct ConcurrencySafeStorage<T: Sendable>: Sendable {
    private let container: LegacyMutex<[String: T]>
    
    var count: Int {
        container.withLock { $0.count } ?? 0
    }
    
    init(initialValues: [String: T] = [:]) {
        container = LegacyMutex(initialValues)
    }
    
    func set(key: String, _ value: T) {
        container.withLock { $0[key] = value }
    }
    
    func get(key: String) -> T? {
        container.withLock { $0[key] }
    }
    
    func removeValue(forKey key: String) {
        container.withLock { $0.removeValue(forKey: key) }
    }
    
    func removeAll() {
        container.withLock { $0.removeAll() }
    }
    
    func forEach(_ body: @Sendable ((key: String, value: T)) -> Void) {
        container.withLock { $0.forEach(body) }
    }
}
