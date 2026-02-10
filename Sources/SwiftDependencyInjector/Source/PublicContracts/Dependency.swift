//
//  Dep.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

public struct Dependency<T> {
    let dependency: T.Type
    let name: String?
    let injectionType: InjectionType
    let constrainedTo: String?
    
    public init(
        _ dependency: T.Type,
        name: String? = nil,
        injectionType: InjectionType = .singleton,
        constrainedTo: String? = nil
    ) {
        self.dependency = dependency
        self.name = name
        self.injectionType = injectionType
        self.constrainedTo = constrainedTo
    }
}
