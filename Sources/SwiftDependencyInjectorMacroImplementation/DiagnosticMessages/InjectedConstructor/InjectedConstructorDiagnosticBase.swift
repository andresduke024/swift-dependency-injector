//
//  InjectedConstructorDiagnosticBase.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics

protocol InjectedConstructorDiagnosticBase: BaseDiagnosticMessage {}

extension InjectedConstructorDiagnosticBase {
    var domain: String { Constants.Macros.injectedConstructor }
}
