//
//  DependenciesInjectorDiagnosticBase.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftDiagnostics

protocol DependenciesInjectorDiagnosticBase: BaseDiagnosticMessage {}

extension DependenciesInjectorDiagnosticBase {
    var domain: String { Constants.Macros.dependenciesInjector }
}
