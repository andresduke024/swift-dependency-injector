//
//  InitializersContainerMapper.swift
//  
//
//  Created by Andres Duque on 12/07/23.
//

import Foundation

struct InitializersContainerMapper {
    
    /// To map a dictionary of specific implementations to a dictionary of generic implementations (InitializersContainer)
    /// - Parameter implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation
    /// - Returns: A regular InitializersContainer
    static func map<Abstraction>(_ implementations: [String: () -> Abstraction?]) -> InitializersContainer {
        implementations.mapValues { initializer in { initializer() as? AnyObject } }
    }
    
    /// To map a key and a closure to a dictionary of generic implementations (InitializersContainer)
    /// - Parameters:
    ///   - key: The key to identify the implementation
    ///   - initializer: A closure which has the job to create a new instance of the given implementation
    /// - Returns: A regular InitializersContainer
    static func map<Abstraction>(_ key: String?, _ initializer: @escaping () -> Abstraction?) -> InitializersContainer {
        let newKey = key ?? UUID().uuidString
        return [ newKey : { initializer() as? AnyObject } ]
    }
}
