//
//  DependenciesInjectorInvalidSelfTypeDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

struct DependenciesInjectorInvalidSelfTypeDiagnostic: DependenciesInjectorDiagnosticBase, InvalidSelfTypeDiagnostic {
    var message: String {
        "Dependencies must be specified as `Type.self`"
    }
}
