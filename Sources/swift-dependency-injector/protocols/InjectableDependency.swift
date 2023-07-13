//
//  InjectableDependency.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// Defines the structure for a class that can be used as an implementation for a given abstraction.
public protocol InjectableDependency: Initializable {
    
    /// To encasulated a way to get an instance of the given class.
    /// - Returns: A new instance of the class tha implements this protocol.
    static func instance() -> Self
}

public extension InjectableDependency {
    
    /// Default definition for the 'instance' function that use de contract of the 'Initializable' protocol to get a new instance of the given class.
    static func instance() -> Self {
        return self.init()
    }
}
