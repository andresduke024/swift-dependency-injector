//
//  InvalidSelfTypeDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

struct InjectedConstructorInvalidSelfTypeDiagnostic: InjectedConstructorDiagnosticBase, InvalidSelfTypeDiagnostic {
    var message: String {
        """
        Invalid dependency. Only `Type.self` or \
        `Dependency(Type.self, ...)` are allowed.
        """
    }
}
