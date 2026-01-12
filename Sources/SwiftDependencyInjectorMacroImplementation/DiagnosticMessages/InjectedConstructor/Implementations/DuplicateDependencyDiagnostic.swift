//
//  DuplicateDependencyDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics

struct DuplicateDependencyDiagnostic: InjectedConstructorDiagnosticBase {
    let typeName: String
    
    var id: String { "DuplicateDependency" }

    var message: String {
        """
        Duplicate dependency `\(typeName)` declared directly. Remove the duplicate or use `Dependency(...)`.
        """
    }
}
