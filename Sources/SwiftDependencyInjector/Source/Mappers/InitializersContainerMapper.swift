//
//  InitializersContainerMapper.swift
//  
//
//  Created by Andres Duque on 12/07/23.
//

import Foundation

/// To map specific initialization blocks as generic initializations blocks based on a given abstraction.
struct InitializersContainerMapper {

    /// To map a dictionary of specific implementations to a dictionary of generic implementations (InitializersContainer).
    /// - Parameter implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation.
    /// - Returns: A regular InitializersContainer.
    static func map<Abstraction: Sendable>(
        _ implementations: [String: @Sendable () -> Abstraction?]
    ) -> InitializersContainer {
        let newContainer = InitializersContainer()
        
        for (key, value) in implementations {
            newContainer.set(key: key, value)
        }
        
        return newContainer
    }

    /// To map a key and a closure to a dictionary of generic implementations (InitializersContainer).
    /// - Parameters:
    ///   - key: The key to identify the implementation.
    ///   - initializer: A closure which has the job to create a new instance of the given implementation.
    /// - Returns: A regular InitializersContainer.
    static func map<Abstraction: Sendable>(
        _ key: String?,
        _ initializer: @Sendable @escaping () -> Abstraction?
    ) -> InitializersContainer {
        let newKey = key ?? UUID().uuidString
        let newContainer = InitializersContainer()
        
        newContainer.set(key: newKey, initializer)
        return newContainer
    }
}
