//
//  DesignedInitializerDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax

struct DesignedInitializerDiagnostic: InjectedConstructorDiagnosticBase {
    var id: String { "InitializerExists" }
    
    var message: String {
        """
        @InjectedConstructor cannot be applied because \
        the type already defines a designed initializer.
        """
    }
}
