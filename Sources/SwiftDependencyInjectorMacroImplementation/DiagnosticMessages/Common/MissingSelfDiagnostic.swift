//
//  MissingSelfDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

protocol MissingSelfDiagnostic: BaseDiagnosticMessage {}

extension MissingSelfDiagnostic {
    var id: String { "MissingSelf" }
    
    var message: String {
        """
        Dependency must be declared using `Type.self`
        """
    }
}
