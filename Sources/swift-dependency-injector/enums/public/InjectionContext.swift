//
//  InjectionContext.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation

/// Used to separe a set of injectable abstractions and implementations into different containers.
public enum InjectionContext {
    
    /// Used by the whole application, all dependencies will be registered into this context by default and it's accesible from every where.
    case global
    
    /// All the dependencies registered into this context will be isolated and only will be accessed when is requeried.
    /// This context can be created with a custom name (identifier) what it means that we can created every custom injection contexts as we want.
    /// This context is very useful to isolate test cases and be sure that tests don't affect each other.
    /// This context needs to know the name of the file where the subject (class) we will test is defined.
    case tests(name: String)
    
    /// All the dependencies registered into this context will be isolated and only will be accessed when is requeried.
    /// This context can be created with a custom name (identifier) what it means that we can created every custom injection contexts as we want.
    case custom(name: String)
    
    /// To identify the context itself
    public var id: String {
        switch self {
        case .global:
            return "global"
        case .tests(let name):
            return name
        case .custom(let name):
            return name
        }
    }
}
