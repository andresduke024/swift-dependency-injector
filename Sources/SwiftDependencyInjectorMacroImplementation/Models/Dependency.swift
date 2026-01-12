//
//  Dependency.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

struct Dependency {
    let typeName: String
    let variableName: String
    let injectionType: String
    let constrainedTo: String?
    let source: DependencySource
}
