//
//  DependenciesInjectorDuplicatedDependency.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

struct DependenciesInjectorDuplicatedDependency: DependenciesInjectorDiagnosticBase, DuplicateDependencyDiagnostic {
    
    var typeName: String
    
    init(typeName: String) { self.typeName = typeName }
    
    var message: String { "Duplicated dependency: \(String(describing: Self.self))" }
}
