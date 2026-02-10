//
//  InjectedConstructorDuplicateDependencyDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics

struct InjectedConstructorDuplicateDependencyDiagnostic: InjectedConstructorDiagnosticBase, DuplicateDependencyDiagnostic {
    let typeName: String
    
    init(typeName: String) {
        self.typeName = typeName
    }
}
