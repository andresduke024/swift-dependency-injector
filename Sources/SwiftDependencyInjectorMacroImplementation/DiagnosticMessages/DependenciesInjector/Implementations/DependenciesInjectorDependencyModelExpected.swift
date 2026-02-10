//
//  DependenciesInjectorDependencyModelExpected.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

struct DependenciesInjectorDependencyModelExpected: DependenciesInjectorDiagnosticBase {
    var id: String {
        "DependencieModelExpected"
    }
    
    var message: String {
        "Expected a type reference like `Dependency.self`"
    }
}
