//
//  ObjectTypeDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftDiagnostics

struct ObjectTypeDiagnostic: InjectedConstructorDiagnosticBase {
    
    let macro: String
    
    var id: String { "ObjectType" }
    
    var message: String {
        """
        @\(macro) can only be applied to a struct, class, or actor
        """
    }
}
