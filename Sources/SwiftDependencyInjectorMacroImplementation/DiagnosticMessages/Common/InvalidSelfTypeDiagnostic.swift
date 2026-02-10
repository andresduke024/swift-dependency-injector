//
//  InvalidSelfTypeDiagnostic.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

protocol InvalidSelfTypeDiagnostic: BaseDiagnosticMessage {}

extension InvalidSelfTypeDiagnostic {
    var id: String { "InvalidSelfType" }
}
