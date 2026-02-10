//
//  MissingDependencyArgumentsDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

struct MissingDependencyArgumentsDiagnostic: InjectedConstructorDiagnosticBase {
    
    let macro: String
    
    var id: String { "MissingDependencyArguments" }
    
    var message: String {
        """
        @\(macro) requires at least one dependency
        """
    }
}
