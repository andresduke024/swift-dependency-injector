//
//  InjectableDependencyDiagnosticBase.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftDiagnostics

protocol InjectableDependencyDiagnosticBase: BaseDiagnosticMessage {}

extension InjectableDependencyDiagnosticBase {
    var domain: String { Constants.Macros.injectableDependency }
}
