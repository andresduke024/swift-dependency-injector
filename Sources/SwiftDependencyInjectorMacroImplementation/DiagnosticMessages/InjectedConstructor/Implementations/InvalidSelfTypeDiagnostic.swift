//
//  InvalidSelfTypeDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics

struct InvalidSelfTypeDiagnostic: InjectedConstructorDiagnosticBase {
    var id: String { "InvalidSelfType" }
    
    var message: String {
        """
        Invalid dependency. Only `Type.self` or \
        `Dependency(Type.self, ...)` are allowed.
        """
    }
}
