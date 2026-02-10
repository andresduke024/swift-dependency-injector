//
//  InitParameterNameConflictDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics

struct InitParameterNameConflictDiagnostic: InjectedConstructorDiagnosticBase {
    private let name: String
    
    init(name: String) {
        self.name = name
    }
    
    var id: String { "InitParameterNameConflict" }
    
    var message: String {
        """
        InitParameter '\(name)' conflicts \
        with injected dependency name.
        """
    }
}
