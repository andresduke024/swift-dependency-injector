//
//  InjectableDependencyArgs.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

public struct InjectableDependencyArgs<T> {
    let dependency: T.Type
    let key: String?
    
    public init(
        _ dependency: T.Type,
        key: String? = nil
    ) {
        self.dependency = dependency
        self.key = key
    }
}
