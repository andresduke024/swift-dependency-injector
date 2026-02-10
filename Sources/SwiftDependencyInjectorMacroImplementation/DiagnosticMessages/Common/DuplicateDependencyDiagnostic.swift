//
//  DuplicateDependencyDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

protocol DuplicateDependencyDiagnostic: BaseDiagnosticMessage {
    var typeName: String { get }
}

extension DuplicateDependencyDiagnostic {
    var id: String { "DuplicateDependency" }
    
    var message: String {
        """
        Duplicate dependency `\(typeName)` declared directly. Remove the duplicate or use `Dependency(...)`.
        """
    }
}
