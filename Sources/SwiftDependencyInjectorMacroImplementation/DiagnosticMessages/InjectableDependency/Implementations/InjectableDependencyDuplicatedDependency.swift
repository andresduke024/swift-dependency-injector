//
//  InjectableDependencyDuplicatedDependency.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

struct InjectableDependencyDuplicatedDependency: InjectableDependencyDiagnosticBase, DuplicateDependencyDiagnostic {
    var typeName: String
    
    init(typeName: String) { self.typeName = typeName }
}
