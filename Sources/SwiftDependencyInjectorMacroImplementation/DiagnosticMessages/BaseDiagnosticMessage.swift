//
//  BaseDiagnosticMessage.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics

protocol BaseDiagnosticMessage: DiagnosticMessage, Error {
    var id: String { get }
    
    var domain: String { get }
}

extension BaseDiagnosticMessage {
    var severity: DiagnosticSeverity { .error }
    
    var diagnosticID: MessageID {
        MessageID(domain: domain, id: id)
    }
}
