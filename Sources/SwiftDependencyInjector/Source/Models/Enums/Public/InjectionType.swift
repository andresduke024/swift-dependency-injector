//
//  InjectionType.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// Defines how all the implementations that will be injected are going to be created and returned.
public enum InjectionType: Sendable {

    /// Every injection will create a new instance of the given implementation when this case is selected.
    case regular

    ///  Every injection will get an already stored instance of the given implementation when this case is selected.
    ///  When is the first injection, will create, store and return a new instance of the given implementation.
    case singleton
}
