//
//  Constants.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax

struct Constants {
    struct Macros {
        static let injectedConstructor: String = "InjectedConstructor"
        static let injectableDependency: String = "InjectableDependency"
        static let dependenciesInjector: String = "DependenciesInjector"
    }
    
    struct Trivia {
        static let defaultSpaces = SwiftSyntax.Trivia.spaces(4)
    }
    
    struct SintaxKeys {
        
        static let selfSintax = "self"
        
        static let protocolSintax = "Protocol"
        
        static let dependencyClass = "Dependency"
        
        static let injectionTypeProperty = "injectionType"
        
        static let regularInjectionTypePropertyValue = ".regular"
        
        static let constrainedToProperty = "constrainedTo"
        
        static let injectorClass = "Injector"
        
        static let injectorGlobalProperty = "global"
        
        static let injectorAddOrRegisterMethod = "addOrRegister"
        
        static let getMethod = "get"
        
        static let nameProperty = "name"
        
        static let initParameterClass = "InitParameter"
        
        static let observationIgnoredMacro = "ObservationIgnored"
        
        static let dependenciesInjectorProtocol = "DependenciesInjectorProtocol"
        
        static let injectableDependencyProtocol = "InjectableDependencyProtocol"
        
        static let injectableDependencyArgsModelName = "InjectableDependencyArgs"
    }
}
