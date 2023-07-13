//
//  InstantiationType.swift
//  
//
//  Created by Andres Duque on 12/07/23.
//

import Foundation

/// Defines the moment of instantiation of an injected implementation.
public enum InstantiationType {
    
    /// The implementation will be instantiate at the creation of the property wrapper.
    case regular
    
    /// The implementation will not be instantiate until it's required for the first time.go.
    case lazy
}
