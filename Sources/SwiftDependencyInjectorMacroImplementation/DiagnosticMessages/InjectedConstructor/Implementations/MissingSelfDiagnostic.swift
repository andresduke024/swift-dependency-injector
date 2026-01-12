//
//  MissingSelfDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics

struct MissingSelfDiagnostic: InjectedConstructorDiagnosticBase {
    
    var id: String { "MissingSelf" }
    
    var message: String {
        """
        Dependency must be declared using `Type.self`
        """
    }
}
