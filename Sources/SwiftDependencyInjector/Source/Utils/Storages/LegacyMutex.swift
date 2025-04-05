//
//  LegacyMutex.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 3/04/25.
//

import Foundation

final class LegacyMutex<Wrapped>: @unchecked Sendable {
    private var mutex = pthread_mutex_t()
    private var wrapped: Wrapped
    
    init(_ initialValue: Wrapped) {
        pthread_mutex_init(&mutex, nil)
        self.wrapped = initialValue
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    @discardableResult
    func withLock<T>(_ body: @Sendable (inout Wrapped) throws -> T?) rethrows -> T? {
        pthread_mutex_lock(&mutex)
        
        defer { pthread_mutex_unlock(&mutex) }
        
        return try body(&wrapped)
    }
}
